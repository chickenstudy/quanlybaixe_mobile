import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/providers.dart';
import '../../../core/strings/strings.dart';

final _logsProvider = StreamProvider<List<ActivityLogRow>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.activityLog)
        // Phá hoà bằng id: hai thao tác trong cùng một giây có `at` bằng nhau
        // (thu tiền rồi huỷ ngay chẳng hạn), sắp theo mỗi `at` sẽ ra thứ tự
        // tuỳ SQLite quyết định. id tăng dần nên id lớn hơn là mới hơn.
        ..orderBy([
          (t) => OrderingTerm.desc(t.at),
          (t) => OrderingTerm.desc(t.id),
        ])
        ..limit(500))
      .watch();
});

/// Nhật ký thao tác (mục 10 đặc tả).
///
/// Câu mô tả đã được dựng sẵn lúc ghi, nên màn hình này vẽ được mà **không cần
/// join bảng nào**, và vẫn đọc đúng kể cả sau khi chiếc xe được nhắc tới đã bị
/// xoá — đây chính là cách nhật ký thao tác hay hỏng nhất.
class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logs = ref.watch(_logsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.activityLog)),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) => rows.isEmpty
            ? Center(
                child: Text(Strings.activityLogEmpty,
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              )
            : ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = rows[i];
                  return ListTile(
                    leading: Icon(_icon(r), color: theme.colorScheme.primary),
                    title: Text(r.summary),
                    subtitle: Text(formatDateTime(r.at)),
                  );
                },
              ),
      ),
    );
  }

  IconData _icon(ActivityLogRow r) => switch (r.entityType) {
        LogEntity.lot => Icons.local_parking_outlined,
        LogEntity.vehicle => Icons.two_wheeler_outlined,
        LogEntity.payment => Icons.payments_outlined,
        LogEntity.expense => Icons.receipt_long_outlined,
        LogEntity.template => Icons.event_repeat_outlined,
        LogEntity.app => Icons.settings_outlined,
      };
}
