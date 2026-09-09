/// Chữ riêng của màn hình bãi xe.
///
/// Chỉ khai ở đây những câu **chưa có** trong `Strings`. Mọi thứ dùng chung
/// (nút Lưu/Huỷ/Xoá, nhãn "Tên bãi", "Sức chứa", câu xác nhận xoá có tên…) đều
/// lấy từ `Strings` để một ngày đổi cách xưng hô thì chỉ phải sửa một chỗ.
library;

abstract final class LotsStrings {
  /// Nhãn công tắc trong bảng sửa bãi. `Strings` chỉ có
  /// `expenseTemplateActive` ("Đang áp dụng") — đúng cho mẫu chi phí, sai nghĩa
  /// cho một bãi xe.
  static const String isActive = 'Đang hoạt động';

  /// Nói rõ tắt công tắc thì mất gì và KHÔNG mất gì — người dùng hay nhầm nó
  /// với xoá.
  static const String isActiveHint =
      'Tắt để bãi không hiện ra khi thêm xe mới. Xe và lịch sử cũ vẫn giữ nguyên.';

  /// Nhãn nhỏ trên thẻ bãi đã bị tắt.
  static const String inactive = 'Ngừng hoạt động';

  /// Chú thích ô sức chứa: giải thích hệ quả của việc để trống, vì tỷ lệ lấp
  /// đầy bị ẩn hoàn toàn khi không có sức chứa và người dùng sẽ tưởng là lỗi.
  static const String capacityHelp =
      'Để trống nếu chưa muốn theo dõi tỷ lệ lấp đầy.';

  /// Xe đăng ký rồi nhưng chưa đóng tiền lần nào.
  ///
  /// Tách hẳn khỏi "đã hết hạn": xe chưa từng có kỳ hạn thì không thể nói là
  /// hết hạn, và cách xử lý cũng khác — một bên là nhắc gia hạn, một bên là
  /// thu lần đầu.
  static String vehiclesNeverPaid(int count) => '\$count xe chưa thu';
}
