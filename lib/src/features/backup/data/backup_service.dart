import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/db/database.dart';
import '../../../core/time/clock.dart';
import '../domain/backup_envelope.dart';

/// Cách nhập dữ liệu.
enum ImportMode {
  /// Xoá sạch rồi chèn lại — kịch bản đổi điện thoại của đặc tả.
  replace,

  /// Giữ dữ liệu hiện có, chỉ thêm phần chưa có.
  merge,
}

class ImportResult {
  const ImportResult({
    required this.mode,
    required this.inserted,
    required this.safetyBackup,
  });

  final ImportMode mode;
  final Map<String, int> inserted;
  final File? safetyBackup;

  int get totalRows => inserted.values.fold(0, (a, b) => a + b);
}

/// Xuất và nhập toàn bộ dữ liệu (mục 9 đặc tả — chức năng bắt buộc).
class BackupService {
  BackupService(this._db, this._clock, {this.appVersion = '1.0.0'});

  final AppDatabase _db;
  final Clock _clock;
  final String appVersion;

  /// Thứ tự này là thứ tự phụ thuộc khoá ngoại. Nhập theo đúng thứ tự, xoá
  /// theo thứ tự ngược lại.
  static const List<String> tableOrder = [
    'app_settings',
    'lots',
    'recurring_cost_templates',
    'vehicles',
    'payments',
    'payment_allocations',
    'expenses',
    'activity_log',
  ];

  // ───────────────────────────── XUẤT ─────────────────────────────

  Future<BackupEnvelope> buildEnvelope() async {
    final data = <String, List<Map<String, Object?>>>{};
    for (final name in tableOrder) {
      final rows = await _db.customSelect('SELECT * FROM $name').get();
      data[name] = [
        for (final r in rows)
          {for (final e in r.data.entries) e.key: _toJsonValue(e.value)},
      ];
    }
    return BackupEnvelope(
      formatVersion: BackupEnvelope.currentFormatVersion,
      schemaVersion: _db.schemaVersion,
      appVersion: appVersion,
      exportedAt: _clock.now(),
      counts: {for (final e in data.entries) e.key: e.value.length},
      data: data,
    );
  }

  /// JSON dễ đọc bằng mắt (mục 9 đặc tả).
  Future<File> exportJson({Directory? dir}) async {
    final env = await buildEnvelope();
    final file = File(
        '${(dir ?? await getApplicationDocumentsDirectory()).path}/${_fileName('json')}');
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(env.toJson()));
    return file;
  }

  /// File sao lưu riêng của ứng dụng: cùng JSON đó, nén gzip.
  Future<File> exportBackup({Directory? dir}) async {
    final env = await buildEnvelope();
    final bytes = gzip.encode(utf8.encode(jsonEncode(env.toJson())));
    final file = File(
        '${(dir ?? await getApplicationDocumentsDirectory()).path}/${_fileName('qlbx')}');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Tên file chỉ dùng ASCII để sống sót qua Zalo, email và AirDrop.
  String _fileName(String ext) {
    final t = _clock.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return 'SaoLuu_QuanLyBaiXe_'
        '${t.year}${p(t.month)}${p(t.day)}_${p(t.hour)}${p(t.minute)}.$ext';
  }

  // ───────────────────────────── ĐỌC ─────────────────────────────

  /// Đọc file mà KHÔNG ghi gì — để hiện màn hình xem trước trước khi người
  /// dùng đồng ý ghi đè.
  Future<BackupEnvelope> inspect(File file) async {
    final bytes = await file.readAsBytes();
    // Nhận biết gzip qua hai byte đầu, nhờ vậy file .json thường cũng nhập
    // được — miễn phí tương thích với bản xuất JSON.
    final isGzip = bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    final text = utf8.decode(isGzip ? gzip.decode(bytes) : bytes);
    final json = jsonDecode(text);
    if (json is! Map<String, Object?>) {
      throw const BackupFormatException('File sao lưu không hợp lệ.');
    }
    return BackupEnvelope.fromJson(json);
  }

  // ───────────────────────────── NHẬP ─────────────────────────────

  /// Khôi phục dữ liệu.
  ///
  /// Toàn bộ nằm trong **một** transaction: hỏng ở bất kỳ bảng nào thì hoàn
  /// nguyên sạch, không để lại trạng thái nửa vời. Trước khi ghi đè còn tự tạo
  /// một bản sao lưu an toàn — một cú bấm nhầm không được phép mất hết dữ liệu.
  Future<ImportResult> import(
    BackupEnvelope env, {
    ImportMode mode = ImportMode.replace,
    bool safetyBackup = true,
    Directory? dir,
  }) async {
    File? safety;
    if (safetyBackup && mode == ImportMode.replace) {
      safety = await exportBackup(dir: dir);
    }

    final inserted = <String, int>{};

    // PRAGMA không có tác dụng bên trong transaction nên phải đặt ngoài.
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _db.transaction(() async {
        if (mode == ImportMode.replace) {
          for (final name in tableOrder.reversed) {
            await _db.customStatement('DELETE FROM $name');
          }
        }
        for (final name in tableOrder) {
          final rows = env.data[name] ?? const [];
          var n = 0;
          for (final row in rows) {
            final cols = row.keys.toList();
            final marks = List.filled(cols.length, '?').join(', ');
            // INSERT OR IGNORE cho chế độ gộp: dòng đã có thì bỏ qua thay vì
            // đè lên dữ liệu người dùng đang dùng.
            final verb =
                mode == ImportMode.merge ? 'INSERT OR IGNORE' : 'INSERT';
            await _db.customStatement(
              '$verb INTO $name (${cols.join(', ')}) VALUES ($marks)',
              [for (final c in cols) row[c]],
            );
            n++;
          }
          inserted[name] = n;
        }
      });
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }

    return ImportResult(mode: mode, inserted: inserted, safetyBackup: safety);
  }

  /// Chỉ giữ lại [keep] bản sao lưu an toàn gần nhất.
  Future<void> pruneSafetyBackups({Directory? dir, int keep = 3}) async {
    final d = dir ?? await getApplicationDocumentsDirectory();
    final files = d
        .listSync()
        .whereType<File>()
        .where((f) => f.path.split('/').last.startsWith('SaoLuu_QuanLyBaiXe_'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in files.skip(keep)) {
      await f.delete();
    }
  }

  static Object? _toJsonValue(Object? v) {
    if (v is DateTime) return v.millisecondsSinceEpoch;
    if (v is Uint8List) return base64Encode(v);
    return v;
  }
}
