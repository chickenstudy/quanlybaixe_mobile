import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/date_math.dart';
import '../../../theme/app_theme.dart';
import '../../payments/presentation/renew_sheet.dart';
import 'vehicle_form_sheet.dart';
import 'vehicles_providers.dart';
import 'vehicles_strings.dart';

/// Chi tiết một xe: thông tin đăng ký, lịch sử thu tiền, và mọi thao tác vòng
/// đời của xe (mục 3 đặc tả).
class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(vehicleDetailProvider(vehicleId));

    return detail.when(
      loading: () => const _Shell(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => _Shell(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 40, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 8),
              const Text(Strings.errorGeneric, textAlign: TextAlign.center),
              Text('$e', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      // Xe bị xoá mềm ở nơi khác trong lúc màn hình đang mở: nói thẳng ra thay
      // vì giữ lại dữ liệu cũ trên màn hình, vì mọi nút thao tác đã vô nghĩa.
      data: (d) => d == null
          ? const _Shell(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(Strings.deleted, textAlign: TextAlign.center),
                ),
              ),
            )
          : _DetailView(detail: d),
    );
  }
}

/// Khung rỗng dùng cho các trạng thái chưa có dữ liệu, để thanh tiêu đề và nút
/// quay lại luôn có mặt.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(Strings.details)),
        body: child,
      );
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.detail});

  final VehicleDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = context.statusColors;
    final v = detail.vehicle;
    final today = ref.watch(todayProvider);
    final days = v.currentPeriodEnd == null
        ? null
        : daysRemaining(today, v.currentPeriodEnd!);

    return Scaffold(
      appBar: AppBar(
        title: Text(v.plate),
        actions: [
          IconButton(
            tooltip: Strings.edit,
            icon: const Icon(Icons.edit),
            onPressed: () => showVehicleFormSheet(context, vehicle: v),
          ),
          PopupMenuButton<_VehicleAction>(
            onSelected: (a) => _onAction(context, ref, a),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _VehicleAction.stop,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(VehiclesStrings.vehicleStopEnd),
                ),
              ),
              PopupMenuItem(
                value: _VehicleAction.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text(Strings.delete),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          if (v.status == VehicleStatus.stopped)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Card(
                margin: EdgeInsets.zero,
                color: theme.colorScheme.surfaceContainerHighest,
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(VehiclesStrings.stoppedBanner),
                  subtitle: v.leftOn == null
                      ? null
                      : Text(formatDay(v.leftOn!)),
                ),
              ),
            ),

          // ── Hạn hiện tại: con số người dùng mở màn hình này để xem ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Card(
              margin: EdgeInsets.zero,
              color: days == null
                  ? theme.colorScheme.surfaceContainerHighest
                  : status.containerForDaysRemaining(days),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Strings.vehiclePeriodEnd,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      v.currentPeriodEnd == null
                          ? Strings.vehicleNoExpiry
                          : formatDay(v.currentPeriodEnd!),
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    // Màu của thẻ không bao giờ đứng một mình.
                    Text(
                      days == null
                          ? VehiclesStrings.neverPaidChip
                          : formatDaysRemaining(days),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: OverflowBar(
              spacing: 8,
              overflowSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _collect(context, ref, v),
                  icon: const Icon(Icons.payments),
                  label: const Text(Strings.paymentCollect),
                ),
                OutlinedButton.icon(
                  onPressed: () => showVehicleFormSheet(context, vehicle: v),
                  icon: const Icon(Icons.edit),
                  label: const Text(Strings.edit),
                ),
              ],
            ),
          ),

          // ── Thông tin đăng ký ──
          _Section(title: Strings.details),
          _InfoRow(label: Strings.vehicleOwner, value: v.ownerName),
          if ((v.phone ?? '').isNotEmpty)
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(Strings.phone, style: theme.textTheme.bodyMedium),
              subtitle: Text(v.phone!, style: theme.textTheme.bodyLarge),
              trailing: FilledButton.tonalIcon(
                onPressed: () => _call(context, v.phoneDigits ?? v.phone!),
                icon: const Icon(Icons.call),
                label: const Text(Strings.vehicleCall),
              ),
            ),
          _InfoRow(
              label: Strings.vehicleType, value: vehicleTypeLabel(v.vehicleType)),
          _InfoRow(label: Strings.vehiclePlate, value: v.plate),
          _InfoRow(label: Strings.lot, value: detail.lotName),
          _InfoRow(
              label: Strings.vehicleMonthlyFee,
              value: formatVnd(v.monthlyPrice)),
          _InfoRow(
              label: Strings.vehicleStartDate, value: formatDay(v.startDate)),
          _InfoRow(
            label: VehiclesStrings.totalMonthsPaid,
            value: VehiclesStrings.monthCount(v.totalMonthsPaid),
          ),
          _InfoRow(
              label: VehiclesStrings.totalCollected,
              value: formatVnd(v.totalPaid)),
          _InfoRow(
              label: Strings.vehicleStatusLabelText,
              value: vehicleStatusLabel(v.status)),
          if ((v.notes ?? '').isNotEmpty)
            _InfoRow(label: Strings.note, value: v.notes!),

          // ── Lịch sử thu tiền ──
          _Section(title: Strings.vehicleHistory),
          _PaymentHistory(vehicleId: v.id),
        ],
      ),
    );
  }

  Future<void> _onAction(
      BuildContext context, WidgetRef ref, _VehicleAction action) async {
    switch (action) {
      case _VehicleAction.stop:
        await _stop(context, ref);
      case _VehicleAction.delete:
        await _delete(context, ref);
    }
  }

  /// Thu tiền — dùng lại đúng bảng của màn hình tổng quan.
  ///
  /// Không dựng bảng thu tiền thứ hai: hai bảng tính hạn theo hai đoạn mã khác
  /// nhau là cách chắc chắn nhất để một ngày nào đó chúng cho ra hai kết quả
  /// khác nhau trên cùng một chiếc xe.
  Future<void> _collect(
      BuildContext context, WidgetRef ref, VehicleRow v) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showRenewSheet(context, vehicle: v);
    if (result == null) return;
    messenger.showSnackBar(SnackBar(
      content: Text('${Strings.paymentPeriodEnd} '
          '${formatDay(result.periodEnd)} · ${formatVnd(result.amount)}'),
    ));
  }

  Future<void> _call(BuildContext context, String phone) async {
    // Giữ messenger TRƯỚC khi await: stream có thể phát bản ghi mới và tháo
    // widget này khỏi cây trong lúc chờ hệ điều hành mở ứng dụng gọi.
    final messenger = ScaffoldMessenger.of(context);
    if (!await launchUrl(Uri(scheme: 'tel', path: phone))) {
      messenger.showSnackBar(
          const SnackBar(content: Text(Strings.vehicleCallFailed)));
    }
  }

  /// Kết thúc gửi xe. Không xoá: lịch sử thu tiền của xe vẫn phải nằm trong
  /// báo cáo doanh thu của bãi.
  Future<void> _stop(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.vehicleStopTitle),
        content: const Text(Strings.vehicleStopMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(Strings.vehicleStop),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(vehicleRepositoryProvider).stop(detail.vehicle.id);
    // Xe không còn trong danh sách mặc định nữa, nên ở lại màn hình chi tiết
    // là đưa người dùng vào ngõ cụt — trả họ về danh sách.
    navigator.pop();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Strings.confirmDeleteNamed(detail.vehicle.plate)),
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
    if (ok != true) return;
    await ref.read(vehicleRepositoryProvider).softDelete(detail.vehicle.id);
    navigator.pop();
  }
}

enum _VehicleAction { stop, delete }

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lịch sử thu tiền của xe.
class _PaymentHistory extends ConsumerWidget {
  const _PaymentHistory({required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(vehiclePaymentsProvider(vehicleId));
    final theme = Theme.of(context);

    return payments.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('$e'),
      ),
      data: (rows) => rows.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                Strings.paymentEmpty,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          : Column(
              children: [for (final p in rows) _PaymentTile(payment: p)],
            ),
    );
  }
}

/// Một biên lai.
///
/// Biên lai đã huỷ **vẫn hiện**, chỉ gạch ngang và mờ đi. Giấu nó đi thì số
/// tiền cứ thế biến mất khỏi màn hình mà không lời giải thích, đúng vào lúc
/// người dùng cần đối chiếu với khách nhất — đó cũng là lý do
/// `PaymentRepository` huỷ mềm chứ không xoá cứng.
class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({required this.payment});

  final PaymentRow payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final voided = payment.voidedAt != null;
    final strike = voided ? TextDecoration.lineThrough : null;
    final muted = voided ? theme.colorScheme.onSurfaceVariant : null;

    return Opacity(
      opacity: voided ? 0.6 : 1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      formatDay(payment.paidAt),
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: strike,
                        color: muted,
                      ),
                    ),
                  ),
                  Text(
                    formatVnd(payment.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: strike,
                      color: muted,
                    ),
                  ),
                  if (!voided)
                    IconButton(
                      tooltip: Strings.paymentVoid,
                      icon: const Icon(Icons.block),
                      onPressed: () => _void(context, ref),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
              Text(
                '${Strings.paidForMonths(payment.monthsPaid)} · '
                '${paymentMethodLabel(payment.method)}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(decoration: strike, color: muted),
              ),
              Text(
                formatDayRange(payment.periodStart, payment.periodEnd),
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: strike,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if ((payment.note ?? '').isNotEmpty)
                Text(
                  payment.note!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(decoration: strike, color: muted),
                ),
              if (voided)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 18, color: context.statusColors.expired),
                      const SizedBox(width: 4),
                      // Chữ "Đã huỷ" chứ không chỉ có gạch ngang: gạch ngang
                      // một mình dễ bị nhìn nhầm thành lỗi hiển thị.
                      Text(
                        Strings.paymentVoided,
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: context.statusColors.expired),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _void(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String?>(
      context: context,
      builder: (_) => const _VoidReasonDialog(),
    );
    // `null` = đóng hộp thoại; chuỗi rỗng = xác nhận huỷ nhưng không nêu lý do.
    if (reason == null) return;
    await ref
        .read(paymentRepositoryProvider)
        .voidPayment(payment.id, reason: reason.isEmpty ? null : reason);
  }
}

/// Hộp thoại xác nhận huỷ biên lai kèm ô lý do.
///
/// Là widget có trạng thái riêng để `TextEditingController` được `dispose`
/// đúng lúc; tạo controller ngay trong hàm gọi `showDialog` sẽ rò rỉ nó mỗi
/// lần người dùng mở rồi đóng hộp thoại.
class _VoidReasonDialog extends StatefulWidget {
  const _VoidReasonDialog();

  @override
  State<_VoidReasonDialog> createState() => _VoidReasonDialogState();
}

class _VoidReasonDialogState extends State<_VoidReasonDialog> {
  final TextEditingController _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Strings.paymentVoidTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(Strings.paymentVoidMessage),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonCtrl,
            decoration: const InputDecoration(
              labelText: VehiclesStrings.voidReasonLabel,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(Strings.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _reasonCtrl.text.trim()),
          child: const Text(Strings.paymentVoid),
        ),
      ],
    );
  }
}
