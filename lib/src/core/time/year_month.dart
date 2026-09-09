import 'day.dart';

/// Tháng kế toán, dạng `YYYY-MM`.
///
/// Đây là đơn vị gom nhóm của doanh thu phân bổ và của chi phí cố định. Lưu
/// dưới dạng chuỗi `YYYY-MM` vì nó **sắp xếp theo thứ tự từ điển đúng bằng thứ
/// tự thời gian**, nên `ORDER BY period_month` và `BETWEEN` trong SQL chạy
/// thẳng trên index mà không cần hàm chuyển đổi nào.
class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month);

  final int year;
  final int month;

  factory YearMonth.fromDay(Day d) => YearMonth(d.year, d.month);

  factory YearMonth.parse(String s) {
    if (s.length < 7) throw FormatException('Tháng không hợp lệ', s);
    return YearMonth(int.parse(s.substring(0, 4)), int.parse(s.substring(5, 7)));
  }

  /// Khoá lưu trong DB và khoá gom nhóm trong báo cáo.
  String get key =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  /// Ngày đầu tháng — dùng làm trục hoành của biểu đồ xu hướng.
  Day get firstDay => Day(year, month, 1);

  /// Tổng số tháng kể từ năm 0, để cộng trừ tháng bằng số học đơn giản.
  int get ordinal => year * 12 + (month - 1);

  YearMonth addMonths(int n) {
    final t = ordinal + n;
    return YearMonth(t ~/ 12, t % 12 + 1);
  }

  /// Số tháng từ [from] đến this, có thể âm.
  int difference(YearMonth from) => ordinal - from.ordinal;

  @override
  int compareTo(YearMonth other) => ordinal.compareTo(other.ordinal);

  bool operator <(YearMonth o) => ordinal < o.ordinal;
  bool operator <=(YearMonth o) => ordinal <= o.ordinal;
  bool operator >(YearMonth o) => ordinal > o.ordinal;
  bool operator >=(YearMonth o) => ordinal >= o.ordinal;

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => key;
}
