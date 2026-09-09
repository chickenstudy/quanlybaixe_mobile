import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../theme/app_theme.dart';
import '../data/lot_repository.dart';
import 'lot_form_sheet.dart';
import 'lots_providers.dart';
import 'lots_strings.dart';

/// Danh sách bãi xe (mục 2 đặc tả).
///
/// Mỗi dòng trả lời đúng ba câu chủ bãi hỏi khi mở màn hình này: bãi này đang
/// có bao nhiêu xe, bao nhiêu xe đã quá hạn, và còn chỗ không.
class LotsScreen extends ConsumerWidget {
  const LotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(lotSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.lots)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showLotFormSheet(context),
        tooltip: Strings.lotAdd,
        child: const Icon(Icons.add),
      ),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e),
        data: (items) => items.isEmpty
            ? const _EmptyView()
            : ListView.builder(
                // Chừa chỗ cho nút `+` khỏi che thẻ cuối cùng.
                padding: const EdgeInsets.only(top: 8, bottom: 96),
                itemCount: items.length,
                itemBuilder: (_, i) => _LotCard(summary: items[i]),
              ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_parking,
                size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(Strings.lotEmpty, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              Strings.lotEmptyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            // Nút ngay trong khoảng trống: nút `+` ở góc dưới nhỏ và dễ bị bỏ
            // qua với người dùng lớn tuổi chưa quen giao diện.
            FilledButton.icon(
              onPressed: () => showLotFormSheet(context),
              icon: const Icon(Icons.add),
              label: const Text(Strings.lotAdd),
            ),
          ],
        ),
      ),
    );
  }
}

/// Một bãi trên danh sách. Chạm vào thẻ để sửa, biểu tượng thùng rác để xoá.
class _LotCard extends ConsumerWidget {
  const _LotCard({required this.summary});

  final LotSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final lot = summary.lot;
    final rate = summary.occupancyRate;
    final isFull = rate != null && rate >= 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showLotFormSheet(context, lot: lot),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lot.name,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        // "Địa chỉ · 12 xe" — gộp một dòng để thẻ không cao
                        // quá, danh sách vài chục bãi vẫn liếc hết được.
                        Text(
                          Strings.lotSubtitle(
                              lot.address ?? '', summary.activeVehicles),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, ref, lot),
                    tooltip: Strings.delete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  // Chỉ hiện khi thực sự có xe quá hạn: một con số 0 màu đỏ
                  // trên mọi dòng làm mất hết sức cảnh báo của màu đỏ.
                  if (summary.expiredVehicles > 0)
                    _Tag(
                      icon: Icons.error_outline,
                      label: Strings.vehiclesExpired(summary.expiredVehicles),
                      color: status.expired,
                    ),
                  // Chưa thu lần nào là việc khác với quá hạn gia hạn — gộp
                  // chung sẽ khiến con số ở đây vênh với màn hình tổng quan,
                  // nơi hai loại đã được tách sẵn.
                  if (summary.neverPaidVehicles > 0)
                    _Tag(
                      icon: Icons.money_off,
                      label: LotsStrings.vehiclesNeverPaid(
                          summary.neverPaidVehicles),
                      color: status.expired,
                    ),
                  if (!lot.isActive)
                    _Tag(
                      icon: Icons.pause_circle_outline,
                      label: LotsStrings.inactive,
                    ),
                ],
              ),
              // Tỷ lệ lấp đầy CHỈ hiện khi biết sức chứa. Không có sức chứa mà
              // vẫn vẽ thanh 0% thì người dùng đọc thành "bãi đang trống".
              if (rate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _OccupancyBar(rate: rate, isFull: isFull)),
                    const SizedBox(width: 12),
                    Text(
                      isFull ? Strings.lotFull : '${(rate * 100).round()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isFull
                            ? status.expired
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  Strings.occupancy(summary.activeVehicles, lot.capacity!),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hỏi xác nhận rồi xoá mềm.
  ///
  /// Bãi còn xe thì kho dữ liệu từ chối và ném [LotHasVehiclesException] —
  /// thông điệp của nó đã nói rõ còn bao nhiêu xe và phải làm gì, nên hiện
  /// thẳng chứ không thay bằng câu chung chung.
  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, LotRow lot) async {
    // Giữ messenger TRƯỚC khi await: xoá xong stream phát danh sách mới và
    // chính thẻ này bị gỡ khỏi cây widget, lúc đó tra ancestor sẽ ném lỗi.
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(lotRepositoryProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Strings.confirmDeleteNamed(lot.name)),
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
    if (confirmed != true) return;

    try {
      await repo.softDelete(lot.id);
      messenger.showSnackBar(
          const SnackBar(content: Text(Strings.deleted)));
    } on LotHasVehiclesException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString()),
        // Câu này dài và có một con số phải đọc kỹ — 4 giây mặc định không đủ.
        duration: const Duration(seconds: 6),
      ));
    }
  }
}

/// Thanh lấp đầy vẽ tay.
///
/// Không dùng `LinearProgressIndicator` vì nó mang ngữ nghĩa "đang tải" cho
/// trình đọc màn hình, trong khi đây là một số liệu tĩnh; con số phần trăm nằm
/// ngay bên cạnh mới là thông tin, thanh này chỉ để liếc nhanh.
class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({required this.rate, required this.isFull});

  final double rate;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 8,
        color: theme.colorScheme.surfaceContainerHighest,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: rate.clamp(0.0, 1.0),
          child: ColoredBox(
            color: isFull
                ? context.statusColors.expired
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Nhãn nhỏ có biểu tượng. Biểu tượng luôn đi kèm chữ — màu và hình một mình
/// không đủ cho người phân biệt màu kém.
class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: c)),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 40, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 8),
          Text('$error', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
