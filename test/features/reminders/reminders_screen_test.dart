import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/providers.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';
import 'package:quan_ly_bai_xe/src/features/reminders/presentation/reminders_screen.dart';
import 'package:quan_ly_bai_xe/src/theme/app_theme.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Tháo cây widget ngay trong thân test: Drift lên lịch một Timer 0ms khi
/// stream bị huỷ, để `ProviderScope` tháo sau thân test thì timer còn treo lúc
/// khung kiểm thử soát bất biến.
void widgetTest(String d, Future<void> Function(WidgetTester) body) {
  testWidgets(d, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}

void main() {
  late AppDatabase db;
  late PaymentRepository pay;
  late int lotId;
  final clock = FixedClock(DateTime(2026, 9, 8, 9));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    pay = PaymentRepository(db, clock);
    lotId = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi A',
          nameFold: 'bai a',
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
          home: const RemindersScreen(),
        ),
      );

  /// Tạo xe có hạn cách hôm nay [daysLeft] ngày (âm = đã quá hạn).
  Future<int> vehicle(String plate, {required int daysLeft, String? phone}) async {
    final end = const Day(2026, 9, 8).addDays(daysLeft);
    final start = Day(end.year, end.month - 1, end.day);
    final id = await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'Chủ $plate',
          ownerNameFold: 'chu',
          phone: Value(phone),
          phoneDigits: Value(phone?.replaceAll(RegExp(r'\D'), '')),
          vehicleType: VehicleType.motorbike,
          plate: plate,
          plateNormalized: plate.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''),
          monthlyPrice: 150000,
          startDate: start,
          anchorDay: start.day,
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));
    await pay.recordPayment(vehicleId: id, months: 1, paidAt: start);
    return id;
  }

  widgetTest('mặc định mở nhóm Tuần này', (tester) async {
    await vehicle('29A-111.11', daysLeft: 3);
    await tester.pumpWidget(host());
    await settle(tester);
    expect(find.text('29A-111.11'), findsOneWidget);
  });

  widgetTest('nhóm Hôm nay chỉ lấy xe tới hạn hôm nay và xe đã quá hạn',
      (tester) async {
    await vehicle('29A-HOMNAY.00', daysLeft: 0);
    await vehicle('29A-QUAHAN.00', daysLeft: -5);
    await vehicle('29A-TUANSAU.00', daysLeft: 5);

    await tester.pumpWidget(host());
    await settle(tester);
    await tester.tap(find.text('Hôm nay'));
    await settle(tester);

    expect(find.text('29A-HOMNAY.00'), findsOneWidget);
    expect(find.text('29A-QUAHAN.00'), findsOneWidget,
        reason: 'xe trễ hạn là thứ cần đòi nhất, không được biến mất');
    expect(find.text('29A-TUANSAU.00'), findsNothing);
  });

  widgetTest('nhóm Tháng này lấy được cả xe hết hạn sau 20 ngày',
      (tester) async {
    await vehicle('29A-M20.00', daysLeft: 20);
    await tester.pumpWidget(host());
    await settle(tester);

    expect(find.text('29A-M20.00'), findsNothing, reason: 'quá 7 ngày');

    await tester.tap(find.text('Tháng này'));
    await settle(tester);
    expect(find.text('29A-M20.00'), findsOneWidget);
  });

  widgetTest('xe quá hạn lâu nhất xếp lên ĐẦU', (tester) async {
    await vehicle('29A-TRE1.00', daysLeft: -1);
    await vehicle('29A-TRE9.00', daysLeft: -9);
    await vehicle('29A-CON3.00', daysLeft: 3);

    await tester.pumpWidget(host());
    await settle(tester);

    final plates = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .where((s) => s != null && s.startsWith('29A-'))
        .toList();
    expect(plates.first, '29A-TRE9.00');
  });

  widgetTest('hiện tổng số xe và tiền dự kiến thu', (tester) async {
    await vehicle('29A-001.00', daysLeft: 1);
    await vehicle('29A-002.00', daysLeft: 2);
    await tester.pumpWidget(host());
    await settle(tester);

    expect(find.textContaining('2 xe'), findsOneWidget);
    expect(find.textContaining('300.000'), findsOneWidget,
        reason: '2 xe × 150.000');
  });

  widgetTest('xe không có số điện thoại thì nói rõ, không hiện nút gọi rỗng',
      (tester) async {
    await vehicle('29A-NOPHONE.0', daysLeft: 2);
    await tester.pumpWidget(host());
    await settle(tester);
    expect(find.text('Chưa có số điện thoại'), findsOneWidget);
  });

  widgetTest('có số điện thoại thì hiện số để bấm gọi', (tester) async {
    await vehicle('29A-PHONE.00', daysLeft: 2, phone: '0912345678');
    await tester.pumpWidget(host());
    await settle(tester);
    expect(find.text('0912345678'), findsOneWidget);
  });

  widgetTest('đánh dấu đã nhắc ghi vào DB và đổi hiển thị', (tester) async {
    final v = await vehicle('29A-NHAC.00', daysLeft: 2);
    await tester.pumpWidget(host());
    await settle(tester);

    await tester.ensureVisible(find.text('Đã nhắc'));
    await tester.pump();
    await tester.tap(find.text('Đã nhắc'));
    await settle(tester);

    final row =
        await (db.select(db.vehicles)..where((t) => t.id.equals(v))).getSingle();
    expect(row.lastRemindedAt, isNotNull);
    expect(row.remindedForPeriodEnd, row.currentPeriodEnd);
  });

  widgetTest('xe chưa đóng tiền lần nào luôn nằm trong danh sách',
      (tester) async {
    await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'Khách mới',
          ownerNameFold: 'khach moi',
          vehicleType: VehicleType.motorbike,
          plate: '29A-MOI.000',
          plateNormalized: '29AMOI000',
          monthlyPrice: 150000,
          startDate: const Day(2026, 9, 8),
          anchorDay: 8,
          createdAt: DateTime.utc(2026, 9, 8),
          updatedAt: DateTime.utc(2026, 9, 8),
        ));
    await tester.pumpWidget(host());
    await settle(tester);
    expect(find.text('29A-MOI.000'), findsOneWidget);
    expect(find.text('Đã quá hạn'), findsOneWidget);
  });

  widgetTest('không có xe nào cần nhắc thì hiện trạng thái rỗng', (tester) async {
    await vehicle('29A-XA.0000', daysLeft: 90);
    await tester.pumpWidget(host());
    await settle(tester);
    expect(find.text('Tuần này không có xe nào tới hạn'), findsOneWidget);
  });

  widgetTest('dựng được ở giao diện tối, không tràn ở màn hình hẹp',
      (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 667 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await vehicle('29A-DARK.000', daysLeft: 2, phone: '0912345678');
    await tester.pumpWidget(host(theme: AppTheme.dark));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
