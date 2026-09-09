import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/database.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../theme/app_theme.dart';
import '../../lots/data/lot_repository.dart';
import '../../lots/presentation/lots_providers.dart';
import '../../payments/presentation/renew_sheet.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tổng bãi xe'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/lots'),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Chi tiết bãi'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e),
        data: (s) => s.lotCount == 0
            ? const _WelcomeView()
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(dashboardSummaryProvider);
                  ref.invalidate(lotSummariesProvider);
                  ref.invalidate(expiredVehiclesProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _LotManagementSection(summary: s),
                    const SizedBox(height: 24),
                    const _ExpiredVehiclesSection(),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Quản lý tổng về bãi xe: Tổng quan các bãi xe và danh sách từng bãi kèm sức chứa.
class _LotManagementSection extends ConsumerWidget {
  const _LotManagementSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotSummaries = ref.watch(lotSummariesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CountRow(summary: summary),
        const SizedBox(height: 14),
        lotSummaries.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const SizedBox.shrink(),
          data: (items) => Column(
            children: [for (final item in items) _LotSummaryCard(item: item)],
          ),
        ),
      ],
    );
  }
}

class _LotSummaryCard extends StatelessWidget {
  const _LotSummaryCard({required this.item});

  final LotSummary item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final lot = item.lot;
    final cap = lot.capacity;
    final rate = item.occupancyRate;
    final needPay = item.needCollection;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/lots'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.local_parking,
                        size: 20, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lot.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (lot.address != null && lot.address!.isNotEmpty)
                          Text(
                            lot.address!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (needPay > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: status.expiredContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: status.expired.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '$needPay xe cần thu',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: status.expired,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Đang gửi: ${item.activeVehicles}${cap != null ? ' / $cap' : ''} xe',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (rate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (rate > 0.9 ? status.expired : theme.colorScheme.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(rate * 100).round()}% lấp đầy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: rate > 0.9 ? status.expired : theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (rate != null) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: rate.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: rate > 0.9 ? status.expired : theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Bốn ô đếm: bãi, xe đang gửi, sắp hết hạn, đã hết hạn.
class _CountRow extends StatelessWidget {
  const _CountRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = context.statusColors;
    final rate = summary.occupancyRate;
    final theme = Theme.of(context);

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.38,
          children: [
            _CountChip(
              label: Strings.lots,
              value: '${summary.lotCount}',
              icon: Icons.local_parking,
              onTap: () => context.push('/lots'),
            ),
            _CountChip(
              label: Strings.dashboardVehicleCount,
              value: '${summary.activeVehicles}',
              icon: Icons.two_wheeler,
              note: rate == null
                  ? null
                  : '${(rate * 100).round()}% ${Strings.dashboardOccupancy.toLowerCase()}',
            ),
            _CountChip(
              label: Strings.dashboardExpiringSoon,
              onTap: () => context.push('/reminders'),
              value: '${summary.expiringSoon}',
              icon: Icons.schedule,
              color: status.expiring,
            ),
            _CountChip(
              label: Strings.dashboardExpired,
              onTap: () => context.push('/reminders'),
              value: '${summary.expired}',
              icon: Icons.error_outline,
              color: status.expired,
            ),
          ],
        ),
        if (summary.neverPaid > 0) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: status.expiredContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: status.expired.withValues(alpha: 0.3),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/reminders'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: status.expiredContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.money_off, size: 20, color: status.expired),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${Strings.dashboardUnpaid}: ',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: status.expired,
                                ),
                              ),
                              Text(
                                '${summary.neverPaid} xe',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: status.expired,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Chưa từng thu tiền gửi lần nào',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: status.expired,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.note,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: c.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: c),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: c,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    note ?? '',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: note != null
                          ? theme.colorScheme.onSurfaceVariant
                          : Colors.transparent,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

enum ExpiryTab { expired, expiringSoon }

/// Danh sách xe hết hạn cho màn hình tổng quan.
class _ExpiredVehiclesSection extends ConsumerStatefulWidget {
  const _ExpiredVehiclesSection();

  @override
  ConsumerState<_ExpiredVehiclesSection> createState() =>
      _ExpiredVehiclesSectionState();
}

class _ExpiredVehiclesSectionState
    extends ConsumerState<_ExpiredVehiclesSection> {
  ExpiryTab _tab = ExpiryTab.expired;

  @override
  Widget build(BuildContext context) {
    final listAsync = _tab == ExpiryTab.expired
        ? ref.watch(expiredVehiclesProvider)
        : ref.watch(expiringVehiclesProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xe hết hạn & Cần thu',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ExpiryTab>(
            segments: const [
              ButtonSegment(
                value: ExpiryTab.expired,
                label: Text('Đã hết hạn'),
              ),
              ButtonSegment(
                value: ExpiryTab.expiringSoon,
                label: Text('Sắp hết hạn'),
              ),
            ],
            selected: {_tab},
            onSelectionChanged: (set) {
              setState(() => _tab = set.first);
            },
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 12),
        listAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => _ErrorView(error: e),
          data: (items) => items.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tab == ExpiryTab.expired
                              ? 'Không có xe nào đang hết hạn'
                              : 'Không có xe nào sắp hết hạn',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [for (final v in items) _ExpiringTile(item: v)],
                ),
        ),
      ],
    );
  }
}

class _ExpiringTile extends ConsumerWidget {
  const _ExpiringTile({required this.item});

  final VehicleListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final days = item.daysLeft;
    final v = item.vehicle;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          v.plate,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${v.ownerName} · ${item.lotName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (v.currentPeriodEnd != null)
                        Text(
                          '${Strings.paymentPeriodEnd} '
                          '${formatDay(v.currentPeriodEnd!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        Text(
                          Strings.dashboardUnpaid,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: status.expired,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: days == null
                        ? status.expiredContainer
                        : status.containerForDaysRemaining(days),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    days == null
                        ? Strings.dashboardUnpaid
                        : formatDaysRemaining(days),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: days == null
                          ? status.expired
                          : status.forDaysRemaining(days),
                    ),
                  ),
                ),
              ],
            ),
            if ((v.phone ?? '').isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _call(context, v.phoneDigits ?? v.phone!),
                  icon: const Icon(Icons.phone),
                  label: Text(v.phone!),
                ),
              ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              overflowSpacing: 4,
              overflowAlignment: OverflowBarAlignment.end,
              children: [
                if (item.isReminded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_active,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(Strings.reminderMarkShort,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => ref
                        .read(vehicleRepositoryProvider)
                        .markReminded(v.id),
                    child: const Text(Strings.reminderMarkShort),
                  ),
                FilledButton(
                  onPressed: () => _renew(context, ref, v),
                  child: const Text(Strings.renewQuick),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      messenger.showSnackBar(
          const SnackBar(content: Text(Strings.vehicleCallFailed)));
    }
  }

  Future<void> _renew(BuildContext context, WidgetRef ref, VehicleRow v) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showRenewSheet(context, vehicle: v);
    if (result == null) return;

    messenger.showSnackBar(SnackBar(
      content: Text('${Strings.paymentPeriodEnd} '
          '${formatDay(result.periodEnd)} · ${formatVnd(result.amount)}'),
    ));
  }
}

class _WelcomeView extends ConsumerStatefulWidget {
  const _WelcomeView();

  @override
  ConsumerState<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends ConsumerState<_WelcomeView> {
  bool _seeding = false;

  Future<void> _seed() async {
    setState(() => _seeding = true);
    try {
      await ref.read(sampleDataSeederProvider).seed();
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_seeding) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(Strings.welcomeSeeding),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmptyStateWidget(
            imagePath: 'assets/images/app_logo.png',
            title: Strings.welcomeTitle,
            subtitle: Strings.welcomeBody,
            actionLabel: Strings.lotAdd,
            onActionPressed: () => context.push('/lots'),
          ),
          TextButton.icon(
            onPressed: _seed,
            icon: const Icon(Icons.auto_awesome),
            label: const Text(Strings.welcomeSeedSample),
          ),
          const SizedBox(height: 24),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
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
