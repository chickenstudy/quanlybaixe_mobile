import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';
import 'expenses_providers.dart';
import 'expenses_strings.dart';

/// Mở bảng thêm/sửa một dòng chi phí. Trả `true` khi đã lưu hoặc đã xoá.
///
/// Truyền [expense] để sửa. [initialMonth] là tháng màn hình đang xem — khoản
/// vừa thêm phải rơi đúng vào đó, nếu không nó biến mất ngay trước mắt người
/// vừa nhập.
Future<bool?> showExpenseFormSheet(
  BuildContext context, {
  ExpenseRow? expense,
  YearMonth? initialMonth,
  int? initialLotId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ExpenseFormSheet(
      expense: expense,
      initialMonth: initialMonth,
      initialLotId: initialLotId,
    ),
  );
}

/// Bảng thêm/sửa chi phí.
///
/// Điểm khác biệt duy nhất so với một form nhập liệu thường: **hai mốc thời
/// gian tách rời nhau**. "Ngày chi" là ngày tiền rời túi, "Tháng áp dụng" là
/// tháng khoản đó được hạch toán. Hoá đơn điện tháng 8 trả ngày 03/09 phải
/// nhập ngày 03/09 nhưng tháng áp dụng là tháng 8 — gộp hai thứ này làm một là
/// cách chắc chắn nhất để lãi lỗ theo tháng chập chờn.
class ExpenseFormSheet extends ConsumerStatefulWidget {
  const ExpenseFormSheet({
    super.key,
    this.expense,
    this.initialMonth,
    this.initialLotId,
  });

  final ExpenseRow? expense;
  final YearMonth? initialMonth;
  final int? initialLotId;

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  int? _lotId;
  late CostCategory _category;
  late Day _incurredOn;
  late YearMonth _period;

  /// Người dùng đã tự đặt tháng áp dụng chưa. Chừng nào chưa, đổi ngày chi sẽ
  /// kéo tháng áp dụng theo — đó là hành vi đúng cho 9 trên 10 khoản chi. Đụng
  /// vào rồi thì thôi, không giật lại lựa chọn của họ nữa.
  bool _periodTouched = false;
  bool _saving = false;

  bool get _isEdit => widget.expense != null;

  bool get _canSave =>
      !_saving &&
      _lotId != null &&
      _nameCtrl.text.trim().isNotEmpty &&
      (VndInputFormatter.parse(_amountCtrl.text) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    final today = ref.read(todayProvider);
    final month = widget.initialMonth ?? YearMonth.fromDay(today);

    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _amountCtrl = TextEditingController(
        text: e == null ? '' : VndInputFormatter.toEditingText(e.amount));
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? CostCategory.other;

    if (e != null) {
      _incurredOn = e.incurredOn;
      _period = YearMonth.parse(e.periodMonth);
      _periodTouched = true;
    } else {
      // Đang xem tháng cũ mà ghi thêm khoản chi thì ngày mặc định phải nằm
      // trong chính tháng ấy, chứ không phải hôm nay — nếu không khoản vừa
      // nhập rơi sang tháng khác và lập tức biến mất khỏi danh sách.
      _incurredOn = YearMonth.fromDay(today) == month ? today : month.firstDay;
      _period = month;
    }

    final lots = ref.read(expenseLotsProvider).value ?? const <LotRow>[];
    _lotId = e?.lotId ??
        widget.initialLotId ??
        // Chỉ tự chọn khi không có gì để chọn nhầm.
        (lots.length == 1 ? lots.first.id : null);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _incurredOn.localMidnight,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );
    if (picked == null) return;
    setState(() {
      _incurredOn = Day.fromLocal(picked);
      if (!_periodTouched) _period = YearMonth.fromDay(_incurredOn);
    });
  }

  void _shiftPeriod(int months) {
    setState(() {
      _periodTouched = true;
      _period = _period.addMonths(months);
    });
  }

  String? _trimmedOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _submit() async {
    if (!_canSave) return;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(expenseRepositoryProvider);
    final name = _nameCtrl.text.trim();
    final amount = VndInputFormatter.parse(_amountCtrl.text) ?? 0;

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await repo.update(
          widget.expense!.id,
          lotId: _lotId!,
          name: name,
          category: _category,
          amount: amount,
          incurredOn: _incurredOn,
          periodMonth: _period,
          note: _trimmedOrNull(_noteCtrl),
        );
      } else {
        await repo.createAdhoc(
          lotId: _lotId!,
          name: name,
          category: _category,
          amount: amount,
          incurredOn: _incurredOn,
          periodMonth: _period,
          note: _trimmedOrNull(_noteCtrl),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger
          .showSnackBar(const SnackBar(content: Text(Strings.errorGeneric)));
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final expense = widget.expense!;
    final navigator = Navigator.of(context);
    final repo = ref.read(expenseRepositoryProvider);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Strings.confirmDeleteNamed(expense.name)),
        content: const Text(Strings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(Strings.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await repo.softDelete(expense.id);
    if (!mounted) return;
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lots = ref.watch(expenseLotsProvider);

    return Padding(
      // Đẩy nội dung lên trên bàn phím, nếu không ô ghi chú và nút Lưu bị che.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? Strings.expenseEdit : Strings.expenseAdd,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (_isEdit)
                    IconButton(
                      onPressed: _saving ? null : _confirmDelete,
                      tooltip: Strings.delete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Bãi xe (bắt buộc) ──
              lots.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (rows) => DropdownButtonFormField<int>(
                  // Chống `assert` của Material: giá trị đang chọn phải nằm
                  // trong danh sách item.
                  initialValue: rows.any((l) => l.id == _lotId) ? _lotId : null,
                  decoration: const InputDecoration(
                    labelText: Strings.lotSelect,
                    prefixIcon: Icon(Icons.local_parking),
                  ),
                  items: [
                    for (final l in rows)
                      DropdownMenuItem<int>(value: l.id, child: Text(l.name)),
                  ],
                  onChanged: (id) => setState(() => _lotId = id),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _nameCtrl,
                autofocus: !_isEdit,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: Strings.expenseDescription,
                  hintText: ExpensesStrings.templateNameHint,
                  suffixText: Strings.required,
                ),
              ),
              const SizedBox(height: 16),

              Text(Strings.expenseCategory, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in CostCategory.values)
                    ChoiceChip(
                      label: Text(costCategoryLabel(c)),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: const [VndInputFormatter()],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: Strings.expenseAmount,
                  suffixText: kVndSymbol,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: Strings.expenseDate,
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(formatDay(_incurredOn),
                      style: theme.textTheme.bodyLarge),
                ),
              ),
              const SizedBox(height: 12),

              // ── Tháng kế toán ──
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: Strings.expenseMonth,
                  helperText: ExpensesStrings.periodMonthHelp,
                  helperMaxLines: 4,
                  contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                ),
                child: MonthStepper(
                  month: _period,
                  onPrevious: () => _shiftPeriod(-1),
                  onNext: () => _shiftPeriod(1),
                  previousTooltip: ExpensesStrings.periodPrevious,
                  nextTooltip: ExpensesStrings.periodNext,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: Strings.note,
                  hintText: Strings.noteHint,
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text(Strings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _canSave ? _submit : null,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(Strings.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút lùi/tới một tháng, kèm nhãn tháng ở giữa.
///
/// Dùng ở ba nơi (tháng đang xem, tháng áp dụng, khoảng hiệu lực của mẫu) nên
/// **chú thích của hai nút phải truyền vào**: khi bảng nhập đang mở, cả thanh
/// tháng của màn hình lẫn thanh tháng của form cùng nằm trên cây widget, hai
/// nút mũi tên giống hệt nhau thì trình đọc màn hình — và cả bộ kiểm thử —
/// không phân biệt được cái nào là cái nào.
class MonthStepper extends StatelessWidget {
  const MonthStepper({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    this.labelStyle,
  });

  final YearMonth month;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: previousTooltip,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            formatMonth(month),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle ??
                theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: nextTooltip,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
