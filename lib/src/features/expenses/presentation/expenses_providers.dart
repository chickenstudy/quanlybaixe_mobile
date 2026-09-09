import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/time/year_month.dart';
import '../data/expense_repository.dart';

/// Provider của cụm màn hình CHI PHÍ.
///
/// Riverpod **thuần, không codegen** — cùng lý do đã ghi ở `core/providers.dart`:
/// mấy dòng nối dây này không đáng để đổi lấy một vòng `build_runner` mỗi lần
/// sửa.

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(
      ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

/// Danh sách bãi cho chip lọc và cho ô chọn bãi trong form.
///
/// **Lấy cả bãi đã ngừng hoạt động** (`includeInactive: true`), khác với màn
/// hình xe: chi phí lịch sử vẫn thuộc về bãi đã đóng cửa, và bỏ bãi đó ra khỏi
/// danh sách sẽ khiến các dòng chi phí của nó mất tên bãi trên giao diện.
final expenseLotsProvider = StreamProvider<List<LotRow>>(
  (ref) => ref.watch(lotRepositoryProvider).watchAll(includeInactive: true),
);

/// Tra tên bãi theo id, cho dòng chi phí khi đang xem tất cả các bãi.
final lotNamesProvider = Provider<Map<int, String>>((ref) {
  final lots = ref.watch(expenseLotsProvider).value ?? const <LotRow>[];
  return {for (final l in lots) l.id: l.name};
});

/// Tháng kế toán đang xem.
///
/// Đặt ở tầng provider chứ không phải `State` của màn hình để lựa chọn **sống
/// sót qua việc chuyển thẻ điều hướng** — chủ bãi hay nhảy sang màn hình khác
/// rồi quay lại và mong vẫn đang đứng ở tháng cũ.
final selectedExpenseMonthProvider =
    NotifierProvider<SelectedExpenseMonthNotifier, YearMonth>(
  SelectedExpenseMonthNotifier.new,
);

class SelectedExpenseMonthNotifier extends Notifier<YearMonth> {
  @override
  YearMonth build() => ref.watch(currentMonthProvider);

  void previous() => state = state.addMonths(-1);
  void next() => state = state.addMonths(1);
  void set(YearMonth month) => state = month;
}

/// Bãi đang lọc. `null` = tất cả các bãi.
final expenseLotFilterProvider =
    NotifierProvider<ExpenseLotFilterNotifier, int?>(
  ExpenseLotFilterNotifier.new,
);

class ExpenseLotFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? lotId) => state = lotId;
}

/// Chi phí của tháng đang xem, đã lọc theo bãi.
///
/// `ref.watch(costsMaterializedProvider)` là **bắt buộc**, không phải cho vui:
/// chi phí cố định chỉ tồn tại sau khi bộ sinh chạy, nên bỏ dòng này thì lần
/// mở app đầu tiên trong tháng sẽ hiện một danh sách thiếu hẳn tiền thuê, điện,
/// nước — và không có lỗi nào được báo.
final monthExpensesProvider = StreamProvider<List<ExpenseRow>>((ref) {
  ref.watch(costsMaterializedProvider);
  return ref.watch(expenseRepositoryProvider).watchByMonth(
        month: ref.watch(selectedExpenseMonthProvider),
        lotId: ref.watch(expenseLotFilterProvider),
      );
});

/// Tổng chi của tháng đang xem.
///
/// Cộng lại từ chính danh sách đang hiển thị thay vì bắn thêm một câu `SUM`:
/// hai truy vấn riêng có thể phát lệch nhau một khung hình và người dùng sẽ
/// thấy tổng không khớp với các dòng ngay bên dưới nó. Bản `SUM` trong SQL vẫn
/// còn ở `ExpenseRepository.monthTotal` cho báo cáo, nơi không có sẵn danh
/// sách.
final monthExpenseTotalProvider = Provider<int>((ref) {
  final rows =
      ref.watch(monthExpensesProvider).value ?? const <ExpenseRow>[];
  return rows.fold<int>(0, (sum, e) => sum + e.amount);
});

/// Toàn bộ mẫu chi phí cố định, cho màn hình quản lý mẫu.
final expenseTemplatesProvider =
    StreamProvider<List<RecurringCostTemplateRow>>(
  (ref) => ref.watch(expenseRepositoryProvider).watchTemplates(),
);
