import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/year_month.dart';
import 'expenses_providers.dart';
import 'expenses_strings.dart';
import 'recurring_template_form_sheet.dart';

/// Quản lý mẫu chi phí cố định hàng tháng (mục 2 đặc tả).
///
/// Mẫu ở đây **không phải là chi phí**. Nó là lời khai "bãi này tháng nào cũng
/// mất chừng này tiền điện"; mỗi tháng ứng dụng tự sinh ra một dòng chi phí
/// thật từ nó, và người dùng sửa lại đúng số trên hoá đơn khi hoá đơn về. Vì
/// vậy sửa mẫu không hề đụng tới các tháng đã sinh — điều đó được nói thẳng
/// trên đầu màn hình, nếu không người dùng sẽ sửa mẫu rồi ngồi đợi tháng cũ
/// thay đổi.
class RecurringTemplatesScreen extends ConsumerWidget {
  const RecurringTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(expenseTemplatesProvider);
    final lots = ref.watch(expenseLotsProvider).value ?? const <LotRow>[];

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.expenseTemplates)),
      floatingActionButton: lots.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => showRecurringTemplateFormSheet(context),
              tooltip: Strings.expenseTemplateAdd,
              child: const Icon(Icons.add),
            ),
      body: templates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('$e', textAlign: TextAlign.center),
        ),
        data: (rows) => rows.isEmpty
            ? _EmptyView(hasLots: lots.isNotEmpty)
            : _TemplateList(rows: rows, lots: lots),
      ),
    );
  }
}

class _TemplateList extends StatelessWidget {
  const _TemplateList({required this.rows, required this.lots});

  final List<RecurringCostTemplateRow> rows;
  final List<LotRow> lots;

  @override
  Widget build(BuildContext context) {
    final names = {for (final l in lots) l.id: l.name};
    // Đã sắp theo `lotId` từ tầng truy vấn, nên chỉ cần chèn tiêu đề mỗi khi
    // đổi bãi thay vì gom nhóm lại lần nữa trong Dart.
    final children = <Widget>[const _NoteCard()];
    int? currentLot;
    for (final t in rows) {
      if (t.lotId != currentLot) {
        currentLot = t.lotId;
        children.add(_LotHeader(name: names[t.lotId] ?? Strings.lots));
      }
      children.add(_TemplateCard(template: t));
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 96),
      children: children,
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              Strings.expenseTemplateNote,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _LotHeader extends StatelessWidget {
  const _LotHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Một mẫu. Chạm vào thẻ để sửa, công tắc để tạm dừng, thùng rác để xoá hẳn.
///
/// Tạm dừng và xoá là hai việc khác nhau và đều cần: dừng khi hết mùa cao điểm
/// mà vẫn có thể bật lại, xoá khi khai nhầm. Chỉ có xoá thì người dùng sẽ xoá
/// rồi khai lại từ đầu mỗi lần.
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({required this.template});

  final RecurringCostTemplateRow template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final endMonth = template.endMonth;
    final range = ExpensesStrings.templateRange(
      formatMonth(YearMonth.parse(template.startMonth)),
      endMonth == null ? null : formatMonth(YearMonth.parse(endMonth)),
    );

    return Card(
      child: InkWell(
        onTap: () =>
            showRecurringTemplateFormSheet(context, template: template),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ExpensesStrings.categoryAndDay(
                        costCategoryLabel(template.category),
                        ExpensesStrings.amountPerMonth(
                            formatVnd(template.amount)),
                      ),
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.isActive
                          ? range
                          : '$range · ${Strings.expenseTemplateStopped}',
                      maxLines: 2,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(
                value: template.isActive,
                onChanged: (v) => _setActive(ref, v),
              ),
              IconButton(
                onPressed: () => _confirmDelete(context, ref),
                tooltip: Strings.delete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bật/tắt đi qua kho dữ liệu chứ không ghi thẳng vào bảng: chỉ ở đó mới có
  /// bước chạy lại bộ sinh, mà thiếu bước đó thì mẫu vừa bật lên không sinh ra
  /// dòng nào cho tháng hiện tại.
  Future<void> _setActive(WidgetRef ref, bool value) {
    return ref.read(expenseRepositoryProvider).updateTemplate(
          template.id,
          lotId: template.lotId,
          name: template.name,
          category: template.category,
          amount: template.amount,
          dayOfMonth: template.dayOfMonth,
          startMonth: YearMonth.parse(template.startMonth),
          endMonth: template.endMonth == null
              ? null
              : YearMonth.parse(template.endMonth!),
          isActive: value,
          note: template.note,
        );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    // Giữ messenger TRƯỚC khi await: xoá xong stream phát danh sách mới và
    // chính thẻ này bị gỡ khỏi cây widget.
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(expenseRepositoryProvider);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Strings.confirmDeleteNamed(template.name)),
        // KHÔNG dùng `Strings.confirmDeleteMessage` ("không lấy lại được"): ở
        // đây câu đó vừa đúng vừa sai, và phần sai — tưởng mất luôn sổ chi phí
        // cũ — là phần khiến người dùng không dám bấm.
        content: const Text(ExpensesStrings.deleteTemplateMessage),
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
    await repo.deleteTemplate(template.id);
    messenger.showSnackBar(const SnackBar(content: Text(Strings.deleted)));
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasLots});

  final bool hasLots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_repeat_outlined,
                size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(ExpensesStrings.templateEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              hasLots
                  ? ExpensesStrings.templateEmptyHint
                  : ExpensesStrings.needLotFirst,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (hasLots) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => showRecurringTemplateFormSheet(context),
                icon: const Icon(Icons.add),
                label: const Text(Strings.expenseTemplateAdd),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
