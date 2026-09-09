/// Chữ riêng của cụm màn hình XE, phần `Strings` chung chưa có.
///
/// Đặt ở đây thay vì bổ sung vào `core/strings/strings.dart` vì đây là câu chữ
/// chỉ ba màn hình này dùng; đưa hết lên lớp chung sẽ khiến lớp đó phình ra vì
/// những chuỗi không ai khác gọi tới. Quy tắc vẫn giữ nguyên: hằng số cho câu
/// cố định, hàm `static` cho câu có tham số.
///
/// **Luôn ưu tiên `Strings` trước.** Mọi chuỗi dưới đây đều đã được đối chiếu
/// và xác nhận là chưa có bản tương đương.
library;

abstract final class VehiclesStrings {
  // ── Bộ lọc ────────────────────────────────────────────────────────────

  /// Nhãn của `ExpiryFilter.current`. Không dùng lại `Strings.vehicleFilterActive`
  /// ("Đang gửi") vì đó là **tình trạng gửi xe** (còn trong bãi hay đã rời),
  /// một khái niệm khác hẳn với **hạn thanh toán**. Một xe có thể đang gửi mà
  /// đã quá hạn đóng tiền.
  static const String expiryCurrent = 'Còn hạn';

  /// Giá trị "không lọc" của bộ lọc bãi. Không dùng `Strings.all` ("Tất cả") vì
  /// chip lọc hạn ngay cạnh đã mang chữ đó — hai chip cùng chữ "Tất cả" nằm
  /// cạnh nhau thì không đọc ra được cái nào lọc cái gì.
  static const String allLots = 'Mọi bãi';
  static const String allTypes = 'Mọi loại xe';

  /// Nhãn nhóm cho bảng chọn bật lên từ chip lọc.
  static const String pickLotTitle = 'Lọc theo bãi xe';
  static const String pickTypeTitle = 'Lọc theo loại xe';

  // ── Trạng thái danh sách ──────────────────────────────────────────────

  /// Câu gợi ý dưới `Strings.vehicleEmpty` — trạng thái **chưa có dữ liệu**.
  static const String emptyHint =
      'Bấm nút "Thêm xe" ở góc dưới để đăng ký chiếc đầu tiên.';

  /// Câu gợi ý dưới `Strings.noResult` — trạng thái **lọc/tìm không ra**.
  /// Cố ý khác hẳn [emptyHint]: một bên là chưa nhập liệu, một bên là dữ liệu
  /// có nhưng bộ lọc đang giấu đi. Gộp hai câu sẽ khiến người dùng đi tìm nút
  /// thêm xe trong khi thứ họ cần là bỏ bộ lọc.
  static const String noResultHint =
      'Không có xe nào khớp. Thử đổi từ khoá hoặc bỏ bớt bộ lọc.';

  /// `"4 xe"` — số dòng đang hiện, để thấy ngay bộ lọc đã cắt bớt bao nhiêu.
  static String matchCount(int n) => '$n xe';

  // ── Thẻ trạng thái trên từng dòng ─────────────────────────────────────

  /// Xe **chưa từng đóng tiền**, khác hẳn xe đã đóng rồi để quá hạn.
  ///
  /// Hai việc này trông giống nhau nếu chỉ nhìn màu đỏ, nhưng cách xử lý khác
  /// nhau: xe quá hạn thì đòi tiền kỳ tiếp theo, xe chưa đóng lần nào thì phải
  /// truy thu từ ngày bắt đầu gửi. Vì vậy chúng có chữ riêng, biểu tượng riêng
  /// và kiểu thẻ riêng (viền, không tô nền).
  static const String neverPaidChip = 'Chưa thu tiền';

  /// `"Chưa đóng lần nào — gửi từ 01/08/2026"`.
  static String neverPaidSince(String day) =>
      'Chưa đóng lần nào — gửi từ $day';

  // ── Màn hình chi tiết ─────────────────────────────────────────────────

  static const String totalMonthsPaid = 'Tổng số tháng đã đóng';
  static const String totalCollected = 'Tổng đã thu';
  static const String vehicleStopEnd = 'Kết thúc gửi';
  static const String stoppedBanner = 'Xe này đã kết thúc gửi';

  /// `"5 tháng"` — giá trị của [totalMonthsPaid].
  static String monthCount(int n) => '$n tháng';

  /// Nhãn ô nhập lý do trong hộp thoại huỷ biên lai. Lý do không bắt buộc:
  /// bắt gõ lý do sẽ khiến người dùng gõ bừa một ký tự cho xong.
  static const String voidReasonLabel = 'Lý do huỷ (không bắt buộc)';

  // ── Form thêm / sửa xe ────────────────────────────────────────────────

  /// Giải thích vì sao chỉ số duy nhất chặn — chỉ số là **bộ phận**, chỉ áp
  /// dụng cho xe đang gửi, nên biển số dùng lại được sau khi xe cũ rời bãi.
  /// Không nói ra thì người dùng tưởng biển số bị khoá vĩnh viễn.
  static const String duplicatePlateHint =
      'Trong bãi này đang có một xe khác gửi với biển số đó. '
      'Biển số dùng lại được sau khi xe cũ kết thúc gửi.';

  /// Ngày bắt đầu là mốc neo chu kỳ thanh toán (`anchorDay`), đổi nó sẽ làm
  /// lệch toàn bộ các kỳ đã thu, nên form sửa khoá ô này lại.
  static const String startDateLocked =
      'Ngày bắt đầu không sửa được vì các kỳ đã thu tiền đều tính từ mốc này.';

  static const String priceFromLot = 'Điền sẵn theo giá mặc định của bãi';
}
