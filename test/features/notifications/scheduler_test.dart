import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/notifications/data/notification_scheduler.dart';
import 'package:quan_ly_bai_xe/src/features/notifications/data/notification_service.dart';
import 'package:quan_ly_bai_xe/src/features/notifications/domain/digest_plan.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';

/// Giả lập lớp chạm hệ điều hành, để kiểm được phần điều phối mà không cần
/// thiết bị hay plugin thật.
class FakeNotificationService implements NotificationService {
  bool permission = true;
  int cancelCount = 0;
  final List<DigestPlan> scheduled = [];

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<void> cancelDigests() async => cancelCount++;

  @override
  Future<int> schedule(DigestPlan plan) async {
    scheduled.add(plan);
    return plan.entries.length;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} không dùng trong test');
}

void main() {
  late AppDatabase db;
  late FakeNotificationService service;
  late NotificationScheduler scheduler;
  late PaymentRepository payments;
  final clock = FixedClock(DateTime(2026, 9, 1, 7));
  late int lotId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = FakeNotificationService();
    scheduler = NotificationScheduler(db, service, clock);
    payments = PaymentRepository(db, clock);
    lotId = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi test',
          nameFold: 'bai test',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ));
  });

  tearDown(() async {
    await scheduler.dispose();
    await db.close();
  });

  Future<int> vehicle(String plate, {required int daysLeft}) async {
    // Đi ngược từ hạn mong muốn: đóng 1 tháng, nên bắt đầu = hạn - 1 tháng.
    final end = const Day(2026, 9, 1).addDays(daysLeft);
    final start = Day(end.year, end.month - 1, end.day);
    final id = await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'Chủ $plate',
          ownerNameFold: 'chu',
          vehicleType: VehicleType.motorbike,
          plate: plate,
          plateNormalized: plate.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''),
          monthlyPrice: 100000,
          startDate: start,
          anchorDay: start.day,
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));
    await payments.recordPayment(vehicleId: id, months: 1, paidAt: start);
    return id;
  }

  test('đặt lịch xong thì lần gọi sau bị BỎ QUA vì kế hoạch không đổi', () async {
    await vehicle('29A-111.11', daysLeft: 3);

    final first = await scheduler.reschedule();
    expect(first, greaterThan(0));
    expect(service.scheduled, hasLength(1));

    final second = await scheduler.reschedule();
    expect(second, -1, reason: 'kế hoạch y hệt thì không đụng tới hệ điều hành');
    expect(service.scheduled, hasLength(1), reason: 'không đặt lịch lần hai');
  });

  test('gia hạn một xe thì kế hoạch đổi và được đặt lại', () async {
    final v = await vehicle('29A-222.22', daysLeft: 3);
    await scheduler.reschedule();
    final before = service.scheduled.single.hash;

    await payments.recordPayment(vehicleId: v, months: 6);

    final n = await scheduler.reschedule();
    expect(n, isNot(-1), reason: 'gia hạn xong hạn đổi nên kế hoạch phải đổi');
    expect(service.scheduled.last.hash, isNot(before));
  });

  test('nội dung thông báo đúng câu chữ đặc tả', () async {
    for (var i = 0; i < 5; i++) {
      await vehicle('29A-00$i.00', daysLeft: 3);
    }
    await scheduler.reschedule();

    final bodies = service.scheduled.single.entries.map((e) => e.body).toList();
    expect(bodies.any((b) => b.contains('Có 5 xe sẽ hết hạn trong vòng 3 ngày.')),
        isTrue);
  });

  test('không có quyền thì huỷ hết và không đặt gì', () async {
    await vehicle('29A-333.33', daysLeft: 3);
    service.permission = false;

    final n = await scheduler.reschedule();
    expect(n, 0);
    expect(service.cancelCount, 1);
    expect(service.scheduled, isEmpty);
  });

  test('tắt nhắc hạn thì huỷ hết, kể cả khi có quyền', () async {
    await vehicle('29A-444.44', daysLeft: 3);
    final n = await scheduler
        .reschedule(prefs: const NotificationPrefs(enabled: false));
    expect(n, 0);
    expect(service.scheduled, isEmpty);
  });

  test('bật lại sau khi tắt thì đặt lịch lại từ đầu', () async {
    await vehicle('29A-555.55', daysLeft: 3);
    await scheduler.reschedule();
    expect(service.scheduled, hasLength(1));

    await scheduler.reschedule(prefs: const NotificationPrefs(enabled: false));
    // Băm đã bị xoá nên lần bật lại phải đặt lịch thật, không bị bỏ qua.
    final n = await scheduler.reschedule();
    expect(n, greaterThan(0));
    expect(service.scheduled, hasLength(2));
  });

  test('số thông báo chờ không vượt cửa sổ, an toàn dưới trần 64 của iOS',
      () async {
    for (var d = 1; d <= 40; d++) {
      await vehicle('29Z-${d.toString().padLeft(3, '0')}.00', daysLeft: d);
    }
    await scheduler.reschedule();
    expect(service.scheduled.single.entries.length, lessThanOrEqualTo(30));
  });

  test('xe đã xoá mềm không được tính vào thông báo', () async {
    final v = await vehicle('29A-666.66', daysLeft: 3);
    await scheduler.reschedule();
    final withVehicle = service.scheduled.single.entries.length;

    await (db.update(db.vehicles)..where((t) => t.id.equals(v)))
        .write(VehiclesCompanion(deletedAt: Value(DateTime.utc(2026, 9, 1))));

    final n = await scheduler.reschedule();
    expect(n, isNot(-1));
    expect(service.scheduled.last.entries.length, lessThan(withVehicle));
  });

  test('không có xe nào thì kế hoạch rỗng, không lỗi', () async {
    final n = await scheduler.reschedule();
    expect(n, 0);
  });
}
