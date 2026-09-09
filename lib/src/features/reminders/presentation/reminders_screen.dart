import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../theme/app_theme.dart';
import '../../payments/presentation/renew_sheet.dart';
import '../../vehicles/data/vehicle_repository.dart';
import 'reminders_providers.dart';
import 'reminders_strings.dart';

/// Danh sách nhắc thu tiền (mục 10 đặc tả).
///
/// Đây là màn hình dùng để **làm việc**, không phải để xem: chủ bãi mở ra, gọi
/// lần lượt từng người, đánh dấu đã nhắc, thu tiền. Nên mọi thao tác đó phải
/// nằm ngay trên từng dòng, không bắt đi vào màn hình khác.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reminderRangeProvider);
    final items = ref.watch(remindersProvider(range));

    return Scaffold(
      appBar: AppBar(title: const Text(RemindersStrings.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<ReminderRange>(
              segments: const [
                ButtonSegment(
                    value: ReminderRange.today,
                    label: Text(RemindersStrings.tabToday)),
                ButtonSegment(
                    value: ReminderRange.week,
                    label: Text(RemindersStrings.tabWeek)),
                ButtonSegment(
                    value: ReminderRange.month,
                    label: Text(RemindersStrings.tabMonth)),
              ],
              selected: {range},
              onSelectionChanged: (s) =>
                  ref.read(reminderRangeProvider.notifier).set(s.first),
            ),
          ),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? _Empty(range: range)
                  : Column(
                      children: [
                        _SummaryBar(items: list),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            itemBuilder: (_, i) => _ReminderTile(item: list[i]),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.items});

  final List<VehicleListItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          RemindersStrings.summary(
              items.length, formatVnd(expectedTotal(items))),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.range});

  final ReminderRange range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = switch (range) {
      ReminderRange.today => RemindersStrings.emptyToday,
      ReminderRange.week => RemindersStrings.emptyWeek,
      ReminderRange.month => RemindersStrings.emptyMonth,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.item});

  final VehicleListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final v = item.vehicle;
    final days = item.daysLeft;
    final phone = (v.phone ?? '').trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                      Text(v.plate,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('${v.ownerName} · ${item.lotName}',
                          style: theme.textTheme.bodyMedium),
                      Text(
                        v.currentPeriodEnd == null
                            ? Strings.dashboardUnpaid
                            : '${Strings.paymentPeriodEnd} '
                                '${formatDay(v.currentPeriodEnd!)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(days == null
                      ? RemindersStrings.overdue
                      : formatDaysRemaining(days)),
                  backgroundColor:
                      status.containerForDaysRemaining(days ?? -1),
                  side: BorderSide.none,
                ),
              ],
            ),
            if (phone.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _call(context, v.phoneDigits ?? phone),
                  icon: const Icon(Icons.phone),
                  label: Text(phone),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(RemindersStrings.noPhone,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
            if (item.isReminded)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      v.lastRemindedAt == null
                          ? Strings.reminderMarkedDone
                          : '${Strings.reminderLastRemindedAt}: '
                              '${formatDateTime(v.lastRemindedAt!)}',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              overflowSpacing: 4,
              overflowAlignment: OverflowBarAlignment.end,
              children: [
                if (!item.isReminded)
                  TextButton(
                    onPressed: () => ref
                        .read(vehicleRepositoryProvider)
                        .markReminded(v.id),
                    child: const Text(Strings.reminderMarkShort),
                  ),
                FilledButton(
                  onPressed: () => _collect(context, ref),
                  child: const Text(Strings.dashboardCollectMoney),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _call(BuildContext context, String phone) async {
    // Giữ messenger trước await: dòng này biến khỏi danh sách ngay khi xe được
    // thu tiền, và tra ancestor từ widget đã chết sẽ ném lỗi.
    final messenger = ScaffoldMessenger.of(context);
    if (!await launchUrl(Uri(scheme: 'tel', path: phone))) {
      messenger.showSnackBar(
          const SnackBar(content: Text(Strings.vehicleCallFailed)));
    }
  }

  Future<void> _collect(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showRenewSheet(context, vehicle: item.vehicle);
    if (result == null) return;
    messenger.showSnackBar(SnackBar(
      content: Text('${Strings.paymentPeriodEnd} '
          '${formatDay(result.periodEnd)} · ${formatVnd(result.amount)}'),
    ));
  }
}
