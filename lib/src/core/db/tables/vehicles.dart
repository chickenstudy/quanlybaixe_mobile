import 'package:drift/drift.dart';

import '../converters/day_converter.dart';
import '../enums.dart';
import 'lots.dart';

/// Xe đang gửi (mục 3 đặc tả) — chức năng trọng tâm của hệ thống.
///
/// Bốn cột `current*` / `total*` / `lastPayment*` là **bản sao dẫn xuất** từ
/// bảng `payments`. Chúng tồn tại vì dashboard, bộ lọc và bộ lập lịch thông
/// báo đều truy vấn hạn thanh toán trên hàng trăm dòng liên tục; nếu không có
/// cache thì mỗi lần vẽ danh sách là một truy vấn con `MAX()` cho từng dòng.
///
/// **Bất biến:** các cột đó chỉ được ghi bởi đúng một nơi —
/// `PaymentRepository.recomputeVehicleCache()` — và luôn nằm trong cùng
/// transaction với thao tác thay đổi thanh toán. Không sửa tay ở bất kỳ đâu.
@DataClassName('VehicleRow')
class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lotId =>
      integer().references(Lots, #id, onDelete: KeyAction.restrict)();

  TextColumn get ownerName => text().withLength(min: 1, max: 120)();

  /// `viFold(ownerName)` — để gõ "nguyen" tìm ra "Nguyễn".
  TextColumn get ownerNameFold => text()();

  /// Số điện thoại đúng như người dùng gõ, ví dụ `0912 345 678`.
  TextColumn get phone => text().nullable()();

  /// Chỉ chữ số — dùng cho tìm kiếm và cho `tel:`.
  TextColumn get phoneDigits => text().nullable()();

  IntColumn get vehicleType => intEnum<VehicleType>()();

  /// Biển số hiển thị, giữ nguyên định dạng người dùng gõ: `59A1-234.56`.
  TextColumn get plate => text()();

  /// Biển số đã chuẩn hoá: `59A123456`. Dùng cho index chống trùng và tìm kiếm.
  TextColumn get plateNormalized => text()();

  /// Giá thuê hiện hành, VND/tháng.
  IntColumn get monthlyPrice => integer()();

  DateTimeColumn get startDate => dateTime().map(const DayConverter())();

  /// Ngày trong tháng của [startDate] gốc, 1..31.
  ///
  /// Neo chu kỳ vào ngày này thay vì vào ngày của kỳ trước, để cái kẹp ngày
  /// cuối tháng không bị dính vĩnh viễn: xe bắt đầu ngày 31 sau khi qua tháng 2
  /// phải quay lại ngày 31, chứ không tụt xuống 28 rồi ở đó mãi.
  IntColumn get anchorDay => integer()();

  IntColumn get status =>
      intEnum<VehicleStatus>().withDefault(const Constant(0))();

  /// Ngày xe rời bãi — "ngày kết thúc" trong đặc tả.
  DateTimeColumn get leftOn => dateTime().nullable().map(const DayConverter())();

  // ─── Cache dẫn xuất từ payments — chỉ ghi qua recomputeVehicleCache() ───

  /// `MAX(payments.periodEnd)`. Là mốc **loại trừ**: hết hạn khi
  /// `today >= currentPeriodEnd`.
  DateTimeColumn get currentPeriodEnd =>
      dateTime().nullable().map(const DayConverter())();

  DateTimeColumn get lastPaymentDate =>
      dateTime().nullable().map(const DayConverter())();

  IntColumn get totalMonthsPaid => integer().withDefault(const Constant(0))();
  IntColumn get totalPaid => integer().withDefault(const Constant(0))();

  // ─── Cờ "đã nhắc" (mục 6 đặc tả) ───

  DateTimeColumn get lastRemindedAt => dateTime().nullable()();

  /// Đã nhắc cho kỳ hạn nào. So sánh với [currentPeriodEnd] để dấu "đã nhắc"
  /// **tự xoá** khi xe được gia hạn — nếu không, người dùng sẽ tưởng đã nhắc
  /// rồi trong khi thực ra đó là lần nhắc của kỳ trước.
  DateTimeColumn get remindedForPeriodEnd =>
      dateTime().nullable().map(const DayConverter())();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
