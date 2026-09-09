import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/digest_plan.dart';

/// Lớp mỏng bọc `flutter_local_notifications`.
///
/// Toàn bộ phần *quyết định gửi gì, ngày nào* nằm ở [DigestPlanner] — một hàm
/// thuần, test được không cần thiết bị. Lớp này chỉ làm phần chạm vào hệ điều
/// hành, nên nó mỏng và không chứa nghiệp vụ.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  /// Dải id dành riêng cho thông báo tổng hợp.
  ///
  /// Huỷ theo dải thay vì `cancelAll()` để sau này thêm loại thông báo khác
  /// (nhắc sao lưu chẳng hạn) thì chúng không bị xoá nhầm mỗi lần đặt lại lịch.
  static const int idBase = 1000;
  static const int idMax = 1099;

  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;

    tzdata.initializeTimeZones();
    // flutter_timezone 5.x trả về TimezoneInfo, không phải String — mọi hướng
    // dẫn cũ trên mạng dùng thẳng chuỗi sẽ không biên dịch được.
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));

    // Bản 22.x đổi TOÀN BỘ sang tham số đặt tên — mọi ví dụ cũ trên mạng
    // truyền vị trí sẽ không biên dịch được.
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          // KHÔNG xin quyền ở đây. iOS chỉ cho hỏi đúng một lần trong đời ứng
          // dụng; bị từ chối là người dùng phải tự vào Cài đặt bật lại. Nên
          // phải hỏi đúng lúc người dùng hiểu vì sao — xem [requestPermission].
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        ),
      ),
    );
    _ready = true;
  }

  Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  /// Người dùng có thể tắt quyền trong Cài đặt hệ thống bất cứ lúc nào mà ứng
  /// dụng không hay biết, nên phải hỏi lại mỗi lần mở app.
  Future<bool> hasPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final granted = await ios?.checkPermissions();
    return granted?.isAlertEnabled ?? false;
  }

  Future<void> cancelDigests() async {
    for (var id = idBase; id <= idMax; id++) {
      await _plugin.cancel(id: id);
    }
  }

  /// Đặt lịch toàn bộ kế hoạch. Gọi [cancelDigests] trước.
  Future<int> schedule(DigestPlan plan) async {
    var scheduled = 0;
    for (final entry in plan.entries) {
      final when = tz.TZDateTime(
        tz.local,
        entry.date.year,
        entry.date.month,
        entry.date.day,
        entry.hour,
      );
      // Không bao giờ đặt lịch vào quá khứ — iOS sẽ bắn ngay lập tức.
      if (!when.isAfter(tz.TZDateTime.now(tz.local))) continue;
      if (idBase + scheduled > idMax) break;

      await _plugin.zonedSchedule(
        id: idBase + scheduled,
        title: entry.title,
        body: entry.body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: entry.payload,
      );
      scheduled++;
    }
    return scheduled;
  }

  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests())
          .where((r) => r.id >= idBase && r.id <= idMax)
          .length;

  /// Gửi thử ngay lập tức — nút "Gửi thử" trong màn hình cài đặt.
  ///
  /// Cần thiết vì người dùng không có cách nào khác để biết thông báo có thật
  /// sự hoạt động, ngoài việc chờ tới ngày.
  Future<void> sendTest(String title, String body) => _plugin.show(
        id: idMax,
        title: title,
        body: body,
        notificationDetails:
            const NotificationDetails(iOS: DarwinNotificationDetails()),
      );
}
