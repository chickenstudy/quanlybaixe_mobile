/// Các kiểu liệt kê được lưu xuống DB dưới dạng **chỉ số nguyên**.
///
/// Quy tắc bất di bất dịch: **chỉ được thêm giá trị vào cuối, không bao giờ
/// chèn giữa hay đổi thứ tự**. Drift lưu `index` của enum, nên đổi thứ tự sẽ
/// âm thầm diễn giải lại toàn bộ dữ liệu cũ — ô tô biến thành xe máy trong mọi
/// bản ghi lịch sử, không có lỗi nào được báo.
library;

/// Loại xe (mục 3 đặc tả).
enum VehicleType { motorbike, car, truck, other }

/// Xe còn gửi hay đã rời bãi. Khác hẳn với "hết hạn": một xe có thể quá hạn
/// thanh toán nhưng vẫn đang nằm trong bãi.
enum VehicleStatus { active, stopped }

enum PaymentMethod { cash, transfer, other }

/// Nhóm chi phí (mục 2 đặc tả). Sáu nhóm đầu là chi phí cố định hàng tháng,
/// ba nhóm sau là chi phí phát sinh.
enum CostCategory {
  rent,
  electricity,
  water,
  internet,
  security,
  staff,
  repair,
  equipment,
  maintenance,
  other,
}

/// Chi phí này sinh ra từ mẫu cố định hàng tháng, hay do người dùng nhập tay.
enum ExpenseKind { recurring, adhoc }

/// Chế độ tính doanh thu (mục 4 đặc tả).
enum RevenueMode {
  /// Toàn bộ tiền nhận trong tháng tính vào tháng đó.
  cash,

  /// Tiền đóng nhiều tháng được rải đều ra từng tháng được bao phủ.
  accrual,
}

/// Mốc gom nhóm của báo cáo (mục 5 đặc tả).
enum ReportGranularity { day, month, quarter, year }

enum LogAction {
  lotCreated,
  lotUpdated,
  lotDeleted,
  vehicleCreated,
  vehicleUpdated,
  vehicleDeleted,
  vehicleMoved,
  vehicleStopped,
  paymentCreated,
  paymentVoided,
  vehicleReminded,
  expenseCreated,
  expenseUpdated,
  expenseDeleted,
  templateCreated,
  templateUpdated,
  templateDeleted,
  dataExported,
  dataImported,
}

enum LogEntity { lot, vehicle, payment, expense, template, app }
