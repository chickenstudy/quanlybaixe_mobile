import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/format/vi_date_format.dart';
import 'package:quan_ly_bai_xe/src/core/time/date_math.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/core/time/year_month.dart';

void main() {
  group('formatDay', () {
    test('ví dụ chuẩn của đặc tả', () {
      expect(formatDay(const Day(2026, 8, 1)), '01/08/2026');
    });

    test('luôn đủ hai chữ số cho ngày và tháng', () {
      expect(formatDay(const Day(2026, 1, 5)), '05/01/2026');
      expect(formatDay(const Day(2026, 12, 31)), '31/12/2026');
      expect(formatDay(const Day(2028, 2, 29)), '29/02/2028');
    });

    test('năm dưới bốn chữ số vẫn đệm đủ 0', () {
      expect(formatDay(const Day(1, 1, 1)), '01/01/0001');
      expect(formatDay(const Day(999, 12, 9)), '09/12/0999');
    });

    test('không phụ thuộc khởi tạo locale — gọi được ngay lập tức', () {
      // Không có initializeDateFormatting nào chạy trước, mà vẫn không ném lỗi.
      expect(() => formatDay(const Day(2026, 8, 1)), returnsNormally);
    });
  });

  group('formatDayShort', () {
    test('bỏ phần năm', () {
      expect(formatDayShort(const Day(2026, 8, 1)), '01/08');
      expect(formatDayShort(const Day(2026, 12, 31)), '31/12');
    });

    test('là tiền tố đúng của formatDay', () {
      const d = Day(2026, 3, 7);
      expect(formatDay(d).startsWith(formatDayShort(d)), isTrue);
    });
  });

  group('formatMonth', () {
    test('ví dụ chuẩn của đặc tả', () {
      expect(formatMonth(const YearMonth(2026, 8)), 'Tháng 8/2026');
    });

    test('số tháng không đệm 0 — người Việt nói "tháng 8"', () {
      expect(formatMonth(const YearMonth(2026, 1)), 'Tháng 1/2026');
      expect(formatMonth(const YearMonth(2026, 12)), 'Tháng 12/2026');
    });

    test('nhận được YearMonth dựng từ Day', () {
      expect(
        formatMonth(YearMonth.fromDay(const Day(2026, 8, 15))),
        'Tháng 8/2026',
      );
    });

    test('nhận được YearMonth dựng từ khoá YYYY-MM của DB', () {
      expect(formatMonth(YearMonth.parse('2026-08')), 'Tháng 8/2026');
    });
  });

  group('formatQuarterKey', () {
    test('ví dụ chuẩn của đặc tả', () {
      expect(formatQuarterKey('2026-Q3'), 'Quý 3/2026');
    });

    test('đủ bốn quý', () {
      expect(formatQuarterKey('2026-Q1'), 'Quý 1/2026');
      expect(formatQuarterKey('2026-Q2'), 'Quý 2/2026');
      expect(formatQuarterKey('2026-Q3'), 'Quý 3/2026');
      expect(formatQuarterKey('2026-Q4'), 'Quý 4/2026');
    });

    test('chấp nhận chữ q thường', () {
      expect(formatQuarterKey('2026-q2'), 'Quý 2/2026');
    });

    test('khoá sai khuôn thì ném FormatException', () {
      expect(() => formatQuarterKey(''), throwsFormatException);
      expect(() => formatQuarterKey('2026-08'), throwsFormatException);
      expect(() => formatQuarterKey('2026-Q0'), throwsFormatException);
      expect(() => formatQuarterKey('2026-Q5'), throwsFormatException);
      expect(() => formatQuarterKey('2026-Q'), throwsFormatException);
      expect(() => formatQuarterKey('20xx-Q1'), throwsFormatException);
      expect(() => formatQuarterKey('2026-Q10'), throwsFormatException);
    });
  });

  group('formatYear', () {
    test('nhãn mốc năm', () {
      expect(formatYear(2026), 'Năm 2026');
    });
  });

  group('formatDaysRemaining', () {
    test('ba trường hợp của đặc tả', () {
      expect(formatDaysRemaining(3), 'còn 3 ngày');
      expect(formatDaysRemaining(0), 'hết hạn hôm nay');
      expect(formatDaysRemaining(-5), 'quá hạn 5 ngày');
    });

    test('một ngày viết như nhiều ngày — tiếng Việt không chia số nhiều', () {
      expect(formatDaysRemaining(1), 'còn 1 ngày');
      expect(formatDaysRemaining(-1), 'quá hạn 1 ngày');
    });

    test('số ngày lớn', () {
      expect(formatDaysRemaining(365), 'còn 365 ngày');
      expect(formatDaysRemaining(-365), 'quá hạn 365 ngày');
    });

    test('không bao giờ hiện dấu trừ cho vế quá hạn', () {
      for (var d = -400; d <= 400; d++) {
        expect(
          formatDaysRemaining(d).contains('-'),
          isFalse,
          reason: 'lọt dấu trừ với $d ngày',
        );
      }
    });

    test('ghép đúng với daysRemaining của date_math', () {
      const today = Day(2026, 8, 1);
      expect(
        formatDaysRemaining(daysRemaining(today, const Day(2026, 8, 4))),
        'còn 3 ngày',
      );
      expect(
        formatDaysRemaining(daysRemaining(today, const Day(2026, 8, 1))),
        'hết hạn hôm nay',
      );
      expect(
        formatDaysRemaining(daysRemaining(today, const Day(2026, 7, 27))),
        'quá hạn 5 ngày',
      );
    });
  });

  group('formatDateTime', () {
    test('ví dụ chuẩn của đặc tả', () {
      expect(formatDateTime(DateTime(2026, 8, 1, 14, 30)), '01/08/2026 14:30');
    });

    test('giờ 24 tiếng, đủ hai chữ số', () {
      expect(formatDateTime(DateTime(2026, 8, 1, 0, 0)), '01/08/2026 00:00');
      expect(formatDateTime(DateTime(2026, 8, 1, 9, 5)), '01/08/2026 09:05');
      expect(formatDateTime(DateTime(2026, 8, 1, 23, 59)), '01/08/2026 23:59');
    });

    test('giữ nguyên múi giờ của DateTime được truyền vào', () {
      final utc = DateTime.utc(2026, 8, 1, 14, 30);
      expect(formatDateTime(utc), '01/08/2026 14:30');
    });

    test('phần ngày trùng khớp với formatDay', () {
      final dt = DateTime(2026, 3, 7, 8, 9);
      expect(formatDateTime(dt).startsWith(formatDay(const Day(2026, 3, 7))),
          isTrue);
    });
  });

  group('formatTime', () {
    test('chỉ phần giờ phút', () {
      expect(formatTime(DateTime(2026, 8, 1, 14, 30)), '14:30');
      expect(formatTime(DateTime(2026, 8, 1, 7, 5)), '07:05');
    });
  });

  group('formatDayRange', () {
    test('dùng gạch nối dài để không lẫn với dấu trừ', () {
      expect(
        formatDayRange(const Day(2026, 8, 1), const Day(2026, 8, 31)),
        '01/08/2026 – 31/08/2026',
      );
    });
  });
}
