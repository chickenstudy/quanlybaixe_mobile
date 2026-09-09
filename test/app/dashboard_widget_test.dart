import 'package:drift/drift.dart' show OrderingTerm, Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/dashboard/presentation/dashboard_screen.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';
import 'package:quan_ly_bai_xe/src/theme/app_theme.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

void widgetTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}

void main() {
  late AppDatabase db;
  final clock = FixedClock(DateTime(2026, 8, 10, 9));

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

  Future<int> seed() async {
    final lotId = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi Nguyễn Trãi',
          nameFold: 'bai nguyen trai',
          capacity: const Value(50),
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));
    final v = await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'Nguyễn Văn An',
          ownerNameFold: 'nguyen van an',
          phone: const Value('0912 345 678'),
          phoneDigits: const Value('0912345678'),
          vehicleType: VehicleType.motorbike,
          plate: '59A1-234.56',
          plateNormalized: '59A123456',
          monthlyPrice: 100000,
          startDate: const Day(2026, 7, 15),
          anchorDay: 15,
          createdAt: DateTime.utc(2026, 7, 15),
          updatedAt: DateTime.utc(2026, 7, 15),
        ));
    // Đóng 1 tháng từ 15/07 -> hết hạn 15/08, tức còn 5 ngày tính từ 10/08.
    await PaymentRepository(db, clock)
        .recordPayment(vehicleId: v, months: 1, paidAt: const Day(2026, 7, 15));

    // Xe hết hạn / chưa từng đóng tiền
    await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'Trần Văn Bách',
          ownerNameFold: 'tran van bach',
          phone: const Value('0988 777 666'),
          phoneDigits: const Value('0988777666'),
          vehicleType: VehicleType.car,
          plate: '30F-999.88',
          plateNormalized: '30F99988',
          monthlyPrice: 1200000,
          startDate: const Day(2026, 6, 1),
          anchorDay: 1,
          createdAt: DateTime.utc(2026, 6, 1),
          updatedAt: DateTime.utc(2026, 6, 1),
        ));

    return v;
  }

  widgetTest('dashboard dựng được và hiện đúng thông tin bãi xe', (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    expect(find.text('Quản lý tổng bãi xe'), findsOneWidget);
    expect(find.text('Bãi Nguyễn Trãi'), findsOneWidget);
    expect(find.text('Doanh thu tháng này'), findsNothing);
  });

  widgetTest('danh sách xe hết hạn hiện thông tin xe hết hạn và nút thao tác',
      (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    expect(find.text('30F-999.88'), findsOneWidget);
    expect(find.textContaining('Trần Văn Bách'), findsOneWidget);
    expect(find.text('Chưa thu'), findsWidgets);
    expect(find.text('Gia hạn nhanh'), findsWidgets);
    expect(find.text('0988 777 666'), findsOneWidget);
  });

  widgetTest('chuyển tab sang Xe sắp hết hạn hiển thị đúng xe', (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    await scrollAndTap(
        tester,
        find.descendant(
            of: find.byType(SegmentedButton<ExpiryTab>),
            matching: find.text('Sắp hết hạn')));
    await tester.pumpAndSettle();

    expect(find.text('59A1-234.56'), findsOneWidget);
    expect(find.textContaining('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('còn 5 ngày'), findsOneWidget);
    expect(find.text('0912 345 678'), findsOneWidget);
  });

  widgetTest('thẻ Xe đang gửi hiện tỷ lệ lấp đầy khi bãi có khai sức chứa',
      (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    expect(find.textContaining('lấp đầy'), findsWidgets);
  });

  widgetTest('không khai sức chứa thì KHÔNG hiện tỷ lệ lấp đầy', (tester) async {
    await seed();
    await (db.update(db.lots)..where((l) => l.id.isNotNull()))
        .write(const LotsCompanion(capacity: Value(null)));
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    expect(find.textContaining('lấp đầy'), findsNothing);
  });

  widgetTest('bảng thu tiền: chọn 3 tháng rồi xác nhận, hạn đẩy đúng',
      (tester) async {
    final v = await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    await scrollAndTap(
        tester,
        find.descendant(
            of: find.byType(SegmentedButton<ExpiryTab>),
            matching: find.text('Sắp hết hạn')));
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Gia hạn nhanh').first);
    await tester.pumpAndSettle();

    expect(find.text('Thu tiền gửi xe'), findsOneWidget);
    expect(find.text('Hạn mới'), findsOneWidget);
    expect(find.text('15/09/2026'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pumpAndSettle();
    expect(find.text('15/11/2026'), findsOneWidget);

    await scrollAndTap(tester, find.textContaining('Xác nhận thu tiền'));
    await tester.pumpAndSettle();
    await settle(tester);

    final row =
        await (db.select(db.vehicles)..where((t) => t.id.equals(v))).getSingle();
    expect(row.currentPeriodEnd, const Day(2026, 11, 15));
    expect(row.totalMonthsPaid, 4);
    expect(row.totalPaid, 100000 * 4);
  });

  widgetTest('bảng thu tiền: SỬA ĐƠN GIÁ thì thành tiền tự tính lại',
      (tester) async {
    final v = await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    await scrollAndTap(
        tester,
        find.descendant(
            of: find.byType(SegmentedButton<ExpiryTab>),
            matching: find.text('Sắp hết hạn')));
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Gia hạn nhanh').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Đơn giá / tháng'), '120000');
    await tester.pumpAndSettle();

    expect(find.textContaining('360.000'), findsWidgets);
    expect(find.text('Cập nhật giá gửi của xe'), findsOneWidget);

    await scrollAndTap(tester, find.textContaining('Xác nhận thu tiền'));
    await tester.pumpAndSettle();
    await settle(tester);

    final pay = await (db.select(db.payments)
          ..orderBy([(p) => OrderingTerm.desc(p.id)]))
        .get();
    expect(pay.first.unitPrice, 120000);
    expect(pay.first.amount, 360000);

    final row =
        await (db.select(db.vehicles)..where((t) => t.id.equals(v))).getSingle();
    expect(row.monthlyPrice, 100000);
  });

  widgetTest('bảng thu tiền: BỚT TIỀN cho khách quen được ghi nhận nguyên vẹn',
      (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    await scrollAndTap(
        tester,
        find.descendant(
            of: find.byType(SegmentedButton<ExpiryTab>),
            matching: find.text('Sắp hết hạn')));
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Gia hạn nhanh').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '3'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Thành tiền'), '250000');
    await tester.pumpAndSettle();
    expect(find.text('Thành tiền khác đơn giá × số tháng'), findsOneWidget);

    await scrollAndTap(tester, find.textContaining('Xác nhận thu tiền'));
    await tester.pumpAndSettle();
    await settle(tester);

    final pay = await (db.select(db.payments)
          ..orderBy([(p) => OrderingTerm.desc(p.id)]))
        .get();
    expect(pay.first.amount, 250000);
    expect(pay.first.unitPrice, 100000);
    expect(pay.first.monthsPaid, 3);

    final sum = await db
        .customSelect(
            'SELECT SUM(amount) AS s FROM payment_allocations WHERE payment_id = ?1',
            variables: [Variable.withInt(pay.first.id)])
        .getSingle();
    expect(sum.read<int>('s'), 250000);
  });

  widgetTest('bảng thu tiền: số tháng không hợp lệ thì chặn xác nhận',
      (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    await scrollAndTap(
        tester,
        find.descendant(
            of: find.byType(SegmentedButton<ExpiryTab>),
            matching: find.text('Sắp hết hạn')));
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.widgetWithText(FilledButton, 'Gia hạn nhanh').first);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Số tháng khác'), '0');
    await tester.pumpAndSettle();

    final btn = tester.widget<FilledButton>(find.ancestor(
      of: find.textContaining('Xác nhận thu tiền'),
      matching: find.byType(FilledButton),
    ));
    expect(btn.onPressed, isNull);
  });

  widgetTest('đánh dấu đã nhắc ghi nhận vào bản ghi xe', (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);

    await scrollAndTap(tester, find.widgetWithText(TextButton, 'Đã nhắc').first);
    await settle(tester);

    final row =
        await (db.select(db.vehicles)..where((t) => t.plate.equals('30F-999.88'))).getSingle();
    expect(row.lastRemindedAt, isNotNull);
  });

  widgetTest('không có dữ liệu vẫn dựng được, không lỗi', (tester) async {
    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);
    expect(find.text('Quản lý tổng bãi xe'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  widgetTest('dựng được ở giao diện tối', (tester) async {
    await seed();
    await tester.pumpWidget(host(const DashboardScreen(), theme: AppTheme.dark));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('30F-999.88'), findsOneWidget);
  });

  widgetTest('không tràn layout ở màn hình iPhone hẹp nhất', (tester) async {
    await seed();
    tester.view.physicalSize = const Size(375 * 3, 667 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(host(const DashboardScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
