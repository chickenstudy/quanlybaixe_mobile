import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/backup/data/backup_service.dart';
import 'package:quan_ly_bai_xe/src/features/backup/domain/backup_envelope.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;
  late Directory tmp;
  final clock = FixedClock(DateTime(2026, 9, 7, 10, 30));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backup = BackupService(db, clock);
    tmp = await Directory.systemTemp.createTemp('qlbx_test');
  });

  tearDown(() async {
    await db.close();
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  /// Dựng một bộ dữ liệu chạm tới mọi bảng.
  Future<void> seed() async {
    final lotId = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi Nguyễn Trãi',
          nameFold: 'bai nguyen trai',
          address: const Value('145 Nguyễn Trãi'),
          capacity: const Value(50),
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));
    await db.into(db.recurringCostTemplates).insert(
          RecurringCostTemplatesCompanion.insert(
            lotId: lotId,
            name: 'Tiền điện',
            category: CostCategory.electricity,
            amount: 850000,
            startMonth: '2026-08',
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    final vId = await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'Nguyễn Văn An',
          ownerNameFold: 'nguyen van an',
          phone: const Value('0912 345 678'),
          phoneDigits: const Value('0912345678'),
          vehicleType: VehicleType.motorbike,
          plate: '59A1-234.56',
          plateNormalized: '59A123456',
          monthlyPrice: 150000,
          startDate: const Day(2026, 8, 1),
          anchorDay: 1,
          notes: const Value('Khách quen, ghi chú có dấu tiếng Việt'),
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));
    await PaymentRepository(db, clock)
        .recordPayment(vehicleId: vId, months: 3, paidAt: const Day(2026, 8, 1));
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
          lotId: lotId,
          name: 'Sửa cửa cuốn',
          category: CostCategory.repair,
          kind: ExpenseKind.adhoc,
          amount: 1800000,
          incurredOn: const Day(2026, 8, 20),
          periodMonth: '2026-08',
          createdAt: DateTime.utc(2026, 8, 20),
          updatedAt: DateTime.utc(2026, 8, 20),
        ));
    await db.into(db.appSettings).insertOnConflictUpdate(
        const AppSettingRow(key: 'revenue_mode', value: 'accrual'));
  }

  Future<Map<String, List<Map<String, Object?>>>> dump() async {
    final out = <String, List<Map<String, Object?>>>{};
    for (final t in BackupService.tableOrder) {
      final rows = await db.customSelect('SELECT * FROM $t ORDER BY rowid').get();
      out[t] = [for (final r in rows) Map<String, Object?>.from(r.data)];
    }
    return out;
  }

  test('KHỨ HỒI: xuất → xoá sạch → nhập lại, mọi bảng khớp TỪNG DÒNG', () async {
    await seed();
    final before = await dump();
    final env = await backup.buildEnvelope();

    // Xoá sạch, mô phỏng máy mới.
    await db.customStatement('PRAGMA foreign_keys = OFF');
    for (final t in BackupService.tableOrder.reversed) {
      await db.customStatement('DELETE FROM $t');
    }
    await db.customStatement('PRAGMA foreign_keys = ON');
    expect((await dump())['lots'], isEmpty);

    await backup.import(env, safetyBackup: false, dir: tmp);

    final after = await dump();
    for (final t in BackupService.tableOrder) {
      expect(after[t], equals(before[t]), reason: 'bảng $t không khớp');
    }
  });

  test('khứ hồi qua FILE .qlbx thật, có nén gzip', () async {
    await seed();
    final before = await dump();

    final file = await backup.exportBackup(dir: tmp);
    expect(file.existsSync(), isTrue);
    expect(file.path, endsWith('.qlbx'));
    final bytes = await file.readAsBytes();
    expect(bytes[0], 0x1f, reason: 'phải là gzip');
    expect(bytes[1], 0x8b);

    await db.customStatement('PRAGMA foreign_keys = OFF');
    for (final t in BackupService.tableOrder.reversed) {
      await db.customStatement('DELETE FROM $t');
    }
    await db.customStatement('PRAGMA foreign_keys = ON');

    final env = await backup.inspect(file);
    await backup.import(env, safetyBackup: false, dir: tmp);
    expect(await dump(), equals(before));
  });

  test('file JSON không nén cũng nhập được', () async {
    await seed();
    final before = await dump();
    final file = await backup.exportJson(dir: tmp);
    expect(file.path, endsWith('.json'));

    await db.customStatement('PRAGMA foreign_keys = OFF');
    for (final t in BackupService.tableOrder.reversed) {
      await db.customStatement('DELETE FROM $t');
    }
    await db.customStatement('PRAGMA foreign_keys = ON');

    await backup.import(await backup.inspect(file), safetyBackup: false, dir: tmp);
    expect(await dump(), equals(before));
  });

  test('giữ nguyên dấu tiếng Việt qua vòng khứ hồi', () async {
    await seed();
    final file = await backup.exportBackup(dir: tmp);
    await db.customStatement('PRAGMA foreign_keys = OFF');
    for (final t in BackupService.tableOrder.reversed) {
      await db.customStatement('DELETE FROM $t');
    }
    await db.customStatement('PRAGMA foreign_keys = ON');
    await backup.import(await backup.inspect(file), safetyBackup: false, dir: tmp);

    final v = await db.select(db.vehicles).getSingle();
    expect(v.ownerName, 'Nguyễn Văn An');
    expect(v.notes, 'Khách quen, ghi chú có dấu tiếng Việt');
    expect((await db.select(db.lots).getSingle()).name, 'Bãi Nguyễn Trãi');
  });

  test('doanh thu tính lại y hệt sau khi khôi phục', () async {
    await seed();
    final envBefore = await db
        .revenueAccrualByMonth(fromYm: '2026-01', toYm: '2026-12')
        .get();

    final file = await backup.exportBackup(dir: tmp);
    await db.customStatement('PRAGMA foreign_keys = OFF');
    for (final t in BackupService.tableOrder.reversed) {
      await db.customStatement('DELETE FROM $t');
    }
    await db.customStatement('PRAGMA foreign_keys = ON');
    await backup.import(await backup.inspect(file), safetyBackup: false, dir: tmp);

    final after =
        await db.revenueAccrualByMonth(fromYm: '2026-01', toYm: '2026-12').get();
    expect(after.map((r) => '${r.ym}:${r.total}'),
        envBefore.map((r) => '${r.ym}:${r.total}'));
  });

  test('checksum sai thì TỪ CHỐI nhập', () async {
    await seed();
    final file = await backup.exportJson(dir: tmp);
    final json = jsonDecode(await file.readAsString()) as Map<String, Object?>;
    // Sửa lén một con số tiền.
    (json['data'] as Map)['payments'][0]['amount'] = 999999999;
    await file.writeAsString(jsonEncode(json));

    expect(
      () => backup.inspect(file),
      throwsA(isA<BackupFormatException>().having(
          (e) => e.message, 'message', contains('bị lỗi hoặc đã bị chỉnh sửa'))),
    );
  });

  test('file của phiên bản MỚI HƠN bị từ chối với lời nhắc cập nhật', () async {
    await seed();
    final file = await backup.exportJson(dir: tmp);
    final json = jsonDecode(await file.readAsString()) as Map<String, Object?>;
    json['formatVersion'] = 99;
    await file.writeAsString(jsonEncode(json));

    expect(
      () => backup.inspect(file),
      throwsA(isA<BackupFormatException>()
          .having((e) => e.message, 'message', contains('cập nhật ứng dụng'))),
    );
  });

  test('file lạ bị từ chối với câu tiếng Việt dễ hiểu', () async {
    final f = File('${tmp.path}/linh_tinh.json');
    await f.writeAsString('{"hello":"world"}');
    expect(
      () => backup.inspect(f),
      throwsA(isA<BackupFormatException>().having((e) => e.message, 'message',
          contains('không phải file sao lưu'))),
    );
  });

  test('xem trước cho biết số dòng TRƯỚC khi ghi đè', () async {
    await seed();
    final env = await backup.inspect(await backup.exportBackup(dir: tmp));
    expect(env.counts['lots'], 1);
    expect(env.counts['vehicles'], 1);
    expect(env.counts['payments'], 1);
    expect(env.counts['payment_allocations'], 3);
    expect(env.exportedAt, DateTime(2026, 9, 7, 10, 30));
  });

  test('ghi đè tự tạo bản sao lưu an toàn trước', () async {
    await seed();
    final env = await backup.buildEnvelope();
    final r = await backup.import(env, dir: tmp);
    expect(r.safetyBackup, isNotNull);
    expect(r.safetyBackup!.existsSync(), isTrue,
        reason: 'một cú bấm nhầm không được phép mất hết dữ liệu');
  });

  test('chế độ GỘP giữ nguyên dữ liệu đang có', () async {
    await seed();
    final env = await backup.buildEnvelope();
    // Gộp lại chính nó: không được nhân đôi.
    await backup.import(env, mode: ImportMode.merge, safetyBackup: false, dir: tmp);
    expect((await db.select(db.lots).get()).length, 1);
    expect((await db.select(db.vehicles).get()).length, 1);
    expect((await db.select(db.payments).get()).length, 1);
  });

  test('tên file chỉ dùng ASCII để sống sót qua Zalo, email, AirDrop', () async {
    await seed();
    final name = (await backup.exportBackup(dir: tmp)).path.split('/').last;
    expect(name, matches(RegExp(r'^[A-Za-z0-9_.\-]+$')));
    expect(name, 'SaoLuu_QuanLyBaiXe_20260907_1030.qlbx');
  });

  test('nhập hỏng giữa chừng thì HOÀN NGUYÊN sạch, không để lại nửa vời',
      () async {
    await seed();
    final before = await dump();
    final env = await backup.buildEnvelope();
    // Bơm một dòng payments trỏ tới cột không tồn tại -> lỗi giữa transaction.
    env.data['payments']!.add({'cot_khong_ton_tai': 1});

    await expectLater(
        backup.import(env, safetyBackup: false, dir: tmp), throwsA(anything));

    expect(await dump(), equals(before),
        reason: 'transaction phải hoàn nguyên toàn bộ');
  });

  test('sao lưu khi chưa có dữ liệu vẫn chạy được', () async {
    final env = await backup.buildEnvelope();
    expect(env.counts['lots'], 0);
    await backup.import(env, safetyBackup: false, dir: tmp);
    expect(await db.select(db.lots).get(), isEmpty);
  });
}
