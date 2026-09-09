import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../vehicles/data/vehicle_repository.dart';

/// Ba nhóm nhắc thu tiền của mục 10 đặc tả.
enum ReminderRange { today, week, month }

/// Số ngày tính tới hết nhóm, kể từ hôm nay.
///
/// "Tuần này" và "tháng này" hiểu theo nghĩa **7 ngày tới** và **30 ngày tới**,
/// không phải theo mốc lịch. Chủ bãi hỏi "tuần này còn ai phải thu" vào thứ
/// Năm là muốn biết cả sang thứ Ba tuần sau, chứ không phải chỉ tới Chủ nhật.
int rangeDays(ReminderRange r) => switch (r) {
      ReminderRange.today => 0,
      ReminderRange.week => 7,
      ReminderRange.month => 30,
    };

// Riverpod 3.x đã BỎ `StateProvider`. Dùng `NotifierProvider`, đồng nhất với
// `revenueModeProvider`.
final reminderRangeProvider =
    NotifierProvider<ReminderRangeNotifier, ReminderRange>(
        ReminderRangeNotifier.new);

class ReminderRangeNotifier extends Notifier<ReminderRange> {
  @override
  ReminderRange build() => ReminderRange.week;

  void set(ReminderRange r) => state = r;
}

/// Xe cần thu tiền trong nhóm đang chọn.
///
/// **Luôn bao gồm xe đã quá hạn**, ở mọi nhóm: một xe trễ ba ngày mà biến mất
/// khỏi danh sách "hôm nay" thì đúng là thứ dễ bị quên nhất, mà lại là thứ cần
/// đòi nhất.
final remindersProvider =
    StreamProvider.family<List<VehicleListItem>, ReminderRange>((ref, range) {
  final days = rangeDays(range);
  return ref.watch(vehicleRepositoryProvider).watchList(
        VehicleFilter(
          expiry: ExpiryFilter.all,
          soonDays: days,
        ),
      ).map((items) {
    final today = ref.read(todayProvider);
    final limit = today.addDays(days);
    return items.where((it) {
      final end = it.vehicle.currentPeriodEnd;
      if (end == null) return true; // chưa đóng lần nào -> luôn cần thu
      return end <= limit;
    }).toList()
      ..sort(_byUrgency);
  });
});

/// Quá hạn lâu nhất lên đầu, rồi tới sắp hết hạn gần nhất.
int _byUrgency(VehicleListItem a, VehicleListItem b) {
  final ea = a.vehicle.currentPeriodEnd;
  final eb = b.vehicle.currentPeriodEnd;
  if (ea == null && eb == null) return a.vehicle.plate.compareTo(b.vehicle.plate);
  if (ea == null) return -1;
  if (eb == null) return 1;
  return ea.compareTo(eb);
}

/// Tổng tiền dự kiến thu được nếu gia hạn 1 tháng cho toàn bộ nhóm.
int expectedTotal(List<VehicleListItem> items) =>
    items.fold(0, (sum, it) => sum + it.vehicle.monthlyPrice);
