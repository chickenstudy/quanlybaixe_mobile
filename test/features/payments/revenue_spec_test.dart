import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';

/// Bài test nghiệm thu của mục 4 đặc tả — hai cách tính doanh thu.
void main() {
  late AppDatabase db;
  late PaymentRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PaymentRepository(db, FixedClock(DateTime(2026, 8, 1, 9)));
  });
  tearDown(() => db.close());

  group('Ví dụ tháng 8 trong đặc tả', () {
    late int lotId;

    setUp(() async {
      lotId = await _lot(db, 'Bãi Nguyễn Trãi');
    });

    test('thực thu tháng 8 = 600.000 và phân bổ = 300k/200k/100k', () async {
      final a = await _vehicle(db, lotId, 'A', '59A1-111.11', 100000);
      final b = await _vehicle(db, lotId, 'B', '59A1-222.22', 100000);
      final c = await _vehicle(db, lotId, 'C', '59A1-333.33', 100000);

      await repo.recordPayment(vehicleId: a, months: 1, paidAt: const Day(2026, 8, 1));
      await repo.recordPayment(vehicleId: b, months: 2, paidAt: const Day(2026, 8, 3));
      await repo.recordPayment(vehicleId: c, months: 3, paidAt: const Day(2026, 8, 5));

      // ── Cách 1: doanh thu thu tiền thực tế ──
      final cash = await db
          .revenueCashByMonth(from: const Day(2026, 8, 1), to: const Day(2026, 9, 1))
          .get();
      expect(cash, hasLength(1));
      expect(cash.single.ym, '2026-08');
      expect(cash.single.total, 600000,
          reason: 'đặc tả: 100.000 + 200.000 + 300.000 = 600.000');

      // ── Cách 2: doanh thu phân bổ theo tháng ──
      final accrual =
          await db.revenueAccrualByMonth(fromYm: '2026-08', toYm: '2026-12').get();
      final byMonth = {for (final r in accrual) r.ym: r.total};
      expect(byMonth['2026-08'], 300000);
      expect(byMonth['2026-09'], 200000);
      expect(byMonth['2026-10'], 100000);
      expect(byMonth['2026-11'], isNull);

      // Tổng hai cách phải bằng nhau — chỉ khác thời điểm ghi nhận.
      final totalAccrual =
          accrual.fold<int>(0, (s, r) => s + (r.total ?? 0));
      expect(totalAccrual, 600000);
    });

    test('ngày hết hạn khớp đúng ba dòng ví dụ của đặc tả', () async {
      // "Ngày bắt đầu: 01/08/2026 — đóng 1 tháng → hết hạn 01/09/2026" v.v.
      for (final (months, expected) in const [
        (1, Day(2026, 9, 1)),
        (2, Day(2026, 10, 1)),
        (3, Day(2026, 11, 1)),
      ]) {
        final v = await _vehicle(db, lotId, 'X$months', '59X$months-000.00', 100000);
        final r = await repo.recordPayment(vehicleId: v, months: months);
        expect(r.periodEnd, expected, reason: 'đóng $months tháng');

        final row = await (db.select(db.vehicles)..where((t) => t.id.equals(v)))
            .getSingle();
        expect(row.currentPeriodEnd, expected,
            reason: 'cache trên bản ghi xe phải khớp sổ cái');
      }
    });
  });

  group('Bất biến của sổ cái', () {
    test('tổng phân bổ luôn khớp tuyệt đối số tiền đã thu', () async {
      final lotId = await _lot(db, 'Bãi test');
      // 100.000 chia 3 tháng là trường hợp chia không hết.
      final v = await _vehicle(db, lotId, 'Chia lẻ', '30F-123.45', 100000);
      final r = await repo.recordPayment(
          vehicleId: v, months: 3, amountOverride: 100000);

      expect(r.amount, 100000);
      expect(r.allocations.map((a) => a.amount).toList(), [33334, 33333, 33333]);

      final sum = await db
          .customSelect('SELECT SUM(amount) AS s FROM payment_allocations')
          .getSingle();
      expect(sum.read<int>('s'), 100000, reason: 'không được lệch dù 1 đồng');
    });

    test('phân bổ rơi vào các tháng phân biệt kể cả khi bắt đầu ngày 31', () async {
      final lotId = await _lot(db, 'Bãi test');
      final v = await _vehicle(db, lotId, 'Cuối tháng', '30G-999.99', 100000,
          start: const Day(2026, 1, 31));
      await repo.recordPayment(vehicleId: v, months: 3);

      final months = await db
          .customSelect(
              'SELECT period_month AS m FROM payment_allocations ORDER BY m')
          .map((r) => r.read<String>('m'))
          .get();
      expect(months, ['2026-01', '2026-02', '2026-03']);
    });

    test('gia hạn nối liền kỳ trước, không hở ngày nào', () async {
      final lotId = await _lot(db, 'Bãi test');
      final v = await _vehicle(db, lotId, 'Nối kỳ', '51A-100.00', 200000);

      final k1 = await repo.recordPayment(vehicleId: v, months: 3);
      expect(k1.periodEnd, const Day(2026, 11, 1));

      final k2 = await repo.recordPayment(vehicleId: v, months: 6);
      expect(k2.periodStart, k1.periodEnd, reason: 'mốc loại trừ nối liền mạch');
      expect(k2.periodEnd, const Day(2027, 5, 1));

      final row =
          await (db.select(db.vehicles)..where((t) => t.id.equals(v))).getSingle();
      expect(row.totalMonthsPaid, 9);
      expect(row.totalPaid, 200000 * 9);
    });

    test('kẹp cuối tháng HỒI PHỤC qua nhiều lần gia hạn', () async {
      final lotId = await _lot(db, 'Bãi test');
      final v = await _vehicle(db, lotId, 'Ngày 31', '51B-313.13', 100000,
          start: const Day(2026, 12, 31));

      expect((await repo.recordPayment(vehicleId: v, months: 1)).periodEnd,
          const Day(2027, 1, 31));
      expect((await repo.recordPayment(vehicleId: v, months: 1)).periodEnd,
          const Day(2027, 2, 28), reason: 'tháng 2 buộc phải kẹp');
      expect((await repo.recordPayment(vehicleId: v, months: 1)).periodEnd,
          const Day(2027, 3, 31), reason: 'phải quay lại ngày 31, không dính ở 28');
    });
  });

  group('Huỷ biên lai', () {
    test('biên lai đã huỷ biến khỏi CẢ HAI chế độ doanh thu', () async {
      final lotId = await _lot(db, 'Bãi test');
      final v = await _vehicle(db, lotId, 'Bấm nhầm', '59Z-000.01', 100000);
      final r = await repo.recordPayment(
          vehicleId: v, months: 3, paidAt: const Day(2026, 8, 10));

      await repo.voidPayment(r.paymentId, reason: 'bấm nhầm');

      final cash = await db
          .revenueCashByMonth(from: const Day(2026, 8, 1), to: const Day(2026, 9, 1))
          .get();
      expect(cash, isEmpty);

      final accrual =
          await db.revenueAccrualByMonth(fromYm: '2026-01', toYm: '2026-12').get();
      expect(accrual, isEmpty, reason: 'phép join đã lọc voidedAt IS NULL');
    });

    test('huỷ biên lai thì hạn của xe lùi lại đúng', () async {
      final lotId = await _lot(db, 'Bãi test');
      final v = await _vehicle(db, lotId, 'Hoàn tác', '59Z-000.02', 100000);

      final k1 = await repo.recordPayment(vehicleId: v, months: 3);
      final k2 = await repo.recordPayment(vehicleId: v, months: 3);
      expect(k2.periodEnd, const Day(2027, 2, 1));

      await repo.voidPayment(k2.paymentId);

      final row =
          await (db.select(db.vehicles)..where((t) => t.id.equals(v))).getSingle();
      expect(row.currentPeriodEnd, k1.periodEnd);
      expect(row.totalMonthsPaid, 3);
      expect(await repo.findVehiclesWithStaleCache(), isEmpty);
    });

    test('huỷ hai lần không gây hại', () async {
      final lotId = await _lot(db, 'Bãi test');
      final v = await _vehicle(db, lotId, 'Huỷ đôi', '59Z-000.03', 100000);
      final r = await repo.recordPayment(vehicleId: v, months: 1);
      await repo.voidPayment(r.paymentId);
      await repo.voidPayment(r.paymentId);
      expect(await repo.findVehiclesWithStaleCache(), isEmpty);
    });
  });

  group('Ảnh chụp lịch sử', () {
    test('chuyển xe sang bãi khác KHÔNG viết lại doanh thu bãi cũ', () async {
      final lotA = await _lot(db, 'Bãi A');
      final lotB = await _lot(db, 'Bãi B');
      final v = await _vehicle(db, lotA, 'Chuyển bãi', '92A-555.55', 100000);
      await repo.recordPayment(vehicleId: v, months: 2, paidAt: const Day(2026, 8, 1));

      await (db.update(db.vehicles)..where((t) => t.id.equals(v)))
          .write(VehiclesCompanion(lotId: Value(lotB), updatedAt: Value(DateTime.now())));

      final aRev = await db
          .revenueCashByMonth(
            from: const Day(2026, 8, 1),
            to: const Day(2026, 9, 1),
            lotFilter: (p) => p.lotId.equals(lotA),
          )
          .get();
      expect(aRev.single.total, 200000,
          reason: 'tiền đã thu ở bãi A phải ở lại bãi A');

      final bRev = await db
          .revenueCashByMonth(
            from: const Day(2026, 8, 1),
            to: const Day(2026, 9, 1),
            lotFilter: (p) => p.lotId.equals(lotB),
          )
          .get();
      expect(bRev, isEmpty, reason: 'bãi B chưa từng thu đồng nào');
    });

    test('tăng giá bãi không làm đổi biên lai cũ', () async {
      final lotId = await _lot(db, 'Bãi test');
      final v = await _vehicle(db, lotId, 'Giá cũ', '92B-111.11', 100000);
      final r1 = await repo.recordPayment(vehicleId: v, months: 1);
      expect(r1.amount, 100000);

      await (db.update(db.vehicles)..where((t) => t.id.equals(v))).write(
          VehiclesCompanion(
              monthlyPrice: const Value(150000), updatedAt: Value(DateTime.now())));
      final r2 = await repo.recordPayment(vehicleId: v, months: 1);
      expect(r2.amount, 150000);

      final old = await (db.select(db.payments)
            ..where((p) => p.id.equals(r1.paymentId)))
          .getSingle();
      expect(old.unitPrice, 100000, reason: 'đơn giá là ảnh chụp lúc thu');
      expect(old.amount, 100000);
    });
  });

  test('mọi thao tác đều để lại nhật ký', () async {
    final lotId = await _lot(db, 'Bãi test');
    final v = await _vehicle(db, lotId, 'Nhật ký', '99A-123.45', 100000);
    final r = await repo.recordPayment(vehicleId: v, months: 2);
    await repo.voidPayment(r.paymentId, reason: 'khách đổi ý');

    final logs = await db.select(db.activityLog).get();
    expect(logs, hasLength(2));
    expect(logs.first.action, LogAction.paymentCreated);
    expect(logs.first.summary, contains('99A-123.45'));
    expect(logs.last.action, LogAction.paymentVoided);
    expect(logs.last.summary, contains('khách đổi ý'));
  });
}

// ─────────────────────── helper dựng dữ liệu ───────────────────────

Future<int> _lot(AppDatabase db, String name) => db.into(db.lots).insert(
      LotsCompanion.insert(
        name: name,
        nameFold: name.toLowerCase(),
        createdAt: DateTime.utc(2026, 8, 1),
        updatedAt: DateTime.utc(2026, 8, 1),
      ),
    );

Future<int> _vehicle(
  AppDatabase db,
  int lotId,
  String owner,
  String plate,
  int price, {
  Day start = const Day(2026, 8, 1),
}) =>
    db.into(db.vehicles).insert(
          VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: owner,
            ownerNameFold: owner.toLowerCase(),
            vehicleType: VehicleType.motorbike,
            plate: plate,
            plateNormalized: plate.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''),
            monthlyPrice: price,
            startDate: start,
            anchorDay: start.day,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
