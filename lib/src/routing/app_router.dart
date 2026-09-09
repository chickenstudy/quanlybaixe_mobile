import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/strings/strings.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/lots/presentation/lots_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/vehicles/presentation/vehicles_screen.dart';

/// Điều hướng chính: 5 thẻ theo mục 6–11 đặc tả.
///
/// Dùng [StatefulShellRoute.indexedStack] để mỗi thẻ giữ nguyên trạng thái
/// cuộn và bộ lọc khi chuyển qua lại — chủ bãi thường nhảy giữa danh sách xe
/// và màn hình thu tiền liên tục.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _Scaffold(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/vehicles',
              builder: (context, state) => const VehiclesScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpensesScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen()),
        ]),
      ],
    ),
    // Quản lý bãi xe là việc cài đặt một lần chứ không phải thao tác hằng
    // ngày, nên không chiếm chỗ ở thanh dưới — nơi chỉ nên có tối đa 5 mục,
    // và nhãn tiếng Việt đã chật ngay ở con số đó. Vào từ Cài đặt và từ màn
    // hình chào, đẩy toàn màn hình nên có sẵn nút quay lại.
    GoRoute(path: '/lots', builder: (context, state) => const LotsScreen()),
    // Nhắc thu tiền là danh sách việc cần làm, mở từ dashboard khi có xe tới
    // hạn — không chiếm một thẻ cố định ở thanh dưới.
    GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersScreen()),
  ],
);

class _Scaffold extends StatelessWidget {
  const _Scaffold({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Strings.dashboard),
          NavigationDestination(
              icon: Icon(Icons.two_wheeler_outlined),
              selectedIcon: Icon(Icons.two_wheeler),
              label: Strings.vehicles),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: Strings.expenses),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: Strings.reports),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: Strings.settings),
        ],
      ),
    );
  }
}
