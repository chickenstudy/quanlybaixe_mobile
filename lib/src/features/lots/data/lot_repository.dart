import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/text/vi_normalize.dart';
import '../../../core/time/clock.dart';

/// Bãi xe kèm các số liệu tổng hợp cần cho danh sách và thống kê.
class LotSummary {
  const LotSummary({
    required this.lot,
    required this.activeVehicles,
    required this.expiredVehicles,
    required this.neverPaidVehicles,
  });

  final LotRow lot;
  final int activeVehicles;

  /// Xe ĐÃ từng đóng tiền nhưng kỳ đã kết thúc.
  final int expiredVehicles;

  /// Xe đăng ký rồi nhưng chưa đóng tiền lần nào.
  ///
  /// Tách khỏi [expiredVehicles] để khớp với màn hình tổng quan — cùng một
  /// khái niệm mà hai màn hình đếm hai kiểu thì con số vênh nhau, và người
  /// dùng sẽ thôi tin vào cả hai. Về nghĩa cũng khác: xe chưa từng có kỳ hạn
  /// thì không thể gọi là "đã hết hạn".
  final int neverPaidVehicles;

  /// Tổng số xe cần thu tiền — dùng khi chỉ cần một con số duy nhất.
  int get needCollection => expiredVehicles + neverPaidVehicles;

  /// Tỷ lệ lấp đầy, `null` khi chưa khai báo sức chứa.
  ///
  /// Trả `null` chứ không trả 0: màn hình thống kê phải **ẩn** chỉ số này khi
  /// không biết sức chứa, thay vì hiện một con số sai.
  double? get occupancyRate {
    final cap = lot.capacity;
    if (cap == null || cap <= 0) return null;
    return activeVehicles / cap;
  }
}

class LotRepository {
  LotRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Stream<List<LotRow>> watchAll({bool includeInactive = false}) {
    final q = _db.select(_db.lots)
      ..where((l) => l.deletedAt.isNull())
      ..orderBy([
        (l) => OrderingTerm.asc(l.sortOrder),
        (l) => OrderingTerm.asc(l.name),
      ]);
    if (!includeInactive) q.where((l) => l.isActive.equals(true));
    return q.watch();
  }

  Future<LotRow?> findById(int id) =>
      (_db.select(_db.lots)..where((l) => l.id.equals(id))).getSingleOrNull();

  /// Danh sách bãi kèm số xe đang gửi và số xe đã quá hạn.
  ///
  /// Đếm bằng một câu SQL có gom nhóm thay vì đếm từng bãi trong vòng lặp Dart:
  /// màn hình tổng quan gọi liên tục, và số bãi có thể lên vài chục.
  Stream<List<LotSummary>> watchSummaries({required DateTime today}) {
    return _db.customSelect(
      '''
      SELECT l.*,
        (SELECT COUNT(*) FROM vehicles v
          WHERE v.lot_id = l.id AND v.deleted_at IS NULL AND v.status = 0
        ) AS active_vehicles,
        (SELECT COUNT(*) FROM vehicles v
          WHERE v.lot_id = l.id AND v.deleted_at IS NULL AND v.status = 0
            AND v.current_period_end IS NOT NULL
            AND v.current_period_end <= ?1
        ) AS expired_vehicles,
        (SELECT COUNT(*) FROM vehicles v
          WHERE v.lot_id = l.id AND v.deleted_at IS NULL AND v.status = 0
            AND v.current_period_end IS NULL
        ) AS never_paid_vehicles
      FROM lots l
      WHERE l.deleted_at IS NULL
      ORDER BY l.sort_order, l.name
      ''',
      variables: [Variable.withDateTime(today)],
      readsFrom: {_db.lots, _db.vehicles},
    ).watch().map((rows) => rows
        .map((r) => LotSummary(
              lot: _db.lots.map(r.data),
              activeVehicles: r.read<int>('active_vehicles'),
              expiredVehicles: r.read<int>('expired_vehicles'),
              neverPaidVehicles: r.read<int>('never_paid_vehicles'),
            ))
        .toList());
  }

  Future<int> create({
    required String name,
    String? address,
    int? capacity,
    String? notes,
  }) {
    return _db.transaction(() async {
      final now = _clock.now();
      final id = await _db.into(_db.lots).insert(LotsCompanion.insert(
            name: name,
            nameFold: viFold(name),
            address: Value(address),
            capacity: Value(capacity),
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ));
      await _log(now, LogAction.lotCreated, id, 'Thêm bãi xe "$name"');
      return id;
    });
  }

  Future<void> update(
    int id, {
    required String name,
    String? address,
    int? capacity,
    String? notes,
    required bool isActive,
  }) {
    return _db.transaction(() async {
      final now = _clock.now();
      await (_db.update(_db.lots)..where((l) => l.id.equals(id)))
          .write(LotsCompanion(
        name: Value(name),
        nameFold: Value(viFold(name)),
        address: Value(address),
        capacity: Value(capacity),
        notes: Value(notes),
        isActive: Value(isActive),
        updatedAt: Value(now),
      ));
      await _log(now, LogAction.lotUpdated, id, 'Sửa bãi xe "$name"');
    });
  }

  /// Số xe còn gắn với bãi — dùng để chặn xoá.
  Future<int> countVehicles(int lotId) async {
    final r = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM vehicles WHERE lot_id = ?1 AND deleted_at IS NULL',
      variables: [Variable.withInt(lotId)],
    ).getSingle();
    return r.read<int>('c');
  }

  /// Xoá mềm một bãi.
  ///
  /// Từ chối nếu bãi còn xe: xoá bãi mà vẫn còn khách gửi thì toàn bộ doanh thu
  /// lịch sử của bãi đó thành mồ côi. Người dùng phải chuyển hoặc kết thúc các
  /// xe trước — thông báo lỗi nói rõ còn bao nhiêu xe.
  Future<void> softDelete(int id) {
    return _db.transaction(() async {
      final remaining = await countVehicles(id);
      if (remaining > 0) {
        throw LotHasVehiclesException(lotId: id, vehicleCount: remaining);
      }
      final lot = await findById(id);
      final now = _clock.now();
      await (_db.update(_db.lots)..where((l) => l.id.equals(id)))
          .write(LotsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await _log(now, LogAction.lotDeleted, id, 'Xoá bãi xe "${lot?.name ?? id}"');
    });
  }

  Future<void> _log(
      DateTime at, LogAction action, int lotId, String summary) {
    return _db.into(_db.activityLog).insert(ActivityLogCompanion.insert(
          at: at,
          action: action,
          entityType: LogEntity.lot,
          entityId: Value(lotId),
          lotId: Value(lotId),
          summary: summary,
          detailsJson: Value(jsonEncode({'lotId': lotId})),
        ));
  }
}

class LotHasVehiclesException implements Exception {
  const LotHasVehiclesException({required this.lotId, required this.vehicleCount});
  final int lotId;
  final int vehicleCount;

  @override
  String toString() =>
      'Không thể xoá: bãi còn $vehicleCount xe đang gửi. '
      'Hãy chuyển hoặc kết thúc các xe này trước.';
}
