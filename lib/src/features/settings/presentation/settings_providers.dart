import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../backup/data/backup_service.dart';
import '../../backup/data/excel_exporter.dart';
import '../../notifications/data/notification_scheduler.dart';
import '../../notifications/data/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(FlutterLocalNotificationsPlugin()),
);

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => NotificationScheduler(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(clockProvider),
  ),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final excelExporterProvider = Provider<ExcelExporter>(
  (ref) => ExcelExporter(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

/// Cài đặt nhắc hạn, lưu xuống bảng `app_settings`.
///
/// Lưu vào CSDL chứ không dùng `SharedPreferences`, để nó đi theo file sao lưu
/// — người dùng đổi máy thì giờ nhắc quen thuộc cũng theo sang.
final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
        NotificationPrefsNotifier.new);

class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefs> {
  static const _kEnabled = 'notify_enabled';
  static const _kHour = 'notify_hour';

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  Future<NotificationPrefs> build() async {
    final rows = await _db.select(_db.appSettings).get();
    final map = {for (final r in rows) r.key: r.value};
    return NotificationPrefs(
      enabled: map[_kEnabled] != 'false',
      hour: int.tryParse(map[_kHour] ?? '') ?? 8,
    );
  }

  Future<void> _write(String key, String value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(AppSettingRow(key: key, value: value));

  Future<void> setEnabled(bool v) async {
    await _write(_kEnabled, '$v');
    state = AsyncData(NotificationPrefs(
        enabled: v, hour: state.value?.hour ?? 8));
    await _reschedule();
  }

  Future<void> setHour(int h) async {
    await _write(_kHour, '$h');
    state = AsyncData(NotificationPrefs(
        enabled: state.value?.enabled ?? true, hour: h));
    await _reschedule();
  }

  Future<void> _reschedule() async {
    final prefs = state.value;
    if (prefs == null) return;
    await ref.read(notificationSchedulerProvider).reschedule(prefs: prefs);
  }
}

/// Số thông báo đang chờ gửi — bằng chứng cho người dùng thấy nhắc hạn đang chạy.
final pendingNotificationsProvider = FutureProvider<int>((ref) async {
  ref.watch(notificationPrefsProvider);
  return ref.watch(notificationServiceProvider).pendingCount();
});

final notificationPermissionProvider = FutureProvider<bool>(
  (ref) => ref.watch(notificationServiceProvider).hasPermission(),
);
