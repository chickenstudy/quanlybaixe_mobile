import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/strings/strings.dart';
import '../../backup/domain/backup_envelope.dart';
import 'activity_log_screen.dart';
import 'settings_providers.dart';
import 'settings_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.settings)),
      body: ListView(
        children: const [
          _NotifySection(),
          Divider(height: 1),
          _DataSection(),
          Divider(height: 1),
          _ManageSection(),
        ],
      ),
    );
  }
}

// ───────────────────────────── Nhắc hạn ─────────────────────────────

class _NotifySection extends ConsumerWidget {
  const _NotifySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(notificationPrefsProvider);
    final granted = ref.watch(notificationPermissionProvider);
    final pending = ref.watch(pendingNotificationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(SettingsStrings.notifySection),
        prefs.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => ListTile(title: Text('$e')),
          data: (p) => Column(
            children: [
              SwitchListTile(
                value: p.enabled,
                onChanged: (v) async {
                  final n = ref.read(notificationPrefsProvider.notifier);
                  // Xin quyền đúng lúc người dùng vừa bày tỏ ý muốn — iOS chỉ
                  // cho hỏi một lần, hỏi lúc mở app lần đầu thì tỷ lệ đồng ý
                  // thấp hơn hẳn và hỏng thì không hỏi lại được.
                  if (v && !(granted.value ?? false)) {
                    await ref.read(notificationServiceProvider).init();
                    await ref.read(notificationServiceProvider).requestPermission();
                    ref.invalidate(notificationPermissionProvider);
                  }
                  await n.setEnabled(v);
                  ref.invalidate(pendingNotificationsProvider);
                },
                title: const Text(SettingsStrings.notifyEnable),
                subtitle: const Text(SettingsStrings.notifyEnableHint),
              ),
              if (p.enabled) ...[
                ListTile(
                  title: const Text(SettingsStrings.notifyHour),
                  trailing: Text('${p.hour.toString().padLeft(2, '0')}:00',
                      style: theme.textTheme.titleMedium),
                  onTap: () => _pickHour(context, ref, p.hour),
                ),
                const ListTile(
                  title: Text(SettingsStrings.notifyLead),
                  subtitle: Text(SettingsStrings.notifyLeadHint),
                ),
                ListTile(
                  title: const Text(SettingsStrings.notifyPending),
                  trailing: Text(
                      SettingsStrings.notifyPendingCount(pending.value ?? 0)),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text(SettingsStrings.notifyTest),
                  onTap: () => _sendTest(context, ref),
                ),
                if (granted.value == false)
                  _Warning(
                    title: SettingsStrings.notifyDenied,
                    body: SettingsStrings.notifyDeniedHint,
                    actionLabel: SettingsStrings.notifyOpenSettings,
                    onAction: () => launchUrl(Uri.parse('app-settings:')),
                  ),
                // Nói thẳng giới hạn thay vì để người dùng tự phát hiện rồi
                // mất tin vào con số.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(SettingsStrings.notifySnapshotWarning,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickHour(BuildContext context, WidgetRef ref, int current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
    );
    if (picked == null) return;
    await ref.read(notificationPrefsProvider.notifier).setHour(picked.hour);
    ref.invalidate(pendingNotificationsProvider);
  }

  Future<void> _sendTest(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(notificationServiceProvider);
    await service.init();
    if (!await service.hasPermission()) {
      await service.requestPermission();
      ref.invalidate(notificationPermissionProvider);
    }
    await service.sendTest(
        'Nhắc thu tiền bãi xe', 'Đây là thông báo thử. Nhắc hạn đang hoạt động.');
    messenger.showSnackBar(
        const SnackBar(content: Text(SettingsStrings.notifyTestSent)));
  }
}

// ───────────────────────────── Dữ liệu ─────────────────────────────

class _DataSection extends ConsumerWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(SettingsStrings.dataSection),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text(Strings.backupExport),
          subtitle: const Text(SettingsStrings.backupHint),
          onTap: () => _share(context, ref, _Kind.backup),
        ),
        ListTile(
          leading: const Icon(Icons.table_chart_outlined),
          title: const Text(Strings.exportExcel),
          subtitle: const Text(SettingsStrings.excelHint),
          onTap: () => _share(context, ref, _Kind.excel),
        ),
        ListTile(
          leading: const Icon(Icons.data_object),
          title: const Text(Strings.exportJson),
          onTap: () => _share(context, ref, _Kind.json),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text(Strings.backupImport),
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref, _Kind kind) async {
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
    try {
      final file = switch (kind) {
        _Kind.backup => await ref.read(backupServiceProvider).exportBackup(),
        _Kind.json => await ref.read(backupServiceProvider).exportJson(),
        _Kind.excel => await ref.read(excelExporterProvider).export(),
      };
      await ref.read(backupServiceProvider).pruneSafetyBackups();
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        // iPad bắt buộc có điểm neo, thiếu thì share sheet không hiện.
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
      messenger
          .showSnackBar(const SnackBar(content: Text(Strings.exportDone)));
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('${Strings.exportFailed}: $e')));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    // FileType.custom + đuôi .qlbx ánh xạ sang UTI không xác định trên iOS và
    // làm XÁM hết mọi file. Phải nhận mọi loại rồi tự kiểm tra đuôi.
    // file_picker 12.x: `FilePicker.platform` đã bị bỏ, nay là hàm tĩnh
    // `pickFile` trả thẳng `PlatformFile?`.
    final picked = await FilePicker.pickFile(type: FileType.any);
    final path = picked?.path;
    if (path == null) return;

    final service = ref.read(backupServiceProvider);
    try {
      final env = await service.inspect(File(path));
      if (!context.mounted) return;

      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(SettingsStrings.importWarnTitle),
          content: Text(SettingsStrings.importWarnBody(
            env.counts['lots'] ?? 0,
            env.counts['vehicles'] ?? 0,
            env.counts['payments'] ?? 0,
          )),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(Strings.cancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(SettingsStrings.importConfirm)),
          ],
        ),
      );
      if (ok != true) return;

      final result = await service.import(env);
      messenger.showSnackBar(SnackBar(
          content: Text(SettingsStrings.importedRows(result.totalRows))));
    } on BackupFormatException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger
          .showSnackBar(SnackBar(content: Text('${Strings.importFailed}: $e')));
    }
  }
}

enum _Kind { backup, json, excel }

// ───────────────────────────── Quản lý ─────────────────────────────

class _ManageSection extends ConsumerWidget {
  const _ManageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(SettingsStrings.manageSection),
        ListTile(
          leading: const Icon(Icons.local_parking_outlined),
          title: const Text(Strings.lots),
          onTap: () => context.push('/lots'),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text(Strings.activityLog),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ActivityLogScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text(SettingsStrings.about),
          subtitle: const Text(SettingsStrings.aboutBody),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(text,
          style: theme.textTheme.titleSmall
              ?.copyWith(color: theme.colorScheme.primary)),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: theme.colorScheme.onErrorContainer)),
          const SizedBox(height: 4),
          Text(body,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onErrorContainer)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}
