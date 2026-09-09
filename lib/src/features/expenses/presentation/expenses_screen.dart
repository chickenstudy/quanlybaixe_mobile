import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/year_month.dart';
import 'expense_form_sheet.dart';
import 'expenses_providers.dart';
import 'expenses_strings.dart';
import 'recurring_templates_screen.dart';

/// Sổ chi phí theo tháng (mục 2 đặc tả).
///
/// Màn hình trả lời đúng một câu: **tháng này bãi tốn bao nhiêu tiền, vào
/// những khoản gì**. Vì vậy con số tổng nằm trên đầu, và danh sách bên dưới
/// tách hẳn hai loại — chi phí cố định hàng tháng (do mẫu sinh ra) và chi phí
/// phát sinh (nhập tay). Hai loại ấy khác nhau về bản chất: một bên đã biết
/// trước và chỉ chờ đối chiếu hoá đơn, một bên là chuyện bất ngờ của tháng.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedExpenseMonthProvider);
    final lotFilter = ref.watch(expenseLotFilterProvider);
    final expenses = ref.watch(monthExpensesProvider);
    final total = ref.watch(monthExpenseTotalProvider);
    final lots = ref.watch(expenseLotsProvider).value ?? const <LotRow>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.expenses),
        actions: [
          IconButton(
            tooltip: Strings.expenseTemplates,
            icon: const Icon(Icons.event_repeat_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RecurringTemplatesScreen(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showExpenseFormSheet(
          context,
          initialMonth: month,
          initialLotId: lotFilter,
        ),
        tooltip: Strings.expenseAdd,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _Header(
            month: month,
            total: total,
            lots: lots,
            selectedLotId: lotFilter,
          ),
          Expanded(
            child: expenses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(error: e),
              data: (rows) => rows.isEmpty
                  ? _EmptyView(month: month, hasLots: lots.isNotEmpty)
                  : _ExpenseList(
                      rows: rows,
                      month: month,
                      showLotName: lotFilter == null && lots.length > 1,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thanh chọn tháng + tổng chi + lọc theo bãi.
///
/// Gộp cả ba vào một khối cố định trên đầu thay vì cho cuộn theo danh sách:
/// con số tổng là thứ người dùng liếc lại nhiều nhất, và bộ chọn tháng phải
/// luôn trong tầm ngón tay cái.
class _Header extends ConsumerWidget {
  const _Header({
    required this.month,
    required this.total,
    required this.lots,
    required this.selectedLotId,
  });

  final YearMonth month;
  final int total;
  final List<LotRow> lots;
  final int? selectedLotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final monthCtrl = ref.read(selectedExpenseMonthProvider.notifier);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
            child: MonthStepper(
              month: month,
              onPrevious: monthCtrl.previous,
              onNext: monthCtrl.next,
              previousTooltip: Strings.lastMonth,
              nextTooltip: ExpensesStrings.nextMonth,
              labelStyle: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Text(
                  ExpensesStrings.monthTotal,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  // Số tiền là thứ tuyệt đối không được cắt cụt hay xuống
                  // dòng; ở màn hình hẹp thì thu nhỏ chữ chứ không ellipsis.
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatVnd(total),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          // Một bãi thì không có gì để lọc — chip "Tất cả bãi" đứng một mình
          // chỉ tổ chiếm chỗ.
          if (lots.length > 1)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: const Text(ExpensesStrings.allLots),
                      selected: selectedLotId == null,
                      onSelected: (_) =>
                          ref.read(expenseLotFilterProvider.notifier).set(null),
                    ),
                  ),
                  for (final l in lots)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(l.name),
                        selected: selectedLotId == l.id,
                        onSelected: (_) => ref
                            .read(expenseLotFilterProvider.notifier)
                            .set(l.id),
                      ),
                    ),
                ],
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

/// Danh sách chi phí, tách hai khối theo [ExpenseKind].
class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({
    required this.rows,
    required this.month,
    required this.showLotName,
  });

  final List<ExpenseRow> rows;
  final YearMonth month;
  final bool showLotName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotNames = ref.watch(lotNamesProvider);
    final recurring =
        rows.where((e) => e.kind == ExpenseKind.recurring).toList();
    final adhoc = rows.where((e) => e.kind == ExpenseKind.adhoc).toList();

    Iterable<Widget> section(String title, List<ExpenseRow> items) sync* {
      if (items.isEmpty) return;
      yield _SectionHeader(
        title: title,
        total: items.fold<int>(0, (s, e) => s + e.amount),
      );
      for (final e in items) {
        yield _ExpenseTile(
          expense: e,
          month: month,
          lotName: showLotName ? lotNames[e.lotId] : null,
        );
      }
    }

    return ListView(
      // Chừa chỗ cho nút `+` khỏi che dòng cuối cùng.
      padding: const EdgeInsets.only(top: 4, bottom: 96),
      children: [
        ...section(Strings.expenseFixed, recurring),
        ...section(Strings.expenseAdhoc, adhoc),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.total});

  final String title;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatVnd(total),
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Một dòng chi phí. Chạm vào để sửa hoặc xoá.
class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.month,
    required this.lotName,
  });

  final ExpenseRow expense;
  final YearMonth month;
  final String? lotName;

  /// Dòng do mẫu sinh ra mà người dùng chưa xác nhận số tiền thật.
  ///
  /// Bám vào `isEdited` chứ không vào `sourceTemplateId`: mẫu có thể đã bị xoá
  /// (khi đó cột trỏ về mẫu thành `null`) nhưng con số vẫn chỉ là ước tính
  /// chưa ai đối chiếu, và người dùng vẫn cần biết điều đó.
  bool get _isEstimate =>
      expense.kind == ExpenseKind.recurring && !expense.isEdited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = costCategoryLabel(expense.category);
    final day = formatDay(expense.incurredOn);

    return InkWell(
      onTap: () => showExpenseFormSheet(
        context,
        expense: expense,
        initialMonth: month,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _isEstimate ? Icons.receipt_long_outlined : Icons.receipt_long,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lotName == null
                        ? ExpensesStrings.categoryAndDay(category, day)
                        : ExpensesStrings.categoryDayLot(
                            category, day, lotName!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatVnd(expense.amount),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (_isEstimate) ...[
                  const SizedBox(height: 2),
                  const _EstimateBadge(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Nhãn "ước tính".
///
/// Cố tình nhỏ và nhạt: đây không phải cảnh báo, chỉ là lời nhắc rằng con số
/// này lấy từ mẫu chứ chưa ai nhìn hoá đơn. Nhưng nó phải có mặt — không có
/// thì người dùng đọc tổng chi phí tháng như một con số đã chốt, trong khi
/// tiền điện thật có thể lệch vài trăm nghìn.
class _EstimateBadge extends StatelessWidget {
  const _EstimateBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: ExpensesStrings.estimateHint,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          ExpensesStrings.estimate,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.month, required this.hasLots});

  final YearMonth month;
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
            Icon(Icons.receipt_long_outlined,
                size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(Strings.expenseEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              hasLots
                  ? ExpensesStrings.emptyHint
                  : ExpensesStrings.needLotFirst,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (hasLots) ...[
              const SizedBox(height: 24),
              // Nút ngay trong khoảng trống: nút `+` ở góc dưới nhỏ và dễ bị
              // bỏ qua với người dùng lớn tuổi chưa quen giao diện.
              FilledButton.icon(
                onPressed: () =>
                    showExpenseFormSheet(context, initialMonth: month),
                icon: const Icon(Icons.add),
                label: const Text(Strings.expenseAdd),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RecurringTemplatesScreen(),
                  ),
                ),
                icon: const Icon(Icons.event_repeat_outlined),
                label: const Text(Strings.expenseTemplates),
              ),
            ],
          ],
        ),
      ),
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
