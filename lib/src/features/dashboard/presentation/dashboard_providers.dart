import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/enums.dart';
import '../../../core/providers.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../../dev/sample_data.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(appDatabaseProvider)),
);

/// Chế độ doanh thu đang chọn (mục 4 đặc tả).
///
/// Để ở đây thay vì trong từng màn hình để công tắc bật/tắt đổi đồng loạt cả
/// dashboard lẫn báo cáo — người dùng sẽ rất bối rối nếu hai màn hình hiển thị
/// hai con số khác nhau cho cùng một tháng.
final revenueModeProvider =
    NotifierProvider<RevenueModeNotifier, RevenueMode>(RevenueModeNotifier.new);

class RevenueModeNotifier extends Notifier<RevenueMode> {
  @override
  RevenueMode build() => RevenueMode.cash;

  void set(RevenueMode mode) => state = mode;
  void toggle() => state =
      state == RevenueMode.cash ? RevenueMode.accrual : RevenueMode.cash;
}

/// Ngưỡng "sắp hết hạn", tính bằng ngày.
final expiringSoonDaysProvider = Provider<int>((ref) => 7);

final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  // Chờ chi phí cố định của tháng được sinh xong rồi mới đọc, nếu không lần mở
  // app đầu tiên trong tháng sẽ hiện lợi nhuận thiếu chi phí.
  ref.watch(costsMaterializedProvider);
  return ref.watch(dashboardRepositoryProvider).watch(
        today: ref.watch(todayProvider),
        soonDays: ref.watch(expiringSoonDaysProvider),
        mode: ref.watch(revenueModeProvider),
      );
});

/// Danh sách xe sắp hết hạn cho màn hình tổng quan (mục 6 đặc tả).
final expiringVehiclesProvider =
    StreamProvider<List<VehicleListItem>>((ref) {
  return ref.watch(vehicleRepositoryProvider).watchList(
        VehicleFilter(
          expiry: ExpiryFilter.expiringSoon,
          soonDays: ref.watch(expiringSoonDaysProvider),
        ),
      );
});

final expiredVehiclesProvider = StreamProvider<List<VehicleListItem>>((ref) {
  return ref
      .watch(vehicleRepositoryProvider)
      .watchList(const VehicleFilter(expiry: ExpiryFilter.expired));
});

final sampleDataSeederProvider = Provider<SampleDataSeeder>(
  (ref) =>
      SampleDataSeeder(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);
