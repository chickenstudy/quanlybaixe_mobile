/// Toàn bộ chữ tiếng Việt của giao diện, gom về một chỗ.
///
/// **Cố tình không dùng ARB / `gen_l10n`.** Bộ máy quốc tế hoá của Flutter sinh
/// ra để giải hai bài toán mà ứng dụng này không có: nhiều ngôn ngữ, và quy tắc
/// số nhiều theo ngôn ngữ. Ứng dụng chỉ chạy tiếng Việt — thứ tiếng không chia
/// số nhiều, không chia giống, không biến cách — nên `gen_l10n` chỉ thêm một
/// vòng codegen, một lớp `BuildContext` bắt buộc, và hàng chục file `.arb`,
/// đổi lại đúng con số 0 lợi ích. Một lớp hằng số cho tra cứu tĩnh, tự động
/// hoàn thành trong IDE, và trình phân tích bắt được chữ chết ngay lúc biên
/// dịch.
///
/// Nếu về sau thật sự cần thêm ngôn ngữ: đổi các `static const` ở đây thành
/// getter đọc từ `AppLocalizations`, mọi nơi gọi giữ nguyên hình dạng
/// `Strings.xxx`.
library;

import '../db/enums.dart';

/// Chữ giao diện, nhóm theo màn hình.
///
/// Hằng số chứ không phải hàm, trừ khi câu chữ có tham số — lúc đó dùng hàm
/// `static` trả `String` ở cuối lớp.
abstract final class Strings {
  // ══════════════════════════════════════════════════════════════════════
  // CHUNG — nút bấm, trạng thái, thông báo dùng lại ở mọi màn hình
  // ══════════════════════════════════════════════════════════════════════

  static const String appName = 'Quản Lý Bãi Xe';

  static const String save = 'Lưu';
  static const String cancel = 'Huỷ';
  static const String delete = 'Xoá';
  static const String edit = 'Sửa';
  static const String add = 'Thêm';
  static const String close = 'Đóng';
  static const String confirm = 'Xác nhận';
  static const String ok = 'Đồng ý';
  static const String back = 'Quay lại';
  static const String next = 'Tiếp tục';
  static const String done = 'Xong';
  static const String retry = 'Thử lại';
  static const String undo = 'Hoàn tác';
  static const String search = 'Tìm kiếm';
  static const String searchHint = 'Nhập biển số, tên hoặc số điện thoại';
  static const String filter = 'Lọc';
  static const String sort = 'Sắp xếp';
  static const String all = 'Tất cả';
  static const String none = 'Không có';
  static const String selectAll = 'Chọn tất cả';
  static const String clearFilter = 'Bỏ lọc';
  static const String more = 'Thêm nữa';
  static const String details = 'Chi tiết';
  static const String note = 'Ghi chú';
  static const String noteHint = 'Ghi chú thêm (không bắt buộc)';
  static const String optional = 'không bắt buộc';
  static const String required = 'bắt buộc';
  static const String loading = 'Đang tải…';
  static const String saving = 'Đang lưu…';
  static const String empty = 'Chưa có dữ liệu';
  static const String noResult = 'Không tìm thấy kết quả nào';
  static const String today = 'Hôm nay';
  static const String yesterday = 'Hôm qua';
  static const String thisMonth = 'Tháng này';
  static const String lastMonth = 'Tháng trước';
  static const String thisYear = 'Năm nay';
  static const String from = 'Từ ngày';
  static const String to = 'Đến ngày';
  static const String total = 'Tổng cộng';
  static const String amount = 'Số tiền';
  static const String amountHint = 'Nhập số tiền';
  static const String date = 'Ngày';
  static const String month = 'Tháng';
  static const String name = 'Tên';
  static const String phone = 'Số điện thoại';
  static const String status = 'Trạng thái';
  static const String type = 'Loại';
  static const String category = 'Nhóm';
  static const String currencyUnit = 'đồng';

  // Xác nhận & lỗi dùng chung.
  static const String confirmDeleteTitle = 'Xoá dữ liệu?';
  static const String confirmDeleteMessage =
      'Dữ liệu đã xoá không lấy lại được. Bạn chắc chắn muốn xoá?';
  static const String discardChangesTitle = 'Bỏ thay đổi?';
  static const String discardChangesMessage =
      'Bạn đã sửa nhưng chưa lưu. Thoát bây giờ sẽ mất phần vừa sửa.';
  static const String saved = 'Đã lưu';
  static const String deleted = 'Đã xoá';
  static const String errorGeneric = 'Có lỗi xảy ra. Vui lòng thử lại.';
  static const String errorRequired = 'Không được để trống';
  static const String errorInvalidNumber = 'Số không hợp lệ';
  static const String errorAmountPositive = 'Số tiền phải lớn hơn 0';
  static const String errorInvalidPhone = 'Số điện thoại không hợp lệ';
  static const String errorInvalidDate = 'Ngày không hợp lệ';
  static const String errorDuplicatePlate = 'Biển số này đã có trong bãi';

  // ══════════════════════════════════════════════════════════════════════
  // TỔNG QUAN (dashboard)
  // ══════════════════════════════════════════════════════════════════════

  static const String dashboard = 'Tổng quan';
  static const String dashboardRevenueThisMonth = 'Doanh thu tháng này';
  static const String dashboardExpenseThisMonth = 'Chi phí tháng này';
  static const String dashboardProfitThisMonth = 'Lãi/lỗ tháng này';
  static const String dashboardVehicleCount = 'Xe đang gửi';
  static const String dashboardOccupancy = 'Tỷ lệ lấp đầy';
  static const String dashboardExpiringSoon = 'Sắp hết hạn';
  static const String dashboardExpired = 'Đã hết hạn';
  static const String dashboardUnpaid = 'Chưa thu';
  static const String dashboardRevenueTrend = 'Xu hướng doanh thu';
  static const String dashboardTopLots = 'Bãi xe theo doanh thu';
  static const String dashboardQuickActions = 'Thao tác nhanh';
  static const String dashboardAddVehicle = 'Thêm xe';
  static const String dashboardCollectMoney = 'Thu tiền';
  static const String dashboardAddExpense = 'Ghi chi phí';
  static const String dashboardSeeAll = 'Xem tất cả';

  // Màn hình trống lần đầu mở ứng dụng
  static const String welcomeTitle = 'Chào mừng!'
;
  static const String welcomeBody =
      'Chưa có dữ liệu nào. Bạn có thể tạo bãi xe đầu tiên, '
      'hoặc nạp dữ liệu mẫu để xem thử ứng dụng hoạt động thế nào.'
;
  static const String welcomeSeedSample = 'Nạp dữ liệu mẫu'
;
  static const String welcomeSeeding = 'Đang nạp dữ liệu mẫu…';
  static const String dashboardNoVehicleYet =
      'Chưa có xe nào. Thêm bãi xe rồi thêm xe để bắt đầu.';

  // ══════════════════════════════════════════════════════════════════════
  // BÃI XE
  // ══════════════════════════════════════════════════════════════════════

  static const String lots = 'Bãi xe';
  static const String lot = 'Bãi';
  static const String lotAdd = 'Thêm bãi xe';
  static const String lotEdit = 'Sửa bãi xe';
  static const String lotName = 'Tên bãi';
  static const String lotNameHint = 'Ví dụ: Bãi Nguyễn Trãi';
  static const String lotAddress = 'Địa chỉ';
  static const String lotCapacity = 'Sức chứa';
  static const String lotCapacityHint = 'Số xe tối đa';
  static const String lotVehicleCount = 'Số xe đang gửi';
  static const String lotSelect = 'Chọn bãi xe';
  static const String lotEmpty = 'Chưa có bãi xe nào';
  static const String lotEmptyHint = 'Thêm bãi xe đầu tiên để bắt đầu quản lý.';
  static const String lotDeleteBlocked =
      'Bãi này còn xe đang gửi nên chưa xoá được. Hãy chuyển hoặc ngừng gửi các xe trước.';
  static const String lotFull = 'Bãi đã đầy';

  // ══════════════════════════════════════════════════════════════════════
  // XE
  // ══════════════════════════════════════════════════════════════════════

  static const String vehicles = 'Xe';
  static const String vehiclesList = 'Danh sách xe';
  static const String vehicleAdd = 'Thêm xe';
  static const String vehicleEdit = 'Sửa thông tin xe';
  static const String vehiclePlate = 'Biển số';
  static const String vehiclePlateHint = 'Ví dụ: 29A-123.45';
  static const String vehicleType = 'Loại xe';
  static const String vehicleOwner = 'Chủ xe';
  static const String vehicleOwnerHint = 'Họ tên chủ xe';
  static const String vehicleMonthlyFee = 'Giá gửi hàng tháng';
  static const String vehicleStartDate = 'Ngày bắt đầu gửi';
  static const String vehicleMonthsCount = 'Số tháng đăng ký';
  static const String vehicleEndDate = 'Ngày kết thúc (Hạn gửi xe)';
  static const String vehiclePeriodEnd = 'Hạn đóng tiếp theo';
  static const String vehicleNoExpiry = 'Chưa đóng lần nào';
  static const String vehicleStatusLabelText = 'Tình trạng';
  static const String vehicleStop = 'Ngừng gửi';
  static const String vehicleStopTitle = 'Ngừng gửi xe?';
  static const String vehicleStopMessage =
      'Xe sẽ được đánh dấu là đã rời bãi. Lịch sử thanh toán vẫn giữ nguyên.';
  static const String vehicleResume = 'Gửi lại';
  static const String vehicleMove = 'Chuyển bãi';
  static const String vehicleMoveTitle = 'Chuyển xe sang bãi khác';
  static const String vehicleMoveTo = 'Chuyển đến bãi';
  static const String vehicleCall = 'Gọi điện';
  static const String vehicleCallNoPhone = 'Xe này chưa có số điện thoại';
  static const String vehicleCallFailed = 'Không mở được ứng dụng gọi điện';
  static const String vehicleHistory = 'Lịch sử thanh toán';
  static const String vehicleEmpty = 'Chưa có xe nào trong bãi';
  static const String vehicleFilterActive = 'Đang gửi';
  static const String vehicleFilterStopped = 'Đã rời bãi';
  static const String vehicleFilterExpiring = 'Sắp hết hạn';
  static const String vehicleFilterExpired = 'Đã hết hạn';
  static const String vehicleSortByPlate = 'Theo biển số';
  static const String vehicleSortByExpiry = 'Theo ngày hết hạn';
  static const String vehicleSortByFee = 'Theo giá gửi';

  // ══════════════════════════════════════════════════════════════════════
  // THANH TOÁN
  // ══════════════════════════════════════════════════════════════════════

  static const String payments = 'Thanh toán';
  static const String paymentCollect = 'Thu tiền';
  static const String paymentAdd = 'Ghi nhận thanh toán';
  static const String paymentDate = 'Ngày thu';
  static const String paymentAmount = 'Số tiền thu';
  static const String paymentMonths = 'Số tháng đóng';
  static const String paymentMethodLabelText = 'Hình thức';
  static const String paymentPeriod = 'Kỳ được bao phủ';
  static const String paymentPeriodStart = 'Từ ngày';
  static const String paymentPeriodEnd = 'Hết hạn ngày';
  static const String paymentReceipt = 'Biên lai';
  static const String paymentVoid = 'Huỷ phiếu thu';
  static const String paymentVoidTitle = 'Huỷ phiếu thu này?';
  static const String paymentVoidMessage =
      'Phiếu thu bị huỷ sẽ không tính vào doanh thu nữa và hạn đóng tiền của xe được tính lại. Bản ghi vẫn nằm trong nhật ký.';
  static const String paymentVoided = 'Đã huỷ';
  static const String paymentEmpty = 'Chưa có phiếu thu nào';
  static const String paymentSuggestedAmount = 'Số tiền gợi ý';
  static const String paymentAmountDiffers =
      'Số tiền khác với giá gửi × số tháng. Vẫn lưu chứ?';

  // Gia hạn nhanh — nút bấm một chạm ở màn hình thu tiền.
  static const String renewQuick = 'Gia hạn nhanh';

  // Bảng thu tiền / gia hạn
  static const String renewSheetTitle = 'Thu tiền gửi xe'
;
  static const String renewMonthCount = 'Số tháng đóng'
;
  static const String renewUnitPrice = 'Đơn giá / tháng'
;
  static const String renewTotal = 'Thành tiền'
;
  static const String renewNewExpiry = 'Hạn mới'
;
  static const String renewFrom = 'Tính từ'
;
  static const String renewPaidOn = 'Ngày thu'
;
  static const String renewApplyPrice = 'Cập nhật giá gửi của xe'
;
  static const String renewApplyPriceHint =
      'Các kỳ sau sẽ dùng đơn giá mới này'
;
  static const String renewCustomMonths = 'Số tháng khác'
;
  static const String renewConfirm = 'Xác nhận thu tiền'
;
  static const String renewAmountDiffers =
      'Thành tiền khác đơn giá × số tháng'
;
  static const String renewInvalidMonths = 'Số tháng phải từ 1 đến 120'
;
  static const String renewInvalidAmount = 'Số tiền không hợp lệ';
  static const String renew1Month = '1 tháng';
  static const String renew3Months = '3 tháng';
  static const String renew6Months = '6 tháng';
  static const String renew12Months = '12 tháng';

  // ══════════════════════════════════════════════════════════════════════
  // CHI PHÍ
  // ══════════════════════════════════════════════════════════════════════

  static const String expenses = 'Chi phí';
  static const String expenseAdd = 'Thêm chi phí';
  static const String expenseEdit = 'Sửa chi phí';
  static const String expenseCategory = 'Nhóm chi phí';
  static const String expenseAmount = 'Số tiền chi';
  static const String expenseDate = 'Ngày chi';
  static const String expenseMonth = 'Tháng áp dụng';
  static const String expenseDescription = 'Diễn giải';
  static const String expenseEmpty = 'Chưa ghi chi phí nào';
  static const String expenseFixed = 'Chi phí cố định hàng tháng';
  static const String expenseAdhoc = 'Chi phí phát sinh';
  static const String expenseTemplates = 'Mẫu chi phí hàng tháng';
  static const String expenseTemplateAdd = 'Thêm mẫu chi phí';
  static const String expenseTemplateEdit = 'Sửa mẫu chi phí';
  static const String expenseTemplateNote =
      'Mẫu chi phí được sinh tự động vào đầu mỗi tháng. Sửa mẫu không làm thay đổi các tháng đã sinh.';
  static const String expenseTemplateActive = 'Đang áp dụng';
  static const String expenseTemplateStopped = 'Đã dừng';
  static const String expenseGenerateNow = 'Sinh chi phí tháng này';
  static const String expenseGenerated = 'Đã sinh chi phí từ mẫu';
  static const String expenseAlreadyGenerated =
      'Tháng này đã sinh chi phí từ mẫu rồi.';

  // ══════════════════════════════════════════════════════════════════════
  // BÁO CÁO
  // ══════════════════════════════════════════════════════════════════════

  static const String reports = 'Báo cáo';
  static const String reportRevenue = 'Doanh thu';
  static const String reportExpense = 'Chi phí';
  static const String reportProfit = 'Lãi/lỗ';
  static const String reportProfitMargin = 'Tỷ suất lợi nhuận';
  static const String reportGranularity = 'Gom nhóm theo';
  static const String reportRange = 'Khoảng thời gian';
  static const String reportByLot = 'Theo bãi xe';
  static const String reportByCategory = 'Theo nhóm chi phí';
  static const String reportByVehicleType = 'Theo loại xe';
  static const String reportRevenueMode = 'Cách tính doanh thu';
  static const String reportRevenueModeCashNote =
      'Thực thu: toàn bộ tiền nhận trong tháng tính hết vào tháng đó.';
  static const String reportRevenueModeAccrualNote =
      'Phân bổ: tiền đóng nhiều tháng được rải đều ra từng tháng được bao phủ.';
  static const String reportEmpty = 'Không có số liệu trong khoảng này';
  static const String reportCompareLastPeriod = 'So với kỳ trước';
  static const String reportProfitPositive = 'Lãi';
  static const String reportProfitNegative = 'Lỗ';
  static const String reportBreakEven = 'Hoà vốn';

  // ══════════════════════════════════════════════════════════════════════
  // THÔNG BÁO / NHẮC HẠN
  // ══════════════════════════════════════════════════════════════════════

  static const String notifications = 'Thông báo';
  static const String notificationSettings = 'Cài đặt nhắc hạn';
  static const String notificationEnable = 'Bật nhắc hạn';
  static const String notificationDaysBefore = 'Nhắc trước bao nhiêu ngày';
  static const String notificationTime = 'Giờ nhắc hàng ngày';
  static const String notificationPermissionTitle = 'Cần quyền thông báo';
  static const String notificationPermissionMessage =
      'Ứng dụng cần quyền gửi thông báo để nhắc bạn khi xe sắp tới hạn đóng tiền.';
  static const String notificationOpenSettings = 'Mở cài đặt';
  static const String reminderList = 'Danh sách cần nhắc';
  static const String reminderMarkDone = 'Đánh dấu đã nhắc';
  static const String reminderMarkShort = 'Đã nhắc';
  static const String reminderMarkedDone = 'Đã đánh dấu là đã nhắc';
  static const String reminderUndoMark = 'Bỏ đánh dấu đã nhắc';
  static const String reminderLastRemindedAt = 'Lần nhắc gần nhất';
  static const String reminderNeverReminded = 'Chưa nhắc lần nào';
  static const String reminderEmpty = 'Không có xe nào cần nhắc';

  // ══════════════════════════════════════════════════════════════════════
  // SAO LƯU / XUẤT / NHẬP DỮ LIỆU
  // ══════════════════════════════════════════════════════════════════════

  static const String backup = 'Sao lưu & phục hồi';
  static const String backupExport = 'Tạo file sao lưu';
  static const String backupExportNote =
      'Toàn bộ dữ liệu được đóng gói thành một file. Hãy lưu file này ra nơi khác — điện thoại hỏng là mất hết.';
  static const String backupImport = 'Phục hồi từ file sao lưu';
  static const String backupPickFile = 'Chọn file';
  static const String backupLastAt = 'Sao lưu gần nhất';
  static const String backupNever = 'Chưa sao lưu lần nào';
  static const String backupCreated = 'Đã tạo file sao lưu';
  static const String backupRestored = 'Đã phục hồi dữ liệu';
  static const String backupInvalidFile =
      'File không đúng định dạng sao lưu của ứng dụng.';
  static const String backupVersionTooNew =
      'File này được tạo bởi phiên bản ứng dụng mới hơn. Hãy cập nhật ứng dụng rồi thử lại.';
  static const String backupChecksumFailed =
      'File sao lưu bị hỏng hoặc đã bị sửa đổi. Không phục hồi được.';

  static const String overwriteWarningTitle = 'Ghi đè toàn bộ dữ liệu?';
  static const String overwriteWarningMessage =
      'Phục hồi sẽ XOÁ SẠCH dữ liệu hiện có và thay bằng dữ liệu trong file. '
      'Không hoàn tác được. Nếu chưa chắc, hãy tạo file sao lưu hiện tại trước.';
  static const String overwriteConfirmAction = 'Xoá và phục hồi';
  static const String overwriteBackupFirst = 'Sao lưu hiện tại trước đã';

  static const String export = 'Xuất dữ liệu';
  static const String exportExcel = 'Xuất Excel';
  static const String exportJson = 'Xuất JSON';
  static const String exportShare = 'Chia sẻ file';
  static const String exportScope = 'Phạm vi xuất';
  static const String exportDone = 'Đã xuất xong';
  static const String exportFailed = 'Xuất dữ liệu thất bại';
  static const String importData = 'Nhập dữ liệu';
  static const String importPreview = 'Xem trước dữ liệu sẽ nhập';
  static const String importRowsOk = 'Dòng hợp lệ';
  static const String importRowsError = 'Dòng lỗi';
  static const String importDone = 'Đã nhập dữ liệu';
  static const String importFailed = 'Nhập dữ liệu thất bại';

  // ══════════════════════════════════════════════════════════════════════
  // NHẬT KÝ THAO TÁC
  // ══════════════════════════════════════════════════════════════════════

  static const String activityLog = 'Nhật ký thao tác';
  static const String activityLogEmpty = 'Chưa có thao tác nào được ghi';
  static const String activityLogFilterEntity = 'Lọc theo đối tượng';
  static const String activityLogFilterAction = 'Lọc theo hành động';
  static const String activityLogClear = 'Xoá nhật ký';
  static const String activityLogClearMessage =
      'Xoá nhật ký không ảnh hưởng tới dữ liệu nghiệp vụ, chỉ mất lịch sử thao tác.';
  static const String activityLogRetention = 'Giữ nhật ký trong';

  // ══════════════════════════════════════════════════════════════════════
  // CÀI ĐẶT
  // ══════════════════════════════════════════════════════════════════════

  static const String settings = 'Cài đặt';
  static const String settingsGeneral = 'Chung';
  static const String settingsAppearance = 'Giao diện';
  static const String settingsThemeMode = 'Chế độ hiển thị';
  static const String settingsThemeLight = 'Sáng';
  static const String settingsThemeDark = 'Tối';
  static const String settingsThemeSystem = 'Theo hệ thống';
  static const String settingsTextScale = 'Cỡ chữ';
  static const String settingsDefaultRevenueMode =
      'Cách tính doanh thu mặc định';
  static const String settingsDefaultLot = 'Bãi xe mặc định';
  static const String settingsData = 'Dữ liệu';
  static const String settingsAbout = 'Giới thiệu';
  static const String settingsVersion = 'Phiên bản';
  static const String settingsOfflineNote =
      'Ứng dụng chạy hoàn toàn ngoại tuyến. Dữ liệu chỉ nằm trên máy này và không gửi đi đâu cả.';
  static const String settingsResetData = 'Xoá toàn bộ dữ liệu';
  static const String settingsResetDataMessage =
      'Toàn bộ bãi xe, xe, thanh toán, chi phí và nhật ký sẽ bị xoá vĩnh viễn.';

  // ══════════════════════════════════════════════════════════════════════
  // CÂU CÓ THAM SỐ
  // ══════════════════════════════════════════════════════════════════════

  /// `"3 xe sắp hết hạn"` — dùng cho thẻ cảnh báo ở màn hình tổng quan.
  static String vehiclesExpiringSoon(int count) => '$count xe sắp hết hạn';

  /// `"2 xe đã hết hạn"`.
  static String vehiclesExpired(int count) => '$count xe đã hết hạn';

  /// `"12/50 xe"` — số xe đang gửi trên sức chứa.
  static String occupancy(int used, int capacity) => '$used/$capacity xe';

  /// `"Gia hạn 3 tháng"`.
  static String renewMonths(int months) => 'Gia hạn $months tháng';

  /// `"Đóng cho 3 tháng"`.
  static String paidForMonths(int months) => 'Đóng cho $months tháng';

  /// Xác nhận xoá có nêu tên đối tượng, an toàn hơn hẳn câu chung chung.
  static String confirmDeleteNamed(String what) => 'Xoá "$what"?';

  /// `"Đã nhập 42 dòng, bỏ qua 3 dòng lỗi"`.
  static String importSummary(int ok, int failed) =>
      'Đã nhập $ok dòng, bỏ qua $failed dòng lỗi';

  /// `"Bãi Nguyễn Trãi · 12 xe"`.
  static String lotSubtitle(String address, int vehicleCount) =>
      address.isEmpty ? '$vehicleCount xe' : '$address · $vehicleCount xe';
}

// ════════════════════════════════════════════════════════════════════════
// NHÃN CHO CÁC KIỂU LIỆT KÊ
//
// Viết bằng `switch` biểu thức không có nhánh `default`: thêm một giá trị mới
// vào enum sẽ thành lỗi biên dịch ngay tại đây, thay vì âm thầm hiện chuỗi
// rỗng trên giao diện.
// ════════════════════════════════════════════════════════════════════════

String vehicleTypeLabel(VehicleType t) => switch (t) {
      VehicleType.motorbike => 'Xe máy',
      VehicleType.car => 'Ô tô',
      VehicleType.truck => 'Xe tải',
      VehicleType.other => 'Khác',
    };

String costCategoryLabel(CostCategory c) => switch (c) {
      CostCategory.rent => 'Tiền thuê mặt bằng',
      CostCategory.electricity => 'Điện',
      CostCategory.water => 'Nước',
      CostCategory.internet => 'Internet',
      CostCategory.security => 'Bảo vệ',
      CostCategory.staff => 'Nhân viên',
      CostCategory.repair => 'Sửa chữa',
      CostCategory.equipment => 'Thiết bị',
      CostCategory.maintenance => 'Bảo trì',
      CostCategory.other => 'Khác',
    };

String revenueModeLabel(RevenueMode m) => switch (m) {
      RevenueMode.cash => 'Thực thu',
      RevenueMode.accrual => 'Phân bổ',
    };

String reportGranularityLabel(ReportGranularity g) => switch (g) {
      ReportGranularity.day => 'Ngày',
      ReportGranularity.month => 'Tháng',
      ReportGranularity.quarter => 'Quý',
      ReportGranularity.year => 'Năm',
    };

String paymentMethodLabel(PaymentMethod m) => switch (m) {
      PaymentMethod.cash => 'Tiền mặt',
      PaymentMethod.transfer => 'Chuyển khoản',
      PaymentMethod.other => 'Khác',
    };

String vehicleStatusLabel(VehicleStatus s) => switch (s) {
      VehicleStatus.active => 'Đang gửi',
      VehicleStatus.stopped => 'Đã rời bãi',
    };

String expenseKindLabel(ExpenseKind k) => switch (k) {
      ExpenseKind.recurring => 'Cố định hàng tháng',
      ExpenseKind.adhoc => 'Phát sinh',
    };

String logEntityLabel(LogEntity e) => switch (e) {
      LogEntity.lot => 'Bãi xe',
      LogEntity.vehicle => 'Xe',
      LogEntity.payment => 'Thanh toán',
      LogEntity.expense => 'Chi phí',
      LogEntity.template => 'Mẫu chi phí',
      LogEntity.app => 'Ứng dụng',
    };

String logActionLabel(LogAction a) => switch (a) {
      LogAction.lotCreated => 'Thêm bãi xe',
      LogAction.lotUpdated => 'Sửa bãi xe',
      LogAction.lotDeleted => 'Xoá bãi xe',
      LogAction.vehicleCreated => 'Thêm xe',
      LogAction.vehicleUpdated => 'Sửa thông tin xe',
      LogAction.vehicleDeleted => 'Xoá xe',
      LogAction.vehicleMoved => 'Chuyển bãi',
      LogAction.vehicleStopped => 'Ngừng gửi xe',
      LogAction.paymentCreated => 'Ghi nhận thanh toán',
      LogAction.paymentVoided => 'Huỷ phiếu thu',
      LogAction.vehicleReminded => 'Đánh dấu đã nhắc',
      LogAction.expenseCreated => 'Thêm chi phí',
      LogAction.expenseUpdated => 'Sửa chi phí',
      LogAction.expenseDeleted => 'Xoá chi phí',
      LogAction.templateCreated => 'Thêm mẫu chi phí',
      LogAction.templateUpdated => 'Sửa mẫu chi phí',
      LogAction.templateDeleted => 'Xoá mẫu chi phí',
      LogAction.dataExported => 'Xuất dữ liệu',
      LogAction.dataImported => 'Nhập dữ liệu',
    };
