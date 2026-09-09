import 'package:drift/drift.dart';

import '../converters/day_converter.dart';
import '../enums.dart';
import 'lots.dart';
import 'recurring_cost_templates.dart';

/// Chi phí thực tế — chứa **cả** chi phí cố định đã sinh ra lẫn chi phí phát
/// sinh nhập tay. Một bảng duy nhất cho mọi loại chi phí.
///
/// Chi phí cố định được **vật chất hoá lười** vào đây thay vì cộng động từ mẫu
/// lúc chạy báo cáo, vì lý do rất thực tế: tiền điện tháng nào cũng khác nhau.
/// Có dòng thật thì người dùng sửa được đúng số tiền điện của riêng tháng 8
/// trong khi mẫu vẫn giữ giá trị mặc định cho các tháng sau. Cộng động thì đó
/// là một dòng ma không sửa được, và để sửa được lại phải thêm một bảng
/// "ghi đè" — nhiều bộ máy hơn hẳn so với việc cứ ghi thẳng dòng đó ra.
///
/// Đổi lại, mọi truy vấn chi phí chỉ đọc một bảng, và `lợi nhuận = doanh thu −
/// chi phí` là một phép join chứ không phải join với một chuỗi tháng tổng hợp
/// tại chỗ.
@DataClassName('ExpenseRow')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lotId =>
      integer().references(Lots, #id, onDelete: KeyAction.restrict)();

  TextColumn get name => text()();
  IntColumn get category => intEnum<CostCategory>()();
  IntColumn get kind => intEnum<ExpenseKind>()();
  IntColumn get amount => integer()();

  /// Ngày chi tiền thực tế.
  DateTimeColumn get incurredOn => dateTime().map(const DayConverter())();

  /// Tháng kế toán `YYYY-MM` — tách riêng khỏi [incurredOn] để người dùng ghi
  /// hoá đơn điện tháng 8 với ngày trả 03/09 nhưng vẫn hạch toán vào tháng 8.
  /// Đó chính là cách hoá đơn tiện ích hoạt động ngoài đời; không tách ra thì
  /// con số lợi nhuận theo tháng sẽ chập chờn.
  TextColumn get periodMonth => text().withLength(min: 7, max: 7)();

  /// Trỏ về mẫu đã sinh ra dòng này. `null` = chi phí phát sinh nhập tay.
  ///
  /// `ON DELETE SET NULL`: xoá mẫu thì chi phí lịch sử vẫn còn — tiền đó đã
  /// thực sự chi ra rồi.
  IntColumn get sourceTemplateId => integer()
      .nullable()
      .references(RecurringCostTemplates, #id, onDelete: KeyAction.setNull)();

  /// Người dùng đã sửa lại số tiền so với ước tính của mẫu. Dòng chưa sửa được
  /// hiển thị kèm nhãn "ước tính" để biết hoá đơn nào chưa xác nhận.
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();

  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
