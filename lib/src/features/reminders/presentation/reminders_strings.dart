/// Chuỗi riêng của màn hình nhắc thu tiền.
abstract final class RemindersStrings {
  static const String title = 'Nhắc thu tiền';
  static const String tabToday = 'Hôm nay';
  static const String tabWeek = 'Tuần này';
  static const String tabMonth = 'Tháng này';
  static const String overdue = 'Đã quá hạn';

  /// Số xe và tổng tiền dự kiến thu được của nhóm đang xem.
  static String summary(int count, String amount) =>
      '$count xe · dự kiến thu $amount';

  static const String noPhone = 'Chưa có số điện thoại';
  static const String callAll = 'Gọi lần lượt';
  static const String emptyToday = 'Hôm nay không có xe nào tới hạn';
  static const String emptyWeek = 'Tuần này không có xe nào tới hạn';
  static const String emptyMonth = 'Tháng này không có xe nào tới hạn';
}
