import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/format/vi_date_format.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/strings/strings.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';
import 'package:quan_ly_bai_xe/src/features/reports/presentation/reports_screen.dart';
import 'package:quan_ly_bai_xe/src/features/reports/presentation/reports_strings.dart';
import 'package:quan_ly_bai_xe/src/theme/app_theme.dart';

/// Bơm vài khung hình cho các `FutureProvider` của báo cáo kịp trả kết quả.
///
/// KHÔNG dùng `pumpAndSettle`: lúc đang chờ dữ liệu màn hình hiện
/// `CircularProgressIndicator`, mà vòng quay ấy lên khung hình vô tận nên
/// `pumpAndSettle` sẽ chờ mãi không bao giờ trả về.
///
/// Nhiều nhịp hơn dashboard vì chuỗi ở đây dài hơn: chờ sinh chi phí cố định →
/// truy vấn báo cáo → dựng biểu đồ (fl_chart còn một hoạt ảnh 150ms nữa).
/// Mở bảng "Bộ lọc" đang thu gọn.
///
/// Bãi, mốc gom nhóm và khoảng thời gian nằm trong một `ExpansionTile` thu gọn
/// mặc định — nếu trải hết ra thì bốn nhóm chip chiếm trọn màn hình đầu và đẩy
/// mọi con số xuống dưới nếp gấp. Công tắc cách tính doanh thu thì vẫn luôn
/// hiện, nên các test về nó không cần gọi hàm này.
Future<void> openFilters(WidgetTester tester) async {
  final tile = find.text(ReportsStrings.filtersTitle);
  if (tile.evaluate().isEmpty) return;
  await tester.ensureVisible(tile);
  await tester.pump();
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Cuộn tới rồi mới bấm.
///
/// `tap` vào widget ngoài vùng nhìn thấy **không báo lỗi** — nó chỉ in một
/// cảnh báo rồi test đỏ ở dòng `expect` phía sau, rất tốn công truy nguyên.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

/// Như [testWidgets] nhưng tháo cây widget NGAY TRONG thân test.
///
/// Drift lên lịch một `Timer` 0ms khi stream truy vấn bị huỷ. Nếu để
/// `ProviderScope` bị tháo sau khi thân test kết thúc, timer ấy còn treo lúc
/// khung kiểm thử soát bất biến và mọi test đều đỏ với "A Timer is still
/// pending". `addTearDown` không cứu được vì nó chạy SAU lượt soát đó.
void widgetTest(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}

void main() {
  late AppDatabase db;
  late PaymentRepository pay;
  late int lotA;

  // Tháng 12: khoảng mặc định "12 tháng gần nhất" trải từ 01/01/2026 tới hết
  // 31/12/2026, nên nó ôm trọn cả ba tháng 8–9–10 mà tiền đóng 3 tháng của ví
  // dụ đặc tả được phân bổ vào. Chọn mốc "hôm nay" sớm hơn thì phần phân bổ
  // rơi ra ngoài khoảng và test sẽ kiểm nhầm thứ khác.
  final clock = FixedClock(DateTime(2026, 12, 15, 9));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    pay = PaymentRepository(db, clock);
    lotA = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi A',
          nameFold: 'bai a',
          capacity: const Value(50),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ));
  });
  tearDown(() => db.close());

  Widget host({ThemeData? theme}) => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          home: const ReportsScreen(),
        ),
      );

  Future<int> vehicle(String plate, int price, {int? lotId}) =>
      db.into(db.vehicles).insert(VehiclesCompanion.insert(
            lotId: lotId ?? lotA,
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

  Future<void> expense(
    String month,
    int amount, {
    String name = 'Điện',
    CostCategory category = CostCategory.electricity,
    int? lotId,
  }) =>
      db.into(db.expenses).insert(ExpensesCompanion.insert(
            lotId: lotId ?? lotA,
            name: name,
            category: category,
            kind: ExpenseKind.adhoc,
            amount: amount,
            incurredOn: Day(int.parse(month.substring(0, 4)),
                int.parse(month.substring(5, 7)), 5),
            periodMonth: month,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ));

  /// Ví dụ tháng 8 của đặc tả: ba xe giá 100.000 đóng lần lượt 1, 2 và 3 tháng.
  Future<void> seedSpecScenario() async {
    final a = await vehicle('59A-111.11', 100000);
    final b = await vehicle('59A-222.22', 100000);
    final c = await vehicle('59A-333.33', 100000);
    await pay.recordPayment(vehicleId: a, months: 1, paidAt: const Day(2026, 8, 1));
    await pay.recordPayment(vehicleId: b, months: 2, paidAt: const Day(2026, 8, 3));
    await pay.recordPayment(vehicleId: c, months: 3, paidAt: const Day(2026, 8, 5));
  }

  String totalText(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Color? totalColor(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).style?.color;

  // ══════════════════════════════════════════════════════════════════════
  // VÍ DỤ THÁNG 8 CỦA ĐẶC TẢ
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('THỰC THU: cả 600.000 dồn vào tháng 8', (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);

    expect(find.text(Strings.reports), findsOneWidget);
    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
    expect(totalText(tester, 'report-total-expense'), '0 ₫');
    // Ô lãi/lỗ LUÔN có dấu — màu không bao giờ là tín hiệu duy nhất.
    expect(totalText(tester, 'report-total-profit'), '+600.000 ₫');
    expect(find.text(Strings.reportProfitPositive), findsOneWidget);

    // Bảng chi tiết: đúng một mốc, đúng 600.000.
    expect(find.text('Tháng 8/2026'), findsOneWidget);
    expect(find.textContaining('Thu 600.000 ₫'), findsOneWidget);
    expect(find.text('Tháng 9/2026'), findsNothing);
  });

  widgetTest('bấm công tắc sang PHÂN BỔ thì số liệu đổi ngay: 300 / 200 / 100',
      (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);
    expect(find.text('Tháng 9/2026'), findsNothing);

    await scrollAndTap(tester, find.text(revenueModeLabel(RevenueMode.accrual)));
    await settle(tester);

    // Ba tháng được bao phủ, mỗi tháng đúng phần của nó.
    expect(find.text('Tháng 8/2026'), findsOneWidget);
    expect(find.text('Tháng 9/2026'), findsOneWidget);
    expect(find.text('Tháng 10/2026'), findsOneWidget);
    // Số từng mốc nằm ở dòng phụ của danh sách chi tiết.
    expect(find.textContaining('Thu 300.000 ₫'), findsOneWidget);
    expect(find.textContaining('Thu 200.000 ₫'), findsOneWidget);
    expect(find.textContaining('Thu 100.000 ₫'), findsOneWidget);

    // Tổng hai chế độ phải bằng nhau — nếu lệch thì một trong hai đang sai.
    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
  });

  widgetTest('đổi mốc sang QUÝ thì tổng vẫn 600.000', (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);
    await openFilters(tester);

    await scrollAndTap(
        tester, find.text(reportGranularityLabel(ReportGranularity.quarter)));
    await settle(tester);

    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
    expect(find.text('Quý 3/2026'), findsOneWidget);
  });

  widgetTest('đổi mốc sang NĂM thì tổng vẫn 600.000', (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);
    await openFilters(tester);

    await scrollAndTap(
        tester, find.text(reportGranularityLabel(ReportGranularity.year)));
    await settle(tester);

    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
    expect(find.text('Năm 2026'), findsOneWidget);
  });

  // ══════════════════════════════════════════════════════════════════════
  // MỐC NGÀY TRONG CHẾ ĐỘ PHÂN BỔ
  // ══════════════════════════════════════════════════════════════════════

  widgetTest(
      'mốc NGÀY khi đang PHÂN BỔ: hiện dòng giải thích, KHÔNG hiện biểu đồ trống',
      (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);
    await openFilters(tester);

    await scrollAndTap(tester, find.text(revenueModeLabel(RevenueMode.accrual)));
    await settle(tester);
    await scrollAndTap(
        tester, find.text(reportGranularityLabel(ReportGranularity.day)));
    await settle(tester);

    expect(find.text(ReportsStrings.granularityDowngradedTitle), findsOneWidget);
    expect(find.textContaining('không rải xuống từng ngày'), findsOneWidget);

    // Biểu đồ vẫn vẽ — bằng số liệu THÁNG — chứ không phải một khung trục rỗng.
    expect(find.byType(BarChart), findsNWidgets(2),
        reason: 'một biểu đồ thu-chi và một biểu đồ lãi/lỗ');
    expect(find.text(Strings.reportEmpty), findsNothing);
    expect(find.text('Tháng 8/2026'), findsOneWidget);
    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
  });

  widgetTest('mốc NGÀY ở chế độ THỰC THU chạy bình thường, không có dòng lùi mốc',
      (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);
    await openFilters(tester);

    await scrollAndTap(
        tester, find.text(reportGranularityLabel(ReportGranularity.day)));
    await settle(tester);

    expect(find.text(ReportsStrings.granularityDowngradedTitle), findsNothing);
    expect(find.text('01/08/2026'), findsOneWidget);
    expect(find.text('03/08/2026'), findsOneWidget);
    expect(find.text('05/08/2026'), findsOneWidget);
  });

  // ══════════════════════════════════════════════════════════════════════
  // BỘ LỌC
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('lọc theo bãi tách bạch số liệu', (tester) async {
    final lotB = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi B',
          nameFold: 'bai b',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ));
    await seedSpecScenario();
    await vehicle('51B-999.99', 100000, lotId: lotB);
    await tester.pumpWidget(host());
    await settle(tester);
    await openFilters(tester);

    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');

    await scrollAndTap(tester, find.text('Bãi B'));
    await settle(tester);
    expect(totalText(tester, 'report-total-revenue'), '0 ₫',
        reason: 'bãi B chưa thu đồng nào');

    await scrollAndTap(tester, find.text('Bãi A'));
    await settle(tester);
    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
  });

  widgetTest('nút chọn nhanh đổi khoảng thời gian', (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);
    await openFilters(tester);

    // "Tháng này" là tháng 12/2026 — không có đồng nào.
    await scrollAndTap(tester, find.text(ReportsStrings.rangeThisMonth));
    await settle(tester);
    expect(totalText(tester, 'report-total-revenue'), '0 ₫');
    expect(find.text('01/12/2026 – 31/12/2026'), findsOneWidget,
        reason: 'khoảng hiển thị phải lùi mốc loại trừ về ngày cuối THẬT');

    await scrollAndTap(tester, find.text(ReportsStrings.rangeThisYear));
    await settle(tester);
    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
  });

  // ══════════════════════════════════════════════════════════════════════
  // LÃI / LỖ
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('có chi phí thì lãi tính đúng và hiện dấu cộng, màu lãi',
      (tester) async {
    await seedSpecScenario();
    await expense('2026-08', 200000);
    await tester.pumpWidget(host());
    await settle(tester);

    expect(totalText(tester, 'report-total-expense'), '200.000 ₫');
    expect(totalText(tester, 'report-total-profit'), '+400.000 ₫');
    expect(totalColor(tester, 'report-total-profit'),
        AppStatusColors.lightScheme.profit);
    expect(find.text(Strings.reportProfitPositive), findsOneWidget);
  });

  widgetTest('LỖ thì hiện dấu trừ và màu lỗ, kèm chữ "Lỗ"', (tester) async {
    await seedSpecScenario();
    await expense('2026-08', 800000, name: 'Sửa chữa lớn');
    await tester.pumpWidget(host());
    await settle(tester);

    expect(totalText(tester, 'report-total-profit'), '-200.000 ₫',
        reason: 'dấu trừ là tín hiệu chính, màu chỉ là tín hiệu phụ');
    expect(totalColor(tester, 'report-total-profit'),
        AppStatusColors.lightScheme.loss);
    expect(find.text(Strings.reportProfitNegative), findsOneWidget);
    // Bảng chi tiết cũng phải mang dấu ở cột lãi/lỗ.
    expect(find.text('-200.000 ₫'), findsWidgets);
  });

  // ══════════════════════════════════════════════════════════════════════
  // TÁCH CHI PHÍ THEO NHÓM
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('tách chi phí theo nhóm xếp giảm dần theo số tiền', (tester) async {
    await expense('2026-08', 800000);
    await expense('2026-08', 5000000,
        name: 'Thuê mặt bằng', category: CostCategory.rent);
    await expense('2026-09', 1200000,
        name: 'Lương bảo vệ', category: CostCategory.security);
    await tester.pumpWidget(host());
    await settle(tester);

    final rent = find.text(costCategoryLabel(CostCategory.rent));
    final security = find.text(costCategoryLabel(CostCategory.security));
    final electricity = find.text(costCategoryLabel(CostCategory.electricity));
    expect(rent, findsOneWidget);
    expect(security, findsOneWidget);
    expect(electricity, findsOneWidget);

    // 5.000.000 > 1.200.000 > 800.000 — thứ tự trên màn hình phải đúng như vậy.
    expect(tester.getTopLeft(rent).dy, lessThan(tester.getTopLeft(security).dy));
    expect(tester.getTopLeft(security).dy,
        lessThan(tester.getTopLeft(electricity).dy));
    expect(find.text('5.000.000 ₫'), findsOneWidget);
  });

  widgetTest('không có chi phí thì phần tách nhóm nói rõ là chưa có',
      (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);

    expect(find.text(ReportsStrings.breakdownEmpty), findsOneWidget);
  });

  // ══════════════════════════════════════════════════════════════════════
  // TRẠNG THÁI RỖNG, GIAO DIỆN TỐI, KHỔ MÀN HÌNH
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('không có dữ liệu thì hiện trạng thái rỗng, không lỗi',
      (tester) async {
    await tester.pumpWidget(host());
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(totalText(tester, 'report-total-revenue'), '0 ₫');
    expect(totalText(tester, 'report-total-profit'), '0 ₫');
    expect(find.textContaining(Strings.reportBreakEven), findsOneWidget);
    // Không dựng khung trục trống: chỉ có thông báo.
    expect(find.byType(BarChart), findsNothing);
    expect(find.text(Strings.reportEmpty), findsWidgets);
  });

  widgetTest('biểu đồ dựng được ở giao diện tối', (tester) async {
    await seedSpecScenario();
    await expense('2026-09', 400000);
    await tester.pumpWidget(host(theme: AppTheme.dark));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(BarChart), findsNWidgets(2),
        reason: 'một biểu đồ thu-chi và một biểu đồ lãi/lỗ');
    expect(find.text(Strings.reportRevenue), findsWidgets);
    expect(find.text(Strings.reportExpense), findsWidgets);
    expect(totalText(tester, 'report-total-revenue'), '600.000 ₫');
  });

  widgetTest('không tràn layout ở 375x667 với 24 mốc dữ liệu', (tester) async {
    // iPhone SE — khổ hẹp nhất còn được hỗ trợ.
    tester.view.physicalSize = const Size(375 * 3, 667 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final v = await vehicle('59A-777.77', 100000);
    // 24 ngày thu tiền khác nhau trải khắp năm 2026 → 24 mốc theo NGÀY.
    for (var month = 1; month <= 12; month++) {
      for (final day in const [5, 20]) {
        await pay.recordPayment(
            vehicleId: v, months: 1, paidAt: Day(2026, month, day));
      }
    }

    await tester.pumpWidget(host());
    await settle(tester);
    await openFilters(tester);
    await scrollAndTap(
        tester, find.text(reportGranularityLabel(ReportGranularity.day)));
    await settle(tester);

    expect(tester.takeException(), isNull,
        reason: 'nhiều mốc thì biểu đồ phải cuộn ngang chứ không được tràn');
    expect(find.byType(BarChart), findsNWidgets(2),
        reason: 'một biểu đồ thu-chi và một biểu đồ lãi/lỗ');
    // Có cuộn ngang thì phải nói cho người dùng biết, nếu không họ tưởng mất
    // dữ liệu.
    expect(find.text(ReportsStrings.chartScrollHint), findsOneWidget);
    expect(totalText(tester, 'report-total-revenue'), '2.400.000 ₫');

    // Nhãn trục hoành phải THƯA BỚT chứ không được chồng lên nhau. Kiểm bằng
    // toạ độ thật sau khi dựng, vì `flutter analyze` không thấy được chữ đè
    // chữ và mắt thường thì chỉ thấy khi đã lên máy thật.
    final labelRects = <Rect>[];
    for (var month = 1; month <= 12; month++) {
      for (final day in const [5, 20]) {
        final finder = find.text(formatDayShort(Day(2026, month, day)));
        if (finder.evaluate().isEmpty) continue;
        labelRects.add(tester.getRect(finder.first));
      }
    }
    expect(labelRects.length, greaterThanOrEqualTo(2),
        reason: 'phải còn ít nhất vài nhãn sau khi thưa bớt');
    labelRects.sort((a, b) => a.left.compareTo(b.left));
    for (var i = 1; i < labelRects.length; i++) {
      expect(labelRects[i].left, greaterThanOrEqualTo(labelRects[i - 1].right),
          reason: 'nhãn thứ $i chồng lên nhãn trước đó');
    }
  });

  widgetTest('trục tiền dùng số rút gọn, không phải số đầy đủ', (tester) async {
    await seedSpecScenario();
    await tester.pumpWidget(host());
    await settle(tester);

    // 600.000 trên trục viết là "600 ng"; số đầy đủ chỉ xuất hiện ở ô tổng và
    // bảng chi tiết, nơi có chỗ cho nó.
    expect(find.text('600 ng'), findsWidgets,
        reason: 'nhãn trục tiền xuất hiện ở cả hai biểu đồ');
    expect(find.text('600.000 ₫'), findsOneWidget,
        reason: 'chỉ ở ô tổng, không lặp lại trên trục');
  });
}
