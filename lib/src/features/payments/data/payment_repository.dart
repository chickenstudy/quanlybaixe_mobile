import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/money/money_split.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/date_math.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';

/// Kết quả một lần ghi nhận thu tiền.
class RecordPaymentResult {
  const RecordPaymentResult({
    required this.paymentId,
    required this.periodStart,
    required this.periodEnd,
    required this.amount,
    required this.allocations,
  });

  final int paymentId;
  final Day periodStart;

  /// Mốc **loại trừ** — chính là "ngày hết hạn" hiển thị cho người dùng.
  final Day periodEnd;
  final int amount;

  /// Số tiền đã rải ra từng tháng, theo thứ tự tháng tăng dần.
  final List<({YearMonth month, int amount})> allocations;
}

/// Nơi duy nhất được phép thay đổi tiền bạc và hạn thanh toán.
///
/// Bất biến toàn hệ thống: **các cột cache trên bảng `vehicles`
/// (`currentPeriodEnd`, `lastPaymentDate`, `totalMonthsPaid`, `totalPaid`) chỉ
/// được ghi bởi [_recomputeVehicleCache], và luôn nằm trong cùng transaction
/// với thao tác thay đổi thanh toán.** Không có đường nào khác. Nếu phá vỡ điều
/// này, dashboard sẽ hiển thị hạn sai mà không có lỗi nào được báo.
class PaymentRepository {
  PaymentRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Ghi nhận một lần thu tiền và mọi hệ quả của nó, trong **một** transaction:
  /// bản ghi thanh toán, các dòng phân bổ theo tháng, cache trên bản ghi xe, và
  /// nhật ký thao tác. Hỏng ở bất kỳ bước nào thì rollback toàn bộ.
  ///
  /// [months] là số tháng đóng, người dùng nhập trực tiếp (mục 3 đặc tả).
  ///
  /// [periodStartOverride] để xử lý trường hợp khách bỏ bãi vài tháng rồi quay
  /// lại: mặc định kỳ mới nối liền kỳ cũ (không để lỗ hổng), nhưng chủ bãi
  /// thường tính tiền từ ngày quay lại chứ không truy thu quãng vắng mặt.
  ///
  /// [amountOverride] cho trường hợp bớt giá hoặc làm tròn cho khách. Khi khác
  /// `months * unitPrice`, chênh lệch đọc ra được ngay từ dữ liệu.
  ///
  /// [unitPriceOverride] để thu theo giá khác giá đang lưu trên xe — chủ bãi
  /// tăng giá, hoặc giảm cho khách quen. [applyPriceToVehicle] quyết định giá
  /// mới đó có trở thành giá mặc định của xe cho các kỳ sau hay không. Tách
  /// hai việc ra vì chúng thật sự khác nhau: thu một lần giá khác, và đổi hẳn
  /// giá của xe.
  Future<RecordPaymentResult> recordPayment({
    required int vehicleId,
    required int months,
    Day? paidAt,
    Day? periodStartOverride,
    int? amountOverride,
    int? unitPriceOverride,
    bool applyPriceToVehicle = false,
    PaymentMethod method = PaymentMethod.cash,
    String? note,
  }) {
    assert(months >= 1, 'Số tháng đóng phải >= 1');

    return _db.transaction(() async {
      final vehicle = await (_db.select(_db.vehicles)
            ..where((v) => v.id.equals(vehicleId)))
          .getSingle();

      final now = _clock.now();
      final today = Day.fromLocal(now);
      final paid = paidAt ?? today;

      // Kỳ mới nối liền kỳ cũ: periodStart chính LÀ periodEnd của kỳ trước,
      // không cộng trừ ngày nào — đó là lợi ích của việc chọn mốc loại trừ.
      final periodStart =
          periodStartOverride ?? vehicle.currentPeriodEnd ?? vehicle.startDate;

      // Tính MỘT LẦN với tổng số tháng. Cộng dồn từng tháng sẽ ra kết quả khác
      // vì phép cộng tháng có kẹp không có tính kết hợp — xem date_math.dart.
      final periodEnd = periodEndFor(
        periodStart: periodStart,
        months: months,
        anchorDay: vehicle.anchorDay,
      );

      final unitPrice = unitPriceOverride ?? vehicle.monthlyPrice;
      final amount = amountOverride ?? unitPrice * months;

      final paymentId = await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              vehicleId: vehicleId,
              // Ảnh chụp bãi tại thời điểm thu — không phải bãi hiện tại của xe.
              lotId: vehicle.lotId,
              amount: amount,
              monthsPaid: months,
              unitPrice: unitPrice,
              paidAt: paid,
              periodStart: periodStart,
              periodEnd: periodEnd,
              method: Value(method),
              note: Value(note),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final allocations = _buildAllocations(
        paymentId: paymentId,
        lotId: vehicle.lotId,
        vehicleId: vehicleId,
        periodStart: periodStart,
        months: months,
        amount: amount,
      );
      await _db.batch((b) => b.insertAll(_db.paymentAllocations, allocations));

      if (applyPriceToVehicle && unitPrice != vehicle.monthlyPrice) {
        await (_db.update(_db.vehicles)..where((v) => v.id.equals(vehicleId)))
            .write(VehiclesCompanion(
          monthlyPrice: Value(unitPrice),
          updatedAt: Value(now),
        ));
      }

      await _recomputeVehicleCache(vehicleId);

      await _log(
        at: now,
        action: LogAction.paymentCreated,
        entity: LogEntity.payment,
        entityId: paymentId,
        lotId: vehicle.lotId,
        summary: 'Thu tiền xe ${vehicle.plate} — $months tháng, '
            '${_dong(amount)}, hạn mới ${periodEnd.iso}',
        details: {
          'vehicleId': vehicleId,
          'months': months,
          'amount': amount,
          'periodStart': periodStart.iso,
          'periodEnd': periodEnd.iso,
        },
      );

      return RecordPaymentResult(
        paymentId: paymentId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        amount: amount,
        allocations: [
          for (final a in allocations)
            (month: YearMonth.parse(a.periodMonth.value), amount: a.amount.value)
        ],
      );
    });
  }

  /// Huỷ mềm một biên lai và tính lại hạn của xe.
  ///
  /// Không xoá cứng: chủ bãi bấm nhầm một biên lai vài triệu thì cần dấu vết để
  /// hoàn tác, và nhật ký thao tác thành vô nghĩa nếu bản ghi được nhắc tới đã
  /// biến mất. Các dòng phân bổ cũng được giữ nguyên — mọi truy vấn doanh thu
  /// đã lọc `voidedAt IS NULL` qua phép join, nên chúng tự động biến mất khỏi
  /// báo cáo mà không cần xoá.
  Future<void> voidPayment(int paymentId, {String? reason}) {
    return _db.transaction(() async {
      final payment = await (_db.select(_db.payments)
            ..where((p) => p.id.equals(paymentId)))
          .getSingle();

      if (payment.voidedAt != null) return; // đã huỷ rồi, không làm gì thêm

      final now = _clock.now();
      await (_db.update(_db.payments)..where((p) => p.id.equals(paymentId)))
          .write(PaymentsCompanion(
        voidedAt: Value(now),
        updatedAt: Value(now),
      ));

      await _recomputeVehicleCache(payment.vehicleId);

      await _log(
        at: now,
        action: LogAction.paymentVoided,
        entity: LogEntity.payment,
        entityId: paymentId,
        lotId: payment.lotId,
        summary: 'Huỷ biên lai ${_dong(payment.amount)} '
            '(${payment.monthsPaid} tháng)${reason == null ? '' : ' — $reason'}',
        details: {'reason': reason},
      );
    });
  }

  /// Dựng các dòng phân bổ cho một lần thu tiền.
  ///
  /// Tháng của phần thứ `i` là tháng chứa `addMonthsClamped(periodStart, i)`.
  /// Phép cộng tháng luôn tăng đúng một tháng mỗi bước (chỉ ngày bị kẹp), nên
  /// các tháng chắc chắn phân biệt — điều kiện để khoá duy nhất
  /// `(paymentId, periodMonth)` không bao giờ va chạm.
  ///
  /// Không chia theo tỷ lệ ngày cho tháng lẻ: đóng từ 15/08 ba tháng thì rải
  /// vào tháng 8, 9, 10. Đó đúng là cách chủ bãi nghĩ, và là cách giải thích
  /// được cho khách khi có thắc mắc.
  List<PaymentAllocationsCompanion> _buildAllocations({
    required int paymentId,
    required int lotId,
    required int vehicleId,
    required Day periodStart,
    required int months,
    required int amount,
  }) {
    final parts = splitAmount(amount, months);
    return [
      for (var i = 0; i < months; i++)
        () {
          final month =
              YearMonth.fromDay(addMonthsClamped(periodStart, i));
          return PaymentAllocationsCompanion.insert(
            paymentId: paymentId,
            lotId: lotId,
            vehicleId: vehicleId,
            periodMonth: month.key,
            periodMonthStart: month.firstDay,
            amount: parts[i],
          );
        }(),
    ];
  }

  /// Tính lại toàn bộ cache của một xe từ sổ cái. Chỉ gọi từ trong transaction.
  Future<void> _recomputeVehicleCache(int vehicleId) async {
    final row = await _db.customSelect(
      '''
      SELECT
        MAX(period_end)   AS max_end,
        MAX(paid_at)      AS max_paid,
        SUM(months_paid)  AS months,
        SUM(amount)       AS total
      FROM payments
      WHERE vehicle_id = ?1 AND voided_at IS NULL
      ''',
      variables: [Variable.withInt(vehicleId)],
    ).getSingle();

    final maxEnd = row.read<DateTime?>('max_end');
    final maxPaid = row.read<DateTime?>('max_paid');

    await (_db.update(_db.vehicles)..where((v) => v.id.equals(vehicleId)))
        .write(VehiclesCompanion(
      currentPeriodEnd:
          Value(maxEnd == null ? null : Day.fromUtcMidnight(maxEnd)),
      lastPaymentDate:
          Value(maxPaid == null ? null : Day.fromUtcMidnight(maxPaid)),
      totalMonthsPaid: Value(row.read<int?>('months') ?? 0),
      totalPaid: Value(row.read<int?>('total') ?? 0),
      updatedAt: Value(_clock.now()),
    ));
  }

  /// Dựng lại cache của MỌI xe từ sổ cái.
  ///
  /// Dùng sau khi nhập dữ liệu từ file sao lưu, và trong test để khẳng định
  /// cache luôn khớp với sự thật.
  Future<void> recomputeAllVehicleCaches() => _db.transaction(() async {
        final ids = await _db
            .customSelect('SELECT id FROM vehicles')
            .map((r) => r.read<int>('id'))
            .get();
        for (final id in ids) {
          await _recomputeVehicleCache(id);
        }
      });

  /// Kiểm tra cache có còn khớp sổ cái không. Trả về danh sách xe lệch.
  ///
  /// Dùng trong test và sau một nút ẩn trong màn hình cài đặt. Một bất biến chỉ
  /// đáng tin khi có cách khẳng định nó.
  Future<List<int>> findVehiclesWithStaleCache() async {
    final rows = await _db.customSelect('''
      SELECT v.id AS id
      FROM vehicles v
      LEFT JOIN (
        SELECT vehicle_id,
               MAX(period_end)  AS max_end,
               SUM(months_paid) AS months,
               SUM(amount)      AS total
        FROM payments WHERE voided_at IS NULL
        GROUP BY vehicle_id
      ) p ON p.vehicle_id = v.id
      WHERE v.current_period_end IS NOT p.max_end
         OR v.total_months_paid  IS NOT COALESCE(p.months, 0)
         OR v.total_paid         IS NOT COALESCE(p.total, 0)
    ''').get();
    return rows.map((r) => r.read<int>('id')).toList();
  }

  Future<void> _log({
    required DateTime at,
    required LogAction action,
    required LogEntity entity,
    required String summary,
    int? entityId,
    int? lotId,
    Map<String, Object?>? details,
  }) {
    return _db.into(_db.activityLog).insert(
          ActivityLogCompanion.insert(
            at: at,
            action: action,
            entityType: entity,
            entityId: Value(entityId),
            lotId: Value(lotId),
            summary: summary,
            detailsJson: Value(details == null ? null : jsonEncode(details)),
          ),
        );
  }

  /// Định dạng tiền rút gọn cho câu nhật ký. Bản đầy đủ nằm ở tầng giao diện.
  static String _dong(int amount) {
    final s = amount.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${amount < 0 ? '-' : ''}$buf đ';
  }
}
