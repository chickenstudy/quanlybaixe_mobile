import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/core/time/year_month.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';
import 'package:quan_ly_bai_xe/src/features/reports/data/report_repository.dart';

void main() {
  late AppDatabase db;
  late PaymentRepository pay;
  late ReportRepository reports;
  late int lotId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    pay = PaymentRepository(db, FixedClock(DateTime(2026, 8, 1, 9)));
    reports = ReportRepository(db);
    lotId = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi A',
          nameFold: 'bai a',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ));
  });
  tearDown(() => db.close());

  Future<int> vehicle(String plate, int price) =>
      db.into(db.vehicles).insert(VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: 'Chủ $plate',
            ownerNameFold: 'chu $plate',
            vehicleType: VehicleType.motorbike,
            plate: plate,
            plateNormalized: plate.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''),
            monthlyPrice: price,
            startDate: const Day(2026, 8, 1),
            anchorDay: 1,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ));

  Future<void> expense(String month, int amount, {String name = 'Điện'}) =>
      db.into(db.expenses).insert(ExpensesCompanion.insert(
            lotId: lotId,
            name: name,
            category: CostCategory.electricity,
            kind: ExpenseKind.adhoc,
            amount: amount,
            incurredOn: Day(int.parse(month.substring(0, 4)),
                int.parse(month.substring(5, 7)), 5),
            periodMonth: month,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ));

  /// Ví dụ tháng 8 của đặc tả.
  Future<void> seedSpecScenario() async {
    final a = await vehicle('59A-111.11', 100000);
    final b = await vehicle('59A-222.22', 100000);
    final c = await vehicle('59A-333.33', 100000);
    await pay.recordPayment(vehicleId: a, months: 1, paidAt: const Day(2026, 8, 1));
    await pay.recordPayment(vehicleId: b, months: 2, paidAt: const Day(2026, 8, 3));
    await pay.recordPayment(vehicleId: c, months: 3, paidAt: const Day(2026, 8, 5));
  }

  group('Công tắc chuyển hai chế độ doanh thu', () {
    test('THỰC THU dồn hết vào tháng 8', () async {
      await seedSpecScenario();
      final r = await reports.build(
        from: const Day(2026, 8, 1),
        to: const Day(2027, 1, 1),
        granularity: ReportGranularity.month,
        mode: RevenueMode.cash,
      );
      expect(r.points.map((p) => p.key), ['2026-08']);
      expect(r.totalRevenue, 600000);
    });

    test('PHÂN BỔ rải ra ba tháng', () async {
      await seedSpecScenario();
      final r = await reports.build(
        from: const Day(2026, 8, 1),
        to: const Day(2027, 1, 1),
        granularity: ReportGranularity.month,
        mode: RevenueMode.accrual,
      );
      expect(r.points.map((p) => p.key), ['2026-08', '2026-09', '2026-10']);
      expect(r.points.map((p) => p.revenue), [300000, 200000, 100000]);
      expect(r.totalRevenue, 600000, reason: 'tổng hai chế độ phải bằng nhau');
    });

    test('theo quý và theo năm cho cùng tổng', () async {
      await seedSpecScenario();
      for (final mode in RevenueMode.values) {
        final q = await reports.build(
          from: const Day(2026, 1, 1),
          to: const Day(2027, 1, 1),
          granularity: ReportGranularity.quarter,
          mode: mode,
        );
        final y = await reports.build(
          from: const Day(2026, 1, 1),
          to: const Day(2027, 1, 1),
          granularity: ReportGranularity.year,
          mode: mode,
        );
        expect(q.totalRevenue, 600000, reason: 'quý, chế độ $mode');
        expect(y.totalRevenue, 600000, reason: 'năm, chế độ $mode');
        expect(y.points.single.key, '2026');
      }
    });

    test('quý gom đúng nhóm tháng', () async {
      await seedSpecScenario();
      final r = await reports.build(
        from: const Day(2026, 1, 1),
        to: const Day(2027, 1, 1),
        granularity: ReportGranularity.quarter,
        mode: RevenueMode.accrual,
      );
      final byQ = {for (final p in r.points) p.key: p.revenue};
      expect(byQ['2026-Q3'], 500000, reason: 'tháng 8 + tháng 9');
      expect(byQ['2026-Q4'], 100000, reason: 'tháng 10');
    });
  });

  group('Mốc ngày ở chế độ phân bổ', () {
    test('tự lùi về mốc tháng và bật cờ báo cho giao diện', () async {
      await seedSpecScenario();
      final r = await reports.build(
        from: const Day(2026, 8, 1),
        to: const Day(2026, 9, 1),
        granularity: ReportGranularity.day,
        mode: RevenueMode.accrual,
      );
      expect(r.requestedGranularity, ReportGranularity.day);
      expect(r.granularity, ReportGranularity.month);
      expect(r.granularityDowngraded, isTrue);
    });

    test('chế độ thực thu thì mốc ngày hoạt động bình thường', () async {
      await seedSpecScenario();
      final r = await reports.build(
        from: const Day(2026, 8, 1),
        to: const Day(2026, 9, 1),
        granularity: ReportGranularity.day,
        mode: RevenueMode.cash,
      );
      expect(r.granularityDowngraded, isFalse);
      expect(r.points.map((p) => p.key),
          ['2026-08-01', '2026-08-03', '2026-08-05']);
      expect(r.points.map((p) => p.revenue), [100000, 200000, 300000]);
    });
  });

  group('Lợi nhuận', () {
    test('lợi nhuận = doanh thu - chi phí, có cả trường hợp lỗ', () async {
      await seedSpecScenario();
      await expense('2026-08', 200000);
      await expense('2026-09', 500000, name: 'Sửa chữa');

      final r = await reports.build(
        from: const Day(2026, 8, 1),
        to: const Day(2026, 11, 1),
        granularity: ReportGranularity.month,
        mode: RevenueMode.accrual,
      );
      final byMonth = {for (final p in r.points) p.key: p};
      expect(byMonth['2026-08']!.profit, 300000 - 200000);
      expect(byMonth['2026-09']!.profit, 200000 - 500000);
      expect(byMonth['2026-09']!.isLoss, isTrue, reason: 'tháng 9 lỗ 300.000');
      expect(r.totalExpense, 700000);
      expect(r.profit, 600000 - 700000);
      expect(r.isLoss, isTrue);
    });

    test('tháng chỉ có chi phí, không có doanh thu vẫn hiện trên báo cáo', () async {
      await expense('2026-08', 200000);
      final r = await reports.build(
        from: const Day(2026, 8, 1),
        to: const Day(2026, 9, 1),
        granularity: ReportGranularity.month,
        mode: RevenueMode.cash,
      );
      expect(r.points.single.key, '2026-08');
      expect(r.points.single.revenue, 0);
      expect(r.points.single.expense, 200000);
      expect(r.points.single.isLoss, isTrue);
    });
  });

  test('lọc theo bãi tách bạch số liệu', () async {
    final lotB = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi B',
          nameFold: 'bai b',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ));
    await seedSpecScenario();

    final onlyA = await reports.build(
      from: const Day(2026, 8, 1),
      to: const Day(2027, 1, 1),
      granularity: ReportGranularity.month,
      mode: RevenueMode.cash,
      lotId: lotId,
    );
    expect(onlyA.totalRevenue, 600000);

    final onlyB = await reports.build(
      from: const Day(2026, 8, 1),
      to: const Day(2027, 1, 1),
      granularity: ReportGranularity.month,
      mode: RevenueMode.cash,
      lotId: lotB,
    );
    expect(onlyB.totalRevenue, 0);
  });

  test('mốc `to` là LOẠI TRỪ — khoảng kết thúc 01/09 không chạm tháng 9', () async {
    await seedSpecScenario();
    final r = await reports.build(
      from: const Day(2026, 8, 1),
      to: const Day(2026, 9, 1),
      granularity: ReportGranularity.month,
      mode: RevenueMode.accrual,
    );
    expect(r.points.map((p) => p.key), ['2026-08']);
    expect(r.totalRevenue, 300000);
  });

  test('tách chi phí theo nhóm', () async {
    await expense('2026-08', 800000);
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
          lotId: lotId,
          name: 'Thuê mặt bằng',
          category: CostCategory.rent,
          kind: ExpenseKind.recurring,
          amount: 5000000,
          incurredOn: const Day(2026, 8, 1),
          periodMonth: '2026-08',
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));

    final b = await reports.expenseBreakdown(
        fromYm: const YearMonth(2026, 8), toYm: const YearMonth(2026, 8));
    expect(b.first.category, CostCategory.rent, reason: 'sắp giảm dần theo tiền');
    expect(b.first.total, 5000000);
    expect(b.last.category, CostCategory.electricity);
    expect(b.last.total, 800000);
  });

  test('không có dữ liệu thì báo cáo rỗng, không lỗi', () async {
    final r = await reports.build(
      from: const Day(2026, 1, 1),
      to: const Day(2027, 1, 1),
      granularity: ReportGranularity.month,
      mode: RevenueMode.cash,
    );
    expect(r.points, isEmpty);
    expect(r.totalRevenue, 0);
    expect(r.profit, 0);
    expect(r.isLoss, isFalse);
  });
}
