import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/money/money_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/year_month.dart';
import 'expense_form_sheet.dart' show MonthStepper;
import 'expenses_providers.dart';
import 'expenses_strings.dart';

/// Mở bảng thêm/sửa mẫu chi phí cố định. Trả `true` khi đã lưu.
Future<bool?> showRecurringTemplateFormSheet(
  BuildContext context, {
  RecurringCostTemplateRow? template,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => RecurringTemplateFormSheet(template: template),
  );
}

/// Bảng thêm/sửa mẫu chi phí cố định hàng tháng.
///
/// Khoảng hiệu lực là phần dễ nhầm nhất nên được tách hẳn: **tháng bắt đầu**
/// quyết định bộ sinh chạy lùi tới đâu — khai hợp đồng thuê từ tháng 3 thì
/// tháng 3 đến nay đều được sinh chi phí ngay lập tức, chứ không phải chỉ từ
/// hôm nay trở đi. **Tháng kết thúc** để trống nghĩa là còn hiệu lực, khác hẳn
/// với việc tắt công tắc: hết hạn hợp đồng là chuyện của lịch, còn tắt là
/// quyết định của người dùng.
class RecurringTemplateFormSheet extends ConsumerStatefulWidget {
  const RecurringTemplateFormSheet({super.key, this.template});

  final RecurringCostTemplateRow? template;

  @override
  ConsumerState<RecurringTemplateFormSheet> createState() =>
      _RecurringTemplateFormSheetState();
}

class _RecurringTemplateFormSheetState
    extends ConsumerState<RecurringTemplateFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dayCtrl;
  late final TextEditingController _noteCtrl;

  int? _lotId;
  late CostCategory _category;
  late YearMonth _startMonth;
  late YearMonth _endMonth;
  late bool _ongoing;
  late bool _isActive;
  bool _saving = false;

  bool get _isEdit => widget.template != null;

  int? get _day => int.tryParse(_dayCtrl.text.trim());

  bool get _dayValid {
    final d = _day;
    return d != null && d >= 1 && d <= 28;
  }

  /// Khoảng hiệu lực rỗng là vô nghĩa — chặn ngay ở nút Lưu chứ không để bộ
  /// sinh lặng lẽ không tạo ra dòng nào rồi người dùng ngồi đoán vì sao.
  bool get _rangeValid => _ongoing || _endMonth >= _startMonth;

  bool get _canSave =>
      !_saving &&
      _lotId != null &&
      _nameCtrl.text.trim().isNotEmpty &&
      (VndInputFormatter.parse(_amountCtrl.text) ?? 0) > 0 &&
      _dayValid &&
      _rangeValid;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    final thisMonth = ref.read(currentMonthProvider);

    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _amountCtrl = TextEditingController(
        text: t == null ? '' : VndInputFormatter.toEditingText(t.amount));
    _dayCtrl = TextEditingController(text: (t?.dayOfMonth ?? 1).toString());
    _noteCtrl = TextEditingController(text: t?.note ?? '');
    _category = t?.category ?? CostCategory.rent;
    _startMonth =
        t == null ? thisMonth : YearMonth.parse(t.startMonth);
    _ongoing = t?.endMonth == null;
    _endMonth = t?.endMonth == null
        ? _startMonth.addMonths(11)
        : YearMonth.parse(t!.endMonth!);
    _isActive = t?.isActive ?? true;

    final lots = ref.read(expenseLotsProvider).value ?? const <LotRow>[];
    _lotId = t?.lotId ?? (lots.length == 1 ? lots.first.id : null);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dayCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
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
    final end = _ongoing ? null : _endMonth;

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await repo.updateTemplate(
          widget.template!.id,
          lotId: _lotId!,
          name: name,
          category: _category,
          amount: amount,
          dayOfMonth: _day!,
          startMonth: _startMonth,
          endMonth: end,
          isActive: _isActive,
          note: _trimmedOrNull(_noteCtrl),
        );
      } else {
        await repo.createTemplate(
          lotId: _lotId!,
          name: name,
          category: _category,
          amount: amount,
          dayOfMonth: _day!,
          startMonth: _startMonth,
          endMonth: end,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lots = ref.watch(expenseLotsProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit
                    ? Strings.expenseTemplateEdit
                    : Strings.expenseTemplateAdd,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              lots.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (rows) => DropdownButtonFormField<int>(
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
                  labelText: ExpensesStrings.templateName,
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

              TextField(
                controller: _dayCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: ExpensesStrings.dayOfMonth,
                  helperText: ExpensesStrings.dayOfMonthHelp,
                  helperMaxLines: 2,
                  errorText: _dayCtrl.text.trim().isEmpty || _dayValid
                      ? null
                      : ExpensesStrings.dayOfMonthError,
                ),
              ),
              const SizedBox(height: 12),

              InputDecorator(
                decoration: const InputDecoration(
                  labelText: ExpensesStrings.startMonth,
                  contentPadding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                ),
                child: MonthStepper(
                  month: _startMonth,
                  onPrevious: () =>
                      setState(() => _startMonth = _startMonth.addMonths(-1)),
                  onNext: () =>
                      setState(() => _startMonth = _startMonth.addMonths(1)),
                  previousTooltip: ExpensesStrings.startPrevious,
                  nextTooltip: ExpensesStrings.startNext,
                ),
              ),
              const SizedBox(height: 4),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _ongoing,
                onChanged: (v) => setState(() => _ongoing = v),
                title: const Text(ExpensesStrings.ongoing),
                subtitle: const Text(ExpensesStrings.ongoingHint),
              ),
              if (!_ongoing) ...[
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: ExpensesStrings.endMonth,
                    contentPadding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                    errorText: _rangeValid
                        ? null
                        : ExpensesStrings.endBeforeStartError,
                    errorMaxLines: 2,
                  ),
                  child: MonthStepper(
                    month: _endMonth,
                    onPrevious: () =>
                        setState(() => _endMonth = _endMonth.addMonths(-1)),
                    onNext: () =>
                        setState(() => _endMonth = _endMonth.addMonths(1)),
                    previousTooltip: ExpensesStrings.endPrevious,
                    nextTooltip: ExpensesStrings.endNext,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Chỉ hiện khi sửa: mẫu mới tạo bao giờ cũng đang áp dụng, thêm
              // một công tắc luôn bật vào form tạo chỉ tổ gây phân vân.
              if (_isEdit)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text(ExpensesStrings.templateEnabled),
                  subtitle: const Text(ExpensesStrings.templateEnabledHint),
                ),
              const SizedBox(height: 4),

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
