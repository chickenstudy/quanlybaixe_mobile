import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';

/// Các con số của màn hình tổng quan (mục 6 đặc tả).
class DashboardSummary {
  const DashboardSummary({
    required this.lotCount,
    required this.activeVehicles,
    required this.expiringSoon,
    required this.expired,
    required this.neverPaid,
    required this.revenueThisMonth,
    required this.expenseThisMonth,
    required this.capacity,
  });

  final int lotCount;
  final int activeVehicles;
  final int expiringSoon;
  final int expired;

  /// Xe đã đăng ký nhưng chưa từng đóng tiền. Tách khỏi [expired] vì đây là
  /// việc khác hẳn: chưa thu lần nào, không phải trễ hạn gia hạn.
  final int neverPaid;

  final int revenueThisMonth;
  final int expenseThisMonth;

  /// Tổng sức chứa của các bãi có khai báo. `null` khi không bãi nào khai báo.
  final int? capacity;

  int get profitThisMonth => revenueThisMonth - expenseThisMonth;
  bool get isLoss => profitThisMonth < 0;

  double? get occupancyRate {
    final cap = capacity;
    if (cap == null || cap <= 0) return null;
    return activeVehicles / cap;
  }

  static const empty = DashboardSummary(
    lotCount: 0,
    activeVehicles: 0,
    expiringSoon: 0,
    expired: 0,
    neverPaid: 0,
    revenueThisMonth: 0,
    expenseThisMonth: 0,
    capacity: null,
  );
}

class DashboardRepository {
  DashboardRepository(this._db);

  final AppDatabase _db;

  /// Toàn bộ số liệu tổng quan trong **một** truy vấn.
  ///
  /// Gộp lại thay vì gọi bảy truy vấn riêng vì màn hình này vẽ lại mỗi khi bất
  /// kỳ bảng nào đổi; bảy stream riêng sẽ khiến một lần thu tiền kéo theo bảy
  /// lượt vẽ lại lệch nhau, và người dùng thấy các ô số nhảy so le.
  Stream<DashboardSummary> watch({
    required Day today,
    required int soonDays,
    required RevenueMode mode,
  }) {
    final month = YearMonth.fromDay(today);
    final soon = today.addDays(soonDays);

    // Doanh thu tháng này đổi công thức theo chế độ đang chọn (mục 4 đặc tả).
    final revenueSql = mode == RevenueMode.cash
        ? '''
          (SELECT COALESCE(SUM(amount), 0) FROM payments
            WHERE voided_at IS NULL
              AND strftime('%Y-%m', paid_at, 'unixepoch') = ?4)
          '''
        : '''
          (SELECT COALESCE(SUM(a.amount), 0) FROM payment_allocations a
            JOIN payments p ON p.id = a.payment_id AND p.voided_at IS NULL
            WHERE a.period_month = ?4)
          ''';

    return _db.customSelect(
      '''
      SELECT
        (SELECT COUNT(*) FROM lots WHERE deleted_at IS NULL AND is_active = 1)
          AS lot_count,
        (SELECT COUNT(*) FROM vehicles
          WHERE deleted_at IS NULL AND status = 0) AS active_vehicles,
        (SELECT COUNT(*) FROM vehicles
          WHERE deleted_at IS NULL AND status = 0
            AND current_period_end > ?1 AND current_period_end <= ?2)
          AS expiring_soon,
        (SELECT COUNT(*) FROM vehicles
          WHERE deleted_at IS NULL AND status = 0
            AND current_period_end IS NOT NULL AND current_period_end <= ?1)
          AS expired,
        (SELECT COUNT(*) FROM vehicles
          WHERE deleted_at IS NULL AND status = 0 AND current_period_end IS NULL)
          AS never_paid,
        $revenueSql AS revenue,
        (SELECT COALESCE(SUM(amount), 0) FROM expenses
          WHERE deleted_at IS NULL AND period_month = ?4) AS expense,
        (SELECT SUM(capacity) FROM lots
          WHERE deleted_at IS NULL AND is_active = 1 AND capacity IS NOT NULL)
          AS capacity
      ''',
      variables: [
        Variable.withDateTime(today.utcMidnight),
        Variable.withDateTime(soon.utcMidnight),
        Variable.withInt(0), // giữ chỗ, để các ?N phía sau không đổi số
        Variable.withString(month.key),
      ],
      readsFrom: {
        _db.lots,
        _db.vehicles,
        _db.payments,
        _db.paymentAllocations,
        _db.expenses,
      },
    ).watchSingle().map((r) => DashboardSummary(
          lotCount: r.read<int>('lot_count'),
          activeVehicles: r.read<int>('active_vehicles'),
          expiringSoon: r.read<int>('expiring_soon'),
          expired: r.read<int>('expired'),
          neverPaid: r.read<int>('never_paid'),
          revenueThisMonth: r.read<int>('revenue'),
          expenseThisMonth: r.read<int>('expense'),
          capacity: r.read<int?>('capacity'),
        ));
  }
}
