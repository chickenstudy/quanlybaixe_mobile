import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/enums.dart';
import '../../core/text/vi_normalize.dart';
import '../../core/time/clock.dart';
import '../../core/time/day.dart';
import '../../core/time/year_month.dart';
import '../expenses/data/recurring_cost_materializer.dart';
import '../payments/data/payment_repository.dart';

/// Nạp một bộ dữ liệu mẫu giống thật để xem thử ứng dụng.
///
/// Dựng theo mốc thời gian **tương đối với hôm nay**, không dùng ngày cố định,
/// để dashboard luôn có xe còn hạn, xe sắp hết hạn và xe đã quá hạn — nếu cắm
/// ngày cứng thì vài tuần sau mọi xe đều quá hạn và màn hình mất ý nghĩa.
class SampleDataSeeder {
  SampleDataSeeder(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Future<bool> get isEmpty async {
    final r = await _db
        .customSelect('SELECT COUNT(*) AS c FROM lots WHERE deleted_at IS NULL')
        .getSingle();
    return r.read<int>('c') == 0;
  }

  Future<void> seed() async {
    final now = _clock.now();
    final today = Day.fromLocal(now);
    final payments = PaymentRepository(_db, _clock);

    final lotA = await _lot(
      name: 'Bãi Nguyễn Trãi',
      address: '145 Nguyễn Trãi, Thanh Xuân, Hà Nội',
      price: 150000,
      capacity: 60,
      now: now,
    );
    final lotB = await _lot(
      name: 'Bãi Chung cư Sunrise',
      address: 'Tầng hầm B1, Chung cư Sunrise',
      price: 900000,
      capacity: 25,
      now: now,
    );

    // (tên chủ, sđt, loại, biển số, giá, bãi, số ngày còn lại mong muốn, số tháng đóng)
    final specs = <(String, String, VehicleType, String, int, int, int, int)>[
      ('Nguyễn Văn An', '0912345678', VehicleType.motorbike, '29A1-234.56', 150000, lotA, 88, 3),
      ('Trần Thị Hồng', '0987654321', VehicleType.motorbike, '29B2-111.22', 150000, lotA, 2, 1),
      ('Lê Quốc Cường', '0905112233', VehicleType.motorbike, '29C3-777.88', 150000, lotA, 5, 1),
      ('Phạm Thị Đào', '0913222444', VehicleType.motorbike, '30D4-555.66', 150000, lotA, -8, 2),
      ('Hoàng Minh Đức', '0968111222', VehicleType.motorbike, '30E5-999.00', 150000, lotA, 175, 6),
      ('Vũ Thị Lan', '0977333555', VehicleType.car, '30G-123.45', 900000, lotB, 20, 3),
      ('Đặng Văn Hùng', '0918444666', VehicleType.car, '30H-678.90', 900000, lotB, 1, 1),
      ('Bùi Thanh Tùng', '0934555777', VehicleType.truck, '29K-246.80', 1500000, lotB, -3, 1),
      ('Ngô Thị Mai', '0946666888', VehicleType.car, '30M-135.79', 900000, lotB, 178, 6),
    ];

    for (final (owner, phone, type, plate, price, lotId, daysLeft, months) in specs) {
      // Đi ngược từ ngày hết hạn mong muốn để ra ngày bắt đầu.
      final wantedEnd = today.addDays(daysLeft);
      final start = _minusMonths(wantedEnd, months);
      final id = await _vehicle(
        lotId: lotId,
        owner: owner,
        phone: phone,
        type: type,
        plate: plate,
        price: price,
        start: start,
        now: now,
      );
      // Ngày thu: xe nào bắt đầu trong tháng này thì thu trong tháng này, còn
      // lại thu đúng ngày bắt đầu kỳ. Nhờ vậy dashboard có cả doanh thu thực
      // thu của tháng hiện tại lẫn doanh thu phân bổ từ các kỳ cũ — đủ để thấy
      // hai cách tính cho ra số khác nhau, đúng như mục 4 đặc tả mô tả.
      await payments.recordPayment(
        vehicleId: id,
        months: months,
        paidAt: start,
      );
    }

    // Một xe mới đăng ký nhưng chưa đóng tiền lần nào.
    await _vehicle(
      lotId: lotA,
      owner: 'Trịnh Văn Sơn',
      phone: '0923777999',
      type: VehicleType.motorbike,
      plate: '29P6-321.54',
      price: 150000,
      start: today,
      now: now,
    );

    await _recurring(lotA, 'Tiền thuê mặt bằng', CostCategory.rent, 12000000, now);
    await _recurring(lotA, 'Tiền điện', CostCategory.electricity, 850000, now);
    await _recurring(lotA, 'Bảo vệ', CostCategory.security, 6000000, now);
    await _recurring(lotB, 'Tiền thuê mặt bằng', CostCategory.rent, 8000000, now);
    await _recurring(lotB, 'Tiền điện', CostCategory.electricity, 620000, now);

    await RecurringCostMaterializer(_db, _clock).materializeCurrentMonth();

    // Vài chi phí phát sinh trong tháng này.
    await _expense(lotA, 'Sửa cửa cuốn', CostCategory.repair, 1800000,
        today.addDays(-6), now);
    await _expense(lotB, 'Mua camera', CostCategory.equipment, 3200000,
        today.addDays(-12), now);
  }

  /// Trừ [months] tháng, kẹp ngày về cuối tháng khi tràn.
  Day _minusMonths(Day d, int months) {
    final total = d.year * 12 + (d.month - 1) - months;
    final y = total ~/ 12;
    final m = total % 12 + 1;
    final maxDay = DateTime.utc(y, m + 1, 0).day;
    return Day(y, m, d.day < maxDay ? d.day : maxDay);
  }

  Future<int> _lot({
    required String name,
    required String address,
    required int price,
    required int capacity,
    required DateTime now,
  }) =>
      _db.into(_db.lots).insert(LotsCompanion.insert(
            name: name,
            nameFold: viFold(name),
            address: Value(address),
            capacity: Value(capacity),
            createdAt: now,
            updatedAt: now,
          ));

  Future<int> _vehicle({
    required int lotId,
    required String owner,
    required String phone,
    required VehicleType type,
    required String plate,
    required int price,
    required Day start,
    required DateTime now,
  }) =>
      _db.into(_db.vehicles).insert(VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: owner,
            ownerNameFold: viFold(owner),
            phone: Value(phone),
            phoneDigits: Value(normalizePhone(phone)),
            vehicleType: type,
            plate: plate,
            plateNormalized: normalizePlate(plate),
            monthlyPrice: price,
            startDate: start,
            anchorDay: start.day,
            createdAt: now,
            updatedAt: now,
          ));

  Future<void> _recurring(int lotId, String name, CostCategory cat, int amount,
      DateTime now) async {
    final from = YearMonth.fromDay(Day.fromLocal(now)).addMonths(-3);
    await _db.into(_db.recurringCostTemplates).insert(
          RecurringCostTemplatesCompanion.insert(
            lotId: lotId,
            name: name,
            category: cat,
            amount: amount,
            startMonth: from.key,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _expense(int lotId, String name, CostCategory cat, int amount,
          Day on, DateTime now) =>
      _db.into(_db.expenses).insert(ExpensesCompanion.insert(
            lotId: lotId,
            name: name,
            category: cat,
            kind: ExpenseKind.adhoc,
            amount: amount,
            incurredOn: on,
            periodMonth: YearMonth.fromDay(on).key,
            createdAt: now,
            updatedAt: now,
          ));
}
