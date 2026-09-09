import '../../../core/time/day.dart';

/// Dữ liệu tối thiểu về hạn của một xe, đủ để lập kế hoạch thông báo.
///
/// Cố tình *không* phải là bản ghi xe đầy đủ. Bộ lập lịch chỉ cần biết mỗi xe
/// hết hạn ngày nào và còn được tính hay không; kéo cả biển số, chủ xe, giá
/// tiền vào đây sẽ buộc `DigestPlanner` phụ thuộc vào tầng dữ liệu và làm test
/// phải dựng cả một cái xe chỉ để kiểm tra một con số.
class VehicleExpiry {
  const VehicleExpiry({
    required this.vehicleId,
    required this.lotId,
    required this.currentPeriodEnd,
    required this.isActive,
  });

  final int vehicleId;

  /// Bãi chứa xe. Bản kế hoạch hiện tại gộp chung mọi bãi, nhưng giữ trường này
  /// để về sau tách thông báo theo từng bãi mà không phải đổi kiểu dữ liệu.
  final int lotId;

  /// Mốc kết thúc **loại trừ** của kỳ đã đóng tiền — ngày đầu tiên KHÔNG còn
  /// được bao phủ. `null` nghĩa là xe chưa đóng tiền lần nào.
  ///
  /// Vì là mốc loại trừ nên một xe có `currentPeriodEnd == D` đã được coi là
  /// **hết hạn** vào ngày `D`, chứ không phải "sắp hết hạn trong 0 ngày".
  final Day? currentPeriodEnd;

  /// Xe còn gửi trong bãi hay đã rời. Xe đã rời không bao giờ được nhắc thu.
  final bool isActive;

  VehicleExpiry copyWith({
    int? vehicleId,
    int? lotId,
    Day? currentPeriodEnd,
    bool? isActive,
  }) =>
      VehicleExpiry(
        vehicleId: vehicleId ?? this.vehicleId,
        lotId: lotId ?? this.lotId,
        currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
        isActive: isActive ?? this.isActive,
      );

  @override
  bool operator ==(Object other) =>
      other is VehicleExpiry &&
      other.vehicleId == vehicleId &&
      other.lotId == lotId &&
      other.currentPeriodEnd == currentPeriodEnd &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(vehicleId, lotId, currentPeriodEnd, isActive);

  @override
  String toString() => 'VehicleExpiry(#$vehicleId, lot $lotId, '
      'end ${currentPeriodEnd?.iso ?? '-'}, active $isActive)';
}

/// Một thông báo cục bộ đã được tính sẵn, sẵn sàng đẩy sang
/// `flutter_local_notifications`.
///
/// Mọi con số trong [title]/[body] đã được **chốt tại thời điểm đặt lịch**. iOS
/// không đánh thức code của app khi thông báo bắn, nên không có chỗ nào để tính
/// lại. Đó cũng là lý do phần thân luôn kết thúc bằng lời mời mở app: con số là
/// ảnh chụp, không phải số liệu trực tiếp.
class DigestEntry {
  const DigestEntry({
    required this.date,
    required this.hour,
    required this.title,
    required this.body,
    required this.payload,
    required this.expiringCount,
    required this.expiredCount,
    required this.leadDays,
  });

  /// Ngày thông báo bắn.
  final Day date;

  /// Giờ bắn trong ngày, 0..23.
  final int hour;

  final String title;
  final String body;

  /// JSON để deep-link khi người dùng chạm vào thông báo.
  /// Dạng `{"t":"digest","d":"2026-09-14"}`.
  final String payload;

  /// Số xe sắp hết hạn trong mốc [leadDays] đã chọn.
  final int expiringCount;

  /// Số xe đã quá hạn tính đến [date].
  final int expiredCount;

  /// Mốc nhắc đã chọn cho dòng này — mốc *nhỏ nhất* còn đếm được xe.
  /// Bằng `0` khi ngày đó không có xe nào sắp hết hạn (entry tồn tại chỉ vì
  /// [expiredCount] > 0).
  final int leadDays;

  @override
  bool operator ==(Object other) =>
      other is DigestEntry &&
      other.date == date &&
      other.hour == hour &&
      other.title == title &&
      other.body == body &&
      other.payload == payload &&
      other.expiringCount == expiringCount &&
      other.expiredCount == expiredCount &&
      other.leadDays == leadDays;

  @override
  int get hashCode => Object.hash(
        date,
        hour,
        title,
        body,
        payload,
        expiringCount,
        expiredCount,
        leadDays,
      );

  @override
  String toString() =>
      'DigestEntry(${date.iso} ${hour}h, sắp hết $expiringCount/$leadDays ngày, '
      'quá hạn $expiredCount)';
}

/// Toàn bộ kế hoạch thông báo cho một cửa sổ thời gian.
class DigestPlan {
  const DigestPlan({required this.entries, required this.hash});

  /// Sắp xếp theo [DigestEntry.date] tăng dần. Ngày không có gì để nhắc thì
  /// không có mặt ở đây.
  final List<DigestEntry> entries;

  /// Băm ổn định của nội dung kế hoạch.
  ///
  /// Đặt lại lịch thông báo là thao tác đắt và hay bị gọi thừa (mỗi lần mở app,
  /// mỗi lần sửa một xe). So sánh [hash] với giá trị đã lưu cho phép bỏ qua
  /// hoàn toàn lần đặt lịch khi kế hoạch không đổi.
  final String hash;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
  int get length => entries.length;

  @override
  String toString() => 'DigestPlan(${entries.length} mục, hash ${hash.substring(0, hash.length < 8 ? hash.length : 8)})';
}
