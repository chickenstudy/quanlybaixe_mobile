/// Nguồn thời gian tiêm được.
///
/// Bắt buộc, không phải để cho đẹp: toàn bộ logic hết hạn, nhắc nợ và lập lịch
/// thông báo đều là hàm của "hôm nay". Gọi thẳng [DateTime.now] ở trong đó thì
/// không thể viết test cho các trường hợp biên (qua tháng, năm nhuận, quá hạn)
/// mà không đổi giờ hệ thống.
abstract class Clock {
  const Clock();
  DateTime now();
}

class SystemClock extends Clock {
  const SystemClock();
  @override
  DateTime now() => DateTime.now();
}

/// Đồng hồ đứng yên, dùng trong test.
class FixedClock extends Clock {
  const FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}
