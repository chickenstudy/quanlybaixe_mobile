import 'package:drift/drift.dart';

import '../converters/day_converter.dart';
import '../enums.dart';
import 'lots.dart';
import 'vehicles.dart';

/// Sổ cái thu tiền — **nguồn sự thật duy nhất** về doanh thu.
///
/// Đặc tả đặt "số tháng đóng / ngày đóng tiền / ngày kết thúc" ngay trên bản
/// ghi xe, nhưng như vậy chỉ lưu được **lần đóng gần nhất**. Một xe đã đóng
/// tiền năm lần có năm ngày thu khác nhau; doanh thu thực thu cần từng ngày
/// đó, còn doanh thu phân bổ cần từng khoảng kỳ tương ứng. Một dòng trên bảng
/// xe không biểu diễn nổi. Bảng này giữ sự thật, các cột cache trên `vehicles`
/// giữ trạng thái hiện tại dẫn xuất từ nó.
@DataClassName('PaymentRow')
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  /// **Ảnh chụp** bãi tại thời điểm thu tiền, không phải bãi hiện tại của xe.
  ///
  /// Không có cột này thì chuyển một xe từ Bãi A sang Bãi B sẽ **viết lại quá
  /// khứ** doanh thu của Bãi A. Báo cáo tài chính theo bãi phải là lịch sử bất
  /// biến.
  IntColumn get lotId =>
      integer().references(Lots, #id, onDelete: KeyAction.restrict)();

  /// Tổng số tiền thực nhận, VND.
  IntColumn get amount => integer()();

  /// Số tháng đóng, >= 1.
  IntColumn get monthsPaid => integer()();

  /// **Ảnh chụp** đơn giá tại thời điểm thu. Tăng giá bãi không được làm đổi
  /// nội dung biên lai cũ. Ngoài ra khi `amount != monthsPaid * unitPrice` thì
  /// đó là trường hợp bớt giá / làm tròn cho khách, đọc ra được ngay, chứ
  /// không phải một lỗi dữ liệu bí ẩn.
  IntColumn get unitPrice => integer()();

  /// Ngày thu tiền — nguồn của **doanh thu thực thu**.
  DateTimeColumn get paidAt => dateTime().map(const DayConverter())();

  DateTimeColumn get periodStart => dateTime().map(const DayConverter())();

  /// Mốc kết thúc **loại trừ** — ngày đầu tiên không còn được bao phủ.
  /// Đóng 3 tháng từ 01/08/2026 thì giá trị này là 01/11/2026, đúng như câu
  /// "hết hạn 01/11/2026" của đặc tả. Nhờ loại trừ, `periodStart` của lần đóng
  /// kế tiếp **chính là** giá trị này, không cộng trừ 1 ngày ở đâu cả.
  DateTimeColumn get periodEnd => dateTime().map(const DayConverter())();

  IntColumn get method =>
      intEnum<PaymentMethod>().withDefault(const Constant(0))();

  TextColumn get note => text().nullable()();

  /// Huỷ mềm thay vì xoá cứng. Chủ bãi bấm nhầm một biên lai vài triệu thì cần
  /// dấu vết để hoàn tác, và nhật ký thao tác thành vô nghĩa nếu bản ghi được
  /// tham chiếu biến mất. Mọi truy vấn doanh thu lọc `voidedAt IS NULL`.
  DateTimeColumn get voidedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
