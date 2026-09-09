import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/time/date_math.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';

void main() {
  group('daysInMonth', () {
    test('tháng 2 năm thường có 28 ngày', () {
      expect(daysInMonth(2026, 2), 28);
      expect(daysInMonth(2027, 2), 28);
    });

    test('tháng 2 năm nhuận có 29 ngày', () {
      expect(daysInMonth(2024, 2), 29);
      expect(daysInMonth(2028, 2), 29);
    });

    test('năm chia hết 100 nhưng không chia hết 400 KHÔNG nhuận', () {
      expect(daysInMonth(1900, 2), 28);
      expect(daysInMonth(2000, 2), 29);
    });

    test('các tháng 30 và 31 ngày', () {
      expect(daysInMonth(2026, 1), 31);
      expect(daysInMonth(2026, 4), 30);
      expect(daysInMonth(2026, 12), 31);
    });
  });

  group('addMonthsClamped — kẹp ngày cuối tháng', () {
    test('ví dụ trong đặc tả: 01/08/2026 + 1, 2, 3 tháng', () {
      const start = Day(2026, 8, 1);
      expect(addMonthsClamped(start, 1), const Day(2026, 9, 1));
      expect(addMonthsClamped(start, 2), const Day(2026, 10, 1));
      expect(addMonthsClamped(start, 3), const Day(2026, 11, 1));
    });

    test('31/01 + 1 tháng kẹp về 28/02, KHÔNG tràn sang 03/03', () {
      expect(addMonthsClamped(const Day(2026, 1, 31), 1), const Day(2026, 2, 28));
    });

    test('31/01 + 1 tháng vào năm nhuận kẹp về 29/02', () {
      expect(addMonthsClamped(const Day(2028, 1, 31), 1), const Day(2028, 2, 29));
    });

    test('31/03 + 1 tháng kẹp về 30/04', () {
      expect(addMonthsClamped(const Day(2026, 3, 31), 1), const Day(2026, 4, 30));
    });

    test('29/02 năm nhuận + 12 tháng kẹp về 28/02 năm thường', () {
      expect(addMonthsClamped(const Day(2028, 2, 29), 12), const Day(2029, 2, 28));
    });

    test('vượt qua mốc cuối năm', () {
      expect(addMonthsClamped(const Day(2026, 11, 30), 3), const Day(2027, 2, 28));
      expect(addMonthsClamped(const Day(2026, 12, 31), 1), const Day(2027, 1, 31));
    });

    test('cộng 0 tháng giữ nguyên', () {
      expect(addMonthsClamped(const Day(2026, 1, 31), 0), const Day(2026, 1, 31));
    });

    test('cộng số tháng lớn', () {
      expect(addMonthsClamped(const Day(2026, 8, 1), 12), const Day(2027, 8, 1));
      expect(addMonthsClamped(const Day(2026, 8, 1), 120), const Day(2036, 8, 1));
    });

    test('KHÔNG có tính kết hợp — đây là lý do phải tính một lần', () {
      const start = Day(2026, 1, 31);
      final chained = addMonthsClamped(addMonthsClamped(start, 1), 1);
      final direct = addMonthsClamped(start, 2);
      expect(chained, const Day(2026, 3, 28), reason: 'cộng dồn thì kẹp dính lại');
      expect(direct, const Day(2026, 3, 31), reason: 'cộng một lần thì đúng');
      expect(chained, isNot(direct));
    });
  });

  group('periodEndFor — mốc kết thúc loại trừ, neo theo anchorDay', () {
    test('ví dụ đặc tả: bắt đầu 01/08/2026 đóng 3 tháng → hết hạn 01/11/2026', () {
      expect(
        periodEndFor(periodStart: const Day(2026, 8, 1), months: 3, anchorDay: 1),
        const Day(2026, 11, 1),
      );
    });

    test('đóng 1 / 2 / 3 tháng khớp đúng ba dòng ví dụ của đặc tả', () {
      const start = Day(2026, 8, 1);
      expect(periodEndFor(periodStart: start, months: 1, anchorDay: 1),
          const Day(2026, 9, 1));
      expect(periodEndFor(periodStart: start, months: 2, anchorDay: 1),
          const Day(2026, 10, 1));
      expect(periodEndFor(periodStart: start, months: 3, anchorDay: 1),
          const Day(2026, 11, 1));
    });

    test('anchorDay giúp hồi phục sau khi bị kẹp bởi tháng 2', () {
      // Xe bắt đầu ngày 31/12, gia hạn từng tháng một.
      const anchor = 31;
      final e1 = periodEndFor(
          periodStart: const Day(2026, 12, 31), months: 1, anchorDay: anchor);
      expect(e1, const Day(2027, 1, 31));

      final e2 = periodEndFor(periodStart: e1, months: 1, anchorDay: anchor);
      expect(e2, const Day(2027, 2, 28), reason: 'tháng 2 buộc phải kẹp');

      final e3 = periodEndFor(periodStart: e2, months: 1, anchorDay: anchor);
      expect(e3, const Day(2027, 3, 31),
          reason: 'phải HỒI PHỤC về ngày 31, không được dính ở 28');
    });

    test('không neo thì kẹp sẽ dính vĩnh viễn — minh hoạ lỗi đang tránh', () {
      final e2 = addMonthsClamped(
          addMonthsClamped(const Day(2026, 12, 31), 1), 1); // 28/02
      final e3Sai = addMonthsClamped(e2, 1);
      expect(e3Sai, const Day(2027, 3, 28), reason: 'dính ở ngày 28 — sai');
    });

    test('nối kỳ liền mạch: periodStart lần sau chính là periodEnd lần trước', () {
      const anchor = 15;
      final k1 = periodEndFor(
          periodStart: const Day(2026, 8, 15), months: 3, anchorDay: anchor);
      expect(k1, const Day(2026, 11, 15));
      final k2 = periodEndFor(periodStart: k1, months: 6, anchorDay: anchor);
      expect(k2, const Day(2027, 5, 15));
    });
  });

  group('daysRemaining / isExpired', () {
    test('còn hạn thì dương', () {
      expect(daysRemaining(const Day(2026, 8, 1), const Day(2026, 8, 10)), 9);
    });

    test('đúng ngày hết hạn thì bằng 0 và ĐÃ tính là hết hạn', () {
      const d = Day(2026, 11, 1);
      expect(daysRemaining(d, d), 0);
      expect(isExpired(d, d), isTrue, reason: 'mốc kết thúc là loại trừ');
    });

    test('quá hạn thì âm', () {
      expect(daysRemaining(const Day(2026, 11, 6), const Day(2026, 11, 1)), -5);
      expect(isExpired(const Day(2026, 11, 6), const Day(2026, 11, 1)), isTrue);
    });

    test('chưa tới hạn thì chưa hết hạn', () {
      expect(isExpired(const Day(2026, 10, 31), const Day(2026, 11, 1)), isFalse);
    });

    test('đếm đúng qua mốc cuối năm', () {
      expect(daysRemaining(const Day(2026, 12, 28), const Day(2027, 1, 3)), 6);
    });
  });

  group('Day', () {
    test('epochDay tại mốc gốc', () {
      expect(const Day(1970, 1, 1).epochDay, 0);
      expect(const Day(1970, 1, 2).epochDay, 1);
    });

    test('iso và parseIso đối xứng', () {
      const d = Day(2026, 8, 1);
      expect(d.iso, '2026-08-01');
      expect(Day.parseIso(d.iso), d);
    });

    test('addDays vượt biên tháng và năm', () {
      expect(const Day(2026, 1, 31).addDays(1), const Day(2026, 2, 1));
      expect(const Day(2026, 12, 31).addDays(1), const Day(2027, 1, 1));
      expect(const Day(2026, 3, 1).addDays(-1), const Day(2026, 2, 28));
    });

    test('so sánh và sắp xếp', () {
      final list = [
        const Day(2026, 12, 1),
        const Day(2026, 1, 31),
        const Day(2027, 1, 1),
      ]..sort();
      expect(list, [
        const Day(2026, 1, 31),
        const Day(2026, 12, 1),
        const Day(2027, 1, 1),
      ]);
      expect(const Day(2026, 1, 1) < const Day(2026, 1, 2), isTrue);
    });

    test('utcMidnight lưu đúng nửa đêm UTC', () {
      final u = const Day(2026, 8, 1).utcMidnight;
      expect(u.isUtc, isTrue);
      expect(u.hour, 0);
      expect(Day.fromUtcMidnight(u), const Day(2026, 8, 1));
    });
  });
}
