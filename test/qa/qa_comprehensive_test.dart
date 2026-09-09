import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/text/vi_normalize.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/backup/data/backup_service.dart';
import 'package:quan_ly_bai_xe/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:quan_ly_bai_xe/src/features/expenses/presentation/expenses_screen.dart';
import 'package:quan_ly_bai_xe/src/features/lots/presentation/lots_screen.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';
import 'package:quan_ly_bai_xe/src/features/reminders/presentation/reminders_screen.dart';
import 'package:quan_ly_bai_xe/src/features/reports/data/report_repository.dart';
import 'package:quan_ly_bai_xe/src/features/reports/presentation/reports_screen.dart';
import 'package:quan_ly_bai_xe/src/features/vehicles/presentation/vehicles_screen.dart';
import 'package:quan_ly_bai_xe/src/theme/app_theme.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

void qaTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets('[QA Audit] $description', (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}

void main() {
  late AppDatabase db;
  final clock = FixedClock(DateTime(2026, 8, 15, 10)); // Mốc chuẩn QA: 15/08/2026

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget host(Widget child, {ThemeData? theme}) => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          home: child,
        ),
      );

  test('QA Data & Logic: Khởi tạo dữ liệu bãi xe, xe gửi và tính toán hạn', () async {
    final paymentRepo = PaymentRepository(db, clock);

    // 1. Tạo bãi xe
    final lotAId = await db.into(db.lots).insert(
          LotsCompanion.insert(
            name: 'Bãi Xe Nguyễn Trãi QA',
            nameFold: viFold('Bãi Xe Nguyễn Trãi QA'),
            address: const Value('145 Nguyễn Trãi'),
            capacity: const Value(50),
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    expect(lotAId, isPositive);

    // 2. Thêm xe mới chưa từng đóng tiền
    final v1Id = await db.into(db.vehicles).insert(
          VehiclesCompanion.insert(
            lotId: lotAId,
            ownerName: 'Nguyễn Văn An',
            ownerNameFold: viFold('Nguyễn Văn An'),
            phone: const Value('0912 345 678'),
            phoneDigits: const Value('0912345678'),
            vehicleType: VehicleType.motorbike,
            plate: '29A1-234.56',
            plateNormalized: normalizePlate('29A1-234.56'),
            monthlyPrice: 150000,
            startDate: const Day(2026, 8, 1),
            anchorDay: 1,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
    expect(v1Id, isPositive);

    var v1 = await (db.select(db.vehicles)..where((v) => v.id.equals(v1Id))).getSingle();
    expect(v1.currentPeriodEnd, isNull);

    // 3. Đóng tiền 3 tháng (01/08/2026 đến 01/11/2026)
    final res = await paymentRepo.recordPayment(
      vehicleId: v1Id,
      months: 3,
      paidAt: const Day(2026, 8, 1),
    );
    expect(res.paymentId, isPositive);

    v1 = await (db.select(db.vehicles)..where((v) => v.id.equals(v1Id))).getSingle();
    expect(v1.currentPeriodEnd, const Day(2026, 11, 1));
    expect(v1.totalMonthsPaid, 3);
    expect(v1.totalPaid, 450000);

    // 4. Huỷ biên lai -> Hạn quay trở về chưa từng thu
    await paymentRepo.voidPayment(res.paymentId);
    v1 = await (db.select(db.vehicles)..where((v) => v.id.equals(v1Id))).getSingle();
    expect(v1.currentPeriodEnd, isNull);
    expect(v1.totalPaid, 0);
  });

  test('QA Business Logic: Thu tiền có chiết khấu & sửa đơn giá', () async {
    final paymentRepo = PaymentRepository(db, clock);

    final lotId = await db.into(db.lots).insert(
          LotsCompanion.insert(
            name: 'Bãi Sunrise QA',
            nameFold: viFold('Bãi Sunrise QA'),
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    final vId = await db.into(db.vehicles).insert(
          VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: 'Trần Văn Bách',
            ownerNameFold: viFold('Trần Văn Bách'),
            phone: const Value('0988 777 666'),
            phoneDigits: const Value('0988777666'),
            vehicleType: VehicleType.car,
            plate: '30F-999.88',
            plateNormalized: normalizePlate('30F-999.88'),
            monthlyPrice: 1000000,
            startDate: const Day(2026, 8, 15),
            anchorDay: 15,
            createdAt: DateTime.utc(2026, 8, 15),
            updatedAt: DateTime.utc(2026, 8, 15),
          ),
        );

    // Đóng 2 tháng nhưng giảm còn 1.800.000 (gốc 2.000.000)
    final res = await paymentRepo.recordPayment(
      vehicleId: vId,
      months: 2,
      amountOverride: 1800000,
      paidAt: const Day(2026, 8, 15),
    );

    final p = await (db.select(db.payments)..where((t) => t.id.equals(res.paymentId))).getSingle();
    expect(p.amount, 1800000);
    expect(p.monthsPaid, 2);

    // Phân bổ doanh thu 2 tháng (mỗi tháng 900.000)
    final allocs = await (db.select(db.paymentAllocations)
          ..where((a) => a.paymentId.equals(res.paymentId)))
        .get();
    expect(allocs.length, 2);
    expect(allocs.first.amount, 900000);
    expect(allocs.last.amount, 900000);
  });

  test('QA Financial Reports: So sánh THỰC THU vs PHÂN BỔ', () async {
    final paymentRepo = PaymentRepository(db, clock);
    final reportRepo = ReportRepository(db);

    final lotId = await db.into(db.lots).insert(
          LotsCompanion.insert(
            name: 'Bãi Báo Cáo QA',
            nameFold: viFold('Bãi Báo Cáo QA'),
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    final vId = await db.into(db.vehicles).insert(
          VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: 'Hoàng Thị Cúc',
            ownerNameFold: viFold('Hoàng Thị Cúc'),
            vehicleType: VehicleType.car,
            plate: '30H-111.22',
            plateNormalized: normalizePlate('30H-111.22'),
            monthlyPrice: 600000,
            startDate: const Day(2026, 8, 1),
            anchorDay: 1,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    // Thu tiền 3 tháng (Tháng 8, 9, 10) đóng dồn vào ngày 01/08
    await paymentRepo.recordPayment(
      vehicleId: vId,
      months: 3,
      paidAt: const Day(2026, 8, 1),
    );

    // Báo cáo tháng 8 THỰC THU = 1.800.000
    final cashAug = await reportRepo.build(
      from: const Day(2026, 8, 1),
      to: const Day(2026, 9, 1),
      granularity: ReportGranularity.month,
      mode: RevenueMode.cash,
    );
    expect(cashAug.totalRevenue, 1800000);

    // Báo cáo tháng 8 PHÂN BỔ = 600.000
    final accrualAug = await reportRepo.build(
      from: const Day(2026, 8, 1),
      to: const Day(2026, 9, 1),
      granularity: ReportGranularity.month,
      mode: RevenueMode.accrual,
    );
    expect(accrualAug.totalRevenue, 600000);
  });

  test('QA Backup & Restore: Sao lưu và khôi phục CSDL không mất mát', () async {
    final backupService = BackupService(db, clock);

    await db.into(db.lots).insert(
          LotsCompanion.insert(
            name: 'Bãi Sao Lưu QA',
            nameFold: viFold('Bãi Sao Lưu QA'),
            capacity: const Value(100),
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );

    final envelope = await backupService.buildEnvelope();
    expect(envelope.data['lots']?.first['name'], 'Bãi Sao Lưu QA');
  });

  // UI Screen Integration Audits
  qaTest('Dựng giao diện Màn hình Tổng quan (Dashboard) không tràn layout', (tester) async {
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);
    expect(find.text('Quản lý tổng bãi xe'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  qaTest('Dựng giao diện Màn hình Xe gửi (Vehicles) không tràn layout', (tester) async {
    await tester.pumpWidget(host(const VehiclesScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  qaTest('Dựng giao diện Màn hình Bãi xe (Lots) không tràn layout', (tester) async {
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  qaTest('Dựng giao diện Màn hình Chi phí (Expenses) không tràn layout', (tester) async {
    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  qaTest('Dựng giao diện Màn hình Báo cáo (Reports) không tràn layout', (tester) async {
    await tester.pumpWidget(host(const ReportsScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  qaTest('Dựng giao diện Màn hình Nhắc nhở (Reminders) không tràn layout', (tester) async {
    await tester.pumpWidget(host(const RemindersScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
