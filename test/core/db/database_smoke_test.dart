import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('mở được DB trong bộ nhớ và tạo đủ bảng', () async {
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
        .get();
    final names = tables.map((r) => r.read<String>('name')).toSet();
    expect(names, containsAll(<String>[
      'lots',
      'vehicles',
      'payments',
      'payment_allocations',
      'recurring_cost_templates',
      'expenses',
      'activity_log',
      'app_settings',
    ]));
  });

  test('các chỉ số được tạo, gồm cả chỉ số idempotent của chi phí cố định', () async {
    final idx = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type='index'")
        .get();
    final names = idx.map((r) => r.read<String>('name')).toSet();
    expect(names, contains('uq_expense_template_month'));
    expect(names, contains('uq_vehicles_active_plate'));
    expect(names, contains('idx_alloc_lot_month'));
  });

  test('ràng buộc khoá ngoại thực sự BẬT', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.first, 1,
        reason: 'SQLite mặc định tắt FK; beforeOpen phải bật lên');
  });

  test('DateTime lưu thành epoch giây — điều kiện để strftime unixepoch đúng', () async {
    final lotId = await _seedLot(db);
    await db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'Nguyễn Văn A',
          ownerNameFold: 'nguyen van a',
          vehicleType: VehicleType.motorbike,
          plate: '59A1-234.56',
          plateNormalized: '59A123456',
          monthlyPrice: 100000,
          startDate: const Day(2026, 8, 1),
          anchorDay: 1,
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));

    final r = await db
        .customSelect(
            "SELECT strftime('%Y-%m', start_date, 'unixepoch') AS ym FROM vehicles")
        .getSingle();
    expect(r.read<String>('ym'), '2026-08',
        reason: 'nếu sai, mọi báo cáo gom nhóm theo tháng đều sai lặng lẽ');
  });

  test('chỉ số chống trùng chặn hai xe cùng biển số đang hoạt động trong một bãi',
      () async {
    final lotId = await _seedLot(db);
    Future<void> add() => db.into(db.vehicles).insert(VehiclesCompanion.insert(
          lotId: lotId,
          ownerName: 'A',
          ownerNameFold: 'a',
          vehicleType: VehicleType.car,
          plate: '51G-999.99',
          plateNormalized: '51G99999',
          monthlyPrice: 500000,
          startDate: const Day(2026, 8, 1),
          anchorDay: 1,
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));

    await add();
    await expectLater(add(), throwsA(isA<Exception>()));
  });

  test('truy vấn báo cáo sinh sẵn chạy được, cả khi lọc lẫn không lọc bãi',
      () async {
    final all = await db
        .revenueCashByMonth(from: const Day(2026, 1, 1), to: const Day(2027, 1, 1))
        .get();
    expect(all, isEmpty);

    final filtered = await db
        .revenueCashByMonth(
          from: const Day(2026, 1, 1),
          to: const Day(2027, 1, 1),
          lotFilter: (p) => p.lotId.equals(1),
        )
        .get();
    expect(filtered, isEmpty);

    final accrual =
        await db.revenueAccrualByMonth(fromYm: '2026-01', toYm: '2026-12').get();
    expect(accrual, isEmpty);
  });
}

Future<int> _seedLot(AppDatabase db) => db.into(db.lots).insert(
      LotsCompanion.insert(
        name: 'Bãi Nguyễn Trãi',
        nameFold: 'bai nguyen trai',
        createdAt: DateTime.utc(2026, 8, 1),
        updatedAt: DateTime.utc(2026, 8, 1),
      ),
    );
