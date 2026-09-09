import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Phong bì của file sao lưu.
///
/// Chọn JSON có đánh phiên bản thay vì chép thẳng file `.db`, vì hai lý do
/// thực tế của chính kịch bản mà đặc tả mô tả — người dùng đổi điện thoại:
///
/// 1. **Nâng cấp được qua các phiên bản schema.** File `.db` thô của bản cũ
///    không tự hợp với bản mới hơn trên máy mới. Phong bì JSON cho phép chạy
///    các bước chuyển đổi tiến bằng Dart, viết test được từng bước.
/// 2. **Đọc và sửa được.** Khi người dùng báo nhập lỗi, mở file ra xem được.
///
/// Bù lại phải viết bộ tuần tự hoá — nhưng đằng nào đặc tả cũng yêu cầu xuất
/// JSON riêng, nên đây là cùng một đoạn mã dùng cho hai việc.
class BackupEnvelope {
  const BackupEnvelope({
    required this.formatVersion,
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.counts,
    required this.data,
    this.checksum,
  });

  static const String format = 'qlbx';

  /// Phiên bản của chính cấu trúc phong bì.
  static const int currentFormatVersion = 1;

  final int formatVersion;

  /// Phiên bản schema của Drift lúc xuất.
  final int schemaVersion;
  final String appVersion;
  final DateTime exportedAt;

  /// Số dòng từng bảng — để hiện màn hình xem trước TRƯỚC khi người dùng
  /// đồng ý ghi đè dữ liệu hiện có.
  final Map<String, int> counts;

  final Map<String, List<Map<String, Object?>>> data;
  final String? checksum;

  Map<String, Object?> toJson() => {
        'format': format,
        'formatVersion': formatVersion,
        'schemaVersion': schemaVersion,
        'appVersion': appVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'counts': counts,
        'checksum': checksum ?? checksumOf(data),
        'data': data,
      };

  factory BackupEnvelope.fromJson(Map<String, Object?> json) {
    if (json['format'] != format) {
      throw const BackupFormatException('Đây không phải file sao lưu của ứng dụng.');
    }
    final fv = json['formatVersion'];
    if (fv is! int) {
      throw const BackupFormatException('File sao lưu thiếu thông tin phiên bản.');
    }
    if (fv > currentFormatVersion) {
      throw const BackupFormatException(
        'File sao lưu được tạo bởi phiên bản ứng dụng mới hơn. '
        'Vui lòng cập nhật ứng dụng rồi thử lại.',
      );
    }

    final rawData = json['data'];
    if (rawData is! Map) {
      throw const BackupFormatException('File sao lưu không có dữ liệu.');
    }
    final data = <String, List<Map<String, Object?>>>{
      for (final e in rawData.entries)
        e.key as String: [
          for (final row in (e.value as List)) Map<String, Object?>.from(row as Map),
        ],
    };

    final expected = json['checksum'];
    if (expected is String && expected.isNotEmpty) {
      if (checksumOf(data) != expected) {
        throw const BackupFormatException(
            'File sao lưu bị lỗi hoặc đã bị chỉnh sửa.');
      }
    }

    return BackupEnvelope(
      formatVersion: fv,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      appVersion: json['appVersion'] as String? ?? '',
      exportedAt:
          DateTime.tryParse(json['exportedAt'] as String? ?? '') ?? DateTime(1970),
      counts: {
        for (final e in (json['counts'] as Map? ?? {}).entries)
          e.key as String: (e.value as num).toInt(),
      },
      data: data,
      checksum: expected as String?,
    );
  }

  /// Băm sha256 trên JSON đã chuẩn hoá thứ tự khoá.
  ///
  /// Chuẩn hoá thứ tự là bắt buộc: `jsonEncode` giữ nguyên thứ tự chèn của Map,
  /// nên cùng một dữ liệu ghi ở hai lần chạy khác nhau có thể ra chuỗi khác
  /// nhau, và checksum sẽ báo sai một cách ngẫu nhiên.
  static String checksumOf(Map<String, List<Map<String, Object?>>> data) {
    final canonical = <String, Object?>{};
    for (final table in data.keys.toList()..sort()) {
      canonical[table] = [
        for (final row in data[table]!)
          {for (final k in row.keys.toList()..sort()) k: row[k]},
      ];
    }
    return 'sha256:${sha256.convert(utf8.encode(jsonEncode(canonical)))}';
  }
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;

  @override
  String toString() => message;
}
