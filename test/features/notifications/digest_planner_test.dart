import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/time/date_math.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/features/notifications/domain/digest_plan.dart';
import 'package:quan_ly_bai_xe/src/features/notifications/domain/digest_planner.dart';

/// Ngày neo cho mọi kịch bản. Chọn cố định để test không bao giờ phụ thuộc
/// đồng hồ máy chạy test.
const homNay = Day(2026, 9, 7);

VehicleExpiry xe(int id, Day? hetHan, {bool conGui = true, int bai = 1}) =>
    VehicleExpiry(
      vehicleId: id,
      lotId: bai,
      currentPeriodEnd: hetHan,
      isActive: conGui,
    );

/// Danh sách [soLuong] xe cùng chung một ngày hết hạn.
List<VehicleExpiry> nhomXe(int soLuong, Day hetHan, {int tuId = 1}) =>
    List<VehicleExpiry>.generate(soLuong, (i) => xe(tuId + i, hetHan));

DigestPlan lapKeHoach(
  List<VehicleExpiry> xes, {
  Day today = homNay,
  int windowDays = DigestPlanner.defaultWindowDays,
  int hour = DigestPlanner.defaultHour,
  List<int> leadDays = DigestPlanner.defaultLeadDays,
  bool skipTodayIfHourPassed = false,
  int? currentHour,
}) =>
    const DigestPlanner().build(
      vehicles: xes,
      today: today,
      windowDays: windowDays,
      hour: hour,
      leadDays: leadDays,
      skipTodayIfHourPassed: skipTodayIfHourPassed,
      currentHour: currentHour,
    );

/// Mục thông báo của đúng ngày [d], hoặc `null` nếu ngày đó bị bỏ.
DigestEntry? mucNgay(DigestPlan plan, Day d) {
  for (final e in plan.entries) {
    if (e.date == d) return e;
  }
  return null;
}

void main() {
  group('Câu chữ đúng như đặc tả', () {
    test('5 xe sắp hết hạn trong 3 ngày cho ra đúng câu của đặc tả', () {
      // Không xe nào hết hạn vào ngày mai, nên mốc 1 ngày rỗng và mốc 3 ngày
      // là mốc nhỏ nhất còn đếm được.
      final xes = [
        ...nhomXe(3, homNay.addDays(2)),
        ...nhomXe(2, homNay.addDays(3), tuId: 10),
      ];

      final muc = mucNgay(lapKeHoach(xes), homNay)!;

      expect(muc.body, contains('Có 5 xe sẽ hết hạn trong vòng 3 ngày.'));
      expect(muc.expiringCount, 5);
      expect(muc.leadDays, 3);
      expect(muc.expiredCount, 0);
    });

    test('2 xe quá hạn cho ra đúng câu của đặc tả', () {
      final xes = [
        xe(1, homNay.addDays(-5)),
        xe(2, homNay),
      ];

      final muc = mucNgay(lapKeHoach(xes), homNay)!;

      expect(muc.body, contains('Có 2 xe đã hết hạn thanh toán.'));
      expect(muc.expiredCount, 2);
    });

    test('tiêu đề luôn là "Nhắc thu tiền bãi xe"', () {
      final plan = lapKeHoach([xe(1, homNay.addDays(2))]);

      expect(plan.entries, isNotEmpty);
      for (final e in plan.entries) {
        expect(e.title, 'Nhắc thu tiền bãi xe');
      }
    });

    test('mọi thông báo kết thúc bằng lời mời mở app', () {
      // Con số là ảnh chụp lúc đặt lịch chứ không phải số liệu trực tiếp, nên
      // nội dung không được tỏ ra là con số chính xác tuyệt đối.
      final plan = lapKeHoach([
        xe(1, homNay.addDays(-1)),
        xe(2, homNay.addDays(2)),
      ]);

      expect(plan.entries, isNotEmpty);
      for (final e in plan.entries) {
        expect(e.body, endsWith('Mở app để xem danh sách.'));
      }
    });

    test('cả hai dòng cùng xuất hiện, sắp hết hạn đứng trước quá hạn', () {
      final xes = [
        ...nhomXe(2, homNay.addDays(-3)),
        ...nhomXe(5, homNay.addDays(2), tuId: 10),
      ];

      final muc = mucNgay(lapKeHoach(xes), homNay)!;

      expect(muc.body, '''
Có 5 xe sẽ hết hạn trong vòng 3 ngày.
Có 2 xe đã hết hạn thanh toán.
Mở app để xem danh sách.''');
    });
  });

  group('Chọn mốc nhắc nhỏ nhất còn đếm được', () {
    test('có xe hết hạn ngày mai thì nói "1 ngày", không nói "7 ngày"', () {
      final xes = [
        xe(1, homNay.addDays(1)),
        ...nhomXe(4, homNay.addDays(6), tuId: 10),
      ];

      final muc = mucNgay(lapKeHoach(xes), homNay)!;

      expect(muc.leadDays, 1);
      expect(muc.expiringCount, 1);
      expect(muc.body, contains('Có 1 xe sẽ hết hạn trong vòng 1 ngày.'));
      expect(muc.body, isNot(contains('7 ngày')));
    });

    test('mốc 1 rỗng, mốc 3 rỗng thì tụt xuống mốc 7', () {
      final xes = nhomXe(4, homNay.addDays(6));

      final muc = mucNgay(lapKeHoach(xes), homNay)!;

      expect(muc.leadDays, 7);
      expect(muc.expiringCount, 4);
      expect(muc.body, contains('Có 4 xe sẽ hết hạn trong vòng 7 ngày.'));
    });

    test('thứ tự truyền leadDays không ảnh hưởng kết quả', () {
      final xes = [
        xe(1, homNay.addDays(1)),
        xe(2, homNay.addDays(5)),
      ];

      final tang = lapKeHoach(xes, leadDays: [1, 3, 7]);
      final giam = lapKeHoach(xes, leadDays: [7, 3, 1]);
      final loanXa = lapKeHoach(xes, leadDays: [3, 7, 1]);

      expect(tang.hash, giam.hash);
      expect(tang.hash, loanXa.hash);
      expect(mucNgay(tang, homNay)!.leadDays, 1);
    });

    test('leadDays truyền vào không bị sắp xếp tại chỗ', () {
      final gocLeadDays = [7, 3, 1];

      lapKeHoach([xe(1, homNay.addDays(2))], leadDays: gocLeadDays);

      expect(gocLeadDays, [7, 3, 1]);
    });

    test('xe nằm ngoài mọi mốc nhắc thì ngày đó không có thông báo', () {
      // Hết hạn sau 8 ngày: xa hơn mốc lớn nhất (7) nên hôm nay chưa nhắc.
      final plan = lapKeHoach([xe(1, homNay.addDays(8))]);

      expect(mucNgay(plan, homNay), isNull);
      expect(mucNgay(plan, homNay.addDays(1)), isNotNull);
    });
  });

  group('Mốc kết thúc là LOẠI TRỪ', () {
    test('xe có periodEnd đúng bằng D là ĐÃ hết hạn, không phải sắp hết hạn',
        () {
      final muc = mucNgay(lapKeHoach([xe(1, homNay)]), homNay)!;

      expect(muc.expiredCount, 1);
      expect(muc.expiringCount, 0);
      expect(muc.leadDays, 0);
      expect(muc.body, contains('Có 1 xe đã hết hạn thanh toán.'));
      expect(muc.body, isNot(contains('sẽ hết hạn trong vòng')));
    });

    test('ví dụ đặc tả: đóng 3 tháng từ 01/08/2026 thì 01/11 đã hết hạn', () {
      final hetHan = periodEndFor(
        periodStart: const Day(2026, 8, 1),
        months: 3,
        anchorDay: 1,
      );
      expect(hetHan, const Day(2026, 11, 1));

      final xes = [xe(1, hetHan)];

      // 31/10: chưa hết hạn, còn đúng 1 ngày.
      final truoc = mucNgay(
        lapKeHoach(xes, today: const Day(2026, 10, 31)),
        const Day(2026, 10, 31),
      )!;
      expect(truoc.expiredCount, 0);
      expect(truoc.expiringCount, 1);
      expect(truoc.leadDays, 1);

      // 01/11: đã hết hạn.
      final dung = mucNgay(
        lapKeHoach(xes, today: const Day(2026, 11, 1)),
        const Day(2026, 11, 1),
      )!;
      expect(dung.expiredCount, 1);
      expect(dung.expiringCount, 0);
    });

    test('xe hết hạn đúng D + k được tính là sắp hết hạn trong k ngày', () {
      final muc = mucNgay(
        lapKeHoach([xe(1, homNay.addDays(3))], leadDays: [3]),
        homNay,
      )!;

      expect(muc.expiringCount, 1);
      expect(muc.leadDays, 3);
    });

    test('một xe không bao giờ bị đếm hai lần trong cùng một ngày', () {
      // Xe quá hạn phải nằm ngoài phép đếm "sắp hết hạn" vì cận dưới là mở.
      final muc = mucNgay(lapKeHoach([xe(1, homNay.addDays(-2))]), homNay)!;

      expect(muc.expiredCount, 1);
      expect(muc.expiringCount, 0);
    });
  });

  group('Lọc xe không liên quan', () {
    test('xe đã rời bãi (isActive == false) bị loại hoàn toàn', () {
      final plan = lapKeHoach([
        xe(1, homNay.addDays(2), conGui: false),
        xe(2, homNay.addDays(-2), conGui: false),
      ]);

      expect(plan.entries, isEmpty);
    });

    test('xe chưa đóng tiền lần nào (periodEnd == null) bị loại hoàn toàn', () {
      final plan = lapKeHoach([xe(1, null), xe(2, null)]);

      expect(plan.entries, isEmpty);
    });

    test('chỉ đếm xe còn gửi, lẫn lộn xe đã rời không làm sai con số', () {
      final xes = [
        ...nhomXe(5, homNay.addDays(2)),
        ...nhomXe(3, homNay.addDays(2), tuId: 100)
            .map((v) => v.copyWith(isActive: false)),
        xe(200, null),
      ];

      final muc = mucNgay(lapKeHoach(xes), homNay)!;

      expect(muc.expiringCount, 5);
      expect(muc.body, contains('Có 5 xe sẽ hết hạn trong vòng 3 ngày.'));
    });

    test('danh sách xe rỗng cho kế hoạch rỗng, không ném lỗi', () {
      final plan = lapKeHoach([]);

      expect(plan.entries, isEmpty);
      expect(plan.isEmpty, isTrue);
      expect(plan.hash, isNotEmpty);
    });
  });

  group('Bỏ ngày trắng và giới hạn số lượng', () {
    test('ngày không có gì để nhắc thì không sinh entry', () {
      // Một xe hết hạn 01/10. Nhắc bắt đầu từ 24/09 (mốc 7 ngày), quá hạn từ
      // 01/10. Toàn bộ 07/09–23/09 là ngày trắng.
      final plan = lapKeHoach([xe(1, const Day(2026, 10, 1))]);

      expect(mucNgay(plan, const Day(2026, 9, 23)), isNull);
      expect(mucNgay(plan, const Day(2026, 9, 24)), isNotNull);
      expect(plan.entries.first.date, const Day(2026, 9, 24));
      // 24/09–30/09 nhắc trước (7 ngày) + 01/10–06/10 quá hạn (6 ngày).
      expect(plan.length, 13);
    });

    test('số entry không bao giờ vượt windowDays', () {
      // Mỗi ngày trong cửa sổ đều có xe hết hạn: trường hợp dày đặc nhất.
      final xes = List<VehicleExpiry>.generate(
        60,
        (i) => xe(i, homNay.addDays(i - 10)),
      );

      for (final w in [0, 1, 7, 30, 45]) {
        final plan = lapKeHoach(xes, windowDays: w);
        expect(plan.length, lessThanOrEqualTo(w), reason: 'windowDays = $w');
      }
    });

    test('cửa sổ 30 ngày với 200 xe rải đều vẫn <= 30 entry', () {
      final xes = List<VehicleExpiry>.generate(
        200,
        (i) => xe(i, homNay.addDays(i % 60 - 10)),
      );

      final plan = lapKeHoach(xes, windowDays: 30);

      expect(plan.length, lessThanOrEqualTo(30));
      // Dưới xa trần 64 thông báo chờ của iOS.
      expect(plan.length, lessThanOrEqualTo(64));
    });

    test('windowDays = 0 cho kế hoạch rỗng', () {
      final plan = lapKeHoach([xe(1, homNay)], windowDays: 0);

      expect(plan.entries, isEmpty);
    });

    test('entry luôn sắp xếp theo ngày tăng dần', () {
      final xes = List<VehicleExpiry>.generate(
        40,
        (i) => xe(i, homNay.addDays(i - 5)),
      );

      final plan = lapKeHoach(xes);

      expect(plan.entries, isNotEmpty);
      for (var i = 1; i < plan.length; i++) {
        expect(plan.entries[i - 1].date < plan.entries[i].date, isTrue);
      }
    });
  });

  group('Băm nội dung', () {
    test('cùng đầu vào cho cùng hash', () {
      final xes = [
        ...nhomXe(3, homNay.addDays(2)),
        xe(50, homNay.addDays(-1)),
      ];

      expect(lapKeHoach(xes).hash, lapKeHoach(xes).hash);
    });

    test('hai danh sách khác đối tượng nhưng cùng nội dung cho cùng hash', () {
      final a = [xe(1, homNay.addDays(2)), xe(2, homNay.addDays(-1))];
      final b = [xe(1, homNay.addDays(2)), xe(2, homNay.addDays(-1))];

      expect(lapKeHoach(a).hash, lapKeHoach(b).hash);
    });

    test('gia hạn một xe thì hash đổi', () {
      final truoc = lapKeHoach([xe(1, homNay.addDays(3))]);
      final sau = lapKeHoach([xe(1, homNay.addDays(10))]);

      expect(sau.hash, isNot(truoc.hash));
    });

    test('thêm một xe thì hash đổi', () {
      final truoc = lapKeHoach(nhomXe(3, homNay.addDays(2)));
      final sau = lapKeHoach(nhomXe(4, homNay.addDays(2)));

      expect(sau.hash, isNot(truoc.hash));
    });

    test('đổi giờ nhắc thì hash đổi', () {
      // Nếu bỏ qua giờ khi băm, người dùng đổi giờ nhắc sẽ bị bỏ qua lần đặt
      // lịch và thay đổi âm thầm không có tác dụng.
      final xes = [xe(1, homNay.addDays(2))];

      expect(lapKeHoach(xes, hour: 20).hash, isNot(lapKeHoach(xes, hour: 8).hash));
    });

    test('kế hoạch rỗng vẫn có hash ổn định', () {
      expect(lapKeHoach([]).hash, lapKeHoach([]).hash);
      expect(lapKeHoach([]).hash, hasLength(64));
    });
  });

  group('Payload và giờ bắn', () {
    test('payload là JSON deep-link đúng dạng đặc tả', () {
      final plan = lapKeHoach([xe(1, const Day(2026, 9, 20))]);
      final muc = mucNgay(plan, const Day(2026, 9, 14))!;

      expect(muc.payload, '{"t":"digest","d":"2026-09-14"}');
      final giaiMa = jsonDecode(muc.payload) as Map<String, dynamic>;
      expect(giaiMa['t'], 'digest');
      expect(giaiMa['d'], '2026-09-14');
    });

    test('giờ bắn được gắn vào mọi entry', () {
      final plan = lapKeHoach([xe(1, homNay.addDays(2))], hour: 19);

      expect(plan.entries, isNotEmpty);
      for (final e in plan.entries) {
        expect(e.hour, 19);
      }
    });
  });

  group('Bỏ hôm nay khi giờ nhắc đã trôi qua', () {
    List<VehicleExpiry> xesCoNhac() => nhomXe(2, homNay.addDays(2));

    test('giờ hiện tại đã qua giờ nhắc thì bỏ hôm nay', () {
      final plan = lapKeHoach(
        xesCoNhac(),
        hour: 8,
        skipTodayIfHourPassed: true,
        currentHour: 9,
      );

      expect(mucNgay(plan, homNay), isNull);
      expect(plan.entries.first.date, homNay.addDays(1));
    });

    test('đúng giờ nhắc cũng coi là đã trôi qua', () {
      final plan = lapKeHoach(
        xesCoNhac(),
        hour: 8,
        skipTodayIfHourPassed: true,
        currentHour: 8,
      );

      expect(mucNgay(plan, homNay), isNull);
    });

    test('chưa tới giờ nhắc thì vẫn giữ hôm nay', () {
      final plan = lapKeHoach(
        xesCoNhac(),
        hour: 8,
        skipTodayIfHourPassed: true,
        currentHour: 7,
      );

      expect(mucNgay(plan, homNay), isNotNull);
    });

    test('không biết giờ hiện tại thì không bỏ ngày nào', () {
      final plan = lapKeHoach(
        xesCoNhac(),
        hour: 8,
        skipTodayIfHourPassed: true,
      );

      expect(mucNgay(plan, homNay), isNotNull);
    });

    test('tắt cờ thì giữ hôm nay dù đã quá giờ', () {
      final plan = lapKeHoach(
        xesCoNhac(),
        hour: 8,
        currentHour: 23,
      );

      expect(mucNgay(plan, homNay), isNotNull);
    });

    test('bỏ hôm nay chỉ bỏ đúng hôm nay, các ngày sau giữ nguyên', () {
      final xes = xesCoNhac();
      final day = lapKeHoach(xes);
      final khongHomNay = lapKeHoach(
        xes,
        skipTodayIfHourPassed: true,
        currentHour: 20,
      );

      expect(khongHomNay.length, day.length - 1);
      expect(khongHomNay.entries, day.entries.skip(1).toList());
    });
  });
}
