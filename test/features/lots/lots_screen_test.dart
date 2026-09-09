import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/strings/strings.dart';
import 'package:quan_ly_bai_xe/src/features/lots/presentation/lots_strings.dart';
import 'package:quan_ly_bai_xe/src/core/text/vi_normalize.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/lots/presentation/lots_screen.dart';
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
/// nó chỉ in cảnh báo rồi test đỏ ở dòng `expect` phía sau.
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

  Future<int> addLot(
    String name, {
    String? address,
    int price = 0,
    int? capacity,
  }) {
    return db.into(db.lots).insert(LotsCompanion.insert(
          name: name,
          nameFold: viFold(name),
          address: Value(address),
          capacity: Value(capacity),
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));
  }

  Future<void> addVehicles(int lotId, int count) async {
    for (var i = 0; i < count; i++) {
      await db.into(db.vehicles).insert(VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: 'Chủ xe $i',
            ownerNameFold: 'chu xe $i',
            vehicleType: VehicleType.motorbike,
            plate: '59A1-000.0$i',
            plateNormalized: '59A10000$i',
            monthlyPrice: 100000,
            startDate: const Day(2026, 7, 15),
            anchorDay: 15,
            createdAt: DateTime.utc(2026, 7, 15),
            updatedAt: DateTime.utc(2026, 7, 15),
          ));
    }
  }

  Future<void> openAddSheet(WidgetTester tester) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  widgetTest('danh sách rỗng hiện đúng trạng thái rỗng', (tester) async {
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    expect(find.text(Strings.lotEmpty), findsOneWidget);
    expect(find.text(Strings.lotEmptyHint), findsOneWidget);
    // Trạng thái rỗng phải có lối thoát ngay tại chỗ, không bắt đi tìm nút `+`.
    expect(find.widgetWithText(FilledButton, Strings.lotAdd), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  widgetTest('thêm bãi qua form thì bãi vào CSDL và hiện trên danh sách',
      (tester) async {
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    await openAddSheet(tester);
    expect(find.text(Strings.lotAdd), findsWidgets);

    await tester.enterText(
        find.widgetWithText(TextField, Strings.lotName), 'Bãi Nguyễn Trãi');
    await tester.enterText(
        find.widgetWithText(TextField, Strings.lotAddress), '12 Nguyễn Trãi');
    await tester.enterText(
        find.widgetWithText(TextField, Strings.lotCapacity), '50');
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.widgetWithText(FilledButton, Strings.save));
    await tester.pumpAndSettle();
    await settle(tester);

    final rows = await db.select(db.lots).get();
    expect(rows.length, 1);
    expect(rows.single.name, 'Bãi Nguyễn Trãi');
    expect(rows.single.address, '12 Nguyễn Trãi');
    expect(rows.single.capacity, 50);
    expect(rows.single.nameFold, 'bai nguyen trai',
        reason: 'cột tìm kiếm không dấu phải được sinh cùng lúc');

    expect(find.text('Bãi Nguyễn Trãi'), findsOneWidget);
  });

  widgetTest('sửa tên và sức chứa thì CSDL đổi đúng', (tester) async {
    final id = await addLot('Bãi A', capacity: 20);
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    // Chạm vào dòng để sửa.
    await scrollAndTap(tester, find.text('Bãi A'));
    await tester.pumpAndSettle();
    expect(find.text(Strings.lotEdit), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, Strings.lotName), 'Bãi B');
    await tester.enterText(
        find.widgetWithText(TextField, Strings.lotCapacity), '30');
    await tester.pumpAndSettle();

    await scrollAndTap(tester, find.widgetWithText(FilledButton, Strings.save));
    await tester.pumpAndSettle();
    await settle(tester);

    final row =
        await (db.select(db.lots)..where((l) => l.id.equals(id))).getSingle();
    expect(row.name, 'Bãi B');
    expect(row.nameFold, 'bai b');
    expect(row.capacity, 30);
    expect(find.text('Bãi B'), findsOneWidget);
    expect(find.text('Bãi A'), findsNothing);
  });

  widgetTest('bãi KHÔNG khai sức chứa thì không hiện tỷ lệ lấp đầy',
      (tester) async {
    final id = await addLot('Bãi không rõ sức chứa');
    await addVehicles(id, 3);
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    expect(find.text('Bãi không rõ sức chứa'), findsOneWidget);
    // Số xe vẫn hiện — chỉ tỷ lệ lấp đầy là bị ẩn.
    expect(find.text('3 xe'), findsOneWidget);
    // Thà không hiện còn hơn hiện 0%.
    expect(find.textContaining('%'), findsNothing);
    expect(find.text(Strings.lotFull), findsNothing);
  });

  widgetTest('bãi có sức chứa thì hiện đúng phần trăm lấp đầy', (tester) async {
    final id = await addLot('Bãi Nguyễn Trãi', capacity: 10);
    await addVehicles(id, 4);
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    expect(find.text('40%'), findsOneWidget);
    expect(find.text(Strings.occupancy(4, 10)), findsOneWidget);
    expect(find.text(Strings.lotFull), findsNothing);
  });

  widgetTest('bãi đầy thì hiện cảnh báo thay cho con số phần trăm',
      (tester) async {
    final id = await addLot('Bãi chật', capacity: 2);
    await addVehicles(id, 2);
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    expect(find.text(Strings.lotFull), findsOneWidget);
    expect(find.text(Strings.occupancy(2, 2)), findsOneWidget);
  });

  widgetTest('xe chưa đóng tiền hiện là CHƯA THU, không phải đã hết hạn',
      (tester) async {
    // Hai việc khác nhau: xe chưa từng có kỳ hạn thì không thể gọi là hết hạn,
    // và cách xử lý cũng khác — một bên nhắc gia hạn, một bên thu lần đầu.
    // Màn hình tổng quan cũng tách hai loại này, nên nếu ở đây gộp chung thì
    // hai màn hình sẽ hiện hai con số khác nhau cho cùng một bãi.
    final id = await addLot('Bãi A', capacity: 10);
    await addVehicles(id, 2);
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    expect(find.text(LotsStrings.vehiclesNeverPaid(2)), findsOneWidget);
    expect(find.text(Strings.vehiclesExpired(2)), findsNothing);
  });

  widgetTest('xoá bãi còn xe bị CHẶN và báo rõ còn bao nhiêu xe',
      (tester) async {
    final id = await addLot('Bãi A');
    await addVehicles(id, 2);
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    await scrollAndTap(tester, find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text(Strings.confirmDeleteNamed('Bãi A')), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, Strings.delete));
    await tester.pumpAndSettle();
    await settle(tester);

    // Thông điệp phải nói CON SỐ, không phải câu chung chung.
    expect(find.textContaining('còn 2 xe'), findsOneWidget);
    expect(find.textContaining('chuyển hoặc kết thúc'), findsOneWidget);

    final row =
        await (db.select(db.lots)..where((l) => l.id.equals(id))).getSingle();
    expect(row.deletedAt, isNull, reason: 'bãi phải còn nguyên');
    expect(find.text('Bãi A'), findsOneWidget);
  });

  widgetTest('xoá bãi rỗng thì thành công và đặt deletedAt', (tester) async {
    final id = await addLot('Bãi A');
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);

    await scrollAndTap(tester, find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, Strings.delete));
    await tester.pumpAndSettle();
    await settle(tester);

    final row =
        await (db.select(db.lots)..where((l) => l.id.equals(id))).getSingle();
    expect(row.deletedAt, isNotNull);
    // Xoá mềm: dòng vẫn nằm trong bảng nhưng biến khỏi danh sách.
    expect(find.text('Bãi A'), findsNothing);
    expect(find.text(Strings.lotEmpty), findsOneWidget);
  });

  widgetTest('nút Lưu vô hiệu khi tên bãi để trống', (tester) async {
    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);
    await openAddSheet(tester);

    FilledButton saveButton() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, Strings.save));

    expect(saveButton().onPressed, isNull, reason: 'chưa nhập tên thì không lưu');

    // Khoảng trắng vẫn coi như trống.
    await tester.enterText(
        find.widgetWithText(TextField, Strings.lotName), '   ');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNull);

    await tester.enterText(
        find.widgetWithText(TextField, Strings.lotName), 'Bãi A');
    await tester.pumpAndSettle();
    expect(saveButton().onPressed, isNotNull);

    expect(await db.select(db.lots).get(), isEmpty);
  });

  widgetTest('dựng được ở giao diện tối', (tester) async {
    final id = await addLot('Bãi Nguyễn Trãi', address: '12 Nguyễn Trãi',
        price: 150000, capacity: 10);
    await addVehicles(id, 4);
    await tester.pumpWidget(host(const LotsScreen(), theme: AppTheme.dark));
    await settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Bãi Nguyễn Trãi'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
  });

  widgetTest('không tràn layout ở màn hình 375x667', (tester) async {
    // iPhone SE: 375 x 667
    tester.view.physicalSize = const Size(375 * 3, 667 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final a = await addLot('Bãi Nguyễn Trãi Cơ Sở Hai Rất Dài',
        address: '123 đường Nguyễn Trãi, phường Thanh Xuân Trung, Hà Nội',
        price: 1500000,
        capacity: 4);
    await addVehicles(a, 4);
    final b = await addLot('Bãi B', capacity: 100);
    await addVehicles(b, 3);
    await addLot('Bãi C');

    await tester.pumpWidget(host(const LotsScreen()));
    await settle(tester);
    expect(tester.takeException(), isNull);

    // Cả bảng thêm bãi cũng phải vừa màn hình hẹp.
    await openAddSheet(tester);
    expect(tester.takeException(), isNull);
  });
}
