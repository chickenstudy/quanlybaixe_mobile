import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';

/// Một mốc trên báo cáo — một ngày, một tháng, một quý hoặc một năm.
class ReportPoint {
  const ReportPoint({
    required this.key,
    required this.revenue,
    required this.expense,
  });

  /// Khoá gom nhóm: `2026-08-01` · `2026-08` · `2026-Q3` · `2026`.
  final String key;
  final int revenue;
  final int expense;

  int get profit => revenue - expense;
  bool get isLoss => profit < 0;
}

class ReportResult {
  const ReportResult({
    required this.points,
    required this.granularity,
    required this.mode,
    required this.requestedGranularity,
  });

  final List<ReportPoint> points;

  /// Mốc thực sự được dùng — có thể khác [requestedGranularity], xem
  /// [granularityDowngraded].
  final ReportGranularity granularity;
  final ReportGranularity requestedGranularity;
  final RevenueMode mode;

  int get totalRevenue => points.fold(0, (s, p) => s + p.revenue);
  int get totalExpense => points.fold(0, (s, p) => s + p.expense);
  int get profit => totalRevenue - totalExpense;
  bool get isLoss => profit < 0;

  /// Người dùng chọn xem theo ngày nhưng đang ở chế độ phân bổ.
  ///
  /// Doanh thu phân bổ không có đơn vị nhỏ hơn tháng — tiền đóng 3 tháng được
  /// rải cho *tháng* 8, 9, 10 chứ không cho ngày nào cả. Thay vì vẽ biểu đồ
  /// rỗng, báo cáo tự lùi về mốc tháng và bật cờ này để giao diện nói rõ lý do.
  bool get granularityDowngraded => granularity != requestedGranularity;
}

class ReportRepository {
  ReportRepository(this._db);

  final AppDatabase _db;

  /// Báo cáo doanh thu / chi phí / lợi nhuận (mục 5 đặc tả).
  ///
  /// [to] là mốc **loại trừ**, đồng nhất với quy ước dùng khắp ứng dụng.
  Future<ReportResult> build({
    required Day from,
    required Day to,
    required ReportGranularity granularity,
    required RevenueMode mode,
    int? lotId,
  }) async {
    final effective = (mode == RevenueMode.accrual &&
            granularity == ReportGranularity.day)
        ? ReportGranularity.month
        : granularity;

    final fromYm = YearMonth.fromDay(from);
    // `to` loại trừ: một khoảng kết thúc đúng ngày 01/09 không chạm tháng 9.
    final lastDay = to.addDays(-1);
    final toYm = YearMonth.fromDay(lastDay);

    final revenue = mode == RevenueMode.cash
        ? await _cashRevenue(effective, from, to, fromYm, toYm, lotId)
        : await _accrualRevenue(effective, fromYm, toYm, lotId);

    final expense = await _expenses(effective, from, to, fromYm, toYm, lotId);

    final keys = <String>{...revenue.keys, ...expense.keys}.toList()..sort();
    return ReportResult(
      points: [
        for (final k in keys)
          ReportPoint(
            key: k,
            revenue: revenue[k] ?? 0,
            expense: expense[k] ?? 0,
          ),
      ],
      granularity: effective,
      requestedGranularity: granularity,
      mode: mode,
    );
  }

  Future<Map<String, int>> _cashRevenue(
    ReportGranularity g,
    Day from,
    Day to,
    YearMonth fromYm,
    YearMonth toYm,
    int? lotId,
  ) async {
    Expression<bool> filter($PaymentsTable p) =>
        lotId == null ? const Constant(true) : p.lotId.equals(lotId);

    switch (g) {
      case ReportGranularity.day:
        final r = await _db
            .revenueCashByDay(from: from, to: to, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.month:
        final r = await _db
            .revenueCashByMonth(from: from, to: to, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.quarter:
        final r = await _db
            .revenueCashByQuarter(from: from, to: to, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.year:
        final r = await _db
            .revenueCashByYear(from: from, to: to, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
    }
  }

  Future<Map<String, int>> _accrualRevenue(
    ReportGranularity g,
    YearMonth fromYm,
    YearMonth toYm,
    int? lotId,
  ) async {
    // Truy vấn phân bổ có JOIN nên drift sinh placeholder hai tham số.
    // Lọc trên a.lotId (đã sao chép sẵn sang bảng phân bổ) để không phải
    // chạm bảng payments.
    Expression<bool> filter($PaymentAllocationsTable a, $PaymentsTable p) =>
        lotId == null ? const Constant(true) : a.lotId.equals(lotId);

    switch (g) {
      case ReportGranularity.day:
      case ReportGranularity.month:
        final r = await _db
            .revenueAccrualByMonth(
                fromYm: fromYm.key, toYm: toYm.key, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.quarter:
        final r = await _db
            .revenueAccrualByQuarter(
                fromYm: fromYm.key, toYm: toYm.key, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.year:
        final r = await _db
            .revenueAccrualByYear(
                fromYm: fromYm.key, toYm: toYm.key, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
    }
  }

  Future<Map<String, int>> _expenses(
    ReportGranularity g,
    Day from,
    Day to,
    YearMonth fromYm,
    YearMonth toYm,
    int? lotId,
  ) async {
    Expression<bool> filter($ExpensesTable e) =>
        lotId == null ? const Constant(true) : e.lotId.equals(lotId);

    switch (g) {
      case ReportGranularity.day:
        final r =
            await _db.expensesByDay(from: from, to: to, lotFilter: filter).get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.month:
        final r = await _db
            .expensesByMonth(
                fromYm: fromYm.key, toYm: toYm.key, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.quarter:
        final r = await _db
            .expensesByQuarter(
                fromYm: fromYm.key, toYm: toYm.key, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
      case ReportGranularity.year:
        final r = await _db
            .expensesByYear(
                fromYm: fromYm.key, toYm: toYm.key, lotFilter: filter)
            .get();
        return {for (final x in r) x.ym: x.total ?? 0};
    }
  }

  /// Chi phí tách theo nhóm, cho biểu đồ tròn của màn hình chi phí.
  Future<List<({CostCategory category, int total})>> expenseBreakdown({
    required YearMonth fromYm,
    required YearMonth toYm,
    int? lotId,
  }) async {
    final r = await _db
        .expensesByCategory(
          fromYm: fromYm.key,
          toYm: toYm.key,
          lotFilter: (e) =>
              lotId == null ? const Constant(true) : e.lotId.equals(lotId),
        )
        .get();
    return [
      for (final x in r) (category: x.category, total: x.total ?? 0),
    ];
  }
}
