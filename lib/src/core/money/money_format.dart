/// Định dạng tiền Việt để **hiển thị**.
///
/// Toàn bộ tiền trong ứng dụng là `int` **đồng**, không bao giờ là `double`.
/// Đồng là đơn vị nhỏ nhất của tiền Việt (không có xu), nên số nguyên biểu diễn
/// tiền một cách chính xác tuyệt đối. Dùng `double` sẽ kéo theo sai số nhị phân
/// vào cộng dồn doanh thu — `0.1 + 0.2 != 0.3` — và tới cuối tháng báo cáo lệch
/// vài đồng mà không ai truy được nguồn.
///
/// Không cần `initializeDateFormatting` hay bất kỳ khởi tạo bất đồng bộ nào:
/// bảng ký hiệu số của `intl` là dữ liệu Dart biên dịch sẵn, nên
/// `NumberFormat.decimalPattern('vi')` dùng được ngay từ dòng đầu của `main`.
library;

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Ký hiệu đồng Việt Nam (U+20AB).
const String kVndSymbol = '₫';

const int _codeZero = 0x30;
const int _codeNine = 0x39;

const int _thousand = 1000;
const int _million = 1000 * _thousand;
const int _billion = 1000 * _million;

/// Bộ nhóm nghìn theo quy ước Việt Nam: `GROUP_SEP` là dấu chấm,
/// `DECIMAL_SEP` là dấu phẩy. Tạo một lần vì `NumberFormat` không rẻ và không
/// giữ trạng thái giữa các lần `format`.
final NumberFormat _viGrouped = NumberFormat.decimalPattern('vi');

/// `1234567` → `"1.234.567 ₫"` · `-50000` → `"-50.000 ₫"` · `0` → `"0 ₫"`.
///
/// Đặt [symbol] thành `false` khi ký hiệu đã nằm ở nhãn cột hoặc hậu tố ô nhập
/// liệu, lúc đó lặp lại `₫` trên từng dòng chỉ làm bảng số rối.
String formatVnd(int amount, {bool symbol = true}) {
  final digits = _viGrouped.format(amount);
  return symbol ? '$digits $kVndSymbol' : digits;
}

/// Như [formatVnd] nhưng **luôn có dấu**: `"+1.200.000 ₫"` / `"-800.000 ₫"`.
///
/// Dành riêng cho ô lãi/lỗ và chênh lệch so với kỳ trước, nơi bản thân dấu là
/// thông tin chính. Số `0` không mang dấu.
String formatVndSigned(int amount, {bool symbol = true}) {
  if (amount == 0) return formatVnd(0, symbol: symbol);
  final body = formatVnd(amount.abs(), symbol: symbol);
  return amount > 0 ? '+$body' : '-$body';
}

/// Dạng rút gọn cho thẻ tổng quan và nhãn trục biểu đồ — nơi không đủ chỗ cho
/// số đầy đủ.
///
/// ```
/// formatVndCompact(999)        == '999'
/// formatVndCompact(500000)     == '500 ng'
/// formatVndCompact(1234567)    == '1,23 tr'
/// formatVndCompact(1050000000) == '1,05 tỷ'
/// formatVndCompact(-2500000)   == '-2,5 tr'
/// ```
///
/// Quy ước: dấu phẩy là dấu thập phân (kiểu Việt), tối đa hai chữ số lẻ, cắt bỏ
/// số 0 thừa ở cuối phần lẻ. Dưới 1.000 đồng thì hiện nguyên số vì rút gọn
/// không tiết kiệm được ký tự nào.
///
/// **Không dùng cho số tiền cần đối chiếu.** Đây là con số đã làm tròn; hoá
/// đơn, biên lai và bảng chi tiết luôn phải gọi [formatVnd].
String formatVndCompact(int amount) {
  final negative = amount < 0;
  final abs = negative ? -amount : amount;

  if (abs < _thousand) return negative ? '-$abs' : '$abs';

  var unit = abs >= _billion
      ? _billion
      : abs >= _million
          ? _million
          : _thousand;
  var hundredths = _roundToHundredths(abs, unit);

  // Làm tròn có thể đẩy giá trị tràn sang đơn vị lớn hơn: 999.999 đồng làm
  // tròn hai chữ số lẻ ra 1.000,00 nghìn — phải hiện "1 tr", không phải
  // "1.000 ng".
  if (hundredths >= 1000 * 100 && unit != _billion) {
    unit = unit == _thousand ? _million : _billion;
    hundredths = _roundToHundredths(abs, unit);
  }

  final whole = hundredths ~/ 100;
  final fraction = hundredths % 100;

  final out = StringBuffer();
  if (negative) out.write('-');
  out.write(_viGrouped.format(whole));
  if (fraction != 0) {
    out.write(',');
    // 50 phần trăm đơn vị viết là ",5" chứ không phải ",50".
    out.write(fraction % 10 == 0
        ? '${fraction ~/ 10}'
        : fraction.toString().padLeft(2, '0'));
  }
  out.write(' ');
  out.write(unit == _billion
      ? 'tỷ'
      : unit == _million
          ? 'tr'
          : 'ng');
  return out.toString();
}

/// [value] quy ra phần trăm của [unit], làm tròn nửa lên.
///
/// Chia trước rồi mới cộng phần bù (`scale = unit ~/ 100`) thay vì nhân
/// `value * 100`, để số tiền lớn tới hàng triệu tỷ cũng không tràn `int` 64 bit.
int _roundToHundredths(int value, int unit) {
  final scale = unit ~/ 100;
  return (value + scale ~/ 2) ~/ scale;
}

bool _isDigit(int codeUnit) => codeUnit >= _codeZero && codeUnit <= _codeNine;

/// Chèn dấu chấm phân cách nghìn vào một chuỗi **chỉ gồm chữ số**.
String _groupDigits(String digits) {
  final n = digits.length;
  if (n <= 3) return digits;
  final head = n % 3 == 0 ? 3 : n % 3;
  final out = StringBuffer(digits.substring(0, head));
  for (var i = head; i < n; i += 3) {
    out
      ..write(VndInputFormatter.groupSeparator)
      ..write(digits.substring(i, i + 3));
  }
  return out.toString();
}

/// Nhóm nghìn ngay trong lúc người dùng gõ số tiền.
///
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: const [VndInputFormatter()],
/// )
/// // gõ 1 2 3 4 5 6 7  →  hiển thị 1.234.567
/// ```
///
/// Đọc lại giá trị bằng [parse]; **không bao giờ** gọi `int.parse` thẳng trên
/// text của ô nhập, vì text đã có dấu chấm.
///
/// ### Vì sao con trỏ phải tính lại chứ không giữ nguyên offset
///
/// Sửa số ở giữa chuỗi làm số dấu chấm thay đổi, nên offset cũ trỏ sai vị trí —
/// gõ thêm một chữ số vào `1.234` (con trỏ sau số 1) mà giữ nguyên offset sẽ
/// đẩy con trỏ nhảy lùi và ký tự tiếp theo rơi vào chỗ khác. Cách duy nhất
/// đúng là **neo con trỏ theo số lượng chữ số đứng trước nó**, một đại lượng
/// bất biến với việc thêm bớt dấu phân cách: đếm chữ số trước con trỏ ở chuỗi
/// vào, định dạng lại, rồi đặt con trỏ ngay sau chữ số thứ N của chuỗi ra.
class VndInputFormatter extends TextInputFormatter {
  const VndInputFormatter({this.allowNegative = false, this.maxDigits = 15});

  /// Cho phép gõ dấu trừ. Mặc định tắt: số tiền thu và chi đều nhập dương, dấu
  /// do nghiệp vụ quyết định chứ không do người dùng gõ.
  final bool allowNegative;

  /// Số chữ số tối đa. 15 chữ số ≈ 999 nghìn tỷ đồng, thừa sức cho một bãi xe
  /// và vẫn còn rất xa giới hạn `int` 64 bit nên [parse] không thể tràn.
  /// Ký tự gõ thêm khi đã chạm trần bị bỏ qua, ô nhập giữ nguyên giá trị cũ.
  final int maxDigits;

  static const String groupSeparator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    // `selection.end` là -1 khi giá trị được gán từ code chứ không do gõ phím.
    final caret =
        newValue.selection.end < 0 ? raw.length : newValue.selection.end;

    final negative = allowNegative && raw.contains('-');

    final collected = StringBuffer();
    var digitsBeforeCaret = 0;
    for (var i = 0; i < raw.length; i++) {
      final code = raw.codeUnitAt(i);
      if (_isDigit(code)) {
        collected.writeCharCode(code);
        if (i < caret) digitsBeforeCaret++;
      }
    }

    var digits = collected.toString();

    // Bỏ số 0 vô nghĩa ở đầu nhưng giữ lại đúng một chữ số, để gõ "0" rồi "5"
    // ra 5 chứ không ra 05, mà gõ mỗi "0" thì vẫn thấy 0.
    var dropped = 0;
    while (dropped < digits.length - 1 &&
        digits.codeUnitAt(dropped) == _codeZero) {
      dropped++;
    }
    digits = digits.substring(dropped);
    digitsBeforeCaret = (digitsBeforeCaret - dropped).clamp(0, digits.length);

    if (digits.isEmpty) {
      return negative
          ? const TextEditingValue(
              text: '-',
              selection: TextSelection.collapsed(offset: 1),
            )
          : const TextEditingValue(
              text: '',
              selection: TextSelection.collapsed(offset: 0),
            );
    }

    // Quá trần thì từ chối cả lần sửa, không cắt bớt — cắt bớt sẽ âm thầm làm
    // sai số tiền người dùng vừa dán vào.
    if (digits.length > maxDigits) return oldValue;

    final formatted = '${negative ? '-' : ''}${_groupDigits(digits)}';

    var offset = negative ? 1 : 0;
    if (digitsBeforeCaret > 0) {
      var seen = 0;
      for (var i = 0; i < formatted.length; i++) {
        if (_isDigit(formatted.codeUnitAt(i))) {
          seen++;
          if (seen == digitsBeforeCaret) {
            offset = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  /// Đọc lại số tiền từ text đã nhóm nghìn. `null` khi ô trống hoặc không có
  /// chữ số nào — gọi nơi dùng phân biệt được "chưa nhập" với "nhập số 0".
  ///
  /// ```
  /// VndInputFormatter.parse('1.234.567') == 1234567
  /// VndInputFormatter.parse('-50.000')   == -50000
  /// VndInputFormatter.parse('')          == null
  /// ```
  static int? parse(String text) {
    final digits = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final code = text.codeUnitAt(i);
      if (_isDigit(code)) digits.writeCharCode(code);
    }
    if (digits.isEmpty) return null;
    final value = int.tryParse(digits.toString());
    if (value == null) return null;
    return text.contains('-') ? -value : value;
  }

  /// Giá trị khởi tạo cho ô nhập khi sửa một bản ghi đã có.
  ///
  /// Không dùng [formatVnd] vì ô nhập không được chứa ký hiệu `₫`: người dùng
  /// xoá lùi sẽ đụng phải nó, và [parse] tuy bỏ qua được nhưng con trỏ thì không.
  static String toEditingText(int amount) {
    final negative = amount < 0;
    final abs = negative ? -amount : amount;
    return '${negative ? '-' : ''}${_groupDigits(abs.toString())}';
  }
}
