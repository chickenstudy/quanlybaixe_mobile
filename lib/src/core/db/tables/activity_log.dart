import 'package:drift/drift.dart';

import '../enums.dart';

/// Nhật ký thao tác (mục 10 đặc tả).
@DataClassName('ActivityLogRow')
class ActivityLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get at => dateTime()();
  IntColumn get action => intEnum<LogAction>()();
  IntColumn get entityType => intEnum<LogEntity>()();
  IntColumn get entityId => integer().nullable()();
  IntColumn get lotId => integer().nullable()();

  /// Câu tiếng Việt đã dựng sẵn, hiển thị thẳng lên màn hình.
  ///
  /// Dựng sẵn chứ không dựng lúc đọc, vì hai lẽ: màn hình nhật ký vẽ được mà
  /// **không cần join** bảng nào, và câu chữ vẫn đọc đúng sau khi cái xe được
  /// nhắc tới đã bị xoá — đây chính là cách nhật ký thao tác hay hỏng nhất.
  TextColumn get summary => text()();

  /// JSON mô tả thay đổi trước/sau, cho trường hợp cần soi chi tiết.
  TextColumn get detailsJson => text().nullable()();
}
