import 'package:drift/drift.dart' show OrderingTerm, Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/providers.dart';
import '../../dashboard/presentation/dashboard_providers.dart'
    show expiringSoonDaysProvider;
import '../data/vehicle_repository.dart';

/// Provider của cụm màn hình XE. Riverpod thuần, không codegen — cùng lý do đã
/// ghi trong `core/providers.dart`.

/// Danh sách bãi đang hoạt động: dùng cho chip lọc theo bãi và cho dropdown
/// bắt buộc trong form thêm/sửa xe.
final activeLotsProvider = StreamProvider<List<LotRow>>(
  (ref) => ref.watch(lotRepositoryProvider).watchAll(),
);

/// Bộ lọc đang áp dụng cho danh sách xe (mục 8 đặc tả).
///
/// Đặt ở tầng provider chứ không phải `State` của màn hình để bộ lọc **sống
/// sót qua việc chuyển thẻ điều hướng**: `StatefulShellRoute` giữ cây widget
/// nhưng người dùng vẫn mong quay lại thấy nguyên bộ lọc cũ, và một ngày nào
/// đó màn hình khác (ví dụ chạm vào ô "đã hết hạn" ở tổng quan) sẽ cần đặt sẵn
/// bộ lọc rồi mới điều hướng sang đây.
final vehicleFilterProvider =
    NotifierProvider<VehicleFilterNotifier, VehicleFilter>(
  VehicleFilterNotifier.new,
);

class VehicleFilterNotifier extends Notifier<VehicleFilter> {
  @override
  VehicleFilter build() =>
      VehicleFilter(soonDays: ref.watch(expiringSoonDaysProvider));

  /// Từ khoá tìm theo biển số / tên chủ xe / số điện thoại.
  ///
  /// Không gấp dấu ở đây: `VehicleRepository.watchList` đã tự gọi `viFold`,
  /// `normalizePlate`, `normalizePhone` trên từ khoá. Gấp thêm một lần nữa sẽ
  /// làm hỏng nhánh tìm theo biển số (chữ hoa bị hạ xuống chữ thường).
  void setQuery(String value) => state = state.copyWith(query: value);

  /// `null` nghĩa là mọi bãi. Dùng lối gọi `() => value` của `copyWith` vì đó
  /// là cách duy nhất phân biệt "không đổi" với "đặt về null".
  void setLot(int? lotId) => state = state.copyWith(lotId: () => lotId);

  void setType(VehicleType? type) => state = state.copyWith(type: () => type);

  void setExpiry(ExpiryFilter expiry) => state = state.copyWith(expiry: expiry);

  /// Xoá **toàn bộ** bộ lọc, kể cả từ khoá tìm kiếm.
  ///
  /// Người dùng bấm "Bỏ lọc" khi màn hình trống trơn và họ không hiểu vì sao;
  /// lúc đó thứ họ cần là danh sách đầy đủ trở lại. Giữ lại từ khoá sẽ khiến
  /// nút bấm trông như không có tác dụng.
  void reset() =>
      state = VehicleFilter(soonDays: ref.read(expiringSoonDaysProvider));
}

/// Đang có bộ lọc nào không — quyết định hiện nút "Bỏ lọc", và quyết định
/// trạng thái rỗng là "chưa có xe nào" hay "không tìm thấy".
bool isFiltering(VehicleFilter f) =>
    f.query.trim().isNotEmpty ||
    f.lotId != null ||
    f.type != null ||
    f.expiry != ExpiryFilter.all;

/// Danh sách xe theo bộ lọc hiện hành.
///
/// Lọc hoàn toàn trong SQL. Trước đây ở đây có thêm một lượt lọc lại bằng Dart
/// để chắn lỗi `LIKE '%%'` của repository (từ khoá không có chữ số làm vế tìm
/// theo điện thoại khớp mọi xe). Lỗi đó đã được sửa tận gốc trong
/// `VehicleRepository.watchList`, nên lượt lọc phụ không còn lý do tồn tại —
/// giữ lại chỉ khiến người đọc sau tưởng SQL vẫn không đáng tin.
final vehicleListProvider = StreamProvider<List<VehicleListItem>>((ref) {
  final filter = ref.watch(vehicleFilterProvider);
  return ref.watch(vehicleRepositoryProvider).watchList(filter);
});

/// Một xe kèm tên bãi, cho màn hình chi tiết.
class VehicleDetail {
  const VehicleDetail({required this.vehicle, required this.lotName});

  final VehicleRow vehicle;
  final String lotName;
}

/// Chi tiết một xe, **theo dõi liên tục**.
///
/// Stream chứ không phải `Future`: thu tiền, sửa thông tin hay huỷ biên lai
/// đều đổi bản ghi xe, và màn hình chi tiết phải hiện hạn mới ngay lập tức chứ
/// không đợi người dùng thoát ra vào lại. Trả `null` khi xe không còn (đã xoá
/// mềm ở màn hình khác) để nơi gọi đóng màn hình thay vì hiện dữ liệu ma.
final vehicleDetailProvider =
    StreamProvider.family<VehicleDetail?, int>((ref, id) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .customSelect(
        '''
        SELECT v.*, l.name AS lot_name
        FROM vehicles v
        JOIN lots l ON l.id = v.lot_id
        WHERE v.id = ?1 AND v.deleted_at IS NULL
        ''',
        variables: [Variable.withInt(id)],
        readsFrom: {db.vehicles, db.lots},
      )
      .watch()
      .map((rows) => rows.isEmpty
          ? null
          : VehicleDetail(
              vehicle: db.vehicles.map(rows.first.data),
              lotName: rows.first.read<String>('lot_name'),
            ));
});

/// Lịch sử thu tiền của một xe, mới nhất lên đầu.
///
/// **Không lọc `voidedAt IS NULL`.** Biên lai đã huỷ vẫn phải nằm trong danh
/// sách, chỉ hiện gạch ngang và mờ đi: chủ bãi cần thấy dấu vết của lần huỷ để
/// đối chiếu với khách, còn giấu đi thì bản ghi cứ thế biến mất không lời giải
/// thích. Doanh thu thì đã lọc sẵn ở tầng truy vấn báo cáo.
final vehiclePaymentsProvider =
    StreamProvider.family<List<PaymentRow>, int>((ref, vehicleId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.payments)
        ..where((p) => p.vehicleId.equals(vehicleId))
        ..orderBy([
          (p) => OrderingTerm.desc(p.paidAt),
          // Hai biên lai cùng ngày thu vẫn phải có thứ tự ổn định, nếu không
          // danh sách nhảy chỗ mỗi lần stream phát lại.
          (p) => OrderingTerm.desc(p.id),
        ]))
      .watch();
});
