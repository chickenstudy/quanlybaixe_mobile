import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/strings/strings.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/lots/data/lot_repository.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';
import 'package:quan_ly_bai_xe/src/features/vehicles/data/vehicle_repository.dart';
import 'package:quan_ly_bai_xe/src/features/vehicles/presentation/vehicles_screen.dart';
import 'package:quan_ly_bai_xe/src/theme/app_theme.dart';

/// Bơm vài khung hình để stream của Drift kịp phát dữ liệu.
///
/// KHÔNG dùng `pumpAndSettle` cho lần dựng đầu: lúc đó màn hình đang hiện
/// `CircularProgressIndicator`, mà vòng quay ấy lên khung hình vô tận nên
/// `pumpAndSettle` sẽ chờ mãi không bao giờ trả về.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Gõ từ khoá rồi chờ qua hàng rào chống dội 300ms của ô tìm kiếm.
Future<void> search(WidgetTester tester, String query) async {
  if (find.byType(TextField).evaluate().isEmpty) {
    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump();
  }
  await tester.enterText(find.byType(TextField).first, query);
  await tester.pump(const Duration(milliseconds: 400));
  await settle(tester);
}

/// Đẩy qua hiệu ứng chuyển màn / mở hộp thoại mà KHÔNG dùng `pumpAndSettle`.
///
/// Hai lý do phải bơm tay thay vì `pumpAndSettle`:
///
/// 1. Màn hình chi tiết hiện `CircularProgressIndicator` trong lúc stream chưa
///    phát; vòng quay ấy lên khung hình vô tận nên `pumpAndSettle` chờ hết hạn
///    10 phút rồi mới đỏ.
/// 2. Sau một thao tác ghi DB (huỷ biên lai, ngừng gửi, xoá), Drift còn vài
///    `Timer` 0ms phải nổ trước khi transaction đóng lại. Đọc DB ngay lúc đó
///    mà không bơm thêm khung hình nào thì câu truy vấn xếp hàng sau
///    transaction và không bao giờ trả về.
///
/// 600ms ảo trải trên 12 khung hình phủ đủ cả hiệu ứng chuyển màn 300ms lẫn
/// các timer 0ms của Drift.
Future<void> pumpRoute(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Cuộn tới rồi mới bấm.
///
/// Màn hình test mặc định chỉ 800x600 nên nhiều dòng nằm dưới vùng nhìn thấy.
/// `tap` vào widget ngoài màn hình **không báo lỗi** — nó chỉ in một cảnh báo
/// rồi test đỏ ở dòng `expect` phía sau, rất tốn công truy nguyên.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

/// Như [testWidgets] nhưng tháo cây widget NGAY TRONG thân test.
///
/// Drift lên lịch một `Timer` 0ms khi stream truy vấn bị huỷ, và ô tìm kiếm
/// giữ một `Timer` chống dội. Nếu để `ProviderScope` bị tháo sau khi thân test
/// kết thúc, các timer ấy còn treo lúc khung kiểm thử soát bất biến và mọi test
/// đều đỏ với "A Timer is still pending". `addTearDown` không cứu được vì nó
/// chạy SAU lượt soát đó.
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

  late int lotA;
  late int lotB;
  late int vAn;
  late int vBinh;
  late int vCuong;
  late int vDung;

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

  /// Cho màn hình chi tiết đủ chỗ để mọi mục đều được dựng, khỏi phải cuộn
  /// từng bước. Bề ngang vẫn hẹp để lỗi tràn layout vẫn lộ ra.
  void tallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(400 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  /// Bốn chiếc xe phủ đủ bốn trạng thái hạn, trên hai bãi và ba loại xe.
  ///
  /// Dựng bằng chính các repository chứ không `INSERT` thẳng: nhờ vậy các cột
  /// gấp dấu (`owner_name_fold`, `plate_normalized`, `phone_digits`) được sinh
  /// ra đúng như lúc chạy thật, và các test tìm kiếm mới có ý nghĩa.
  Future<void> seed() async {
    final lots = LotRepository(db, clock);
    lotA = await lots.create(
        name: 'Bãi Nguyễn Trãi', capacity: 50);
    lotB =
        await lots.create(name: 'Bãi Lê Lợi', capacity: 30);

    final vehicles = VehicleRepository(db, clock);
    final payments = PaymentRepository(db, clock);

    // Sắp hết hạn: đóng 1 tháng từ 15/07 → hết hạn 15/08, còn 5 ngày.
    vAn = await vehicles.create(
      lotId: lotA,
      ownerName: 'Nguyễn Văn An',
      phone: '0912 345 678',
      type: VehicleType.motorbike,
      plate: '59A1-234.56',
      monthlyPrice: 100000,
      startDate: const Day(2026, 7, 15),
    );
    await payments.recordPayment(
        vehicleId: vAn, months: 1, paidAt: const Day(2026, 7, 16));
    // Một biên lai bị huỷ, để màn hình chi tiết có dấu vết phải hiển thị.
    final mistake = await payments.recordPayment(
      vehicleId: vAn,
      months: 3,
      paidAt: const Day(2026, 8, 1),
      amountOverride: 300000,
    );
    await payments.voidPayment(mistake.paymentId, reason: 'Ghi nhầm xe');

    // Quá hạn: đóng 1 tháng từ 01/05 → hết hạn 01/06, quá 70 ngày.
    vBinh = await vehicles.create(
      lotId: lotB,
      ownerName: 'Trần Thị Bình',
      phone: '0987 654 321',
      type: VehicleType.car,
      plate: '30G-567.89',
      monthlyPrice: 500000,
      startDate: const Day(2026, 5, 1),
    );
    await payments.recordPayment(
        vehicleId: vBinh, months: 1, paidAt: const Day(2026, 5, 1));

    // Chưa đóng tiền lần nào — KHÁC hẳn quá hạn.
    vCuong = await vehicles.create(
      lotId: lotA,
      ownerName: 'Lê Văn Cường',
      phone: '0333 111 222',
      type: VehicleType.motorbike,
      plate: '29X1-111.11',
      monthlyPrice: 120000,
      startDate: const Day(2026, 8, 1),
    );

    // Còn hạn dài: đóng 6 tháng từ 01/08 → hết hạn 01/02/2027.
    vDung = await vehicles.create(
      lotId: lotB,
      ownerName: 'Phạm Thị Dung',
      phone: '0977 000 111',
      type: VehicleType.truck,
      plate: '51C-999.99',
      monthlyPrice: 800000,
      startDate: const Day(2026, 8, 1),
    );
    await payments.recordPayment(
        vehicleId: vDung, months: 6, paidAt: const Day(2026, 8, 1));
  }

  Future<void> openList(WidgetTester tester, {ThemeData? theme}) async {
    await tester.pumpWidget(host(const VehiclesScreen(), theme: theme));
    await settle(tester);
  }

  // ══════════════════════════════════════════════════════════════════════
  // TÌM KIẾM (mục 8 đặc tả)
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('gõ "nguyen" không dấu tìm ra xe của "Nguyễn Văn An"',
      (tester) async {
    await seed();
    await openList(tester);

    await search(tester, 'nguyen');

    expect(find.text('59A1-234.56'), findsOneWidget);
    expect(find.textContaining('Nguyễn Văn An'), findsOneWidget);
    // Ba xe còn lại phải biến mất, nếu không thì bộ lọc chỉ là trang trí.
    expect(find.text('30G-567.89'), findsNothing);
    expect(find.text('29X1-111.11'), findsNothing);
    expect(find.text('51C-999.99'), findsNothing);
  });

  widgetTest('gõ biển số liền không dấu gạch "59a123456" ra "59A1-234.56"',
      (tester) async {
    await seed();
    await openList(tester);

    await search(tester, '59a123456');

    expect(find.text('59A1-234.56'), findsOneWidget);
    expect(find.text('30G-567.89'), findsNothing);
  });

  widgetTest('gõ số điện thoại tìm ra đúng chủ xe', (tester) async {
    await seed();
    await openList(tester);

    await search(tester, '0987');

    expect(find.text('30G-567.89'), findsOneWidget);
    expect(find.textContaining('Trần Thị Bình'), findsOneWidget);
    expect(find.text('59A1-234.56'), findsNothing);
  });

  // ══════════════════════════════════════════════════════════════════════
  // BỘ LỌC
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('lọc theo bãi chỉ còn xe của bãi đó, và chip hiện tên bãi đang lọc',
      (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.text('Mọi bãi'));
    await tester.pumpAndSettle();
    expect(find.text('Lọc theo bãi xe'), findsOneWidget);

    await tester.tap(find.text('Bãi Lê Lợi'));
    await tester.pumpAndSettle();
    await settle(tester);

    // Nhãn chip đổi thành tên bãi — nhìn một cái là biết đang lọc theo gì.
    expect(find.text('Bãi Lê Lợi'), findsOneWidget);
    expect(find.text('30G-567.89'), findsOneWidget);
    expect(find.text('51C-999.99'), findsOneWidget);
    expect(find.text('59A1-234.56'), findsNothing);
    expect(find.text('29X1-111.11'), findsNothing);
  });

  widgetTest('lọc theo loại xe chỉ còn xe đúng loại', (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.text('Mọi loại xe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ô tô'));
    await tester.pumpAndSettle();
    await settle(tester);

    expect(find.text('Ô tô'), findsOneWidget);
    expect(find.text('30G-567.89'), findsOneWidget);
    expect(find.text('59A1-234.56'), findsNothing);
    expect(find.text('51C-999.99'), findsNothing);
  });

  widgetTest(
      'lọc "Đã hết hạn" gom cả xe quá hạn lẫn xe chưa đóng lần nào, bỏ xe còn hạn',
      (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.text('Đã hết hạn'));
    await settle(tester);

    expect(find.text('30G-567.89'), findsOneWidget);
    expect(find.text('29X1-111.11'), findsOneWidget);
    expect(find.text('59A1-234.56'), findsNothing);
    expect(find.text('51C-999.99'), findsNothing);
  });

  widgetTest('lọc "Sắp hết hạn" chỉ còn xe trong ngưỡng nhắc trước',
      (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.text('Sắp hết hạn'));
    await settle(tester);

    expect(find.text('59A1-234.56'), findsOneWidget);
    expect(find.text('còn 5 ngày'), findsOneWidget);
    expect(find.text('30G-567.89'), findsNothing);
    expect(find.text('51C-999.99'), findsNothing);
  });

  widgetTest('nút "Bỏ lọc" xoá cả từ khoá lẫn bộ lọc, danh sách đầy đủ trở lại',
      (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.text('Đã hết hạn'));
    await settle(tester);
    await search(tester, 'nguyen');
    expect(find.text('30G-567.89'), findsNothing);
    // Không còn kết quả nào: nút bỏ lọc phải có mặt ở CẢ hai chỗ — trên thanh
    // chip và ngay trong màn hình trống, vì đó là nơi người dùng đang nhìn.
    expect(find.widgetWithText(OutlinedButton, 'Bỏ lọc'), findsOneWidget);

    await tester.tap(find.widgetWithText(ActionChip, 'Bỏ lọc'));
    await settle(tester);

    // Dòng đếm là bằng chứng cả bốn xe đã trở lại — xe thứ tư nằm ngoài vùng
    // nhìn thấy của màn hình test nên `find.text` không thấy nó.
    expect(find.text('4 xe'), findsOneWidget);
    expect(find.text('59A1-234.56'), findsOneWidget);
    expect(find.text('30G-567.89'), findsOneWidget);
    expect(find.text('29X1-111.11'), findsOneWidget);
  });

  // ══════════════════════════════════════════════════════════════════════
  // HAI TRẠNG THÁI RỖNG KHÁC NHAU
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('chưa có xe nào thì hiện lời mời thêm xe, không phải "không tìm thấy"',
      (tester) async {
    await openList(tester);

    expect(find.text('Chưa có xe nào trong bãi'), findsOneWidget);
    expect(find.text('Bấm nút "Thêm xe" ở góc dưới để đăng ký chiếc đầu tiên.'),
        findsOneWidget);
    expect(find.text('Không tìm thấy kết quả nào'), findsNothing);
  });

  widgetTest('tìm không ra thì hiện câu "không tìm thấy", khác hẳn câu rỗng',
      (tester) async {
    await seed();
    await openList(tester);

    await search(tester, 'khongcoxenaotenthenay');

    expect(find.text('Không tìm thấy kết quả nào'), findsOneWidget);
    expect(find.text('Không có xe nào khớp. Thử đổi từ khoá hoặc bỏ bớt bộ lọc.'),
        findsOneWidget);
    expect(find.text('Chưa có xe nào trong bãi'), findsNothing);
  });

  // ══════════════════════════════════════════════════════════════════════
  // XE CHƯA ĐÓNG TIỀN ≠ XE QUÁ HẠN
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('xe chưa đóng tiền lần nào hiện khác hẳn xe đã quá hạn',
      (tester) async {
    await seed();
    await openList(tester);

    // Chưa đóng lần nào: thẻ riêng + câu nói rõ mốc bắt đầu gửi.
    expect(find.text('Chưa thu tiền'), findsOneWidget);
    expect(find.text('Chưa đóng lần nào — gửi từ 01/08/2026'), findsOneWidget);

    // Quá hạn: chữ số ngày quá hạn, kèm ngày hết hạn cụ thể.
    expect(find.text('quá hạn 70 ngày'), findsOneWidget);
    expect(find.text('Hết hạn ngày 01/06/2026'), findsOneWidget);

    // Màu không bao giờ là tín hiệu duy nhất — mọi thẻ đều có chữ.
    expect(find.text('còn 5 ngày'), findsOneWidget);
  });

  // ══════════════════════════════════════════════════════════════════════
  // THÊM XE
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('thêm xe mới: nhập đủ thông tin và lưu xong có trong DB',
      (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bãi Lê Lợi').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Chủ xe'), 'Hoàng Văn Em');
    await tester.enterText(
        find.widgetWithText(TextField, 'Biển số'), '43A1-234.56');
    await tester.enterText(
        find.widgetWithText(TextField, Strings.vehicleMonthlyFee), '250000');
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.text('Lưu'));
    await tester.pumpAndSettle();
    await settle(tester);

    final row = await (db.select(db.vehicles)
          ..where((t) => t.plateNormalized.equals('43A123456')))
        .getSingle();
    expect(row.ownerName, 'Hoàng Văn Em');
    expect(row.lotId, lotB);
    expect(row.monthlyPrice, 250000);
    expect(row.startDate, const Day(2026, 8, 10),
        reason: 'ngày bắt đầu mặc định là hôm nay theo đồng hồ đã tiêm');
    expect(row.currentPeriodEnd, const Day(2026, 9, 10),
        reason: 'tự động đăng ký 1 tháng ban đầu nên ngày kết thúc là 10/09/2026');
    expect(row.ownerNameFold, 'hoang van em');
  });

  widgetTest('chủ xe và SĐT được phép trùng nhau trên nhiều xe khác nhau',
      (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bãi Lê Lợi').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Chủ xe'), 'Nguyễn Văn An');
    await tester.enterText(
        find.widgetWithText(TextField, 'Biển số'), '99A1-999.99');
    await tester.enterText(
        find.widgetWithText(TextField, Strings.vehicleMonthlyFee), '150000');
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.text('Lưu'));
    await tester.pumpAndSettle();
    await settle(tester);

    final row = await (db.select(db.vehicles)
          ..where((t) => t.plateNormalized.equals('99A199999')))
        .getSingle();
    expect(row.ownerName, 'Nguyễn Văn An');
  });

  widgetTest('nút Lưu bị vô hiệu khi chưa đủ trường bắt buộc', (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    FilledButton saveButton() => tester.widget<FilledButton>(find.ancestor(
          of: find.text('Lưu'),
          matching: find.byType(FilledButton),
        ));

    expect(saveButton().onPressed, isNull, reason: 'chưa chọn bãi, chưa nhập gì');

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bãi Nguyễn Trãi').last);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Chủ xe'), 'Hoàng Văn Em');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNull, reason: 'còn thiếu biển số và giá');

    await tester.enterText(
        find.widgetWithText(TextField, 'Biển số'), '43A1-234.56');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNull, reason: 'còn thiếu giá');

    await tester.enterText(
        find.widgetWithText(TextField, Strings.vehicleMonthlyFee), '100000');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNotNull);
  });

  widgetTest(
      'trùng biển số trong cùng bãi hiện thông báo tiếng Việt, không lộ lỗi SQLite',
      (tester) async {
    await seed();
    await openList(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bãi Nguyễn Trãi').last);
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Chủ xe'), 'Người khác');
    // Cùng biển số với xe của Nguyễn Văn An, chỉ khác cách gõ dấu phân cách.
    await tester.enterText(
        find.widgetWithText(TextField, 'Biển số'), '59 A1 234 56');
    await tester.enterText(
        find.widgetWithText(TextField, Strings.vehicleMonthlyFee), '100000');
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.text('Lưu'));
    await tester.pumpAndSettle();
    await settle(tester);

    expect(tester.takeException(), isNull, reason: 'không được để văng ngoại lệ');
    expect(find.text('Biển số này đã có trong bãi'), findsOneWidget);
    expect(
      find.textContaining('UNIQUE'),
      findsNothing,
      reason: 'không được để lộ câu lỗi SQLite thô',
    );
    // Bảng vẫn mở để người dùng sửa ngay, và DB không có bản ghi rác.
    final count = await db
        .customSelect(
            "SELECT COUNT(*) AS c FROM vehicles WHERE owner_name = 'Người khác'")
        .getSingle();
    expect(count.read<int>('c'), 0);
  });

  // ══════════════════════════════════════════════════════════════════════
  // MÀN HÌNH CHI TIẾT
  // ══════════════════════════════════════════════════════════════════════

  widgetTest(
      'chi tiết hiện đủ lịch sử thu tiền; biên lai đã huỷ gạch ngang chứ không biến mất',
      (tester) async {
    tallScreen(tester);
    await seed();
    await openList(tester);

    await scrollAndTap(tester, find.text('59A1-234.56'));
    await pumpRoute(tester);

    // Thông tin đăng ký.
    expect(find.text('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('0912 345 678'), findsOneWidget);
    expect(find.text('Xe máy'), findsOneWidget);
    expect(find.text('Bãi Nguyễn Trãi'), findsOneWidget);
    expect(find.text('15/08/2026'), findsOneWidget);
    expect(find.text('còn 5 ngày'), findsOneWidget);
    // Cache trên bản ghi xe chỉ tính biên lai còn hiệu lực.
    expect(find.text('Tổng số tháng đã đóng'), findsOneWidget);
    expect(find.text('1 tháng'), findsOneWidget);

    // Cả hai biên lai đều có mặt.
    expect(find.text('Lịch sử thanh toán'), findsOneWidget);
    expect(find.text('Đóng cho 1 tháng · Tiền mặt'), findsOneWidget);
    expect(find.text('Đóng cho 3 tháng · Tiền mặt'), findsOneWidget);

    // Biên lai đã huỷ: còn nguyên trên màn hình, gạch ngang và có chữ "Đã huỷ".
    expect(find.text('300.000 ₫'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('300.000 ₫')).style?.decoration,
      TextDecoration.lineThrough,
    );
    expect(find.text('Đã huỷ'), findsOneWidget);

    // Biên lai còn hiệu lực thì KHÔNG bị gạch. (`TextTheme` của ứng dụng đặt
    // sẵn `TextDecoration.none`, nên so với "không phải gạch ngang" chứ không
    // so với `null`.)
    expect(
      tester
          .widget<Text>(find.text('Đóng cho 1 tháng · Tiền mặt'))
          .style
          ?.decoration,
      isNot(TextDecoration.lineThrough),
    );
  });

  widgetTest('huỷ một biên lai từ màn hình chi tiết thì hạn của xe tính lại',
      (tester) async {
    tallScreen(tester);
    await seed();
    await openList(tester);

    await scrollAndTap(tester, find.text('30G-567.89'));
    await pumpRoute(tester);

    await scrollAndTap(tester, find.byIcon(Icons.block));
    await pumpRoute(tester);

    expect(find.text('Huỷ phiếu thu này?'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Lý do huỷ (không bắt buộc)'),
        'Khách trả lại tiền');
    await tester.tap(find.widgetWithText(FilledButton, 'Huỷ phiếu thu'));
    await pumpRoute(tester);

    final row = await (db.select(db.vehicles)
          ..where((t) => t.id.equals(vBinh)))
        .getSingle();
    expect(row.currentPeriodEnd, isNull,
        reason: 'huỷ biên lai duy nhất thì xe quay về trạng thái chưa đóng');
    expect(row.totalPaid, 0);
    // Bản ghi vẫn còn, chỉ được đánh dấu huỷ.
    expect(find.text('Đã huỷ'), findsOneWidget);
  });

  widgetTest('kết thúc gửi: status đổi và xe biến khỏi danh sách mặc định',
      (tester) async {
    tallScreen(tester);
    await seed();
    await openList(tester);

    expect(find.text('59A1-234.56'), findsOneWidget);
    await scrollAndTap(tester, find.text('59A1-234.56'));
    await pumpRoute(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await pumpRoute(tester);
    await tester.tap(find.text('Kết thúc gửi'));
    await pumpRoute(tester);

    expect(find.text('Ngừng gửi xe?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Ngừng gửi'));
    await pumpRoute(tester);

    final row =
        await (db.select(db.vehicles)..where((t) => t.id.equals(vAn))).getSingle();
    expect(row.status, VehicleStatus.stopped);
    expect(row.leftOn, const Day(2026, 8, 10));

    // Quay về danh sách và xe không còn nằm trong bộ lọc mặc định.
    expect(find.text('59A1-234.56'), findsNothing);
    expect(find.text('30G-567.89'), findsOneWidget);
  });

  widgetTest('xoá xe có xác nhận, xoá xong xe rời khỏi danh sách',
      (tester) async {
    tallScreen(tester);
    await seed();
    await openList(tester);

    await scrollAndTap(tester, find.text('29X1-111.11'));
    await pumpRoute(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await pumpRoute(tester);
    await tester.tap(find.text('Xoá'));
    await pumpRoute(tester);

    expect(find.text('Xoá "29X1-111.11"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Xoá'));
    await pumpRoute(tester);

    final row = await (db.select(db.vehicles)
          ..where((t) => t.id.equals(vCuong)))
        .getSingle();
    expect(row.deletedAt, isNotNull);
    expect(find.text('29X1-111.11'), findsNothing);
  });

  // ══════════════════════════════════════════════════════════════════════
  // GIAO DIỆN
  // ══════════════════════════════════════════════════════════════════════

  widgetTest('dựng được ở giao diện tối', (tester) async {
    await seed();
    await openList(tester, theme: AppTheme.dark);

    expect(tester.takeException(), isNull);
    expect(find.text('59A1-234.56'), findsOneWidget);
    expect(find.text('Chưa thu tiền'), findsOneWidget);
  });

  widgetTest('không tràn layout ở màn hình iPhone hẹp nhất (375x667)',
      (tester) async {
    // iPhone SE.
    tester.view.physicalSize = const Size(375 * 3, 667 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await seed();
    await openList(tester);
    expect(tester.takeException(), isNull);

    // Mở cả form thêm xe ở khổ hẹp — đây là nơi dễ tràn nhất.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Thêm xe'), findsWidgets);
  });
}
