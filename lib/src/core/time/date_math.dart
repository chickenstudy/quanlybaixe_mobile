import 'dart:math' as math;

import 'day.dart';

/// Số ngày của [month] trong [year]. `daysInMonth(2028, 2) == 29`.
///
/// Thủ thuật: ngày 0 của tháng sau chính là ngày cuối của tháng này.
int daysInMonth(int year, int month) => DateTime.utc(year, month + 1, 0).day;

/// Cộng [months] tháng vào [d], **kẹp** ngày về ngày cuối tháng khi tràn.
///
/// Dart không kẹp: `DateTime(2026, 2, 31)` tự tràn thành 03/03/2026. Toàn bộ
/// nghiệp vụ hết hạn của ứng dụng phụ thuộc vào việc kẹp đúng, nên phép này
/// phải viết tay.
///
/// ```
/// addMonthsClamped(Day(2026, 1, 31), 1) == Day(2026, 2, 28)
/// addMonthsClamped(Day(2028, 1, 31), 1) == Day(2028, 2, 29)  // năm nhuận
/// addMonthsClamped(Day(2026, 8,  1), 3) == Day(2026, 11, 1)  // ví dụ đặc tả
/// ```
///
/// **Cảnh báo — phép này KHÔNG có tính kết hợp.** Cộng dồn từng tháng cho kết
/// quả khác cộng một lần tổng số tháng:
///
/// ```
/// addMonthsClamped(addMonthsClamped(Day(2026,1,31), 1), 1) == Day(2026, 3, 28)
/// addMonthsClamped(Day(2026,1,31), 2)                      == Day(2026, 3, 31)
/// ```
///
/// Vì vậy ngày hết hạn **luôn phải tính một lần** từ đầu kỳ với tổng số tháng,
/// tuyệt đối không lặp cộng từng tháng. Đây cũng là lý do bản ghi thanh toán
/// bắt buộc lưu cả `periodStart` lẫn `monthsPaid`.
Day addMonthsClamped(Day d, int months) {
  final total = d.year * 12 + (d.month - 1) + months;
  final y = total ~/ 12;
  final m = total % 12 + 1;
  return Day(y, m, math.min(d.day, daysInMonth(y, m)));
}

/// Mốc kết thúc **loại trừ** của một kỳ đã đóng tiền — tức ngày đầu tiên
/// *không* còn được bao phủ.
///
/// Loại trừ chứ không phải bao gồm, vì hai lý do:
///
/// 1. Khớp đúng câu chữ của đặc tả: bắt đầu 01/08/2026, đóng 3 tháng thì
///    "hết hạn 01/11/2026" — chính là giá trị trả về.
/// 2. Việc nối kỳ trở nên sạch tuyệt đối: `periodStart` của lần đóng sau
///    **chính là** `periodEnd` của lần đóng trước, không cộng trừ 1 ngày ở
///    bất kỳ đâu.
///
/// [anchorDay] là ngày trong tháng của `startDate` gốc trên bản ghi xe, chứ
/// không phải `periodStart.day`. Nếu tính từ `periodStart.day`, cái kẹp ngày
/// sẽ **dính vĩnh viễn**: một xe bắt đầu ngày 31 sau khi đi qua tháng 2 sẽ tụt
/// về ngày 28 và ở đó mãi mãi. Neo vào ngày gốc thì nó hồi phục:
///
/// ```
/// 31/12 → 31/01 → 28/02 → 31/03
/// ```
///
/// Đây cũng là cách các dịch vụ thuê bao (Stripe, App Store) tính chu kỳ.
Day periodEndFor({
  required Day periodStart,
  required int months,
  required int anchorDay,
}) {
  assert(months >= 1, 'Số tháng đóng phải >= 1');
  assert(anchorDay >= 1 && anchorDay <= 31, 'anchorDay phải trong 1..31');
  final total = periodStart.year * 12 + (periodStart.month - 1) + months;
  final y = total ~/ 12;
  final m = total % 12 + 1;
  return Day(y, m, math.min(anchorDay, daysInMonth(y, m)));
}

/// Số ngày còn lại tính tới hạn.
///
/// `> 0` còn N ngày · `0` hết hạn hôm nay · `< 0` đã quá hạn N ngày.
int daysRemaining(Day today, Day periodEnd) =>
    periodEnd.epochDay - today.epochDay;

/// Đã hết hạn hay chưa. [periodEnd] là mốc loại trừ nên ngày bằng đúng
/// [periodEnd] đã tính là hết hạn.
bool isExpired(Day today, Day periodEnd) => today >= periodEnd;
