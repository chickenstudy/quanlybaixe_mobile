import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../time/day.dart';
import 'converters/day_converter.dart';
import 'enums.dart';
import 'tables/activity_log.dart';
import 'tables/app_settings.dart';
import 'tables/expenses.dart';
import 'tables/lots.dart';
import 'tables/payment_allocations.dart';
import 'tables/payments.dart';
import 'tables/recurring_cost_templates.dart';
import 'tables/vehicles.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Lots,
    Vehicles,
    Payments,
    PaymentAllocations,
    RecurringCostTemplates,
    Expenses,
    ActivityLog,
    AppSettings,
  ],
  include: {
    'queries/indexes.drift',
    'queries/reports.drift',
  },
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Dùng trong test: `AppDatabase.forTesting(NativeDatabase.memory())`.
  /// Nhờ nó, toàn bộ nghiệp vụ doanh thu / chi phí / hết hạn kiểm thử được
  /// ngay trên máy Mac, không cần thiết bị nào.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        beforeOpen: (details) async {
          // SQLite mặc định TẮT ràng buộc khoá ngoại. Không bật thì mọi
          // `references()` ở trên chỉ là chú thích, và dữ liệu mồ côi sẽ lặng
          // lẽ tích tụ.
          await customStatement('PRAGMA foreign_keys = ON');
          // WAL: đọc không chặn ghi. Dashboard có nhiều stream đọc liên tục
          // trong khi người dùng đang nhập liệu.
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );
}

QueryExecutor _openConnection() => driftDatabase(name: 'quan_ly_bai_xe');
