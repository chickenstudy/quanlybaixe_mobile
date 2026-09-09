import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/date_math.dart';
import '../../../core/time/day.dart';
import '../data/payment_repository.dart';

/// Mở bảng thu tiền. Trả về kết quả nếu đã ghi nhận, `null` nếu người dùng huỷ.
Future<RecordPaymentResult?> showRenewSheet(
  BuildContext context, {
  required VehicleRow vehicle,
}) {
  return showModalBottomSheet<RecordPaymentResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => RenewSheet(vehicle: vehicle),
  );
}

/// Bảng thu tiền gửi xe.
///
/// Mọi con số đều **sửa được**, và đều có sẵn giá trị hợp lý để trường hợp phổ
/// biến nhất chỉ cần một chạm. Đây là màn hình chủ bãi dùng nhiều nhất trong
/// ngày, nên nó phải nhanh khi mọi thứ bình thường mà vẫn xử lý được các tình
/// huống lẻ: tăng giá, bớt cho khách quen, thu tiền muộn vài hôm.
class RenewSheet extends ConsumerStatefulWidget {
  const RenewSheet({super.key, required this.vehicle});

  final VehicleRow vehicle;

  @override
  ConsumerState<RenewSheet> createState() => _RenewSheetState();
}

class _RenewSheetState extends ConsumerState<RenewSheet> {
  static const _presets = [1, 3, 6, 12];

  late int _months;
  late int _unitPrice;
  late int _amount;
  late Day _paidAt;
  PaymentMethod _method = PaymentMethod.cash;
  bool _applyPrice = false;
  bool _saving = false;

  /// Người dùng đã tự gõ thành tiền → thôi tự tính lại theo đơn giá × số tháng.
  bool _amountEdited = false;

  late final TextEditingController _priceCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _monthsCtrl;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _months = 1;
    _unitPrice = widget.vehicle.monthlyPrice;
    _amount = _unitPrice;
    _paidAt = ref.read(todayProvider);
    _priceCtrl =
        TextEditingController(text: VndInputFormatter.toEditingText(_unitPrice));
    _amountCtrl =
        TextEditingController(text: VndInputFormatter.toEditingText(_amount));
    _monthsCtrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _amountCtrl.dispose();
    _monthsCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  /// Kỳ mới nối liền kỳ cũ — mốc kết thúc là loại trừ nên không cộng trừ ngày.
  Day get _periodStart =>
      widget.vehicle.currentPeriodEnd ?? widget.vehicle.startDate;

  Day get _newExpiry => periodEndFor(
        periodStart: _periodStart,
        months: _months,
        anchorDay: widget.vehicle.anchorDay,
      );

  bool get _monthsValid => _months >= 1 && _months <= 120;
  bool get _amountValid => _amount >= 0;
  int get _expectedAmount => _unitPrice * _months;

  void _recalcAmount() {
    if (_amountEdited) return;
    _amount = _expectedAmount;
    _amountCtrl.text = VndInputFormatter.toEditingText(_amount);
  }

  void _setMonths(int m) {
    setState(() {
      _months = m;
      if (_monthsCtrl.text != '$m') _monthsCtrl.text = '$m';
      _recalcAmount();
    });
  }

  Future<void> _submit() async {
    if (!_monthsValid || !_amountValid) return;
    setState(() => _saving = true);
    try {
      final result =
          await ref.read(paymentRepositoryProvider).recordPayment(
                vehicleId: widget.vehicle.id,
                months: _months,
                paidAt: _paidAt,
                amountOverride: _amount,
                unitPriceOverride: _unitPrice,
                applyPriceToVehicle: _applyPrice,
                method: _method,
                note: _noteCtrl.text.trim().isEmpty
                    ? null
                    : _noteCtrl.text.trim(),
              );
      if (mounted) Navigator.pop(context, result);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceChanged = _unitPrice != widget.vehicle.monthlyPrice;
    final amountDiffers = _amount != _expectedAmount;

    return Padding(
      // Đẩy nội dung lên trên bàn phím, nếu không ô nhập cuối bị che.
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(Strings.renewSheetTitle, style: theme.textTheme.titleLarge),
              Text(
                '${widget.vehicle.plate} · ${widget.vehicle.ownerName}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              Text(Strings.renewMonthCount, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _presets)
                    ChoiceChip(
                      label: Text('$m'),
                      selected: _months == m,
                      onSelected: (_) => _setMonths(m),
                    ),
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: _monthsCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: Strings.renewCustomMonths,
                        errorText: _monthsValid ? null : '',
                      ),
                      onChanged: (v) =>
                          _setMonths(int.tryParse(v) ?? 0),
                    ),
                  ),
                ],
              ),
              if (!_monthsValid)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(Strings.renewInvalidMonths,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error)),
                ),
              const SizedBox(height: 16),

              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [VndInputFormatter()],
                decoration: const InputDecoration(
                  labelText: Strings.renewUnitPrice,
                  suffixText: kVndSymbol,
                ),
                onChanged: (v) => setState(() {
                  _unitPrice = VndInputFormatter.parse(v) ?? 0;
                  _recalcAmount();
                }),
              ),
              if (priceChanged) ...[
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _applyPrice,
                  onChanged: (v) => setState(() => _applyPrice = v),
                  title: const Text(Strings.renewApplyPrice),
                  subtitle: const Text(Strings.renewApplyPriceHint),
                ),
              ],
              const SizedBox(height: 12),

              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [VndInputFormatter()],
                decoration: InputDecoration(
                  labelText: Strings.renewTotal,
                  suffixText: kVndSymbol,
                  // Không phải lỗi — chỉ báo cho biết số đã lệch công thức,
                  // vì bớt giá cho khách quen là chuyện bình thường.
                  helperText:
                      amountDiffers ? Strings.renewAmountDiffers : null,
                  errorText: _amountValid ? null : Strings.renewInvalidAmount,
                ),
                onChanged: (v) => setState(() {
                  _amountEdited = true;
                  _amount = VndInputFormatter.parse(v) ?? 0;
                }),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _FieldTile(
                      label: Strings.renewPaidOn,
                      value: formatDay(_paidAt),
                      onTap: _pickPaidDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FieldTile(
                      label: Strings.paymentMethodLabelText,
                      value: paymentMethodLabel(_method),
                      onTap: _pickMethod,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: Strings.note),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Xem trước hạn mới — thứ chủ bãi thực sự cần biết trước khi bấm.
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_available,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${Strings.renewFrom} ${formatDay(_periodStart)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Strings.renewNewExpiry,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _monthsValid ? formatDay(_newExpiry) : '—',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      (_saving || !_monthsValid || !_amountValid) ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('${Strings.renewConfirm} · ${formatVnd(_amount)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPaidDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidAt.localMidnight,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) setState(() => _paidAt = Day.fromLocal(picked));
  }

  Future<void> _pickMethod() async {
    final picked = await showModalBottomSheet<PaymentMethod>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final m in PaymentMethod.values)
              ListTile(
                title: Text(paymentMethodLabel(m)),
                selected: m == _method,
                onTap: () => Navigator.pop(ctx, m),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _method = picked);
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, isDense: true),
        child: Text(value),
      ),
    );
  }
}
