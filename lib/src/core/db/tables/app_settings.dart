import 'package:drift/drift.dart';

/// Cấu hình ứng dụng, dạng khoá–giá trị.
///
/// Khoá đang dùng:
/// - `revenue_mode` — `cash` | `accrual`
/// - `notify_enabled` — `true` | `false`
/// - `notify_hour` — giờ gửi thông báo, 0..23
/// - `notify_lead_days` — danh sách mốc nhắc, mặc định `7,3,1`
/// - `expiring_soon_days` — ngưỡng "sắp hết hạn" của dashboard
/// - `last_recurring_materialized_month` — mốc tối ưu của bộ sinh chi phí
/// - `notif_plan_hash` — băm kế hoạch thông báo, để bỏ qua lần đặt lịch thừa
/// - `last_backup_at` — để nhắc sao lưu
/// - `onboarding_done`
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
