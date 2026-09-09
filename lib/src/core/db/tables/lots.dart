import 'package:drift/drift.dart';

/// Bãi xe (mục 2 đặc tả).
@DataClassName('LotRow')
class Lots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// `viFold(name)` — cột phụ có index để tìm kiếm không phân biệt dấu.
  TextColumn get nameFold => text()();

  TextColumn get address => text().nullable()();

  /// Giá thuê chỗ mặc định, VND/tháng. Dùng để điền sẵn khi thêm xe mới.
  /// NGỪNG DÙNG — luôn bằng 0 với mọi bãi tạo mới.
  ///
  /// Một mức giá mặc định cho cả bãi là sai với nghiệp vụ thật: cùng một bãi
  /// vẫn nhận xe máy 150.000/tháng lẫn ô tô 900.000 và xe tải 1.500.000. Điền
  /// sẵn một con số cho mọi loại xe chỉ khiến người dùng sửa lại mỗi lần thêm
  /// xe, mà quên sửa thì ghi sai tiền.
  ///
  /// Cột được giữ lại để dữ liệu và file sao lưu cũ vẫn nhập được. Bỏ hẳn thì
  /// cần nâng schemaVersion và viết một bước migration.
  IntColumn get defaultPrice => integer().withDefault(const Constant(0))();

  /// Sức chứa của bãi. Đặc tả không liệt kê trường này ở mục 2, nhưng mục 10
  /// yêu cầu "tỷ lệ lấp đầy từng bãi" — không có sức chứa thì không tính được.
  /// Cho phép để trống; khi trống thì màn hình thống kê **ẩn** chỉ số lấp đầy
  /// thay vì hiện một con số sai.
  IntColumn get capacity => integer().nullable()();

  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
