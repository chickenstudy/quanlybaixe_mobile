import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/text/vi_normalize.dart';
import '../../../core/time/clock.dart';
import '../../../core/time/date_math.dart';
import '../../../core/time/day.dart';

/// Trạng thái hạn dùng để lọc (mục 8 đặc tả).
enum ExpiryFilter {
  all,

  /// Còn hạn và chưa tới ngưỡng "sắp hết hạn".
  current,

  /// Còn hạn nhưng sẽ hết trong `soonDays` ngày tới.
  expiringSoon,

  /// Đã tới hoặc quá hạn — gồm cả xe chưa từng đóng tiền.
  expired,
}

class VehicleFilter {
  const VehicleFilter({
    this.lotId,
    this.type,
    this.expiry = ExpiryFilter.all,
    this.query = '',
    this.soonDays = 7,
    this.includeStopped = false,
  });

  final int? lotId;
  final VehicleType? type;
  final ExpiryFilter expiry;

  /// Từ khoá tìm theo biển số / tên chủ xe / số điện thoại.
  final String query;
  final int soonDays;
  final bool includeStopped;

  VehicleFilter copyWith({
    int? Function()? lotId,
    VehicleType? Function()? type,
    ExpiryFilter? expiry,
    String? query,
    int? soonDays,
    bool? includeStopped,
  }) =>
      VehicleFilter(
        lotId: lotId != null ? lotId() : this.lotId,
        type: type != null ? type() : this.type,
        expiry: expiry ?? this.expiry,
        query: query ?? this.query,
        soonDays: soonDays ?? this.soonDays,
        includeStopped: includeStopped ?? this.includeStopped,
      );

  @override
  bool operator ==(Object other) =>
      other is VehicleFilter &&
      other.lotId == lotId &&
      other.type == type &&
      other.expiry == expiry &&
      other.query == query &&
      other.soonDays == soonDays &&
      other.includeStopped == includeStopped;

  @override
  int get hashCode =>
      Object.hash(lotId, type, expiry, query, soonDays, includeStopped);
}

/// Một dòng trong danh sách xe: bản ghi xe, tên bãi, và số ngày còn lại.
class VehicleListItem {
  const VehicleListItem({
    required this.vehicle,
    required this.lotName,
    required this.daysLeft,
  });

  final VehicleRow vehicle;
  final String lotName;

  /// `null` khi xe chưa đóng tiền lần nào.
  /// `> 0` còn hạn · `0` hết hạn hôm nay · `< 0` đã quá hạn.
  final int? daysLeft;

  bool get hasNeverPaid => vehicle.currentPeriodEnd == null;
  bool get isExpired => daysLeft == null || daysLeft! <= 0;

  /// Dấu "đã nhắc" chỉ có hiệu lực cho đúng kỳ hạn hiện tại, nên tự mất khi xe
  /// được gia hạn — nếu không, người dùng sẽ tưởng đã nhắc rồi trong khi đó là
  /// lần nhắc của kỳ trước.
  bool get isReminded =>
      vehicle.lastRemindedAt != null &&
      vehicle.remindedForPeriodEnd == vehicle.currentPeriodEnd;
}

class VehicleRepository {
  VehicleRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Day get _today => Day.fromLocal(_clock.now());

  /// Danh sách xe theo bộ lọc và từ khoá tìm kiếm (mục 8 đặc tả).
  ///
  /// Tìm kiếm chạy trên các cột đã gấp dấu sẵn (`owner_name_fold`,
  /// `plate_normalized`, `phone_digits`) nên gõ "nguyen" ra "Nguyễn" và gõ
  /// "59a123456" ra "59A1-234.56". Gấp dấu lúc ghi chứ không lúc đọc, vì
  /// `COLLATE NOCASE` của SQLite chỉ xử lý ASCII và iOS không kèm ICU.
  Stream<List<VehicleListItem>> watchList(VehicleFilter f) {
    final today = _today;
    final where = <String>['v.deleted_at IS NULL'];
    final vars = <Variable>[];

    if (!f.includeStopped) where.add('v.status = 0');

    if (f.lotId != null) {
      vars.add(Variable.withInt(f.lotId!));
      where.add('v.lot_id = ?${vars.length}');
    }
    if (f.type != null) {
      vars.add(Variable.withInt(f.type!.index));
      where.add('v.vehicle_type = ?${vars.length}');
    }

    final q = f.query.trim();
    if (q.isNotEmpty) {
      // Chỉ ghép vế nào có nội dung sau khi chuẩn hoá.
      //
      // Bỏ qua bước này là một lỗi im lặng và rất khó thấy: gõ "nguyen" thì
      // `normalizePhone` trả chuỗi rỗng, vế thành `phone_digits LIKE '%%'` và
      // khớp MỌI xe có số điện thoại — tức là gõ tên khách nào cũng ra nguyên
      // bảng, trông như tìm kiếm hỏng chứ không như một lỗi.
      final terms = <(String, String)>[
        ('v.owner_name_fold', viFold(q)),
        ('v.plate_normalized', normalizePlate(q)),
        ('v.phone_digits', normalizePhone(q)),
      ].where((t) => t.$2.isNotEmpty).toList();

      if (terms.isEmpty) {
        // Từ khoá chỉ gồm ký tự bị loại bỏ hết (ví dụ "---"): không có gì để
        // khớp, trả về rỗng thay vì trả về tất cả.
        where.add('1 = 0');
      } else {
        final parts = <String>[];
        for (final (column, value) in terms) {
          vars.add(Variable.withString('%$value%'));
          parts.add('$column LIKE ?${vars.length}');
        }
        where.add('(${parts.join(' OR ')})');
      }
    }

    switch (f.expiry) {
      case ExpiryFilter.all:
        break;
      case ExpiryFilter.expired:
        vars.add(Variable.withDateTime(today.utcMidnight));
        where.add(
            '(v.current_period_end IS NULL OR v.current_period_end <= ?${vars.length})');
      case ExpiryFilter.expiringSoon:
        vars.add(Variable.withDateTime(today.utcMidnight));
        final a = vars.length;
        vars.add(Variable.withDateTime(today.addDays(f.soonDays).utcMidnight));
        where.add('v.current_period_end > ?$a AND v.current_period_end <= ?${vars.length}');
      case ExpiryFilter.current:
        vars.add(Variable.withDateTime(today.addDays(f.soonDays).utcMidnight));
        where.add('v.current_period_end > ?${vars.length}');
    }

    return _db.customSelect(
      '''
      SELECT v.*, l.name AS lot_name
      FROM vehicles v
      JOIN lots l ON l.id = v.lot_id
      WHERE ${where.join(' AND ')}
      ORDER BY v.current_period_end IS NULL DESC, v.current_period_end ASC, v.plate
      ''',
      variables: vars,
      readsFrom: {_db.vehicles, _db.lots},
    ).watch().map((rows) => rows.map((r) {
          final v = _db.vehicles.map(r.data);
          return VehicleListItem(
            vehicle: v,
            lotName: r.read<String>('lot_name'),
            daysLeft: v.currentPeriodEnd == null
                ? null
                : daysRemaining(today, v.currentPeriodEnd!),
          );
        }).toList());
  }

  Future<VehicleRow?> findById(int id) =>
      (_db.select(_db.vehicles)..where((v) => v.id.equals(id))).getSingleOrNull();

  /// Kiểm tra tức thì biển số đã tồn tại trong bãi hay chưa.
  Future<bool> checkPlateExists(
    String plate,
    int lotId, {
    int? excludeVehicleId,
  }) async {
    final norm = normalizePlate(plate);
    if (norm.isEmpty) return false;
    final query = _db.select(_db.vehicles)
      ..where((v) =>
          v.lotId.equals(lotId) &
          v.plateNormalized.equals(norm) &
          v.status.equals(0) &
          v.deletedAt.isNull());
    if (excludeVehicleId != null) {
      query.where((v) => v.id.equals(excludeVehicleId).not());
    }
    final existing = await query.get();
    return existing.isNotEmpty;
  }

  Future<int> create({
    required int lotId,
    required String ownerName,
    String? phone,
    required VehicleType type,
    required String plate,
    required int monthlyPrice,
    required Day startDate,
    String? notes,
  }) {
    return _db.transaction(() async {
      final now = _clock.now();
      final id = await _db.into(_db.vehicles).insert(VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: ownerName,
            ownerNameFold: viFold(ownerName),
            phone: Value(phone),
            phoneDigits: Value(phone == null ? null : normalizePhone(phone)),
            vehicleType: type,
            plate: plate,
            plateNormalized: normalizePlate(plate),
            monthlyPrice: monthlyPrice,
            startDate: startDate,
            // Neo chu kỳ vào ngày bắt đầu gốc, để kẹp cuối tháng không dính
            // vĩnh viễn qua các lần gia hạn.
            anchorDay: startDate.day,
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ));
      await _log(now, LogAction.vehicleCreated, id, lotId,
          'Thêm xe $plate — $ownerName');
      return id;
    });
  }

  Future<void> update(
    int id, {
    required int lotId,
    required String ownerName,
    String? phone,
    required VehicleType type,
    required String plate,
    required int monthlyPrice,
    String? notes,
  }) {
    return _db.transaction(() async {
      final before = await findById(id);
      final now = _clock.now();
      await (_db.update(_db.vehicles)..where((v) => v.id.equals(id)))
          .write(VehiclesCompanion(
        lotId: Value(lotId),
        ownerName: Value(ownerName),
        ownerNameFold: Value(viFold(ownerName)),
        phone: Value(phone),
        phoneDigits: Value(phone == null ? null : normalizePhone(phone)),
        vehicleType: Value(type),
        plate: Value(plate),
        plateNormalized: Value(normalizePlate(plate)),
        monthlyPrice: Value(monthlyPrice),
        notes: Value(notes),
        updatedAt: Value(now),
      ));

      final movedLot = before != null && before.lotId != lotId;
      await _log(
        now,
        movedLot ? LogAction.vehicleMoved : LogAction.vehicleUpdated,
        id,
        lotId,
        movedLot
            ? 'Chuyển xe $plate sang bãi khác'
            : 'Sửa thông tin xe $plate — $ownerName',
      );
    });
  }

  /// Đánh dấu đã nhắc khách (mục 6 đặc tả).
  ///
  /// Ghi kèm kỳ hạn đang được nhắc, để dấu này tự mất khi xe được gia hạn.
  Future<void> markReminded(int id) {
    return _db.transaction(() async {
      final v = await findById(id);
      if (v == null) return;
      final now = _clock.now();
      await (_db.update(_db.vehicles)..where((t) => t.id.equals(id)))
          .write(VehiclesCompanion(
        lastRemindedAt: Value(now),
        remindedForPeriodEnd: Value(v.currentPeriodEnd),
        updatedAt: Value(now),
      ));
      await _log(now, LogAction.vehicleReminded, id, v.lotId,
          'Đã nhắc thu tiền xe ${v.plate}');
    });
  }

  /// Kết thúc gửi xe — "ngày kết thúc" ở mục 3 đặc tả.
  ///
  /// Không xoá: lịch sử thu tiền của xe này vẫn phải nằm trong báo cáo doanh
  /// thu của bãi.
  Future<void> stop(int id, {Day? on}) {
    return _db.transaction(() async {
      final v = await findById(id);
      if (v == null) return;
      final now = _clock.now();
      await (_db.update(_db.vehicles)..where((t) => t.id.equals(id)))
          .write(VehiclesCompanion(
        status: const Value(VehicleStatus.stopped),
        leftOn: Value(on ?? _today),
        updatedAt: Value(now),
      ));
      await _log(now, LogAction.vehicleStopped, id, v.lotId,
          'Xe ${v.plate} rời bãi');
    });
  }

  Future<void> softDelete(int id) {
    return _db.transaction(() async {
      final v = await findById(id);
      if (v == null) return;
      final now = _clock.now();
      await (_db.update(_db.vehicles)..where((t) => t.id.equals(id)))
          .write(VehiclesCompanion(deletedAt: Value(now), updatedAt: Value(now)));
      await _log(now, LogAction.vehicleDeleted, id, v.lotId,
          'Xoá xe ${v.plate} — ${v.ownerName}');
    });
  }

  Future<void> _log(DateTime at, LogAction action, int vehicleId, int lotId,
      String summary) {
    return _db.into(_db.activityLog).insert(ActivityLogCompanion.insert(
          at: at,
          action: action,
          entityType: LogEntity.vehicle,
          entityId: Value(vehicleId),
          lotId: Value(lotId),
          summary: summary,
          detailsJson: Value(jsonEncode({'vehicleId': vehicleId})),
        ));
  }
}
