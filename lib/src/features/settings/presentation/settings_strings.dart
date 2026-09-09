/// Chuỗi riêng của màn hình cài đặt.
abstract final class SettingsStrings {
  static const String notifySection = 'Nhắc hạn';
  static const String notifyEnable = 'Bật nhắc hạn';
  static const String notifyEnableHint =
      'Mỗi ngày một thông báo tổng hợp về số xe sắp và đã hết hạn.';
  static const String notifyHour = 'Giờ nhắc hằng ngày';
  static const String notifyLead = 'Nhắc trước';
  static const String notifyLeadHint = '7, 3 và 1 ngày trước khi hết hạn';
  static const String notifyTest = 'Gửi thử một thông báo';
  static const String notifyTestSent = 'Đã gửi. Kiểm tra màn hình khoá.';
  static const String notifyPending = 'Đang chờ gửi';
  static String notifyPendingCount(int n) => '$n thông báo đã đặt lịch';
  static const String notifyDenied = 'Chưa được cấp quyền thông báo';
  static const String notifyDeniedHint =
      'iOS chỉ hỏi quyền một lần. Hãy vào Cài đặt hệ thống để bật lại.';
  static const String notifyOpenSettings = 'Mở Cài đặt hệ thống';
  static const String notifySnapshotWarning =
      'Con số trong thông báo được tính lúc đặt lịch. Nếu bạn gia hạn cho xe '
      'rồi lâu không mở ứng dụng, con số đó có thể nhiều hơn thực tế.';

  static const String dataSection = 'Dữ liệu';
  static const String backupHint =
      'File .qlbx dùng để chuyển toàn bộ dữ liệu sang máy khác.';
  static const String excelHint =
      'File Excel chỉ để xem và in, KHÔNG nhập lại được.';
  static const String importWarnTitle = 'Ghi đè toàn bộ dữ liệu?';
  static String importWarnBody(int lots, int vehicles, int payments) =>
      'File này có $lots bãi xe, $vehicles xe và $payments lần thu tiền.\n\n'
      'Toàn bộ dữ liệu hiện tại sẽ bị xoá và thay bằng dữ liệu trong file. '
      'Ứng dụng sẽ tự tạo một bản sao lưu an toàn trước khi ghi đè.';
  static const String importConfirm = 'Ghi đè và khôi phục';
  static String importedRows(int n) => 'Đã khôi phục $n dòng dữ liệu';
  static const String backupNagTitle = 'Nên sao lưu dữ liệu';
  static String backupNagBody(int days) =>
      'Đã $days ngày chưa sao lưu. Dữ liệu chỉ nằm trên chiếc điện thoại này.';

  static const String manageSection = 'Quản lý';
  static const String about = 'Về ứng dụng';
  static const String aboutBody =
      'Quản Lý Bãi Xe chạy hoàn toàn ngoại tuyến. Không có máy chủ, không tài '
      'khoản, không gửi dữ liệu đi đâu. Vì vậy dữ liệu chỉ nằm trên máy này — '
      'hãy sao lưu định kỳ.';
}
