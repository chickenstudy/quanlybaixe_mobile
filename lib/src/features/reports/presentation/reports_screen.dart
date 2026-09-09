/// Màn hình báo cáo doanh thu · chi phí · lợi nhuận (mục 5 đặc tả).
///
/// Bốn điều khiển trên đầu — bãi, mốc gom nhóm, khoảng thời gian, cách tính
/// doanh thu — quyết định toàn bộ phần còn lại của màn hình. Đặt hết ở một chỗ
/// và luôn nhìn thấy được, vì con số bên dưới vô nghĩa nếu không biết nó đang
/// được lọc theo cái gì.
library;


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/day.dart';
import '../../../theme/app_theme.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../data/report_repository.dart';
import 'reports_providers.dart';
import 'reports_strings.dart';
import 'revenue_chart.dart';

/// Báo cáo doanh thu · chi phí · lợi nhuận.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(reportResultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.reports)),
      // `SingleChildScrollView` chứ không `ListView`: báo cáo là một trang
      // liền mạch chứ không phải danh sách dài vô hạn, và dựng hết một lượt
      // thì phần dưới không bị "nhảy" khi cuộn tới.
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FiltersCard(),
            result.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => _ErrorView(error: e),
              data: (r) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Totals(result: r),
                  if (r.granularityDowngraded)
                    const _GranularityDowngradedNotice(),
                  // Không có mốc nào thì hiện đúng MỘT câu, thay vì hai tiêu
                  // đề mục kèm hai khung biểu đồ rỗng.
                  if (r.points.isEmpty)
                    const _ReportEmptyState()
                  else ...[
                    _Charts(result: r),
                    _DetailList(result: r),
                  ],
                ],
              ),
            ),
            const _ExpenseBreakdown(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ĐIỀU KHIỂN
// ══════════════════════════════════════════════════════════════════════════

class _FiltersCard extends ConsumerWidget {
  const _FiltersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lots = ref.watch(reportLotsProvider);
    final lotFilter = ref.watch(reportLotFilterProvider);
    final granularity = ref.watch(reportGranularityProvider);
    final range = ref.watch(reportRangeProvider);
    final mode = ref.watch(revenueModeProvider);

    final lotList = lots.value ?? const <LotRow>[];
    final lotName = lotFilter == null
        ? Strings.all
        : lotList
            .where((l) => l.id == lotFilter)
            .map((l) => l.name)
            .firstOrNull ??
            Strings.all;

    // Thu gọn mặc định. Bốn nhóm chip trải ra chiếm trọn màn hình đầu tiên,
    // đẩy mọi con số xuống dưới nếp gấp — một màn hình báo cáo mà phải cuộn
    // mới thấy số nào thì hỏng mất mục đích. Dòng tóm tắt cho biết đang xem
    // gì mà không cần mở ra.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Công tắc cách tính doanh thu LUÔN hiện, không nằm trong phần thu
        // gọn: đây là tính năng trọng tâm của mục 4 đặc tả và là câu hỏi
        // người dùng đặt ra thường xuyên nhất khi nhìn con số. Ba bộ lọc còn
        // lại (bãi, mốc, khoảng) thì chọn một lần rồi thôi, nên thu gọn được.
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // ── Cách tính doanh thu ────────────────────────────────────────
                  const _FilterLabel(Strings.reportRevenueMode),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final m in RevenueMode.values)
                        ChoiceChip(
                          label: Text(revenueModeLabel(m)),
                          selected: mode == m,
                          // Dùng lại đúng provider của dashboard: đổi ở đây thì
                          // dashboard đổi theo, hai màn hình không bao giờ hiện hai
                          // con số khác nhau cho cùng một tháng.
                          onSelected: (_) =>
                              ref.read(revenueModeProvider.notifier).set(m),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mode == RevenueMode.cash
                        ? Strings.reportRevenueModeCashNote
                        : Strings.reportRevenueModeAccrualNote,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: const Text(ReportsStrings.filtersTitle),
        subtitle: Text(ReportsStrings.filterSummary(
          lotName,
          reportGranularityLabel(granularity),
          revenueModeLabel(mode),
        )),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // ── Bãi ────────────────────────────────────────────────────────
            const _FilterLabel(ReportsStrings.lotFilter),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text(Strings.all),
                  selected: lotFilter == null,
                  onSelected: (_) =>
                      ref.read(reportLotFilterProvider.notifier).set(null),
                ),
                for (final lot in lots.value ?? const <LotRow>[])
                  ChoiceChip(
                    label: Text(lot.name),
                    selected: lotFilter == lot.id,
                    onSelected: (_) =>
                        ref.read(reportLotFilterProvider.notifier).set(lot.id),
                  ),
              ],
            ),

            // ── Mốc gom nhóm ───────────────────────────────────────────────
            const _FilterLabel(Strings.reportGranularity),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final g in ReportGranularity.values)
                  ChoiceChip(
                    label: Text(reportGranularityLabel(g)),
                    selected: granularity == g,
                    onSelected: (_) =>
                        ref.read(reportGranularityProvider.notifier).set(g),
                  ),
              ],
            ),

            // ── Khoảng thời gian ───────────────────────────────────────────
            const _FilterLabel(Strings.reportRange),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final entry in const <(ReportRangePreset, String)>[
                  (ReportRangePreset.thisMonth, ReportsStrings.rangeThisMonth),
                  (ReportRangePreset.thisQuarter, ReportsStrings.rangeThisQuarter),
                  (ReportRangePreset.thisYear, ReportsStrings.rangeThisYear),
                  (ReportRangePreset.last12Months, ReportsStrings.rangeLast12Months),
                ])
                  ChoiceChip(
                    label: Text(entry.$2),
                    selected: range.preset == entry.$1,
                    onSelected: (_) => ref
                        .read(reportRangeProvider.notifier)
                        .setPreset(entry.$1),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: ReportsStrings.rangePickCustom,
                child: OutlinedButton.icon(
                  onPressed: () => _pickRange(context, ref, range),
                  icon: const Icon(Icons.date_range),
                  // Hiện thẳng khoảng đang xem, đã lùi mốc `to` về ngày cuối
                  // **bao gồm** — ghi "tới 01/09" cho báo cáo tháng 8 là sai.
                  label: Text(formatDayRange(range.from, range.lastDay)),
                ),
              ),
            ),

        ],
      ),
        ),
      ],
    );
  }

  Future<void> _pickRange(
    BuildContext context,
    WidgetRef ref,
    ReportRange current,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: current.from.localMidnight,
        end: current.lastDay.localMidnight,
      ),
    );
    if (picked == null) return;
    ref.read(reportRangeProvider.notifier).setCustom(
          from: Day.fromLocal(picked.start),
          lastDay: Day.fromLocal(picked.end),
        );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// BA Ô TỔNG
// ══════════════════════════════════════════════════════════════════════════

class _GranularityDowngradedNotice extends StatelessWidget {
  const _GranularityDowngradedNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ReportsStrings.granularityDowngradedTitle,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ReportsStrings.granularityDowngradedBody,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// BIỂU ĐỒ
// ══════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════
// HÀNG SỐ TỔNG
// ══════════════════════════════════════════════════════════════════════════

/// Ba con số tổng, dạng khối ba dòng gọn.
///
/// Trước đây mỗi con số là một thẻ chiếm trọn bề ngang, ba thẻ ăn hết 540px và
/// đẩy biểu đồ xuống dưới nếp gấp.
///
/// Đã cân nhắc xếp ba ô cạnh nhau, nhưng mỗi ô chỉ còn ~110pt thì buộc phải rút
/// gọn số thành "12,5 tr". Người dùng ở đây đang **đối chiếu tiền mặt**, nên độ
/// chính xác đáng giá hơn sự cân đối. Ba dòng nhãn-trái / số-phải đọc như một
/// tờ biên lai, giữ nguyên số đầy đủ, mà vẫn chỉ tốn ~140px.
class _Totals extends StatelessWidget {
  const _Totals({required this.result});

  final ReportResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final loss = result.isLoss;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            _TotalRow(
              label: ReportsStrings.totalRevenue,
              amount: result.totalRevenue,
              valueKey: 'report-total-revenue',
            ),
            const SizedBox(height: 8),
            _TotalRow(
              label: ReportsStrings.totalExpense,
              amount: result.totalExpense,
              valueKey: 'report-total-expense',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                  height: 1, color: theme.colorScheme.outlineVariant),
            ),
            _TotalRow(
              label: ReportsStrings.totalProfit,
              amount: result.profit,
              valueKey: 'report-total-profit',
              color: loss ? status.loss : status.profit,
              signed: true,
              emphasized: true,
              // Màu không bao giờ là tín hiệu duy nhất: con số luôn mang dấu, và
              // có thêm biểu tượng cùng chữ "Lãi"/"Lỗ".
              badge: result.profit == 0
                  ? Strings.reportBreakEven
                  : (loss
                      ? ReportsStrings.poleNegative
                      : ReportsStrings.polePositive),
              icon: result.profit == 0
                  ? Icons.horizontal_rule
                  : (loss ? Icons.trending_down : Icons.trending_up),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    required this.valueKey,
    this.color,
    this.signed = false,
    this.emphasized = false,
    this.badge,
    this.icon,
  });

  final String label;
  final int amount;
  final String valueKey;
  final Color? color;
  final bool signed;
  final bool emphasized;
  final String? badge;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = (emphasized
            ? theme.textTheme.titleLarge
            : theme.textTheme.titleMedium)
        ?.copyWith(
      color: color,
      fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
    );

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            badge == null ? label : '$label · $badge',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              signed ? formatVndSigned(amount) : formatVnd(amount),
              key: Key(valueKey),
              style: valueStyle,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// BIỂU ĐỒ
// ══════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════
// HÀNG SỐ TỔNG
// ══════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════
// BIỂU ĐỒ
// ══════════════════════════════════════════════════════════════════════════

class _Charts extends StatelessWidget {
  const _Charts({required this.result});

  final ReportResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(ReportsStrings.chartRevenueExpenseTitle),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: RevenueExpenseChart(
            points: result.points,
            granularity: result.granularity,
          ),
        ),
        const _SectionTitle(ReportsStrings.chartProfitTitle),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: ProfitChart(
            points: result.points,
            granularity: result.granularity,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// BẢNG CHI TIẾT
// ══════════════════════════════════════════════════════════════════════════

/// Chi tiết từng mốc, mỗi mốc **hai tầng**.
///
/// Bảng bốn cột trước đây cắt cụt cột lãi/lỗ thành `-2` — con số quan trọng
/// nhất của báo cáo lại là con số duy nhất không đọc được. Bốn số chín chữ số
/// không bao giờ vừa bề ngang điện thoại, nên nới bề rộng tối thiểu chỉ đổi lỗi
/// cắt thành lỗi phải cuộn ngang liên tục.
///
/// Bố cục hai tầng đưa lãi/lỗ — thứ người dùng tìm — lên tầng trên cùng dòng
/// với tên mốc, còn thu và chi xuống tầng dưới ở cỡ chữ nhỏ. Đọc được ở mọi bề
/// ngang, không cắt, không cuộn.
class _DetailList extends StatelessWidget {
  const _DetailList({required this.result});

  final ReportResult result;

  @override
  Widget build(BuildContext context) {
    if (result.points.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final status = context.statusColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(ReportsStrings.tableTitle),
        for (final p in result.points)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reportPeriodLabel(p.key, result.granularity),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      formatVndSigned(p.profit),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: p.isLoss ? status.loss : status.profit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  ReportsStrings.detailLine(
                      formatVnd(p.revenue), formatVnd(p.expense)),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
              ],
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// TÁCH NHÓM CHI PHÍ
// ══════════════════════════════════════════════════════════════════════════

class _ExpenseBreakdown extends ConsumerWidget {
  const _ExpenseBreakdown();

  /// Hiện tối đa 5 nhóm, phần còn lại gộp thành "Khác".
  ///
  /// Quá khoảng bảy hạng mục thì các thanh cuối đều ngắn như nhau và không so
  /// được nữa; gộp đuôi giữ cho phần đầu — phần thực sự quyết định chi phí —
  /// vẫn đọc được.
  static const int _maxRows = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(reportExpenseBreakdownProvider);

    return data.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (rows) {
        if (rows.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle(Strings.reportByCategory),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(ReportsStrings.breakdownEmpty,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
            ],
          );
        }

        final total = rows.fold<int>(0, (s, r) => s + r.total);
        final head = rows.take(_maxRows).toList();
        final tail = rows.skip(_maxRows).fold<int>(0, (s, r) => s + r.total);
        final maxValue = rows.first.total;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(Strings.reportByCategory),
            for (final r in head)
              _BreakdownRow(
                label: costCategoryLabel(r.category),
                amount: r.total,
                fraction: maxValue == 0 ? 0 : r.total / maxValue,
                percent: total == 0 ? 0 : r.total / total,
              ),
            if (tail > 0)
              _BreakdownRow(
                label: ReportsStrings.otherCategories,
                amount: tail,
                fraction: maxValue == 0 ? 0 : tail / maxValue,
                percent: total == 0 ? 0 : tail / total,
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.fraction,
    required this.percent,
  });

  final String label;
  final int amount;

  /// Chiều dài thanh so với nhóm lớn nhất — so sánh độ lớn giữa các nhóm.
  final double fraction;

  /// Tỷ trọng trong tổng chi phí — con số hiển thị.
  final double percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Một sắc duy nhất theo độ lớn: đây là dữ liệu ĐỘ LỚN xếp hạng, không phải
    // dữ liệu danh tính, nên bảy màu khác nhau chỉ thêm nhiễu.
    final base = RevenueChartPalette.of(context).expense;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              // Số đầy đủ, đồng nhất với khối tổng phía trên: người dùng đang
              // đối chiếu tiền mặt nên không rút gọn.
              Text(formatVnd(amount),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  ReportsStrings.breakdownShare((percent * 100).round()),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: [
                Expanded(
                  flex: (fraction * 1000).round().clamp(1, 1000),
                  child: Container(height: 6, color: base),
                ),
                Expanded(
                  flex: (1000 - (fraction * 1000).round()).clamp(0, 1000),
                  child: Container(
                    height: 6,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}

class _ReportEmptyState extends StatelessWidget {
  const _ReportEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(Icons.bar_chart_outlined,
              size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            Strings.reportEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 8),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }
}
