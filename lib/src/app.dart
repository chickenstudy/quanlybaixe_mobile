import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/strings/strings.dart';
import 'features/notifications/data/notification_scheduler.dart';
import 'features/settings/presentation/settings_providers.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class QuanLyBaiXeApp extends ConsumerStatefulWidget {
  const QuanLyBaiXeApp({super.key});

  @override
  ConsumerState<QuanLyBaiXeApp> createState() => _QuanLyBaiXeAppState();
}

class _QuanLyBaiXeAppState extends ConsumerState<QuanLyBaiXeApp>
    with WidgetsBindingObserver {
  NotificationScheduler? _scheduler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Chạy sau khung hình đầu để không chặn lần vẽ đầu tiên bằng I/O.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    // Sinh chi phí cố định của tháng trước khi bất kỳ báo cáo nào đọc dữ liệu.
    // Không có bước này thì lần mở app đầu tiên trong tháng hiện lợi nhuận
    // thiếu toàn bộ tiền thuê, điện, bảo vệ.
    await ref.read(costsMaterializedProvider.future);

    await ref.read(notificationServiceProvider).init();
    final scheduler = ref.read(notificationSchedulerProvider);
    _scheduler = scheduler;
    // Nghe luồng thay đổi bảng của Drift: gia hạn hay thêm xe là lịch thông
    // báo tự đặt lại, không cần nhớ gọi ở từng chỗ ghi dữ liệu.
    scheduler.start();

    final prefs = await ref.read(notificationPrefsProvider.future);
    await scheduler.reschedule(prefs: prefs);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Mở lại app sau vài tuần thì đã sang tháng mới, và lịch thông báo cũ đã
    // hết. Tính lại cả hai.
    ref.invalidate(costsMaterializedProvider);
    unawaitedReschedule();
  }

  void unawaitedReschedule() {
    final s = _scheduler;
    if (s == null) return;
    ref.read(notificationPrefsProvider.future).then((p) => s.reschedule(prefs: p));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scheduler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      // Ứng dụng chỉ tiếng Việt — không dùng ARB/gen_l10n, xem strings.dart.
      locale: const Locale('vi', 'VN'),
      supportedLocales: const [Locale('vi', 'VN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
