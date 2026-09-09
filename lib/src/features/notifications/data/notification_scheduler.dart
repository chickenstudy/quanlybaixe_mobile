import 'dart:async';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/day.dart';
import '../domain/digest_plan.dart';
import '../domain/digest_planner.dart';
import 'notification_service.dart';

/// Cài đặt nhắc hạn do người dùng chọn.
class NotificationPrefs {
  const NotificationPrefs({
    this.enabled = true,
    this.hour = DigestPlanner.defaultHour,
    this.leadDays = DigestPlanner.defaultLeadDays,
    this.windowDays = DigestPlanner.defaultWindowDays,
  });

  final bool enabled;
  final int hour;
  final List<int> leadDays;
  final int windowDays;
}

/// Giữ cho lịch thông báo của hệ điều hành luôn khớp với dữ liệu trong máy.
///
/// iOS không chạy code của ứng dụng lúc thông báo bắn, nên con số trong câu
/// "Có 5 xe sẽ hết hạn trong vòng 3 ngày" phải **tính trước lúc đặt lịch**.
/// Việc này khả thi vì ngày hết hạn là tất định — số xe hết hạn vào một ngày
/// tương lai bất kỳ biết trước được ngay hôm nay, và chỉ đổi khi người dùng
/// gia hạn, thêm hoặc xoá xe.
class NotificationScheduler {
  NotificationScheduler(this._db, this._service, this._clock);

  static const _hashKey = 'notif_plan_hash';

  final AppDatabase _db;
  final NotificationService _service;
  final Clock _clock;
  final _planner = const DigestPlanner();

  StreamSubscription<void>? _sub;

  /// Lắng nghe thẳng luồng thay đổi bảng của Drift.
  ///
  /// Thay cho việc rải lời gọi `reschedule()` ở hàng chục nơi ghi dữ liệu —
  /// cách đó chắc chắn sẽ quên một chỗ, và triệu chứng là thông báo báo sai số
  /// mà không ai biết vì sao.
  void start() {
    _sub?.cancel();
    _sub = _db
        .tableUpdates(TableUpdateQuery.onAllTables([_db.vehicles, _db.payments]))
        .transform(_debounce(const Duration(seconds: 1)))
        .listen((_) => unawaited(reschedule()));
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  /// Tính lại kế hoạch và đặt lịch. Trả về số thông báo đã đặt, `-1` nếu bỏ
  /// qua vì kế hoạch không đổi.
  Future<int> reschedule({NotificationPrefs prefs = const NotificationPrefs()}) async {
    if (!prefs.enabled || !await _service.hasPermission()) {
      await _service.cancelDigests();
      await _clearHash();
      return 0;
    }

    final now = _clock.now();
    final plan = _planner.build(
      vehicles: await _loadExpiries(),
      today: Day.fromLocal(now),
      windowDays: prefs.windowDays,
      hour: prefs.hour,
      leadDays: prefs.leadDays,
      skipTodayIfHourPassed: true,
      currentHour: now.hour,
    );

    // Băm nội dung: nếu không đổi thì KHÔNG đụng gì tới hệ điều hành. Đây là
    // thứ khiến "đặt lại lịch sau mỗi thay đổi dữ liệu" gần như miễn phí.
    if (await _readHash() == plan.hash) return -1;

    await _service.cancelDigests();
    final n = await _service.schedule(plan);
    await _writeHash(plan.hash);
    return n;
  }

  /// Chỉ đọc đúng bốn cột cần cho việc lập lịch, không nạp cả bản ghi xe.
  Future<List<VehicleExpiry>> _loadExpiries() async {
    final rows = await _db.customSelect('''
      SELECT id, lot_id, current_period_end, status
      FROM vehicles
      WHERE deleted_at IS NULL
    ''', readsFrom: {_db.vehicles}).get();

    return [
      for (final r in rows)
        VehicleExpiry(
          vehicleId: r.read<int>('id'),
          lotId: r.read<int>('lot_id'),
          currentPeriodEnd: r.read<DateTime?>('current_period_end') == null
              ? null
              : Day.fromUtcMidnight(r.read<DateTime>('current_period_end')),
          isActive: r.read<int>('status') == 0,
        ),
    ];
  }

  Future<String?> _readHash() async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(_hashKey)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeHash(String hash) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(AppSettingRow(key: _hashKey, value: hash));

  Future<void> _clearHash() =>
      (_db.delete(_db.appSettings)..where((s) => s.key.equals(_hashKey))).go();
}

/// Gộp các đợt thay đổi liên tiếp. Một lần thu tiền chạm vào nhiều bảng nên
/// sinh ra nhiều sự kiện; không gộp thì mỗi lần bấm nút là vài lượt tính lại
/// kế hoạch.
StreamTransformer<T, T> _debounce<T>(Duration duration) {
  Timer? timer;
  return StreamTransformer<T, T>.fromHandlers(
    handleData: (data, sink) {
      timer?.cancel();
      timer = Timer(duration, () => sink.add(data));
    },
    handleDone: (sink) {
      timer?.cancel();
      sink.close();
    },
  );
}
