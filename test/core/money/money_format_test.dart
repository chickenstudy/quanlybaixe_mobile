import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/money/money_format.dart';

/// Mô phỏng một lần gõ phím: chèn [inserted] vào [before] tại vị trí con trỏ
/// [caret], rồi cho bộ định dạng xử lý.
TextEditingValue typeAt(
  VndInputFormatter f,
  String before,
  int caret,
  String inserted,
) {
  final oldValue = TextEditingValue(
    text: before,
    selection: TextSelection.collapsed(offset: caret),
  );
  final newValue = TextEditingValue(
    text: before.substring(0, caret) + inserted + before.substring(caret),
    selection: TextSelection.collapsed(offset: caret + inserted.length),
  );
  return f.formatEditUpdate(oldValue, newValue);
}

/// Mô phỏng một lần xoá lùi: xoá ký tự ngay trước con trỏ [caret].
TextEditingValue backspaceAt(VndInputFormatter f, String before, int caret) {
  final oldValue = TextEditingValue(
    text: before,
    selection: TextSelection.collapsed(offset: caret),
  );
  final newValue = TextEditingValue(
    text: before.substring(0, caret - 1) + before.substring(caret),
    selection: TextSelection.collapsed(offset: caret - 1),
  );
  return f.formatEditUpdate(oldValue, newValue);
}

void main() {
  group('formatVnd', () {
    test('nhóm nghìn bằng dấu chấm kiểu Việt', () {
      expect(formatVnd(1234567), '1.234.567 ₫');
      expect(formatVnd(1000), '1.000 ₫');
      expect(formatVnd(999), '999 ₫');
    });

    test('số 0', () {
      expect(formatVnd(0), '0 ₫');
      expect(formatVnd(0, symbol: false), '0');
    });

    test('bỏ ký hiệu khi symbol: false', () {
      expect(formatVnd(1234567, symbol: false), '1.234.567');
      expect(formatVnd(-50000, symbol: false), '-50.000');
    });

    test('số âm — khoản lỗ', () {
      expect(formatVnd(-50000), '-50.000 ₫');
      expect(formatVnd(-1), '-1 ₫');
      expect(formatVnd(-1234567890), '-1.234.567.890 ₫');
    });

    test('số rất lớn vẫn nhóm đúng từng ba chữ số', () {
      expect(formatVnd(1000000000000), '1.000.000.000.000 ₫');
      expect(formatVnd(999999999999999), '999.999.999.999.999 ₫');
      expect(formatVnd(9223372036854775807), '9.223.372.036.854.775.807 ₫');
    });

    test('mọi số dương đều có đúng một dấu chấm cho mỗi ba chữ số', () {
      for (var digits = 1; digits <= 15; digits++) {
        final value = int.parse('1' * digits);
        final text = formatVnd(value, symbol: false);
        expect(
          text.replaceAll('.', '').length,
          digits,
          reason: 'sai số chữ số với $digits chữ số',
        );
        expect(
          '.'.allMatches(text).length,
          (digits - 1) ~/ 3,
          reason: 'sai số dấu phân cách với $digits chữ số',
        );
      }
    });
  });

  group('formatVndSigned', () {
    test('luôn kèm dấu, trừ số 0', () {
      expect(formatVndSigned(1200000), '+1.200.000 ₫');
      expect(formatVndSigned(-800000), '-800.000 ₫');
      expect(formatVndSigned(0), '0 ₫');
    });
  });

  group('formatVndCompact', () {
    test('các ví dụ chuẩn của đặc tả', () {
      expect(formatVndCompact(1234567), '1,23 tr');
      expect(formatVndCompact(500000), '500 ng');
      expect(formatVndCompact(1050000000), '1,05 tỷ');
    });

    test('dưới một nghìn thì hiện nguyên số', () {
      expect(formatVndCompact(0), '0');
      expect(formatVndCompact(1), '1');
      expect(formatVndCompact(999), '999');
    });

    test('dùng dấu phẩy làm dấu thập phân, cắt số 0 thừa ở cuối', () {
      expect(formatVndCompact(1500000), '1,5 tr');
      expect(formatVndCompact(2000000), '2 tr');
      expect(formatVndCompact(1200), '1,2 ng');
      expect(formatVndCompact(1000), '1 ng');
    });

    test('làm tròn tràn đơn vị thì đôn lên đơn vị lớn hơn', () {
      // 999.999đ làm tròn hai chữ số lẻ ra 1.000,00 nghìn — phải là "1 tr".
      expect(formatVndCompact(999999), '1 tr');
      expect(formatVndCompact(999999999), '1 tỷ');
    });

    test('số âm', () {
      expect(formatVndCompact(-2500000), '-2,5 tr');
      expect(formatVndCompact(-999), '-999');
      expect(formatVndCompact(-1050000000), '-1,05 tỷ');
    });

    test('số rất lớn vẫn ở đơn vị tỷ và có nhóm nghìn', () {
      expect(formatVndCompact(1000000000000), '1.000 tỷ');
      expect(formatVndCompact(1234000000000000), '1.234.000 tỷ');
    });

    test('không bao giờ ném lỗi trên dải giá trị rộng', () {
      for (var v = 0; v < 2000000000; v += 7654321) {
        expect(() => formatVndCompact(v), returnsNormally);
        expect(() => formatVndCompact(-v), returnsNormally);
      }
    });
  });

  group('VndInputFormatter.parse', () {
    test('đọc lại số từ chuỗi đã nhóm nghìn', () {
      expect(VndInputFormatter.parse('1.234.567'), 1234567);
      expect(VndInputFormatter.parse('500.000'), 500000);
      expect(VndInputFormatter.parse('0'), 0);
    });

    test('bỏ qua ký hiệu tiền và khoảng trắng', () {
      expect(VndInputFormatter.parse('1.234.567 ₫'), 1234567);
      expect(VndInputFormatter.parse('  250.000  '), 250000);
    });

    test('số âm', () {
      expect(VndInputFormatter.parse('-50.000'), -50000);
      expect(VndInputFormatter.parse('-0'), 0);
    });

    test('chuỗi không có chữ số nào trả về null', () {
      expect(VndInputFormatter.parse(''), isNull);
      expect(VndInputFormatter.parse('   '), isNull);
      expect(VndInputFormatter.parse('₫'), isNull);
      expect(VndInputFormatter.parse('-'), isNull);
    });

    test('khứ hồi với toEditingText', () {
      for (final v in <int>[0, 1, 999, 1000, 1234567, -50000, 999999999999]) {
        expect(
          VndInputFormatter.parse(VndInputFormatter.toEditingText(v)),
          v,
          reason: 'khứ hồi sai với $v',
        );
      }
    });
  });

  group('VndInputFormatter — nhóm nghìn khi gõ', () {
    const f = VndInputFormatter();

    test('gõ lần lượt từng chữ số', () {
      var text = '';
      var caret = 0;
      const typed = '1234567';
      final expected = <String>[
        '1',
        '12',
        '123',
        '1.234',
        '12.345',
        '123.456',
        '1.234.567',
      ];
      for (var i = 0; i < typed.length; i++) {
        final result = typeAt(f, text, caret, typed[i]);
        expect(result.text, expected[i], reason: 'sai ở chữ số thứ ${i + 1}');
        // Gõ ở cuối thì con trỏ phải luôn ở cuối chuỗi.
        expect(result.selection.baseOffset, result.text.length);
        text = result.text;
        caret = result.selection.baseOffset;
      }
    });

    test('bỏ số 0 vô nghĩa ở đầu nhưng giữ lại một số 0', () {
      expect(typeAt(f, '', 0, '0').text, '0');
      expect(typeAt(f, '0', 1, '5').text, '5');
      expect(typeAt(f, '', 0, '000').text, '0');
      expect(typeAt(f, '', 0, '007').text, '7');
    });

    test('xoá hết thì ô trống, con trỏ về 0', () {
      final result = backspaceAt(f, '5', 1);
      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('dán cả chuỗi có dấu chấm sẵn', () {
      final result = typeAt(f, '', 0, '1.234.567');
      expect(result.text, '1.234.567');
      expect(result.selection.baseOffset, 9);
    });

    test('từ chối lần sửa vượt quá maxDigits, giữ nguyên giá trị cũ', () {
      const small = VndInputFormatter(maxDigits: 3);
      final result = typeAt(small, '123', 3, '4');
      expect(result.text, '123');
      expect(result.selection.baseOffset, 3);
    });
  });

  group('VndInputFormatter — vị trí con trỏ khi gõ ở giữa chuỗi', () {
    const f = VndInputFormatter();

    test('gõ ngay sau chữ số đầu của 1.234', () {
      // "1|.234" + "5" → "15.234", con trỏ phải nằm ngay sau số 5.
      final result = typeAt(f, '1.234', 1, '5');
      expect(result.text, '15.234');
      expect(result.selection.baseOffset, 2);
    });

    test('gõ giữa chuỗi làm sinh thêm một dấu chấm thì con trỏ dịch theo', () {
      // "123|.456" + "9" → "1.239.456": số chữ số trước con trỏ vẫn là 4.
      final result = typeAt(f, '123.456', 3, '9');
      expect(result.text, '1.239.456');
      expect(result.selection.baseOffset, 5);
      // Ký tự ngay trước con trỏ đúng là chữ số vừa gõ.
      expect(result.text[result.selection.baseOffset - 1], '9');
    });

    test('gõ ngay sau một dấu chấm', () {
      // "1.|234" + "9" → "19.234", con trỏ sau số 9.
      final result = typeAt(f, '1.234', 2, '9');
      expect(result.text, '19.234');
      expect(result.selection.baseOffset, 2);
      expect(result.text[result.selection.baseOffset - 1], '9');
    });

    test('gõ ở đầu chuỗi', () {
      final result = typeAt(f, '234.567', 0, '1');
      expect(result.text, '1.234.567');
      expect(result.selection.baseOffset, 1);
    });

    test('xoá lùi ở giữa chuỗi giữ đúng số chữ số đứng trước con trỏ', () {
      // "1.2|34.567" xoá số 2 → "134.567", con trỏ sau số 1.
      final result = backspaceAt(f, '1.234.567', 3);
      expect(result.text, '134.567');
      expect(result.selection.baseOffset, 1);
    });

    test('xoá lùi ngay sau dấu chấm chỉ xoá dấu chấm, chuỗi không đổi', () {
      // "1.|234" xoá dấu chấm → chuỗi vẫn là "1.234", con trỏ đứng yên sau số 1.
      final result = backspaceAt(f, '1.234', 2);
      expect(result.text, '1.234');
      expect(result.selection.baseOffset, 1);
    });

    test('BẤT BIẾN: con trỏ luôn nằm sau đúng số chữ số đã có trước nó', () {
      const text = '12.345.678';
      for (var caret = 0; caret <= text.length; caret++) {
        final digitsBefore =
            text.substring(0, caret).replaceAll('.', '').length;
        final result = typeAt(f, text, caret, '9');
        final actualDigitsBefore = result.text
            .substring(0, result.selection.baseOffset)
            .replaceAll('.', '')
            .length;
        expect(
          actualDigitsBefore,
          digitsBefore + 1,
          reason: 'con trỏ lệch khi gõ tại vị trí $caret',
        );
        expect(
          result.text[result.selection.baseOffset - 1],
          '9',
          reason: 'ký tự trước con trỏ không phải chữ số vừa gõ (vị trí $caret)',
        );
      }
    });

    test('BẤT BIẾN: giá trị đọc lại đúng bằng chuỗi chữ số sau khi chèn', () {
      const text = '12.345.678';
      for (var caret = 0; caret <= text.length; caret++) {
        final digits = text.replaceAll('.', '');
        final digitsBefore =
            text.substring(0, caret).replaceAll('.', '').length;
        final expected = int.parse(
          '${digits.substring(0, digitsBefore)}9'
          '${digits.substring(digitsBefore)}',
        );
        final result = typeAt(f, text, caret, '9');
        expect(
          VndInputFormatter.parse(result.text),
          expected,
          reason: 'sai giá trị khi chèn tại vị trí $caret',
        );
      }
    });
  });

  group('VndInputFormatter — số âm', () {
    test('mặc định không cho gõ dấu trừ', () {
      const f = VndInputFormatter();
      final result = typeAt(f, '', 0, '-50000');
      expect(result.text, '50.000');
      expect(VndInputFormatter.parse(result.text), 50000);
    });

    test('bật allowNegative thì giữ dấu trừ và con trỏ không rơi trước dấu', () {
      const f = VndInputFormatter(allowNegative: true);
      final result = typeAt(f, '', 0, '-50000');
      expect(result.text, '-50.000');
      expect(VndInputFormatter.parse(result.text), -50000);

      final onlyMinus = typeAt(f, '', 0, '-');
      expect(onlyMinus.text, '-');
      expect(onlyMinus.selection.baseOffset, 1);
    });
  });
}
