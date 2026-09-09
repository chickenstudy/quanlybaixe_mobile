import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/lots/data/lot_repository.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';
import 'package:quan_ly_bai_xe/src/features/settings/presentation/activity_log_screen.dart';
import 'package:quan_ly_bai_xe/src/features/settings/presentation/settings_providers.dart';
import 'package:quan_ly_bai_xe/src/features/vehicles/data/vehicle_repository.dart';
import 'package:quan_ly_bai_xe/src/theme/app_theme.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void widgetTest(String d, Future<void> Function(WidgetTester) body) {
  testWidgets(d, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}

void main() {
  late AppDatabase db;
  final clock = FixedClock(DateTime(2026, 9, 8, 14, 30));

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget host(Widget child, {ThemeData? theme}) => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
        ],
        child: MaterialApp(theme: theme ?? AppTheme.light, home: child),
      );

  group('Nhật ký thao tác', () {
    widgetTest('rỗng thì nói rõ chưa có thao tác nào', (tester) async {
      await tester.pumpWidget(host(const ActivityLogScreen()));
      await settle(tester);
      expect(find.text('Chưa có thao tác nào được ghi'), findsOneWidget);
    });

    widgetTest('ghi lại đủ chuỗi thao tác: tạo bãi, thêm xe, thu tiền, huỷ',
        (tester) async {
      final lots = LotRepository(db, clock);
      final vehicles = VehicleRepository(db, clock);
      final pay = PaymentRepository(db, clock);

      final lotId = await lots.create(name: 'Bãi Nguyễn Trãi');
      final vId = await vehicles.create(
        lotId: lotId,
        ownerName: 'Nguyễn Văn An',
        phone: '0912345678',
        type: VehicleType.motorbike,
        plate: '59A1-234.56',
        monthlyPrice: 150000,
        startDate: const Day(2026, 9, 1),
      );
      final r = await pay.recordPayment(vehicleId: vId, months: 3);
      await pay.voidPayment(r.paymentId, reason: 'khách đổi ý');

      await tester.pumpWidget(host(const ActivityLogScreen()));
      await settle(tester);

      expect(find.textContaining('Thêm bãi xe "Bãi Nguyễn Trãi"'), findsOneWidget);
      expect(find.textContaining('Thêm xe 59A1-234.56'), findsOneWidget);
      expect(find.textContaining('Thu tiền xe 59A1-234.56'), findsOneWidget);
      expect(find.textContaining('khách đổi ý'), findsOneWidget);
      expect(find.text('08/09/2026 14:30'), findsWidgets);
    });

    widgetTest('câu nhật ký VẪN ĐỌC ĐÚNG sau khi xe bị xoá', (tester) async {
      // Đây là cách nhật ký thao tác hay hỏng nhất: dựng câu lúc đọc thì bản
      // ghi biến mất là câu vỡ. Ở đây câu được dựng sẵn lúc ghi.
      final lots = LotRepository(db, clock);
      final vehicles = VehicleRepository(db, clock);
      final lotId = await lots.create(name: 'Bãi A');
      final vId = await vehicles.create(
        lotId: lotId,
        ownerName: 'Trần Thị Hồng',
        type: VehicleType.car,
        plate: '30G-123.45',
        monthlyPrice: 900000,
        startDate: const Day(2026, 9, 1),
      );
      await db.delete(db.vehicles).go(); // xoá cứng, khắc nghiệt hơn xoá mềm

      await tester.pumpWidget(host(const ActivityLogScreen()));
      await settle(tester);
      expect(find.textContaining('Thêm xe 30G-123.45'), findsOneWidget);
      expect(vId, isNotNull);
    });

    widgetTest('mới nhất lên đầu', (tester) async {
      final lots = LotRepository(db, clock);
      await lots.create(name: 'Bãi thứ nhất');
      await lots.create(name: 'Bãi thứ hai');

      await tester.pumpWidget(host(const ActivityLogScreen()));
      await settle(tester);

      final titles = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .where((s) => s.startsWith('Thêm bãi xe'))
          .toList();
      expect(titles.first, contains('Bãi thứ hai'));
    });

    widgetTest('dựng được ở giao diện tối', (tester) async {
      await LotRepository(db, clock).create(name: 'Bãi A');
      await tester.pumpWidget(
          host(const ActivityLogScreen(), theme: AppTheme.dark));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('Cài đặt nhắc hạn', () {
    test('mặc định là bật, giờ nhắc 8:00', () async {
      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
      ]);
      addTearDown(container.dispose);

      final prefs = await container.read(notificationPrefsProvider.future);
      expect(prefs.enabled, isTrue);
      expect(prefs.hour, 8);
    });

    test('giờ nhắc được LƯU VÀO CSDL nên đi theo file sao lưu', () async {
      await db.into(db.appSettings).insertOnConflictUpdate(
          const AppSettingRow(key: 'notify_hour', value: '19'));
      await db.into(db.appSettings).insertOnConflictUpdate(
          const AppSettingRow(key: 'notify_enabled', value: 'false'));

      final container = ProviderContainer(overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
      ]);
      addTearDown(container.dispose);

      final prefs = await container.read(notificationPrefsProvider.future);
      expect(prefs.hour, 19);
      expect(prefs.enabled, isFalse);
    });
  });
}
