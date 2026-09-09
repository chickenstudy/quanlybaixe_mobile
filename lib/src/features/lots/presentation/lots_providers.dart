import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/lot_repository.dart';

/// Provider của màn hình bãi xe.
///
/// Riverpod **thuần, không codegen** — cùng lý do đã ghi ở `core/providers.dart`:
/// mấy dòng nối dây này không đáng để đổi lấy một vòng `build_runner` mỗi lần
/// sửa.

/// Danh sách bãi kèm số xe đang gửi, số xe hết hạn và tỷ lệ lấp đầy.
///
/// Mốc "hôm nay" đọc qua [todayProvider] chứ không gọi `DateTime.now()`: đó là
/// thứ quyết định xe nào bị tính là hết hạn, và test phải kiểm được nó.
///
/// Truyền `utcMidnight` chứ không phải `localMidnight`: cột `current_period_end`
/// được `DayConverter` lưu thành nửa đêm UTC, nên so sánh cũng phải ở cùng hệ
/// quy chiếu — dùng giờ địa phương sẽ lệch đúng một ngày ở các múi giờ dương
/// như Việt Nam.
final lotSummariesProvider = StreamProvider<List<LotSummary>>((ref) {
  return ref.watch(lotRepositoryProvider).watchSummaries(
        today: ref.watch(todayProvider).utcMidnight,
      );
});
