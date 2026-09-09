import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/strings/strings.dart';
import 'package:quan_ly_bai_xe/src/core/text/vi_normalize.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/core/time/year_month.dart';
import 'package:quan_ly_bai_xe/src/features/expenses/data/expense_repository.dart';
import 'package:quan_ly_bai_xe/src/features/expenses/data/recurring_cost_materializer.dart';
import 'package:quan_ly_bai_xe/src/features/expenses/presentation/expenses_screen.dart';
import 'package:quan_ly_bai_xe/src/features/expenses/presentation/expenses_strings.dart';
import 'package:quan_ly_bai_xe/src/features/expenses/presentation/recurring_templates_screen.dart';
import 'package:quan_ly_bai_xe/src/theme/app_theme.dart';

/// Bơm vài khung hình để stream của Drift kịp phát dữ liệu.
///
/// KHÔNG dùng `pumpAndSettle` cho lần dựng đầu: màn hình đang hiện
/// `CircularProgressIndicator`, mà vòng quay ấy lên khung hình vô tận nên
/// `pumpAndSettle` sẽ chờ mãi không bao giờ trả về.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Cuộn tới rồi mới bấm — `tap` vào widget ngoài vùng nhìn thấy không báo lỗi,
/// nó chỉ in cảnh báo rồi test đỏ ở dòng `expect` phía sau, rất tốn công truy
/// nguyên. Các bảng nhập liệu ở đây dài hơn màn hình test 800x600.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

/// Như [testWidgets] nhưng tháo cây widget NGAY TRONG thân test.
///
/// Drift lên lịch một `Timer` 0ms khi stream truy vấn bị huỷ, và SnackBar cũng
/// giữ một timer tự ẩn. Nếu để `ProviderScope` bị tháo sau khi thân test kết
/// thúc, các timer ấy còn treo lúc khung kiểm thử soát bất biến và test đỏ với
/// "A Timer is still pending". `addTearDown` không cứu được vì nó chạy SAU
/// lượt soát đó.
void widgetTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}

void main() {
  late AppDatabase db;

  // 03/09/2026 — cố tình chọn đầu tháng 9 để dựng được đúng tình huống kinh
  // điển: hoá đơn điện THÁNG 8 trả vào NGÀY 03/09.
  final clock = FixedClock(DateTime(2026, 9, 3, 9));
  const thisMonth = YearMonth(2026, 9);
  const lastMonth = YearMonth(2026, 8);

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  ExpenseRepository repo() => ExpenseRepository(db, clock);
  RecurringCostMaterializer materializer() =>
      RecurringCostMaterializer(db, clock);

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

  Future<int> addLot(String name) =>
      db.into(db.lots).insert(LotsCompanion.insert(
            name: name,
            nameFold: viFold(name),
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ));

  Future<int> addExpense({
    required int lotId,
    required String name,
    required int amount,
    required Day on,
    String? periodMonth,
    CostCategory category = CostCategory.repair,
    ExpenseKind kind = ExpenseKind.adhoc,
  }) =>
      db.into(db.expenses).insert(ExpensesCompanion.insert(
            lotId: lotId,
            name: name,
            category: category,
            kind: kind,
            amount: amount,
            incurredOn: on,
            periodMonth: periodMonth ?? YearMonth.fromDay(on).key,
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ));

  Future<List<ExpenseRow>> allExpenses() =>
      (db.select(db.expenses)..orderBy([(e) => OrderingTerm.asc(e.id)])).get();

  /// Mở bảng thêm chi phí từ nút `+`.
  Future<void> openAddSheet(WidgetTester tester) async {
    await tester.tap(find.byTooltip(Strings.expenseAdd));
    await tester.pumpAndSettle();
  }

  Future<void> fillText(
      WidgetTester tester, String label, String value) async {
    await tester.enterText(find.widgetWithText(TextField, label), value);
    await tester.pump();
  }

  // ══════════════════════════════════════════════════════════════════════
  // CHI PHÍ PHÁT SINH
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('thêm chi phí phát sinh thì lưu vào CSDL và hiện ngay trong danh sách',
      (tester) async {
    await addLot('Bãi Nguyễn Trãi');
    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);

    await openAddSheet(tester);
    await fillText(tester, Strings.expenseDescription, 'Sửa mái tôn');
    await fillText(tester, Strings.expenseAmount, '1500000');
    await scrollAndTap(tester, find.text(Strings.save));
    await tester.pumpAndSettle();
    await settle(tester);

    final rows = await allExpenses();
    expect(rows.length, 1);
    expect(rows.single.name, 'Sửa mái tôn');
    expect(rows.single.amount, 1500000);
    expect(rows.single.kind, ExpenseKind.adhoc);
    expect(rows.single.incurredOn, const Day(2026, 9, 3));
    expect(rows.single.periodMonth, '2026-09');

    expect(find.text('Sửa mái tôn'), findsOneWidget);
    expect(find.text('1.500.000 ₫'), findsWidgets);
  });

  widgetTest(
      'THÁNG KẾ TOÁN TÁCH KHỎI NGÀY CHI: chi ngày 03/09 nhưng hạch toán tháng 8',
      (tester) async {
    await addLot('Bãi Nguyễn Trãi');
    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);

    await openAddSheet(tester);
    await fillText(tester, Strings.expenseDescription, 'Tiền điện tháng 8');
    await fillText(tester, Strings.expenseAmount, '820000');

    // Ngày chi giữ nguyên hôm nay (03/09), chỉ lùi THÁNG ÁP DỤNG về tháng 8.
    await scrollAndTap(tester, find.byTooltip(ExpensesStrings.periodPrevious));
    await tester.pumpAndSettle();
    expect(find.text('Tháng 8/2026'), findsOneWidget);

    await scrollAndTap(tester, find.text(Strings.save));
    await tester.pumpAndSettle();
    await settle(tester);

    final row = (await allExpenses()).single;
    expect(row.incurredOn, const Day(2026, 9, 3), reason: 'ngày tiền rời túi');
    expect(row.periodMonth, '2026-08', reason: 'tháng hạch toán');

    // Đang đứng ở tháng 9 nên khoản này KHÔNG được hiện.
    expect(find.text('Tiền điện tháng 8'), findsNothing);
    expect(await repo().monthTotal(month: thisMonth), 0);
    expect(await repo().monthTotal(month: lastMonth), 820000);

    // Lùi về tháng 8 thì thấy.
    await tester.tap(find.byTooltip(Strings.lastMonth));
    await settle(tester);
    expect(find.text('Tháng 8/2026'), findsOneWidget);
    expect(find.text('Tiền điện tháng 8'), findsOneWidget);
  });

  widgetTest('nút lùi và tới tháng đổi danh sách theo đúng tháng', (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await addExpense(
        lotId: lot, name: 'Chi của tháng 8', amount: 300000, on: const Day(2026, 8, 20));
    await addExpense(
        lotId: lot, name: 'Chi của tháng 9', amount: 400000, on: const Day(2026, 9, 2));

    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);
    expect(find.text('Tháng 9/2026'), findsOneWidget);
    expect(find.text('Chi của tháng 9'), findsOneWidget);
    expect(find.text('Chi của tháng 8'), findsNothing);

    await tester.tap(find.byTooltip(Strings.lastMonth));
    await settle(tester);
    expect(find.text('Tháng 8/2026'), findsOneWidget);
    expect(find.text('Chi của tháng 8'), findsOneWidget);
    expect(find.text('Chi của tháng 9'), findsNothing);

    await tester.tap(find.byTooltip(ExpensesStrings.nextMonth));
    await settle(tester);
    expect(find.text('Tháng 9/2026'), findsOneWidget);
    expect(find.text('Chi của tháng 9'), findsOneWidget);
  });

  widgetTest('lọc theo bãi chỉ hiện chi phí của bãi đang chọn', (tester) async {
    final a = await addLot('Bãi A');
    final b = await addLot('Bãi B');
    await addExpense(
        lotId: a, name: 'Điện bãi A', amount: 500000, on: const Day(2026, 9, 1));
    // Bãi B để kiểu cố định, nhờ vậy con số tổng của cả tháng (1.200.000)
    // khác hẳn tổng của từng khối và tìm được đúng một widget.
    await addExpense(
        lotId: b,
        name: 'Điện bãi B',
        amount: 700000,
        on: const Day(2026, 9, 1),
        category: CostCategory.electricity,
        kind: ExpenseKind.recurring);

    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);
    expect(find.text('Điện bãi A'), findsOneWidget);
    expect(find.text('Điện bãi B'), findsOneWidget);
    expect(find.text('1.200.000 ₫'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Bãi A'));
    await settle(tester);
    expect(find.text('Điện bãi A'), findsOneWidget);
    expect(find.text('Điện bãi B'), findsNothing);
    expect(find.text('500.000 ₫'), findsWidgets);
    expect(await repo().monthTotal(month: thisMonth, lotId: a), 500000);

    await tester.tap(find.widgetWithText(ChoiceChip, ExpensesStrings.allLots));
    await settle(tester);
    expect(find.text('Điện bãi B'), findsOneWidget);
  });

  widgetTest('tổng chi phí tháng cộng đúng và không lẫn tháng khác',
      (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await addExpense(
        lotId: lot,
        name: 'Tiền thuê',
        amount: 5000000,
        on: const Day(2026, 9, 1),
        category: CostCategory.rent,
        kind: ExpenseKind.recurring);
    await addExpense(
        lotId: lot, name: 'Sửa cổng', amount: 1200000, on: const Day(2026, 9, 2));
    await addExpense(
        lotId: lot, name: 'Chi tháng 8', amount: 900000, on: const Day(2026, 8, 9));

    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);

    // 5.000.000 + 1.200.000; khoản tháng 8 KHÔNG được cộng vào.
    expect(find.text('6.200.000 ₫'), findsOneWidget);
    expect(await repo().monthTotal(month: thisMonth), 6200000);
    expect(await repo().monthTotal(month: lastMonth), 900000);

    // Hai khối tách bạch: cố định hàng tháng và phát sinh.
    expect(find.text(Strings.expenseFixed), findsOneWidget);
    expect(find.text(Strings.expenseAdhoc), findsOneWidget);
  });

  // ══════════════════════════════════════════════════════════════════════
  // MẪU CHI PHÍ CỐ ĐỊNH
  // ══════════════════════════════════════════════════════════════════════

  widgetTest(
      'TẠO MẪU CỐ ĐỊNH MỚI thì chi phí của tháng này xuất hiện ngay lập tức',
      (tester) async {
    // Đây là lỗi đã thực sự xảy ra: quên gọi `invalidate()` sau khi thêm mẫu
    // thì mốc vẫn khớp, bộ sinh bỏ qua, và mẫu mới không sinh ra dòng nào cho
    // tới tận tháng sau — không một lỗi nào được báo.
    await addLot('Bãi Nguyễn Trãi');
    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);
    expect(find.text(Strings.expenseEmpty), findsOneWidget);

    await tester.tap(find.byTooltip(Strings.expenseTemplates));
    await tester.pumpAndSettle();
    await settle(tester);

    await tester.tap(find.byTooltip(Strings.expenseTemplateAdd));
    await tester.pumpAndSettle();
    await fillText(tester, ExpensesStrings.templateName, 'Tiền thuê bãi');
    await fillText(tester, Strings.expenseAmount, '5000000');
    await scrollAndTap(tester, find.text(Strings.save));
    await tester.pumpAndSettle();
    await settle(tester);

    final generated = await allExpenses();
    expect(generated.length, 1, reason: 'mẫu phải sinh chi phí cho tháng này');
    expect(generated.single.periodMonth, '2026-09');
    expect(generated.single.kind, ExpenseKind.recurring);
    expect(generated.single.sourceTemplateId, isNotNull);
    expect(generated.single.amount, 5000000);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await settle(tester);

    expect(find.text('Tiền thuê bãi'), findsOneWidget);
    expect(find.text('5.000.000 ₫'), findsWidgets);
    expect(find.text(ExpensesStrings.estimate), findsOneWidget);
  });

  widgetTest(
      'sửa số tiền dòng sinh từ mẫu thì bật cờ đã sửa và bộ sinh KHÔNG ghi đè',
      (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await repo().createTemplate(
      lotId: lot,
      name: 'Tiền điện',
      category: CostCategory.electricity,
      amount: 800000,
      startMonth: thisMonth,
    );

    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);
    expect(find.text('Tiền điện'), findsOneWidget);
    expect(find.text(ExpensesStrings.estimate), findsOneWidget);

    await tester.tap(find.text('Tiền điện'));
    await tester.pumpAndSettle();
    await fillText(tester, Strings.expenseAmount, '950000');
    await scrollAndTap(tester, find.text(Strings.save));
    await tester.pumpAndSettle();
    await settle(tester);

    var row = (await allExpenses()).single;
    expect(row.amount, 950000);
    expect(row.isEdited, isTrue);

    // Chạy lại bộ sinh: dòng đã sửa là bất khả xâm phạm.
    await materializer().invalidate();
    expect(await materializer().materializeUpTo(thisMonth), 0);
    row = (await allExpenses()).single;
    expect(row.amount, 950000, reason: 'số người dùng nhập không được ghi đè');
    expect(row.isEdited, isTrue);
  });

  widgetTest('XOÁ MẪU thì chi phí lịch sử vẫn còn, chỉ mất liên kết tới mẫu',
      (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await repo().createTemplate(
      lotId: lot,
      name: 'Tiền điện',
      category: CostCategory.electricity,
      amount: 800000,
      startMonth: lastMonth,
    );
    expect((await allExpenses()).length, 2, reason: 'tháng 8 và tháng 9');

    await tester.pumpWidget(host(const RecurringTemplatesScreen()));
    await settle(tester);

    await scrollAndTap(tester, find.byTooltip(Strings.delete));
    await tester.pumpAndSettle();
    // Câu xác nhận phải nói thẳng rằng chi phí cũ KHÔNG mất.
    expect(find.text(ExpensesStrings.deleteTemplateMessage), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, Strings.delete));
    await tester.pumpAndSettle();
    await settle(tester);

    expect(await db.select(db.recurringCostTemplates).get(), isEmpty);

    final rows = await allExpenses();
    expect(rows.length, 2, reason: 'tiền đó đã thực sự chi ra rồi');
    expect(rows.every((e) => e.deletedAt == null), isTrue);
    expect(rows.every((e) => e.sourceTemplateId == null), isTrue,
        reason: 'ON DELETE SET NULL chỉ cắt đường trỏ về mẫu');
    expect(rows.every((e) => e.amount == 800000), isTrue);
  });

  widgetTest('TẮT MẪU thì các tháng sau không sinh thêm chi phí', (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await repo().createTemplate(
      lotId: lot,
      name: 'Tiền nước',
      category: CostCategory.water,
      amount: 200000,
      startMonth: thisMonth,
    );
    expect((await allExpenses()).length, 1);

    await tester.pumpWidget(host(const RecurringTemplatesScreen()));
    await settle(tester);

    await scrollAndTap(tester, find.byType(Switch));
    await tester.pumpAndSettle();
    await settle(tester);

    final t = (await db.select(db.recurringCostTemplates).get()).single;
    expect(t.isActive, isFalse);
    expect(find.text(Strings.expenseTemplateStopped), findsNothing,
        reason: 'nhãn "Đã dừng" nằm chung dòng với khoảng hiệu lực');
    expect(find.textContaining(Strings.expenseTemplateStopped), findsOneWidget);

    // Kéo bộ sinh tới tận tháng 12: không được sinh thêm dòng nào.
    expect(await materializer().materializeUpTo(const YearMonth(2026, 12)), 0);
    expect((await allExpenses()).length, 1);
  });

  widgetTest('dòng chưa sửa hiện nhãn "ước tính", dòng đã sửa thì không',
      (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await repo().createTemplate(
        lotId: lot,
        name: 'Tiền điện',
        category: CostCategory.electricity,
        amount: 800000,
        startMonth: thisMonth);
    await repo().createTemplate(
        lotId: lot,
        name: 'Tiền nước',
        category: CostCategory.water,
        amount: 200000,
        startMonth: thisMonth);

    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);
    expect(find.text(ExpensesStrings.estimate), findsNWidgets(2));

    // Xác nhận số thật của MỘT dòng.
    final water = (await allExpenses()).firstWhere((e) => e.name == 'Tiền nước');
    await (db.update(db.expenses)..where((e) => e.id.equals(water.id)))
        .write(const ExpensesCompanion(isEdited: Value(true)));
    await settle(tester);
    expect(find.text(ExpensesStrings.estimate), findsOneWidget);

    // Xác nhận nốt dòng còn lại.
    await (db.update(db.expenses)..where((e) => e.id.isNotNull()))
        .write(const ExpensesCompanion(isEdited: Value(true)));
    await settle(tester);
    expect(find.text(ExpensesStrings.estimate), findsNothing);
  });

  widgetTest('màn hình mẫu hiện khoảng hiệu lực và trạng thái của từng mẫu',
      (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await repo().createTemplate(
        lotId: lot,
        name: 'Tiền thuê bãi',
        category: CostCategory.rent,
        amount: 5000000,
        startMonth: thisMonth);
    await repo().createTemplate(
        lotId: lot,
        name: 'Bảo vệ ca đêm',
        category: CostCategory.security,
        amount: 4000000,
        startMonth: lastMonth,
        endMonth: const YearMonth(2026, 12),
        isActive: false);

    await tester.pumpWidget(host(const RecurringTemplatesScreen()));
    await settle(tester);

    expect(find.text('Bãi Nguyễn Trãi'), findsOneWidget);
    expect(find.text('Tháng 9/2026 → còn hiệu lực'), findsOneWidget);
    expect(
        find.text('Tháng 8/2026 → Tháng 12/2026 · ${Strings.expenseTemplateStopped}'),
        findsOneWidget);
    expect(find.text('Tiền thuê mặt bằng · 5.000.000 ₫/tháng'), findsOneWidget);

    // Mẫu đã tắt thì không sinh dòng nào, kể cả cho tháng đã qua.
    expect((await allExpenses()).length, 1);
  });

  // ══════════════════════════════════════════════════════════════════════
  // TRẠNG THÁI RỖNG & DỰNG GIAO DIỆN
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('chưa ghi chi phí nào thì hiện trạng thái rỗng có lối thoát',
      (tester) async {
    await addLot('Bãi Nguyễn Trãi');
    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);

    expect(find.text(Strings.expenseEmpty), findsOneWidget);
    expect(find.text(ExpensesStrings.emptyHint), findsOneWidget);
    expect(find.widgetWithText(FilledButton, Strings.expenseAdd), findsOneWidget);
    expect(find.text('0 ₫'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  widgetTest('dựng được ở giao diện tối', (tester) async {
    final lot = await addLot('Bãi Nguyễn Trãi');
    await repo().createTemplate(
        lotId: lot,
        name: 'Tiền điện',
        category: CostCategory.electricity,
        amount: 800000,
        startMonth: thisMonth);
    await addExpense(
        lotId: lot, name: 'Sửa cổng', amount: 1200000, on: const Day(2026, 9, 2));

    await tester.pumpWidget(host(const ExpensesScreen(), theme: AppTheme.dark));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Tiền điện'), findsOneWidget);
    expect(find.text('Sửa cổng'), findsOneWidget);
    expect(find.text(ExpensesStrings.estimate), findsOneWidget);
  });

  widgetTest('không tràn layout ở màn hình iPhone hẹp nhất', (tester) async {
    // iPhone SE: 375 x 667
    tester.view.physicalSize = const Size(375 * 3, 667 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final a = await addLot('Bãi Nguyễn Trãi cơ sở 1');
    await addLot('Bãi Trần Duy Hưng cơ sở 2');
    await repo().createTemplate(
        lotId: a,
        name: 'Tiền thuê mặt bằng cả năm 2026',
        category: CostCategory.rent,
        amount: 125000000,
        startMonth: thisMonth);
    await addExpense(
        lotId: a,
        name: 'Thay toàn bộ mái tôn khu để xe máy',
        amount: 98765432,
        on: const Day(2026, 9, 2));

    await tester.pumpWidget(host(const ExpensesScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip(Strings.expenseTemplates));
    await tester.pumpAndSettle();
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
