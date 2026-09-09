import 'dart:convert';

import 'package:collection/collection.dart' show lowerBound;
import 'package:crypto/crypto.dart';

import '../../../core/time/day.dart';
import 'digest_plan.dart';

/// Lập kế hoạch thông báo tổng hợp nhắc thu tiền bãi xe.
///
/// ## Vì sao con số phải tính trước
///
/// iOS **không** chạy code của app tại thời điểm thông báo cục bộ bắn. Không có
/// callback, không có background fetch nào bảo đảm. Nghĩa là nội dung thông báo
/// phải được viết sẵn ngay lúc đặt lịch — không thể "đếm số xe sắp hết hạn" khi
/// nó nổ.
///
/// May là làm được: ngày hết hạn của từng xe là tất định. Số xe sẽ hết hạn vào
/// một ngày tương lai bất kỳ là biết trước được ngay hôm nay, và chỉ thay đổi
/// khi người dùng gia hạn, thêm hoặc xoá xe — mà những lúc đó app đang chạy nên
/// đặt lại lịch được.
///
/// ## Vì sao là một hàm thuần
///
/// [build] không đọc [DateTime.now], không chạm plugin, không chạm cơ sở dữ
/// liệu. Toàn bộ logic thông báo — thứ khó test nhất trong một app di động —
/// nhờ vậy kiểm chứng được bằng unit test chạy trên máy tính, không cần thiết
/// bị thật và không cần cấp quyền thông báo.
class DigestPlanner {
  const DigestPlanner();

  /// Cửa sổ lập lịch khuyến nghị, tính bằng ngày.
  static const int defaultWindowDays = 30;

  /// Giờ bắn khuyến nghị — 8h sáng, lúc chủ bãi bắt đầu ngày làm việc.
  static const int defaultHour = 8;

  /// Các mốc nhắc theo đặc tả: trước 7 ngày, 3 ngày và 1 ngày.
  static const List<int> defaultLeadDays = [7, 3, 1];

  static const String title = 'Nhắc thu tiền bãi xe';

  /// Câu chốt bắt buộc ở cuối mọi thông báo.
  ///
  /// Con số trong thân là ảnh chụp tại lúc đặt lịch chứ không phải số liệu trực
  /// tiếp, nên nội dung không được tỏ ra là con số chính xác tuyệt đối. Mời mở
  /// app vừa trung thực vừa đúng thứ ta muốn người dùng làm.
  static const String callToAction = 'Mở app để xem danh sách.';

  /// Dựng kế hoạch thông báo cho cửa sổ `[today, today + windowDays)`.
  ///
  /// - [vehicles] — mọi xe của mọi bãi. Xe chưa đóng tiền lần nào
  ///   (`currentPeriodEnd == null`) và xe đã rời bãi (`isActive == false`) bị
  ///   loại hoàn toàn.
  /// - [windowDays] — số ngày lập lịch. Xem [defaultWindowDays].
  /// - [hour] — giờ bắn, 0..23. Xem [defaultHour].
  /// - [leadDays] — các mốc nhắc; thứ tự truyền vào không quan trọng, bên trong
  ///   luôn xét từ nhỏ đến lớn. Xem [defaultLeadDays].
  /// - [skipTodayIfHourPassed] cùng [currentHour] — bỏ thông báo của chính hôm
  ///   nay nếu giờ bắn đã trôi qua. Đặt lịch vào quá khứ trên iOS thì hoặc bị
  ///   bắn ngay lập tức (làm phiền sai lúc) hoặc bị nuốt mất; cả hai đều sai.
  ///   Nếu [currentHour] là `null` thì không có cơ sở để quyết định nên không
  ///   bỏ ngày nào.
  DigestPlan build({
    required List<VehicleExpiry> vehicles,
    required Day today,
    required int windowDays,
    required int hour,
    required List<int> leadDays,
    required bool skipTodayIfHourPassed,
    int? currentHour,
  }) {
    assert(windowDays >= 0, 'windowDays không được âm');
    assert(hour >= 0 && hour <= 23, 'hour phải trong 0..23');
    assert(leadDays.every((k) => k >= 1), 'mọi mốc nhắc phải >= 1 ngày');

    // Chỉ giữ mốc hết hạn, dạng số nguyên đã sắp xếp. Sau bước này bộ lập lịch
    // không còn quan tâm xe nào là xe nào — mỗi ngày chỉ cần đếm, và đếm trên
    // một mảng đã sắp là hai phép tìm nhị phân.
    final ends = <int>[];
    for (final v in vehicles) {
      final end = v.currentPeriodEnd;
      if (!v.isActive || end == null) continue;
      ends.add(end.epochDay);
    }
    ends.sort();

    // Bản sao đã sắp tăng dần: mốc nhỏ nhất được xét trước để tin nhắn chọn
    // được cách diễn đạt khẩn thiết nhất. Sắp trên bản sao vì danh sách của lời
    // gọi không phải của ta.
    final leads = List<int>.of(leadDays)..sort();

    final skipToday =
        skipTodayIfHourPassed && currentHour != null && currentHour >= hour;

    final entries = <DigestEntry>[];
    for (var i = 0; i < windowDays; i++) {
      final date = today.addDays(i);
      if (i == 0 && skipToday) continue;

      final dayNum = date.epochDay;

      // Mốc kết thúc là LOẠI TRỪ: xe có periodEnd đúng bằng ngày này đã hết
      // hạn, nên phép đếm là `<= dayNum`, không phải `< dayNum`.
      final expiredCount = _countAtMost(ends, dayNum);

      var expiringCount = 0;
      var chosenLead = 0;
      for (final k in leads) {
        // Nửa khoảng mở-đóng: D < periodEnd <= D + k. Cận dưới mở để không đếm
        // trùng xe đã tính vào expiredCount.
        final n = _countAtMost(ends, dayNum + k) - expiredCount;
        if (n > 0) {
          expiringCount = n;
          chosenLead = k;
          break;
        }
      }

      // Ngày trắng thì không đặt thông báo. Đây là thứ kéo một cửa sổ 30 ngày
      // xuống còn 5–15 dòng, thoải mái dưới trần 64 thông báo chờ của iOS.
      if (expiringCount == 0 && expiredCount == 0) continue;

      final lines = <String>[];
      if (expiringCount > 0) {
        lines.add('Có $expiringCount xe sẽ hết hạn trong vòng $chosenLead ngày.');
      }
      if (expiredCount > 0) {
        lines.add('Có $expiredCount xe đã hết hạn thanh toán.');
      }
      lines.add(callToAction);

      entries.add(DigestEntry(
        date: date,
        hour: hour,
        title: title,
        body: lines.join('\n'),
        payload: jsonEncode({'t': 'digest', 'd': date.iso}),
        expiringCount: expiringCount,
        expiredCount: expiredCount,
        leadDays: chosenLead,
      ));
    }

    return DigestPlan(entries: entries, hash: _hashOf(entries));
  }

  /// Số phần tử của [sorted] nhỏ hơn hoặc bằng [value].
  ///
  /// `lowerBound` trả về vị trí đầu tiên có giá trị `>= value + 1`, cũng chính
  /// là số phần tử `<= value`.
  static int _countAtMost(List<int> sorted, int value) =>
      lowerBound(sorted, value + 1);

  /// Băm ổn định của kế hoạch.
  ///
  /// Gộp cả [DigestEntry.hour] chứ không chỉ ngày/tiêu đề/nội dung như cách
  /// diễn đạt gọn thường thấy: nếu người dùng đổi giờ nhắc từ 8h sang 20h mà
  /// danh sách xe không đổi, kế hoạch **đã khác** và bắt buộc phải đặt lại
  /// lịch. Băm bỏ qua giờ sẽ khiến thay đổi đó âm thầm không có tác dụng.
  ///
  /// [DigestEntry.payload] và các con số không cần đưa vào vì đều là hàm của
  /// ngày và nội dung — thêm chúng chỉ làm chuỗi dài hơn chứ không phân biệt
  /// thêm được kế hoạch nào.
  static String _hashOf(List<DigestEntry> entries) {
    final buf = StringBuffer();
    for (final e in entries) {
      buf
        ..write(e.date.iso)
        ..write('|')
        ..write(e.hour)
        ..write('|')
        ..write(e.title)
        ..write('|')
        ..write(e.body)
        ..write('\n');
    }
    return sha256.convert(utf8.encode(buf.toString())).toString();
  }
}
