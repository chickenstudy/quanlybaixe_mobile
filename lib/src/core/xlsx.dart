/// File DUY NHẤT nhắc tên gói xlsx.
///
/// Đặc tả ghi gói `excel`, nhưng bản 4.0.6 đã hai năm không cập nhật và ghim
/// `archive ^3.6.1` cùng `xml <7.0.0`. Đó là ràng buộc **bắc cầu** — nó kìm cả
/// cây phụ thuộc và sớm muộn làm kẹt `pub upgrade`. `excel_plus` tương thích
/// mã nguồn gần như tuyệt đối, chỉ khác đúng dòng import này.
///
/// Cô lập ở một chỗ để đổi lại chỉ mất một dòng.
library;

export 'package:excel_plus/excel_plus.dart';
