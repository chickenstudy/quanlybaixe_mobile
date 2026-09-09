import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';

/// Sinh các dòng chi phí thật từ mẫu chi phí cố định hàng tháng.
///
/// Vì sao vật chất hoá thay vì cộng động từ mẫu lúc chạy báo cáo: **tiền điện
/// tháng nào cũng khác nhau**. Có dòng thật thì người dùng sửa được đúng số
/// tiền của riêng tháng 8, trong khi mẫu vẫn giữ giá trị mặc định cho các
/// tháng sau. Cộng động thì đó là dòng ma không sửa được, và để sửa được lại
/// phải thêm bảng "ghi đè" — nhiều bộ máy hơn hẳn so với việc cứ ghi ra.
///
/// **Tính idempotent là cấu trúc, không phải cờ trạng thái:** chỉ số duy nhất
/// bộ phận `uq_expense_template_month (source_template_id, period_month)` cộng
/// với `INSERT OR IGNORE` khiến chạy một nghìn lần cũng ra đúng một trạng thái.
/// Quan trọng hơn: **không bao giờ UPDATE**. Dòng đã tồn tại — dù tự sinh hay
/// người dùng đã sửa — là bất khả xâm phạm với bộ sinh này. Đó chính là điều
/// làm cho việc "sửa tiền điện tháng này" an toàn.
class RecurringCostMaterializer {
  RecurringCostMaterializer(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const _watermarkKey = 'last_recurring_materialized_month';

  /// Tạo các dòng chi phí còn thiếu cho mọi mẫu đang hiệu lực, từ tháng bắt đầu
  /// của mẫu tới `min(endMonth, throughMonth)`.
  ///
  /// **Không bao giờ tạo cho tháng tương lai** — chi phí chưa phát sinh thì
  /// không được xuất hiện trong báo cáo lợi nhuận.
  ///
  /// Trả về số dòng đã tạo.
  Future<int> materializeUpTo(YearMonth throughMonth) {
    return _db.transaction(() async {
      final templates = await (_db.select(_db.recurringCostTemplates)
            ..where((t) => t.isActive.equals(true)))
          .get();
      if (templates.isEmpty) {
        await _setWatermark(throughMonth);
        return 0;
      }

      final now = _clock.now();
      final rows = <ExpensesCompanion>[];

      for (final t in templates) {
        final start = YearMonth.parse(t.startMonth);
        final templateEnd =
            t.endMonth == null ? throughMonth : YearMonth.parse(t.endMonth!);
        final end = templateEnd < throughMonth ? templateEnd : throughMonth;

        for (var m = start; m <= end; m = m.addMonths(1)) {
          // Kẹp trong 1..28 để tháng nào cũng có ngày này, kể cả tháng 2.
          final day = t.dayOfMonth.clamp(1, 28);
          rows.add(ExpensesCompanion.insert(
            lotId: t.lotId,
            name: t.name,
            category: t.category,
            kind: ExpenseKind.recurring,
            amount: t.amount,
            incurredOn: Day(m.year, m.month, day),
            periodMonth: m.key,
            sourceTemplateId: Value(t.id),
            createdAt: now,
            updatedAt: now,
          ));
        }
      }

      if (rows.isEmpty) {
        await _setWatermark(throughMonth);
        return 0;
      }

      final before = await _countRecurring();
      await _db.batch((b) => b.insertAll(
            _db.expenses,
            rows,
            mode: InsertMode.insertOrIgnore,
          ));
      final after = await _countRecurring();

      await _setWatermark(throughMonth);
      return after - before;
    });
  }

  /// Vân tay của tập mẫu: tháng đích + số mẫu + lần sửa gần nhất.
  ///
  /// Chỉ ghi tháng thôi là **sai**: người dùng thêm một mẫu chi phí trong cùng
  /// tháng thì mốc vẫn khớp, `materializeCurrentMonth` bỏ qua, và mẫu mới không
  /// bao giờ sinh ra dòng nào. Lỗi này đã thực sự xảy ra — bộ nạp dữ liệu mẫu
  /// tạo mẫu SAU khi dashboard đã chạy bộ sinh một lượt, và toàn bộ chi phí cố
  /// định biến mất khỏi báo cáo mà không báo gì.
  Future<String> _fingerprint(YearMonth month) async {
    final row = await _db.customSelect('''
      SELECT COUNT(*) AS c, COALESCE(MAX(updated_at), 0) AS m
      FROM recurring_cost_templates WHERE is_active = 1
    ''').getSingle();
    return '${month.key}|${row.read<int>('c')}|${row.read<int>('m')}';
  }

  /// Đã chạy cho đúng tập mẫu này chưa — chỉ là tối ưu, không phải điều kiện
  /// đúng đắn. Mốc hỏng hay mất thì lần chạy sau vẫn ra đúng trạng thái, chỉ
  /// tốn thêm vài trăm lệnh chèn không tác dụng. Tính đúng đắn nằm ở chỉ số
  /// duy nhất `uq_expense_template_month`.
  Future<bool> isUpToDate(YearMonth month) async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_watermarkKey)))
        .getSingleOrNull();
    if (row == null) return false;
    return row.value == await _fingerprint(month);
  }

  /// Chạy cho tới tháng hiện tại, bỏ qua nếu vân tay cho biết đã chạy rồi.
  Future<int> materializeCurrentMonth() async {
    final month = YearMonth.fromDay(Day.fromLocal(_clock.now()));
    if (await isUpToDate(month)) return 0;
    return materializeUpTo(month);
  }

  /// Xoá mốc, buộc lần chạy sau quét lại từ đầu.
  /// Gọi sau mọi thao tác thêm/sửa/xoá mẫu chi phí cố định.
  Future<void> invalidate() => (_db.delete(_db.appSettings)
        ..where((s) => s.key.equals(_watermarkKey)))
      .go();

  Future<int> _countRecurring() async {
    final r = await _db
        .customSelect(
            'SELECT COUNT(*) AS c FROM expenses WHERE source_template_id IS NOT NULL')
        .getSingle();
    return r.read<int>('c');
  }

  Future<void> _setWatermark(YearMonth m) async => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
          AppSettingRow(key: _watermarkKey, value: await _fingerprint(m)));
}
