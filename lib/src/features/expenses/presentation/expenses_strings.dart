/// Chữ riêng của cụm màn hình CHI PHÍ.
///
/// Chỉ khai ở đây những câu **chưa có** trong `Strings`. Nhãn ô nhập, tiêu đề
/// màn hình, tên nhóm chi phí… đều lấy từ `Strings` để một ngày đổi cách xưng
/// hô thì chỉ phải sửa một chỗ.
library;

abstract final class ExpensesStrings {
  // ── Màn hình chi phí ──

  /// Nhãn của con số nổi bật trên đầu. `Strings.dashboardExpenseThisMonth`
  /// ("Chi phí tháng này") sai nghĩa ở đây vì màn hình xem được cả tháng cũ.
  static const String monthTotal = 'Tổng chi phí tháng';

  /// Chú thích của nút lùi/tới tháng. `Strings.lastMonth` đã có sẵn cho chiều
  /// lùi, chiều tới thì chưa.
  static const String nextMonth = 'Tháng sau';

  /// Chip bỏ lọc bãi. `Strings.all` ("Tất cả") đứng cạnh tên các bãi thì mơ
  /// hồ — "tất cả" cái gì.
  static const String allLots = 'Tất cả bãi';

  /// Nhãn nhẹ trên dòng chi phí sinh từ mẫu mà người dùng chưa xác nhận số
  /// thật. Viết thường vì nó là chú thích, không phải trạng thái cần hét lên.
  static const String estimate = 'ước tính';

  static const String estimateHint =
      'Số tiền lấy theo mẫu, chưa đối chiếu hoá đơn thật. Chạm vào để sửa lại '
      'đúng số của tháng này.';

  static const String emptyHint =
      'Ghi tiền thuê mặt bằng, điện, nước, sửa chữa… vào đây thì con số lãi lỗ '
      'của tháng mới đúng.';

  /// Trạng thái rỗng khi chưa có bãi nào: thêm chi phí lúc này là bất khả thi
  /// vì mỗi khoản chi bắt buộc thuộc về một bãi.
  static const String needLotFirst =
      'Hãy tạo bãi xe trước, mỗi khoản chi đều phải thuộc về một bãi.';

  // ── Bảng thêm/sửa chi phí ──

  /// Vì sao có thêm ô "Tháng áp dụng" bên cạnh "Ngày chi" — không giải thích
  /// thì người dùng sẽ tưởng hai ô này trùng nhau và bỏ qua.
  static const String periodMonthHelp =
      'Tháng hạch toán khoản chi. Hoá đơn điện tháng 8 trả ngày 03/09 vẫn để '
      'tháng 8 thì lãi lỗ từng tháng mới đúng.';

  static const String periodPrevious = 'Lùi tháng áp dụng';
  static const String periodNext = 'Tới tháng áp dụng';

  // ── Mẫu chi phí cố định ──

  static const String templateName = 'Tên khoản chi';
  static const String templateNameHint = 'Ví dụ: Tiền điện, Tiền thuê mặt bằng';

  static const String templateEmpty = 'Chưa có mẫu chi phí cố định nào';
  static const String templateEmptyHint =
      'Khai tiền thuê, điện, nước… một lần. Mỗi tháng ứng dụng tự ghi thành '
      'chi phí, bạn chỉ việc sửa lại số tiền thật khi có hoá đơn.';

  static const String dayOfMonth = 'Ngày trong tháng';
  static const String dayOfMonthHelp =
      'Từ 1 đến 28, để tháng nào cũng có ngày này.';
  static const String dayOfMonthError = 'Ngày phải từ 1 đến 28';

  static const String startMonth = 'Tháng bắt đầu';
  static const String startPrevious = 'Lùi tháng bắt đầu';
  static const String startNext = 'Tới tháng bắt đầu';

  static const String endMonth = 'Tháng kết thúc';
  static const String endPrevious = 'Lùi tháng kết thúc';
  static const String endNext = 'Tới tháng kết thúc';

  static const String ongoing = 'Còn hiệu lực';
  static const String ongoingHint =
      'Bật khi khoản chi này chưa biết bao giờ dừng.';
  static const String endBeforeStartError =
      'Tháng kết thúc phải từ tháng bắt đầu trở đi';

  /// Công tắc bật/tắt mẫu. `Strings.expenseTemplateActive` ("Đang áp dụng") là
  /// nhãn trạng thái trên thẻ, còn đây là nhãn của công tắc trong form.
  static const String templateEnabled = 'Đang áp dụng mẫu này';
  static const String templateEnabledHint =
      'Tắt thì từ tháng sau không sinh thêm chi phí nữa. Các tháng đã sinh vẫn '
      'giữ nguyên.';

  /// Câu xác nhận xoá mẫu. Phải nói thẳng cái người dùng sợ nhất — mất sổ chi
  /// phí cũ — vì họ sẽ không dám bấm nếu không chắc.
  static const String deleteTemplateMessage =
      'Chi phí đã ghi của các tháng trước VẪN GIỮ NGUYÊN — tiền đó đã thực sự '
      'chi ra. Chỉ từ nay mẫu này không sinh thêm dòng nào nữa.';

  // ── Câu có tham số ──

  /// `"Tháng 9/2026 → còn hiệu lực"` hoặc `"Tháng 9/2026 → Tháng 12/2026"`.
  static String templateRange(String from, String? to) =>
      to == null ? '$from → còn hiệu lực' : '$from → $to';

  /// `"800.000 ₫/tháng"`.
  static String amountPerMonth(String money) => '$money/tháng';

  /// `"Điện · 03/09/2026"` — nhóm chi phí và ngày chi trên một dòng phụ.
  static String categoryAndDay(String category, String day) =>
      '$category · $day';

  /// `"Điện · 03/09/2026 · Bãi Nguyễn Trãi"` — thêm tên bãi khi đang xem tất
  /// cả các bãi, bỏ đi khi đã lọc vì lúc đó nó lặp lại trên từng dòng.
  static String categoryDayLot(String category, String day, String lot) =>
      '$category · $day · $lot';
}
