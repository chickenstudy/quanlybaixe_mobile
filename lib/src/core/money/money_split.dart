/// Chia [total] đồng thành đúng [parts] phần nguyên, dồn phần dư về đầu.
///
/// Dùng để phân bổ một lần đóng tiền nhiều tháng ra từng tháng (chế độ doanh
/// thu phân bổ). Bất biến bắt buộc:
///
/// ```
/// result.length == parts
/// result.reduce((a, b) => a + b) == total   // khớp tuyệt đối, không lệch 1đ
/// ```
///
/// ```
/// splitAmount(100000, 3) == [33334, 33333, 33333]
/// ```
///
/// **Dồn dư về đầu chứ không về cuối**, vì hai lý do: ghi nhận doanh thu thiên
/// về tháng sớm nhất (thận trọng hơn về mặt kế toán), và nếu xe rời bãi giữa
/// chừng thì phần đã ghi nhận không bao giờ bị thiếu.
///
/// Tiền Việt không có đơn vị nhỏ hơn đồng nên đây là số nguyên chính xác, không
/// phải làm tròn xấp xỉ.
List<int> splitAmount(int total, int parts) {
  assert(parts > 0, 'Số phần phải > 0');
  assert(total >= 0, 'Số tiền không được âm');
  final base = total ~/ parts;
  final remainder = total % parts;
  return List<int>.generate(parts, (i) => i < remainder ? base + 1 : base);
}
