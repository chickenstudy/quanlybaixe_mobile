import 'package:drift/drift.dart';

import '../../time/day.dart';
import '../../time/year_month.dart';

/// Ánh xạ [Day] ↔ cột `DateTime` của Drift.
///
/// Drift lưu `DateTime` thành số nguyên epoch **giây**, nên khi ta ghi đúng
/// nửa đêm UTC thì `strftime('%Y-%m', cột, 'unixepoch')` trong SQL gom nhóm
/// chính xác theo tháng dân dụng mà không cần modifier `'localtime'` — điều
/// này giữ cho báo cáo không phụ thuộc múi giờ của máy.
class DayConverter extends TypeConverter<Day, DateTime>
    with JsonTypeConverter<Day, DateTime> {
  const DayConverter();

  @override
  Day fromSql(DateTime fromDb) => Day.fromUtcMidnight(fromDb);

  @override
  DateTime toSql(Day value) => value.utcMidnight;
}

/// Ánh xạ [YearMonth] ↔ cột `TEXT` dạng `YYYY-MM`.
class YearMonthConverter extends TypeConverter<YearMonth, String>
    with JsonTypeConverter<YearMonth, String> {
  const YearMonthConverter();

  @override
  YearMonth fromSql(String fromDb) => YearMonth.parse(fromDb);

  @override
  String toSql(YearMonth value) => value.key;
}
