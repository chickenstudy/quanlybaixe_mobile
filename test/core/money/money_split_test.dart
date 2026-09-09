import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/money/money_split.dart';

void main() {
  group('splitAmount', () {
    test('ví dụ chuẩn: 100.000 chia 3 tháng', () {
      expect(splitAmount(100000, 3), [33334, 33333, 33333]);
    });

    test('chia hết thì mọi phần bằng nhau', () {
      expect(splitAmount(300000, 3), [100000, 100000, 100000]);
      expect(splitAmount(600000, 6), [100000, 100000, 100000, 100000, 100000, 100000]);
    });

    test('một phần thì trả nguyên số tiền', () {
      expect(splitAmount(250000, 1), [250000]);
    });

    test('số tiền 0', () {
      expect(splitAmount(0, 3), [0, 0, 0]);
    });

    test('dư dồn về đầu, không dồn về cuối', () {
      expect(splitAmount(10, 3), [4, 3, 3]);
      expect(splitAmount(1, 3), [1, 0, 0]);
      expect(splitAmount(2, 3), [1, 1, 0]);
    });

    test('BẤT BIẾN: tổng các phần luôn khớp tuyệt đối số tiền gốc', () {
      for (var total = 0; total <= 1000000; total += 7919) {
        for (var parts = 1; parts <= 24; parts++) {
          final split = splitAmount(total, parts);
          expect(split.length, parts,
              reason: 'sai số phần với total=$total parts=$parts');
          expect(split.reduce((a, b) => a + b), total,
              reason: 'tổng lệch với total=$total parts=$parts');
          expect(split.every((e) => e >= 0), isTrue,
              reason: 'có phần âm với total=$total parts=$parts');
        }
      }
    });

    test('chênh lệch giữa phần lớn nhất và nhỏ nhất không quá 1 đồng', () {
      for (var total = 1; total <= 100000; total += 997) {
        for (var parts = 1; parts <= 12; parts++) {
          final s = splitAmount(total, parts);
          final max = s.reduce((a, b) => a > b ? a : b);
          final min = s.reduce((a, b) => a < b ? a : b);
          expect(max - min, lessThanOrEqualTo(1),
              reason: 'phân bổ không đều với total=$total parts=$parts');
        }
      }
    });

    test('999.999 chia hết cho 7 nên không có dư', () {
      final s = splitAmount(999999, 7);
      expect(s.reduce((a, b) => a + b), 999999);
      expect(s, List.filled(7, 142857));
    });

    test('999.998 chia 7 thì dư 6 đồng, dồn vào 6 phần đầu', () {
      final s = splitAmount(999998, 7);
      expect(s.reduce((a, b) => a + b), 999998);
      expect(s, [142857, 142857, 142857, 142857, 142857, 142857, 142856]);
    });
  });
}
