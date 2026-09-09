import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/date_math.dart';
import '../../../core/time/day.dart';
import 'vehicles_providers.dart';
import 'vehicles_strings.dart';

/// Mở bảng thêm xe (không truyền [vehicle]) hoặc sửa xe.
///
/// Trả `true` khi đã lưu, `null` khi người dùng đóng bảng.
Future<bool?> showVehicleFormSheet(
  BuildContext context, {
  VehicleRow? vehicle,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => VehicleFormSheet(vehicle: vehicle),
  );
}

/// Form thêm / sửa xe (mục 3 đặc tả).
class VehicleFormSheet extends ConsumerStatefulWidget {
  const VehicleFormSheet({super.key, this.vehicle});

  /// `null` là thêm mới.
  final VehicleRow? vehicle;

  @override
  ConsumerState<VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends ConsumerState<VehicleFormSheet> {
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _noteCtrl;

  int? _lotId;
  late VehicleType _type;
  late Day _startDate;
  int _monthsCount = 1;

  bool _saving = false;
  Timer? _plateCheckTimer;

  /// Lỗi hiển thị ngay dưới ô biển số. Đặt ở đây chứ không phải SnackBar vì lỗi
  /// này gắn với đúng một ô nhập và người dùng phải sửa chính ô đó.
  String? _plateError;
  String? _generalError;

  bool get _isEdit => widget.vehicle != null;

  Day get _periodEnd => periodEndFor(
        periodStart: _startDate,
        months: _monthsCount,
        anchorDay: _startDate.day,
      );

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _ownerCtrl = TextEditingController(text: v?.ownerName ?? '');
    _phoneCtrl = TextEditingController(text: v?.phone ?? '');
    _plateCtrl = TextEditingController(text: v?.plate ?? '');
    _priceCtrl = TextEditingController(
      text: v == null ? '' : VndInputFormatter.toEditingText(v.monthlyPrice),
    );
    _noteCtrl = TextEditingController(text: v?.notes ?? '');
    _lotId = v?.lotId;
    _type = v?.vehicleType ?? VehicleType.motorbike;
    _startDate = v?.startDate ?? ref.read(todayProvider);
  }

  @override
  void dispose() {
    _plateCheckTimer?.cancel();
    _ownerCtrl.dispose();
    _phoneCtrl.dispose();
    _plateCtrl.dispose();
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      !_saving &&
      _lotId != null &&
      _ownerCtrl.text.trim().isNotEmpty &&
      _plateCtrl.text.trim().isNotEmpty &&
      _priceCtrl.text.trim().isNotEmpty;

  void _onLotChanged(int? id) {
    setState(() {
      _lotId = id;
    });
    if (_plateCtrl.text.trim().isNotEmpty) {
      _onPlateChanged(_plateCtrl.text);
    }
  }

  void _onPlateChanged(String value) {
    setState(() {
      _plateError = null;
    });
    _plateCheckTimer?.cancel();
    _plateCheckTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted || _lotId == null) return;
      final plate = value.trim();
      if (plate.isEmpty) return;
      final repo = ref.read(vehicleRepositoryProvider);
      final exists = await repo.checkPlateExists(
        plate,
        _lotId!,
        excludeVehicleId: widget.vehicle?.id,
      );
      if (!mounted) return;
      if (exists) {
        setState(() {
          _plateError = Strings.errorDuplicatePlate;
        });
      }
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.localMidnight,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) setState(() => _startDate = Day.fromLocal(picked));
  }

  /// Nhận diện lỗi vi phạm chỉ số duy nhất `(lot_id, plate_normalized)`.
  ///
  /// Bắt theo nội dung thông báo chứ không theo kiểu ngoại lệ: `SqliteException`
  /// nằm trong gói `sqlite3` mà tầng giao diện không nên phụ thuộc, và Drift
  /// bọc lại ngoại lệ khác nhau tuỳ nền tảng.
  static bool _isDuplicatePlate(Object e) {
    final s = e.toString().toUpperCase();
    return s.contains('UNIQUE') || s.contains('UQ_VEHICLES_ACTIVE_PLATE');
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() {
      _saving = true;
      _plateError = null;
      _generalError = null;
    });

    final navigator = Navigator.of(context);
    final repo = ref.read(vehicleRepositoryProvider);
    final phone = _phoneCtrl.text.trim();
    final notes = _noteCtrl.text.trim();
    final price = VndInputFormatter.parse(_priceCtrl.text) ?? 0;

    try {
      if (_isEdit) {
        await repo.update(
          widget.vehicle!.id,
          lotId: _lotId!,
          ownerName: _ownerCtrl.text.trim(),
          phone: phone.isEmpty ? null : phone,
          type: _type,
          plate: _plateCtrl.text.trim(),
          monthlyPrice: price,
          notes: notes.isEmpty ? null : notes,
        );
      } else {
        final id = await repo.create(
          lotId: _lotId!,
          ownerName: _ownerCtrl.text.trim(),
          phone: phone.isEmpty ? null : phone,
          type: _type,
          plate: _plateCtrl.text.trim(),
          monthlyPrice: price,
          startDate: _startDate,
          notes: notes.isEmpty ? null : notes,
        );
        if (_monthsCount > 0) {
          await ref.read(paymentRepositoryProvider).recordPayment(
                vehicleId: id,
                months: _monthsCount,
                paidAt: _startDate,
                periodStartOverride: _startDate,
                unitPriceOverride: price,
              );
        }
      }
      navigator.pop(true);
    } catch (e) {
      // Không để lộ câu lỗi SQLite thô ra màn hình: "UNIQUE constraint failed:
      // vehicles.lot_id, vehicles.plate_normalized" không nói được gì với chủ
      // bãi, và cũng không chỉ ra phải sửa ô nào.
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (_isDuplicatePlate(e)) {
          _plateError = Strings.errorDuplicatePlate;
        } else {
          _generalError = Strings.errorGeneric;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lots = ref.watch(activeLotsProvider);

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
              Text(_isEdit ? Strings.vehicleEdit : Strings.vehicleAdd,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              // ── Bãi xe (bắt buộc) ──
              lots.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (rows) {
                  // Nếu chỉ có 1 bãi duy nhất và chưa chọn bãi nào, tự động chọn luôn bãi đó
                  if (_lotId == null && rows.length == 1) {
                    _lotId = rows.first.id;
                  }
                  final selectedId = rows.any((l) => l.id == _lotId) ? _lotId : null;

                  return DropdownButtonFormField<int>(
                    initialValue: selectedId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: Strings.lotSelect,
                      prefixIcon: Icon(Icons.local_parking),
                    ),
                    items: [
                      for (final l in rows)
                        DropdownMenuItem<int>(value: l.id, child: Text(l.name)),
                    ],
                    onChanged: (id) => _onLotChanged(id),
                  );
                },
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _ownerCtrl,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: Strings.vehicleOwner,
                  hintText: Strings.vehicleOwnerHint,
                  suffixText: Strings.required,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: Strings.phone,
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<VehicleType>(
                initialValue: _type,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: Strings.vehicleType,
                  prefixIcon: Icon(Icons.two_wheeler),
                ),
                items: [
                  for (final t in VehicleType.values)
                    DropdownMenuItem<VehicleType>(
                      value: t,
                      child: Text(vehicleTypeLabel(t)),
                    ),
                ],
                onChanged: (t) {
                  if (t != null) setState(() => _type = t);
                },
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _plateCtrl,
                textCapitalization: TextCapitalization.characters,
                onChanged: _onPlateChanged,
                decoration: InputDecoration(
                  labelText: Strings.vehiclePlate,
                  hintText: Strings.vehiclePlateHint,
                  suffixText: Strings.required,
                  errorText: _plateError,
                ),
              ),
              if (_plateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    VehiclesStrings.duplicatePlateHint,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 12),

              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: const [VndInputFormatter()],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: Strings.vehicleMonthlyFee,
                  suffixText: kVndSymbol,
                ),
              ),
              const SizedBox(height: 16),

              if (!_isEdit) ...[
                Text(Strings.vehicleMonthsCount, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in [1, 2, 3, 6, 12])
                      ChoiceChip(
                        label: Text('$m tháng'),
                        selected: _monthsCount == m,
                        onSelected: (_) => setState(() => _monthsCount = m),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              _DateField(
                label: Strings.vehicleStartDate,
                value: formatDay(_startDate),
                // Ngày bắt đầu neo `anchorDay` của toàn bộ chu kỳ thanh toán;
                // đổi nó sau khi đã thu tiền sẽ làm lệch mọi kỳ đã ghi nhận.
                onTap: _isEdit ? null : _pickStartDate,
                note: _isEdit ? VehiclesStrings.startDateLocked : null,
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                _DateField(
                  label: Strings.vehicleEndDate,
                  value: formatDay(_periodEnd),
                  onTap: null,
                ),
              ],
              const SizedBox(height: 12),

              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: Strings.note,
                  hintText: Strings.noteHint,
                ),
              ),

              if (_generalError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _generalError!,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _saving ? null : () => Navigator.pop(context),
                      child: const Text(Strings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      // Vô hiệu khi thiếu bãi / chủ xe / biển số. Cho bấm rồi
                      // mới báo lỗi sẽ khiến người dùng phải đoán ô nào thiếu.
                      onPressed: _canSave ? _save : null,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.note,
  });

  final String label;
  final String value;

  /// `null` thì ô chỉ để đọc.
  final VoidCallback? onTap;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event),
          enabled: onTap != null,
          helperText: note,
          helperMaxLines: 3,
        ),
        child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
