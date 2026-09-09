/// Một ngày theo lịch dân dụng — không giờ, không múi giờ.
///
/// Mọi mốc thời gian nghiệp vụ của ứng dụng (ngày bắt đầu gửi, ngày đóng tiền,
/// ngày hết hạn) đều là ngày dân dụng, không phải một thời điểm. Dùng thẳng
/// [DateTime] cho loại dữ liệu này sinh ra hai lớp lỗi kinh điển: hai ngày
/// giống nhau nhưng khác giờ thì so sánh ra `false`, và phép cộng ngày bị lệch
/// khi đi qua mốc đổi giờ.
///
/// Khi lưu xuống SQLite, [Day] được ánh xạ thành `DateTime.utc(y, m, d)` —
/// đúng nửa đêm UTC — nhờ vậy `strftime('%Y-%m', col, 'unixepoch')` gom nhóm
/// chính xác mà không cần modifier `'localtime'`.
class Day implements Comparable<Day> {
  const Day(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Ngày dân dụng *tại địa phương* của một [DateTime].
  factory Day.fromLocal(DateTime local) => Day(local.year, local.month, local.day);

  /// Đọc ngược từ giá trị đã lưu trong SQLite.
  factory Day.fromUtcMidnight(DateTime utc) {
    final u = utc.toUtc();
    return Day(u.year, u.month, u.day);
  }

  /// Đọc chuỗi ISO `YYYY-MM-DD`. Ném [FormatException] nếu sai định dạng.
  factory Day.parseIso(String s) {
    if (s.length < 10) throw FormatException('Ngày không hợp lệ', s);
    return Day(
      int.parse(s.substring(0, 4)),
      int.parse(s.substring(5, 7)),
      int.parse(s.substring(8, 10)),
    );
  }

  /// Biểu diễn để lưu xuống DB.
  DateTime get utcMidnight => DateTime.utc(year, month, day);

  /// Biểu diễn để hiển thị / định dạng bằng `intl`.
  DateTime get localMidnight => DateTime(year, month, day);

  /// Số ngày kể từ 1970-01-01. Vì [utcMidnight] luôn là bội số đúng của một
  /// ngày nên phép chia nguyên ở đây chính xác tuyệt đối, kể cả với mốc âm.
  int get epochDay =>
      utcMidnight.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  String get iso => '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  Day addDays(int n) => Day.fromUtcMidnight(
        DateTime.utc(year, month, day + n),
      );

  @override
  int compareTo(Day other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(Day o) => compareTo(o) < 0;
  bool operator <=(Day o) => compareTo(o) <= 0;
  bool operator >(Day o) => compareTo(o) > 0;
  bool operator >=(Day o) => compareTo(o) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Day &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}
