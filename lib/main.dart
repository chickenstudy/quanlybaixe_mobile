import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/routing/app_router.dart';
import 'src/core/providers.dart';
import 'src/features/dashboard/presentation/dashboard_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dựng container tường minh thay vì để `ProviderScope` tự tạo, để công cụ
  // phát triển ở dưới chạm được vào các provider mà không cần BuildContext.
  final container = ProviderContainer();
  if (kDebugMode) _registerDevExtensions(container);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const QuanLyBaiXeApp(),
  ));
}

/// Lệnh dành cho lập trình viên, gọi qua Dart VM Service.
///
/// Chỉ đăng ký ở bản debug nên không tồn tại trong bản phát hành. Dùng để nạp
/// và xoá dữ liệu thử mà không phải bấm tay trên máy, hữu ích khi chạy trên
/// thiết bị thật hoặc khi chụp ảnh màn hình tự động.
void _registerDevExtensions(ProviderContainer container) {
  developer.registerExtension('ext.qlbx.seedSample', (method, params) async {
    final seeder = container.read(sampleDataSeederProvider);
    if (await seeder.isEmpty) await seeder.seed();
    return developer.ServiceExtensionResponse.result(
        jsonEncode({'ok': true}));
  });

  // Điều hướng từ ngoài vào — để chụp màn hình tự động mà không cần chạm tay.
  developer.registerExtension('ext.qlbx.go', (method, params) async {
    final path = params['path'];
    if (path == null || path.isEmpty) {
      return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams, 'thiếu path');
    }
    appRouter.go(path);
    return developer.ServiceExtensionResponse.result(
        jsonEncode({'ok': true, 'path': path}));
  });

  // Chạy một câu SELECT để soi dữ liệu thật khi gỡ lỗi trên máy/simulator.
  // Chỉ đọc: từ chối mọi câu không bắt đầu bằng SELECT.
  developer.registerExtension('ext.qlbx.sql', (method, params) async {
    final sql = params['q'] ?? '';
    if (!sql.trimLeft().toUpperCase().startsWith('SELECT')) {
      return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.invalidParams, 'chỉ nhận SELECT');
    }
    final rows = await container.read(appDatabaseProvider).customSelect(sql).get();
    return developer.ServiceExtensionResponse.result(jsonEncode({
      'rows': [for (final r in rows) r.data.map((k, v) => MapEntry(k, '$v'))],
    }));
  });

  // Cuộn màn hình đang hiện tới một vị trí — để chụp được phần dưới nếp gấp
  // khi soát giao diện mà không có quyền trợ năng để vuốt tay.
  developer.registerExtension('ext.qlbx.scroll', (method, params) async {
    final offset = double.tryParse(params['to'] ?? '') ?? 0;
    final ctx = appRouter.routerDelegate.navigatorKey.currentContext;
    if (ctx == null) {
      return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.extensionError, 'chưa có màn hình');
    }
    // Gom TẤT CẢ vùng cuộn rồi chọn vùng dài nhất. Lấy vùng đầu tiên gặp là
    // sai: thanh chip lọc và các vùng cuộn ngang nhỏ nằm trước thân màn hình
    // trong cây widget.
    final scrollables = <ScrollableState>[];
    void visit(Element e) {
      if (e is StatefulElement && e.state is ScrollableState) {
        scrollables.add(e.state as ScrollableState);
      }
      e.visitChildren(visit);
    }
    (ctx as Element).visitChildren(visit);

    ScrollPosition? pos;
    for (final sc in scrollables) {
      final p = sc.position;
      if (p.axis != Axis.vertical) continue;
      if (pos == null || p.maxScrollExtent > pos.maxScrollExtent) pos = p;
    }
    if (pos == null) {
      return developer.ServiceExtensionResponse.error(
          developer.ServiceExtensionResponse.extensionError,
          'không tìm thấy vùng cuộn dọc');
    }
    final p = pos;
    p.jumpTo(offset.clamp(0, p.maxScrollExtent));
    return developer.ServiceExtensionResponse.result(jsonEncode(
        {'ok': true, 'at': p.pixels, 'max': p.maxScrollExtent, 'n': scrollables.length}));
  });

  developer.registerExtension('ext.qlbx.wipe', (method, params) async {
    final db = container.read(appDatabaseProvider);
    // Tắt ràng buộc khoá ngoại trong lúc xoá, vì `allTables` không theo thứ tự
    // phụ thuộc. PRAGMA này không có tác dụng bên trong transaction nên phải
    // đặt ngoài.
    await db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await db.transaction(() async {
        for (final t in db.allTables) {
          await db.delete(t).go();
        }
      });
    } finally {
      await db.customStatement('PRAGMA foreign_keys = ON');
    }
    return developer.ServiceExtensionResponse.result(
        jsonEncode({'ok': true}));
  });
}
