import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import 'lots_strings.dart';

/// Mở bảng thêm/sửa bãi xe. Trả `true` khi đã lưu, `null` khi người dùng thoát.
///
/// Truyền [lot] để sửa, bỏ trống để thêm mới.
Future<bool?> showLotFormSheet(BuildContext context, {LotRow? lot}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => LotFormSheet(lot: lot),
  );
}

/// Bảng thêm/sửa bãi xe (mục 2 đặc tả).
///
/// Chỉ **tên bãi** là bắt buộc. Địa chỉ, giá mặc định, sức chứa, ghi chú đều có
/// thể để trống: chủ bãi thường tạo bãi trước rồi mới điền dần, bắt nhập đủ
/// ngay từ đầu chỉ khiến họ gõ bừa cho xong.
class LotFormSheet extends ConsumerStatefulWidget {
  const LotFormSheet({super.key, this.lot});

  final LotRow? lot;

  @override
  ConsumerState<LotFormSheet> createState() => _LotFormSheetState();
}

class _LotFormSheetState extends ConsumerState<LotFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _notesCtrl;

  late bool _isActive;
  bool _saving = false;

  bool get _isEdit => widget.lot != null;

  /// Tên trống thì không có gì để lưu — nút Lưu tắt hẳn thay vì cho bấm rồi
  /// mới báo lỗi.
  bool get _canSave => !_saving && _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final lot = widget.lot;
    _nameCtrl = TextEditingController(text: lot?.name ?? '');
    _addressCtrl = TextEditingController(text: lot?.address ?? '');
    _capacityCtrl =
        TextEditingController(text: lot?.capacity?.toString() ?? '');
    _notesCtrl = TextEditingController(text: lot?.notes ?? '');
    _isActive = lot?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _capacityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Ô trống trả `null` chứ không trả chuỗi rỗng: cột trong CSDL cho phép
  /// `NULL`, và `''` sẽ khiến các chỗ kiểm tra "có địa chỉ không" hiểu sai.
  String? _trimmedOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _submit() async {
    if (!_canSave) return;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(lotRepositoryProvider);
    final name = _nameCtrl.text.trim();
    // Sức chứa để trống nghĩa là "chưa biết", khác hẳn với 0 chỗ — danh sách
    // dựa vào chỗ `null` này để ẩn tỷ lệ lấp đầy.
    final capacity = int.tryParse(_capacityCtrl.text.trim());

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await repo.update(
          widget.lot!.id,
          name: name,
          address: _trimmedOrNull(_addressCtrl),
          capacity: capacity,
          notes: _trimmedOrNull(_notesCtrl),
          isActive: _isActive,
        );
      } else {
        await repo.create(
          name: name,
          address: _trimmedOrNull(_addressCtrl),
          capacity: capacity,
          notes: _trimmedOrNull(_notesCtrl),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
          const SnackBar(content: Text(Strings.errorGeneric)));
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // Đẩy nội dung lên trên bàn phím, nếu không ô ghi chú bị che hoàn toàn.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEdit ? Strings.lotEdit : Strings.lotAdd,
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),

              TextField(
                controller: _nameCtrl,
                autofocus: !_isEdit,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: Strings.lotName,
                  hintText: Strings.lotNameHint,
                ),
                // Nút Lưu bật/tắt theo ô này nên phải dựng lại mỗi lần gõ.
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _addressCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: Strings.lotAddress),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _capacityCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  labelText: Strings.lotCapacity,
                  hintText: Strings.lotCapacityHint,
                  helperText: LotsStrings.capacityHelp,
                  helperMaxLines: 2,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: Strings.note,
                  hintText: Strings.noteHint,
                ),
              ),

              // Chỉ hiện khi sửa: bãi mới tạo bao giờ cũng đang hoạt động, thêm
              // một công tắc luôn bật vào form tạo chỉ tổ gây phân vân.
              if (_isEdit) ...[
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text(LotsStrings.isActive),
                  subtitle: const Text(LotsStrings.isActiveHint),
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
