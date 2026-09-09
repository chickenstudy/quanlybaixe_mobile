import 'package:drift/drift.dart';

import '../converters/day_converter.dart';
import 'payments.dart';

/// Phân bổ một lần đóng tiền ra từng tháng được bao phủ — nguồn của
/// **doanh thu phân bổ** (cách 2, mục 4 đặc tả).
///
/// Được sinh ngay trong cùng transaction với bản ghi thanh toán, chứ không
/// tính lại lúc chạy báo cáo. Ba lý do:
///
/// 1. Hai chế độ doanh thu trở thành **cùng một hình dạng truy vấn** — cả hai
///    đều là `GROUP BY` trên một bảng. Công tắc chuyển chế độ chỉ đổi bảng
///    nguồn. Tính động thì nhánh phân bổ là code Dart có hình dạng hoàn toàn
///    khác nhánh SQL thực thu: gấp đôi lượng code, gấp đôi chỗ sai.
/// 2. Việc chia dư trở thành **một sự thật kiểm chứng được** trong DB —
///    `SUM(allocations.amount) == payments.amount` là bất biến test được. Tính
///    động thì hai báo cáo ở hai phạm vi có thể lệch nhau 1 đồng và không bao
///    giờ tìm ra nguyên nhân.
/// 3. Sheet "Phân bổ doanh thu" khi xuất Excel chỉ là một cú đổ bảng, người
///    dùng tự kiểm chứng được phép tính của ứng dụng.
@DataClassName('PaymentAllocationRow')
class PaymentAllocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get paymentId =>
      integer().references(Payments, #id, onDelete: KeyAction.cascade)();

  /// Sao chép để `GROUP BY` theo bãi không cần join.
  IntColumn get lotId => integer()();
  IntColumn get vehicleId => integer()();

  /// Tháng kế toán `YYYY-MM`. Lưu chuỗi vì nó sắp xếp theo thứ tự từ điển đúng
  /// bằng thứ tự thời gian, nên `BETWEEN` và `ORDER BY` chạy thẳng trên index.
  TextColumn get periodMonth => text().withLength(min: 7, max: 7)();

  /// Ngày đầu tháng — trục hoành của biểu đồ xu hướng.
  DateTimeColumn get periodMonthStart =>
      dateTime().map(const DayConverter())();

  IntColumn get amount => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {paymentId, periodMonth},
      ];
}
