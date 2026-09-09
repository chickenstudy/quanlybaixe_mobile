/// Provider của màn hình báo cáo (mục 5 đặc tả).
///
/// Riverpod **thuần, không codegen** — cùng lý do đã ghi ở `core/providers.dart`.
///
/// Chú ý một điều quan trọng về chế độ doanh thu: màn hình này **không** có
/// provider riêng cho nó mà dùng lại `revenueModeProvider` của dashboard. Nếu
/// mỗi màn hình giữ một công tắc riêng thì cùng một tháng sẽ hiện hai con số
/// khác nhau ở hai chỗ, và người dùng sẽ thôi tin cả hai.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/providers.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../data/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(appDatabaseProvider)),
);

/// Danh sách bãi để dựng bộ lọc. Gồm cả bãi đã ngừng hoạt động: số liệu lịch
/// sử của chúng vẫn nằm trong báo cáo, ẩn khỏi bộ lọc thì không ai xem lại
/// được.
final reportLotsProvider = StreamProvider<List<LotRow>>(
  (ref) => ref.watch(lotRepositoryProvider).watchAll(includeInactive: true),
);

/// Bãi đang lọc. `null` nghĩa là **tất cả các bãi**.
final reportLotFilterProvider =
    NotifierProvider<ReportLotFilterNotifier, int?>(ReportLotFilterNotifier.new);

class ReportLotFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? lotId) => state = lotId;
}

/// Mốc gom nhóm người dùng chọn.
///
/// Đây là mốc **được yêu cầu**, không nhất thiết là mốc báo cáo thực sự dùng:
/// chọn Ngày trong chế độ Phân bổ thì kho dữ liệu tự lùi về Tháng và bật cờ
/// `ReportResult.granularityDowngraded`. Giữ nguyên lựa chọn của người dùng ở
/// đây (thay vì lặng lẽ sửa nó về Tháng) để khi họ chuyển lại sang Thực thu,
/// báo cáo quay về đúng mốc Ngày họ đã chọn.
final reportGranularityProvider =
    NotifierProvider<ReportGranularityNotifier, ReportGranularity>(
        ReportGranularityNotifier.new);

class ReportGranularityNotifier extends Notifier<ReportGranularity> {
  @override
  ReportGranularity build() => ReportGranularity.month;

  void set(ReportGranularity g) => state = g;
}

/// Các khoảng chọn nhanh của mục 5 đặc tả.
enum ReportRangePreset { thisMonth, thisQuarter, thisYear, last12Months, custom }

/// Khoảng thời gian của báo cáo.
///
/// [to] là mốc **loại trừ**, đồng nhất với `ReportRepository.build` và với quy
/// ước dùng khắp ứng dụng. Chỗ nào cần hiện cho người đọc thì phải lùi một
/// ngày ([lastDay]) — nếu không, báo cáo "tháng 8" sẽ ghi là tới 01/09.
class ReportRange {
  const ReportRange({
    required this.from,
    required this.to,
    required this.preset,
  });

  final Day from;
  final Day to;
  final ReportRangePreset preset;

  /// Ngày cuối cùng **thực sự** nằm trong khoảng, để hiển thị.
  Day get lastDay => to.addDays(-1);

  YearMonth get fromYm => YearMonth.fromDay(from);
  YearMonth get toYm => YearMonth.fromDay(lastDay);

  /// Dựng khoảng ứng với một nút chọn nhanh, lấy [today] làm mốc.
  ///
  /// [ReportRangePreset.custom] không dựng được từ một ngày nên rơi về
  /// 12 tháng gần nhất; nơi gọi phải dùng [ReportRange.new] cho khoảng tự chọn.
  factory ReportRange.preset(ReportRangePreset preset, Day today) {
    final ym = YearMonth.fromDay(today);
    switch (preset) {
      case ReportRangePreset.thisMonth:
        return ReportRange(
          from: ym.firstDay,
          to: ym.addMonths(1).firstDay,
          preset: preset,
        );
      case ReportRangePreset.thisQuarter:
        // Tháng đầu quý: 1, 4, 7 hoặc 10.
        final firstMonth = ((ym.month - 1) ~/ 3) * 3 + 1;
        final start = YearMonth(ym.year, firstMonth);
        return ReportRange(
          from: start.firstDay,
          to: start.addMonths(3).firstDay,
          preset: preset,
        );
      case ReportRangePreset.thisYear:
        return ReportRange(
          from: Day(ym.year, 1, 1),
          to: Day(ym.year + 1, 1, 1),
          preset: preset,
        );
      case ReportRangePreset.last12Months:
      case ReportRangePreset.custom:
        // 12 tháng **tính cả tháng này** — người dùng nói "12 tháng qua" là
        // muốn thấy tháng đang chạy dở, không phải bị cắt mất.
        return ReportRange(
          from: ym.addMonths(-11).firstDay,
          to: ym.addMonths(1).firstDay,
          preset: ReportRangePreset.last12Months,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ReportRange &&
      other.from == from &&
      other.to == to &&
      other.preset == preset;

  @override
  int get hashCode => Object.hash(from, to, preset);
}

/// Khoảng thời gian đang xem. Mặc định **12 tháng gần nhất**.
final reportRangeProvider =
    NotifierProvider<ReportRangeNotifier, ReportRange>(ReportRangeNotifier.new);

class ReportRangeNotifier extends Notifier<ReportRange> {
  @override
  ReportRange build() => ReportRange.preset(
        ReportRangePreset.last12Months,
        ref.watch(todayProvider),
      );

  void setPreset(ReportRangePreset preset) =>
      state = ReportRange.preset(preset, ref.read(todayProvider));

  /// Khoảng tự chọn. [lastDay] là ngày cuối **bao gồm** — đúng thứ lịch trả
  /// về — nên đẩy thêm một ngày để thành mốc loại trừ.
  void setCustom({required Day from, required Day lastDay}) => state =
      ReportRange(from: from, to: lastDay.addDays(1), preset: ReportRangePreset.custom);
}

/// Kết quả báo cáo cho bộ lọc hiện tại.
///
/// `await ref.watch(costsMaterializedProvider.future)` là bắt buộc trước khi
/// truy vấn: lần mở app đầu tiên trong tháng, chi phí cố định chưa được sinh
/// ra, và báo cáo sẽ hiện lợi nhuận cao giả tạo vì thiếu hẳn phần chi.
final reportResultProvider = FutureProvider<ReportResult>((ref) async {
  await ref.watch(costsMaterializedProvider.future);
  final range = ref.watch(reportRangeProvider);
  return ref.watch(reportRepositoryProvider).build(
        from: range.from,
        to: range.to,
        granularity: ref.watch(reportGranularityProvider),
        mode: ref.watch(revenueModeProvider),
        lotId: ref.watch(reportLotFilterProvider),
      );
});

/// Chi phí tách theo nhóm cho cùng khoảng và cùng bộ lọc bãi.
///
/// Luôn gom theo **tháng** (`fromYm`/`toYm`) chứ không theo mốc đang chọn: đây
/// là một lát cắt "cả khoảng cộng lại", mốc gom nhóm không liên quan.
final reportExpenseBreakdownProvider =
    FutureProvider<List<({CostCategory category, int total})>>((ref) async {
  await ref.watch(costsMaterializedProvider.future);
  final range = ref.watch(reportRangeProvider);
  return ref.watch(reportRepositoryProvider).expenseBreakdown(
        fromYm: range.fromYm,
        toYm: range.toYm,
        lotId: ref.watch(reportLotFilterProvider),
      );
});
