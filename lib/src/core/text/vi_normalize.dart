/// Bảng gấp dấu tiếng Việt: mọi nguyên âm có dấu về nguyên âm trần, `đ` về `d`.
///
/// Viết tay thay vì dùng chuẩn hoá Unicode NFD rồi lọc dấu, vì `đ`/`Đ` không
/// phải là `d` + dấu phụ trong Unicode — nó là một ký tự riêng, nên cách NFD sẽ
/// bỏ sót đúng chữ cái phổ biến nhất trong họ tên người Việt.
const Map<String, String> _viFoldMap = {
  'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
  'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
  'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
  'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
  'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
  'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
  'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
  'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
  'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
  'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
  'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
  'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
  'đ': 'd',
};

/// Gấp dấu và hạ chữ thường để tìm kiếm không phân biệt dấu.
///
/// `viFold('Nguyễn Văn Đức') == 'nguyen van duc'`
///
/// Phải làm ở tầng Dart lúc **ghi** dữ liệu, kết quả lưu vào cột phụ có index,
/// chứ không làm lúc truy vấn: `COLLATE NOCASE` của SQLite chỉ xử lý ASCII, và
/// iOS không kèm sẵn ICU. Nếu gấp dấu lúc truy vấn thì mọi lần tìm kiếm là một
/// lần quét toàn bảng.
String viFold(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final ch in lower.split('')) {
    buffer.write(_viFoldMap[ch] ?? ch);
  }
  return buffer.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Chuẩn hoá biển số để so khớp và chống trùng: bỏ mọi ký tự không phải chữ
/// hoặc số, viết hoa.
///
/// `normalizePlate('59-A1 234.56') == '59A123456'`
///
/// Cần thiết vì cùng một biển số được người dùng gõ mỗi lúc một kiểu
/// (`59A1-234.56`, `59A123456`, `59-A1 23456`), mà chỉ số chống trùng và ô tìm
/// kiếm phải coi chúng là một.
String normalizePlate(String input) =>
    input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// Rút số điện thoại về chuỗi chữ số thuần, để tìm kiếm và để mở `tel:`.
///
/// `normalizePhone('0912 345 678') == '0912345678'`
/// `normalizePhone('+84 912 345 678') == '+84912345678'`
///
/// Giữ lại dấu `+` đứng đầu vì nó có nghĩa với số quốc tế.
String normalizePhone(String input) {
  final trimmed = input.trim();
  final hasPlus = trimmed.startsWith('+');
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  return hasPlus ? '+$digits' : digits;
}
