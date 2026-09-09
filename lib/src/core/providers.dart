import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/expenses/data/recurring_cost_materializer.dart';
import '../features/lots/data/lot_repository.dart';
import '../features/payments/data/payment_repository.dart';
import '../features/vehicles/data/vehicle_repository.dart';
import 'db/database.dart';
import 'time/clock.dart';
import 'time/day.dart';
import 'time/year_month.dart';

/// Provider hạ tầng.
///
/// Dùng Riverpod **thuần, không codegen**. Lý do: các provider ở đây rất mỏng
/// — Drift đã trả sẵn `Stream` nên phần lớn chỉ là nối dây. Thêm
/// `riverpod_generator` sẽ buộc mỗi lần sửa một dòng phải chạy lại
/// `build_runner`, đổi lấy vài dòng khuôn mẫu tiết kiệm được. Không đáng.
///
/// Lưu ý cho ai quen Riverpod 2: bản 3.x đã **hợp nhất kiểu `Ref`** (không còn
/// `MyProviderRef`) và bỏ `AutoDisposeNotifier`. Mọi ví dụ Riverpod 2 trên
/// mạng sẽ không biên dịch được.

/// Ghi đè trong test bằng `FixedClock`, để logic hết hạn kiểm thử được.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Ghi đè trong test bằng `AppDatabase.forTesting(NativeDatabase.memory())`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final lotRepositoryProvider = Provider<LotRepository>(
  (ref) => LotRepository(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) =>
      VehicleRepository(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) =>
      PaymentRepository(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final recurringCostMaterializerProvider = Provider<RecurringCostMaterializer>(
  (ref) => RecurringCostMaterializer(
      ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

/// Ngày hôm nay theo đồng hồ đã tiêm. Mọi nơi cần "hôm nay" phải đọc qua đây
/// chứ không gọi thẳng `DateTime.now()`, nếu không test không kiểm được các
/// trường hợp biên như qua tháng hay năm nhuận.
final todayProvider = Provider<Day>((ref) => Day.fromLocal(ref.watch(clockProvider).now()));

final currentMonthProvider =
    Provider<YearMonth>((ref) => YearMonth.fromDay(ref.watch(todayProvider)));

/// Cổng bảo đảm chi phí cố định đã được sinh ra trước khi bất kỳ báo cáo nào
/// đọc dữ liệu.
///
/// Các provider báo cáo phải `await ref.watch(costsMaterializedProvider.future)`
/// trước khi truy vấn. Nhờ vậy việc sinh chi phí là một phụ thuộc tường minh
/// được chờ, chứ không phải một tác vụ bắn đi rồi bỏ mặc — kiểu đó sẽ khiến
/// lần mở app đầu tiên trong tháng hiện báo cáo thiếu chi phí.
final costsMaterializedProvider = FutureProvider<int>((ref) async {
  final materializer = ref.watch(recurringCostMaterializerProvider);
  return materializer.materializeCurrentMonth();
});
