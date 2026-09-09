/// Định dạng ngày tháng tiếng Việt cho giao diện.
///
/// **Cố tình không dùng `DateFormat` của `intl`.** Định dạng theo locale trong
/// `intl` đòi hỏi `initializeDateFormatting('vi')` chạy xong trước lần gọi đầu
/// tiên; quên một lần là ném `LocaleDataException` ngay giữa màn hình, và cái
/// bẫy đó rơi vào test hoặc vào isolate nền chứ hiếm khi rơi vào `main`. Mọi
/// khuôn ngày của ứng dụng này đều là số thuần `dd/MM/yyyy`, ghép bằng
/// `padLeft` là đủ — đổi lấy sự chắc chắn tuyệt đối, không phụ thuộc khởi tạo,
/// không tra bảng locale, không có gì để hỏng.
///
/// Tên tháng tiếng Việt cũng chỉ là "Tháng " + số, nên chẳng có dữ liệu locale
/// nào cần đến thật.
library;

import '../time/day.dart';
import '../time/year_month.dart';

String _pad2(int n) => n.toString().padLeft(2, '0');
String _pad4(int n) => n.toString().padLeft(4, '0');

/// `Day(2026, 8, 1)` → `"01/08/2026"`.
///
/// Ngày đứng trước tháng, đúng thói quen đọc của người Việt. Luôn đủ hai chữ
/// số để các cột ngày trong bảng thẳng hàng.
String formatDay(Day d) => '${_pad2(d.day)}/${_pad2(d.month)}/${_pad4(d.year)}';

/// `Day(2026, 8, 1)` → `"01/08"`.
///
/// Dùng cho nhãn trục biểu đồ và danh sách trong cùng một năm, nơi bốn chữ số
/// năm chỉ lặp lại vô ích và ăn mất chỗ.
String formatDayShort(Day d) => '${_pad2(d.day)}/${_pad2(d.month)}';

/// `YearMonth(2026, 8)` → `"Tháng 8/2026"`.
///
/// Số tháng **không** đệm 0: người Việt nói "tháng 8", không nói "tháng 08".
String formatMonth(YearMonth m) => 'Tháng ${m.month}/${_pad4(m.year)}';

/// `"2026-Q3"` → `"Quý 3/2026"`.
///
/// Nhận vào khoá quý do lớp báo cáo sinh ra (dạng `YYYY-Qn`) chứ không nhận
/// [YearMonth], vì quý là mốc gom nhóm chỉ tồn tại trong kết quả truy vấn.
///
/// Ném [FormatException] nếu khoá sai khuôn — hỏng dữ liệu báo cáo phải lộ ra
/// ngay chứ không được lặng lẽ hiện một chuỗi vô nghĩa.
String formatQuarterKey(String key) {
  if (key.length != 7 || key[4] != '-' || (key[5] != 'Q' && key[5] != 'q')) {
    throw FormatException('Khoá quý không hợp lệ', key);
  }
  final year = int.tryParse(key.substring(0, 4));
  final quarter = int.tryParse(key.substring(6, 7));
  if (year == null || quarter == null || quarter < 1 || quarter > 4) {
    throw FormatException('Khoá quý không hợp lệ', key);
  }
  return 'Quý $quarter/${_pad4(year)}';
}

/// `2026` → `"Năm 2026"`. Nhãn mốc gom nhóm theo năm của báo cáo.
String formatYear(int year) => 'Năm ${_pad4(year)}';

/// Diễn giải kết quả của `daysRemaining` thành câu tiếng Việt.
///
/// ```
/// formatDaysRemaining(3)  == 'còn 3 ngày'
/// formatDaysRemaining(0)  == 'hết hạn hôm nay'
/// formatDaysRemaining(-5) == 'quá hạn 5 ngày'
/// ```
///
/// Số 0 có câu riêng chứ không phải "còn 0 ngày": ngày hết hạn là mốc **loại
/// trừ** (xem `periodEndFor`), nên hôm nay xe đã không còn được bao phủ nữa —
/// "còn 0 ngày" gợi ý sai rằng vẫn còn hạn.
///
/// Tiếng Việt không chia số nhiều nên "1 ngày" và "3 ngày" viết như nhau; đây
/// chính là lý do dự án không cần tới `gen_l10n` với các quy tắc plural.
String formatDaysRemaining(int days) {
  if (days > 0) return 'còn $days ngày';
  if (days == 0) return 'hết hạn hôm nay';
  return 'quá hạn ${-days} ngày';
}

/// `DateTime(2026, 8, 1, 14, 30)` → `"01/08/2026 14:30"`.
///
/// Dùng cho nhật ký thao tác và dấu thời gian sao lưu — những chỗ cần biết
/// **thời điểm** chứ không chỉ ngày. Giờ 24 tiếng, không SA/CH, vì cột giờ hai
/// chữ số so sánh bằng mắt nhanh hơn hẳn.
///
/// [dt] được hiểu theo đúng múi giờ nó đang mang: mốc lưu trong DB là UTC nên
/// nơi gọi phải `.toLocal()` trước, không thì nhật ký lệch 7 tiếng.
String formatDateTime(DateTime dt) =>
    '${_pad2(dt.day)}/${_pad2(dt.month)}/${_pad4(dt.year)} '
    '${_pad2(dt.hour)}:${_pad2(dt.minute)}';

/// `DateTime(2026, 8, 1, 14, 30)` → `"14:30"`.
String formatTime(DateTime dt) => '${_pad2(dt.hour)}:${_pad2(dt.minute)}';

/// Khoảng ngày dạng `"01/08/2026 – 31/08/2026"`, dùng cho tiêu đề báo cáo.
///
/// Gạch nối dài (–) chứ không phải gạch ngang thường, để không lẫn với dấu trừ
/// của số tiền âm đứng ngay cạnh trong cùng một dòng.
String formatDayRange(Day from, Day to) =>
    '${formatDay(from)} – ${formatDay(to)}';
