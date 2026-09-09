import 'package:drift/drift.dart';

import '../enums.dart';
import 'lots.dart';

/// Mẫu chi phí cố định hàng tháng (mục 2 đặc tả): tiền thuê mặt bằng, điện,
/// nước, internet, bảo vệ, nhân viên...
///
/// Đây chỉ là **mẫu**. Chi phí thật của từng tháng được sinh thành dòng riêng
/// trong bảng `expenses`, xem [Expenses] để biết vì sao.
@DataClassName('RecurringCostTemplateRow')
class RecurringCostTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lotId =>
      integer().references(Lots, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();
  IntColumn get category => intEnum<CostCategory>()();

  /// Số tiền ước tính hàng tháng, VND. Người dùng sửa lại được cho từng tháng
  /// cụ thể ở bảng `expenses` mà không ảnh hưởng tới mẫu này.
  IntColumn get amount => integer()();

  /// Ngày trong tháng gán cho chi phí, kẹp trong 1..28 để tháng nào cũng có.
  IntColumn get dayOfMonth => integer().withDefault(const Constant(1))();

  /// `YYYY-MM` — tháng đầu tiên áp dụng.
  TextColumn get startMonth => text().withLength(min: 7, max: 7)();

  /// `YYYY-MM` — tháng cuối cùng áp dụng, **bao gồm**. `null` = còn hiệu lực.
  TextColumn get endMonth => text().withLength(min: 7, max: 7).nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
