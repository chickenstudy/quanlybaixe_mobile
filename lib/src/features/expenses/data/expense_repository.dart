import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';
import 'recurring_cost_materializer.dart';

/// Nơi duy nhất được phép thay đổi chi phí và mẫu chi phí cố định.
///
/// Hai bất biến của cả cụm chi phí nằm ở đây, không chỗ nào khác:
///
/// 1. **Sau MỌI thao tác thêm/sửa/xoá mẫu phải chạy lại bộ vật chất hoá**
///    ([_refreshMaterialized]). Vân tay của bộ sinh gồm cả số mẫu và lần sửa
///    gần nhất, nên bỏ bước này thì mẫu vừa tạo trong tháng hiện tại **không
///    sinh ra dòng chi phí nào** cho tới tận tháng sau — lỗi này đã thực sự
///    xảy ra một lần và không hề báo gì.
/// 2. **Sửa số tiền của một dòng sinh từ mẫu thì bật `isEdited`.** Đó là cách
///    duy nhất phân biệt "800.000 là ước tính của mẫu" với "800.000 là số trên
///    hoá đơn thật", và cũng là thứ nhãn "ước tính" ngoài giao diện đọc.
class ExpenseRepository {
  ExpenseRepository(this._db, this._clock)
      : _materializer = RecurringCostMaterializer(_db, _clock);

  final AppDatabase _db;
  final Clock _clock;

  /// Dựng tại chỗ chứ không tiêm vào: bộ sinh không giữ trạng thái nào ngoài
  /// CSDL (mốc nằm trong bảng `app_settings`), nên hai thực thể khác nhau vẫn
  /// cho đúng một kết quả.
  final RecurringCostMaterializer _materializer;

  // ══════════════════════════════════════════════════════════════════════
  // CHI PHÍ
  // ══════════════════════════════════════════════════════════════════════

  /// Chi phí của một **tháng kế toán**, mới chi trước.
  ///
  /// Lọc theo `periodMonth` chứ không theo `incurredOn`: hoá đơn điện tháng 8
  /// trả ngày 03/09 phải nằm ở tháng 8. Đây chính là lý do hai cột đó tách
  /// nhau ra.
  Stream<List<ExpenseRow>> watchByMonth({required YearMonth month, int? lotId}) {
    final q = _db.select(_db.expenses)
      ..where((e) => e.deletedAt.isNull() & e.periodMonth.equals(month.key))
      ..orderBy([
        (e) => OrderingTerm.desc(e.incurredOn),
        // Hai khoản cùng ngày vẫn phải có thứ tự ổn định, nếu không danh sách
        // nhảy chỗ mỗi lần stream phát lại.
        (e) => OrderingTerm.desc(e.id),
      ]);
    if (lotId != null) q.where((e) => e.lotId.equals(lotId));
    return q.watch();
  }

  /// Tổng chi của một tháng kế toán. Cộng bằng SQL chứ không cộng trong Dart
  /// để báo cáo không phải kéo về toàn bộ dòng chỉ để lấy một con số.
  Future<int> monthTotal({required YearMonth month, int? lotId}) async {
    final sum = _db.expenses.amount.sum();
    final q = _db.selectOnly(_db.expenses)
      ..addColumns([sum])
      ..where(_db.expenses.deletedAt.isNull() &
          _db.expenses.periodMonth.equals(month.key));
    if (lotId != null) q.where(_db.expenses.lotId.equals(lotId));
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  Future<ExpenseRow?> findById(int id) =>
      (_db.select(_db.expenses)..where((e) => e.id.equals(id)))
          .getSingleOrNull();

  /// Ghi một chi phí phát sinh nhập tay.
  ///
  /// [periodMonth] bỏ trống thì lấy theo [incurredOn] — đúng với đại đa số
  /// khoản chi. Truyền tường minh khi ngày trả tiền và tháng hạch toán khác
  /// nhau.
  Future<int> createAdhoc({
    required int lotId,
    required String name,
    required CostCategory category,
    required int amount,
    required Day incurredOn,
    YearMonth? periodMonth,
    String? note,
  }) {
    return _db.transaction(() async {
      final now = _clock.now();
      final period = periodMonth ?? YearMonth.fromDay(incurredOn);
      final id = await _db.into(_db.expenses).insert(ExpensesCompanion.insert(
            lotId: lotId,
            name: name,
            category: category,
            kind: ExpenseKind.adhoc,
            amount: amount,
            incurredOn: incurredOn,
            periodMonth: period.key,
            note: Value(note),
            createdAt: now,
            updatedAt: now,
          ));
      await _log(
        at: now,
        action: LogAction.expenseCreated,
        entity: LogEntity.expense,
        entityId: id,
        lotId: lotId,
        summary: 'Thêm chi phí "$name" ${_dong(amount)} '
            '(tháng ${period.month}/${period.year})',
        details: {
          'amount': amount,
          'category': category.name,
          'incurredOn': incurredOn.iso,
          'periodMonth': period.key,
        },
      );
      return id;
    });
  }

  /// Sửa một dòng chi phí — kể cả dòng do mẫu sinh ra.
  ///
  /// Đổi số tiền của dòng sinh từ mẫu sẽ bật `isEdited`, và **cờ đó không bao
  /// giờ tắt lại**: một khi người dùng đã đối chiếu hoá đơn thật, con số ấy
  /// không còn là ước tính nữa dù sau này họ có sửa thêm gì.
  ///
  /// Bộ sinh chi phí cố định không bao giờ UPDATE, nên dòng đã sửa an toàn
  /// tuyệt đối trước mọi lần chạy lại.
  Future<void> update(
    int id, {
    required int lotId,
    required String name,
    required CostCategory category,
    required int amount,
    required Day incurredOn,
    required YearMonth periodMonth,
    String? note,
  }) {
    return _db.transaction(() async {
      final current = await findById(id);
      if (current == null) return;
      final now = _clock.now();
      final edited = current.isEdited ||
          (current.sourceTemplateId != null && amount != current.amount);

      await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
        ExpensesCompanion(
          lotId: Value(lotId),
          name: Value(name),
          category: Value(category),
          amount: Value(amount),
          incurredOn: Value(incurredOn),
          periodMonth: Value(periodMonth.key),
          isEdited: Value(edited),
          note: Value(note),
          updatedAt: Value(now),
        ),
      );
      await _log(
        at: now,
        action: LogAction.expenseUpdated,
        entity: LogEntity.expense,
        entityId: id,
        lotId: lotId,
        summary: 'Sửa chi phí "$name" ${_dong(current.amount)} → '
            '${_dong(amount)} (tháng ${periodMonth.month}/${periodMonth.year})',
        details: {
          'amountBefore': current.amount,
          'amountAfter': amount,
          'periodMonth': periodMonth.key,
          'isEdited': edited,
        },
      );
    });
  }

  /// Xoá mềm. Dòng sinh từ mẫu đã xoá mềm sẽ **không** bị bộ sinh tạo lại:
  /// nó vẫn chiếm chỗ trong chỉ số duy nhất `uq_expense_template_month`, nên
  /// `INSERT OR IGNORE` bỏ qua. Người dùng xoá một lần là xong, không phải
  /// xoá đi xoá lại mỗi lần mở app.
  Future<void> softDelete(int id) {
    return _db.transaction(() async {
      final row = await findById(id);
      if (row == null) return;
      final now = _clock.now();
      await (_db.update(_db.expenses)..where((e) => e.id.equals(id)))
          .write(ExpensesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
      await _log(
        at: now,
        action: LogAction.expenseDeleted,
        entity: LogEntity.expense,
        entityId: id,
        lotId: row.lotId,
        summary: 'Xoá chi phí "${row.name}" ${_dong(row.amount)} '
            '(tháng ${row.periodMonth})',
        details: {'amount': row.amount, 'periodMonth': row.periodMonth},
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════════
  // MẪU CHI PHÍ CỐ ĐỊNH
  // ══════════════════════════════════════════════════════════════════════

  /// Mẫu gom theo bãi rồi tới nhóm chi phí — đúng thứ tự người dùng đọc bảng
  /// chi phí cố định của một bãi.
  Stream<List<RecurringCostTemplateRow>> watchTemplates({int? lotId}) {
    final q = _db.select(_db.recurringCostTemplates)
      ..orderBy([
        (t) => OrderingTerm.asc(t.lotId),
        (t) => OrderingTerm.asc(t.category),
        (t) => OrderingTerm.asc(t.name),
        (t) => OrderingTerm.asc(t.id),
      ]);
    if (lotId != null) q.where((t) => t.lotId.equals(lotId));
    return q.watch();
  }

  Future<RecurringCostTemplateRow?> findTemplateById(int id) =>
      (_db.select(_db.recurringCostTemplates)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> createTemplate({
    required int lotId,
    required String name,
    required CostCategory category,
    required int amount,
    int dayOfMonth = 1,
    required YearMonth startMonth,
    YearMonth? endMonth,
    bool isActive = true,
    String? note,
  }) async {
    final id = await _db.transaction(() async {
      final now = _clock.now();
      final newId = await _db
          .into(_db.recurringCostTemplates)
          .insert(RecurringCostTemplatesCompanion.insert(
            lotId: lotId,
            name: name,
            category: category,
            amount: amount,
            dayOfMonth: Value(dayOfMonth.clamp(1, 28)),
            startMonth: startMonth.key,
            endMonth: Value(endMonth?.key),
            isActive: Value(isActive),
            note: Value(note),
            createdAt: now,
            updatedAt: now,
          ));
      await _log(
        at: now,
        action: LogAction.templateCreated,
        entity: LogEntity.template,
        entityId: newId,
        lotId: lotId,
        summary: 'Thêm mẫu chi phí "$name" ${_dong(amount)}/tháng '
            'từ tháng ${startMonth.month}/${startMonth.year}',
        details: {
          'amount': amount,
          'category': category.name,
          'startMonth': startMonth.key,
          'endMonth': endMonth?.key,
        },
      );
      return newId;
    });
    await _refreshMaterialized();
    return id;
  }

  Future<void> updateTemplate(
    int id, {
    required int lotId,
    required String name,
    required CostCategory category,
    required int amount,
    required int dayOfMonth,
    required YearMonth startMonth,
    YearMonth? endMonth,
    required bool isActive,
    String? note,
  }) async {
    await _db.transaction(() async {
      final now = _clock.now();
      await (_db.update(_db.recurringCostTemplates)
            ..where((t) => t.id.equals(id)))
          .write(RecurringCostTemplatesCompanion(
        lotId: Value(lotId),
        name: Value(name),
        category: Value(category),
        amount: Value(amount),
        dayOfMonth: Value(dayOfMonth.clamp(1, 28)),
        startMonth: Value(startMonth.key),
        endMonth: Value(endMonth?.key),
        isActive: Value(isActive),
        note: Value(note),
        updatedAt: Value(now),
      ));
      await _log(
        at: now,
        action: LogAction.templateUpdated,
        entity: LogEntity.template,
        entityId: id,
        lotId: lotId,
        summary: 'Sửa mẫu chi phí "$name" ${_dong(amount)}/tháng'
            '${isActive ? '' : ' (đã dừng)'}',
        details: {
          'amount': amount,
          'startMonth': startMonth.key,
          'endMonth': endMonth?.key,
          'isActive': isActive,
        },
      );
    });
    await _refreshMaterialized();
  }

  /// Xoá hẳn mẫu — **không** đụng tới chi phí lịch sử.
  ///
  /// Cột `expenses.source_template_id` khai `ON DELETE SET NULL`, nên các dòng
  /// đã sinh chỉ mất đường trỏ về mẫu chứ vẫn nằm nguyên trong báo cáo. Đó là
  /// điều đúng duy nhất: tiền của tháng 8 đã thực sự chi ra rồi, xoá nó đi thì
  /// lợi nhuận tháng 8 đột nhiên tăng vọt mà không ai giải thích được.
  Future<void> deleteTemplate(int id) async {
    await _db.transaction(() async {
      final t = await findTemplateById(id);
      if (t == null) return;
      final now = _clock.now();
      await (_db.delete(_db.recurringCostTemplates)
            ..where((r) => r.id.equals(id)))
          .go();
      await _log(
        at: now,
        action: LogAction.templateDeleted,
        entity: LogEntity.template,
        entityId: id,
        lotId: t.lotId,
        summary: 'Xoá mẫu chi phí "${t.name}" — chi phí đã ghi của các tháng '
            'trước vẫn giữ nguyên',
        details: {'amount': t.amount, 'startMonth': t.startMonth},
      );
    });
    await _refreshMaterialized();
  }

  /// Chạy lại bộ vật chất hoá sau khi tập mẫu đổi.
  ///
  /// Gọi **ngoài** transaction ghi mẫu: bộ sinh tự mở transaction riêng, và
  /// mốc chỉ nên xoá khi thay đổi mẫu đã chắc chắn được ghi xuống đĩa.
  Future<void> _refreshMaterialized() async {
    await _materializer.invalidate();
    await _materializer.materializeCurrentMonth();
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
    return _db.into(_db.activityLog).insert(ActivityLogCompanion.insert(
          at: at,
          action: action,
          entityType: entity,
          entityId: Value(entityId),
          lotId: Value(lotId),
          summary: summary,
          detailsJson: Value(details == null ? null : jsonEncode(details)),
        ));
  }

  /// Định dạng tiền rút gọn cho câu nhật ký. Bản đầy đủ nằm ở tầng giao diện —
  /// kho dữ liệu không phụ thuộc vào lớp định dạng của giao diện.
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
