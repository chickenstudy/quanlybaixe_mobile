/// Chữ riêng của màn hình báo cáo.
///
/// Chỉ khai ở đây những câu **chưa có** trong `Strings`. Mọi thứ dùng chung
/// ("Doanh thu", "Chi phí", "Lãi/lỗ", "Cách tính doanh thu", nhãn mốc gom
/// nhóm…) đều lấy từ `Strings` và các hàm `revenueModeLabel` /
/// `reportGranularityLabel`, để một ngày đổi cách xưng hô thì chỉ phải sửa một
/// chỗ và dashboard với báo cáo không bao giờ gọi cùng một khái niệm bằng hai
/// cái tên.
library;

abstract final class ReportsStrings {
  // ── Ba ô tổng ────────────────────────────────────────────────────────────

  /// `Strings.reportRevenue` là nhãn cột ("Doanh thu"); ô tổng cần nói rõ đây
  /// là con số cộng dồn cả khoảng, không phải của một mốc.
  static const String totalRevenue = 'Tổng doanh thu';
  static const String totalExpense = 'Tổng chi phí';

  /// Nhãn ô lãi/lỗ. Bản thân con số luôn mang dấu (`formatVndSigned`) và kèm
  /// chữ "Lãi"/"Lỗ", nên màu không bao giờ là tín hiệu duy nhất.
  static const String totalProfit = 'Lãi/lỗ cả khoảng';

  // ── Bộ lọc ───────────────────────────────────────────────────────────────

  static const String lotFilter = 'Bãi xe';
  static const String rangeThisMonth = 'Tháng này';
  static const String rangeThisQuarter = 'Quý này';
  static const String rangeThisYear = 'Năm nay';
  static const String rangeLast12Months = '12 tháng';

  /// Chú thích của nút mở lịch. Nhãn của nút chính là khoảng đang xem, nên
  /// việc nút ấy *làm gì* phải nói ở đây — nếu không, người dùng chỉ thấy một
  /// dãy ngày và không đoán ra là bấm được.
  static const String rangePickCustom = 'Chọn khoảng thời gian khác';

  // ── Mốc ngày trong chế độ phân bổ ────────────────────────────────────────

  /// Tiêu đề dòng giải thích khi báo cáo tự lùi mốc.
  static const String granularityDowngradedTitle =
      'Đã tự chuyển về mốc Tháng';

  /// Lý do, viết cho chủ bãi chứ không viết cho lập trình viên.
  ///
  /// Không được để người dùng nhìn một biểu đồ trống mà không hiểu vì sao:
  /// họ sẽ tưởng mất dữ liệu và đi đối chiếu lại từng phiếu thu.
  static const String granularityDowngradedBody =
      'Cách tính Phân bổ rải tiền đóng nhiều tháng ra từng THÁNG được bao phủ, '
      'chứ không rải xuống từng ngày — nên không có số liệu theo ngày để hiện. '
      'Muốn xem theo ngày, hãy đổi cách tính doanh thu sang Thực thu.';

  // ── Biểu đồ ──────────────────────────────────────────────────────────────

  static const String chartTitle = 'Xu hướng theo thời gian';

  /// Nhắc rằng cuộn ngang được, vì trên màn hình hẹp biểu đồ nhiều mốc chỉ
  /// hiện được một phần và người dùng dễ tưởng là thiếu dữ liệu.
  static const String chartScrollHint = 'Vuốt ngang để xem các mốc còn lại';

  // ── Bảng chi tiết ────────────────────────────────────────────────────────

  static const String tableTitle = 'Chi tiết từng mốc';

  /// Nhãn cột đầu tiên. Nội dung của nó đổi theo mốc đang chọn (ngày / tháng /
  /// quý / năm) nên không thể đặt tên cụ thể hơn.
  static const String columnPeriod = 'Mốc';

  /// Ký hiệu `₫` được rút khỏi từng ô để bảng số không bị rối; nói bù ở đây.
  static const String amountUnitNote = 'Đơn vị: đồng (₫)';

  // ── Tách chi phí theo nhóm ───────────────────────────────────────────────

  static const String breakdownEmpty = 'Chưa ghi nhận chi phí nào trong khoảng này';

  /// Nhãn phần trăm trên từng dòng nhóm chi phí.
  static String breakdownShare(int percent) => '$percent%';

  /// Tóm tắt lựa chọn hiện tại, hiện trên đầu bảng điều khiển khi đang thu gọn.
  static String filterSummary(String lot, String granularity, String mode) =>
      '$lot · $granularity · $mode';
  static const String filtersTitle = 'Bộ lọc';

  /// Hai cực của thang lãi/lỗ.
  static const String polePositive = 'Lãi';
  static const String poleNegative = 'Lỗ';

  static const String chartRevenueExpenseTitle = 'Thu và chi theo mốc';
  static const String chartProfitTitle = 'Lãi/lỗ theo mốc';

  /// Dòng phụ của mỗi mốc trong danh sách chi tiết.
  static String detailLine(String revenue, String expense) =>
      'Thu $revenue · Chi $expense';

  /// Nhóm gộp phần đuôi khi quá nhiều hạng mục chi phí.
  static const String otherCategories = 'Nhóm khác';
}
