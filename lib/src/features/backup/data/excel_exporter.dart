import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/clock.dart';
import '../../../core/xlsx.dart';

/// Xuất toàn bộ dữ liệu ra Excel nhiều sheet (mục 9 đặc tả).
///
/// **Xuất một chiều, không nhập lại được.** Người dùng thường mặc định file
/// Excel thì nhập lại được, nên màn hình xuất phải nói rõ điều này và chỉ file
/// `.qlbx` mới dùng để khôi phục.
class ExcelExporter {
  ExcelExporter(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  Future<File> export({Directory? dir}) async {
    final book = Excel.createExcel();
    // createExcel tạo sẵn sheet "Sheet1"; đổi tên thành sheet đầu của mình rồi
    // dùng tiếp, tránh để lại một sheet trắng trong file bàn giao.
    book.rename(book.getDefaultSheet()!, _sOverview);

    await _overview(book);
    await _lots(book);
    await _vehicles(book);
    await _payments(book);
    await _allocations(book);
    await _expenses(book);
    await _templates(book);
    await _monthly(book);

    final bytes = book.encode();
    if (bytes == null) {
      throw const FileSystemException('Không tạo được file Excel');
    }
    final t = _clock.now();
    String p(int v) => v.toString().padLeft(2, '0');
    final file = File('${(dir ?? await getApplicationDocumentsDirectory()).path}'
        '/BaoCao_QuanLyBaiXe_${t.year}${p(t.month)}${p(t.day)}_'
        '${p(t.hour)}${p(t.minute)}.xlsx');
    await file.writeAsBytes(bytes);
    return file;
  }

  // Tên sheet phải <= 31 ký tự và không chứa [ ] : * ? / \
  static const _sOverview = 'Tong quan';
  static const _sLots = 'Bai xe';
  static const _sVehicles = 'Xe';
  static const _sPayments = 'Thanh toan';
  static const _sAlloc = 'Phan bo doanh thu';
  static const _sExpenses = 'Chi phi';
  static const _sTemplates = 'Chi phi co dinh';
  static const _sMonthly = 'Bao cao thang';

  void _header(Excel book, String sheet, List<String> cols) {
    book.appendRow(sheet, [for (final c in cols) TextCellValue(c)]);
  }

  Future<List<Map<String, Object?>>> _rows(String sql) async {
    final r = await _db.customSelect(sql).get();
    return [for (final x in r) x.data];
  }

  Future<void> _overview(Excel book) async {
    _header(book, _sOverview, ['Mục', 'Giá trị']);
    final t = _clock.now();
    book.appendRow(_sOverview,
        [TextCellValue('Ngày xuất'), DateTimeCellValue.fromDateTime(t)]);
    for (final (label, sql) in const [
      ('Số bãi xe', 'SELECT COUNT(*) c FROM lots WHERE deleted_at IS NULL'),
      ('Số xe đang gửi',
          'SELECT COUNT(*) c FROM vehicles WHERE deleted_at IS NULL AND status = 0'),
      ('Tổng đã thu',
          'SELECT COALESCE(SUM(amount),0) c FROM payments WHERE voided_at IS NULL'),
      ('Tổng chi phí',
          'SELECT COALESCE(SUM(amount),0) c FROM expenses WHERE deleted_at IS NULL'),
    ]) {
      final v = (await _rows(sql)).single['c'] as int;
      book.appendRow(_sOverview, [TextCellValue(label), IntCellValue(v)]);
    }
    book.appendRow(_sOverview, []);
    book.appendRow(_sOverview, [
      TextCellValue('Lưu ý'),
      TextCellValue('File Excel này chỉ để xem và in. '
          'Muốn khôi phục dữ liệu sang máy khác, hãy dùng file .qlbx.'),
    ]);
  }

  Future<void> _lots(Excel book) async {
    _header(book, _sLots, [
      'ID', 'Tên bãi', 'Địa chỉ', 'Sức chứa', 'Ghi chú', 'Đang hoạt động',
    ]);
    for (final r in await _rows(
        'SELECT * FROM lots WHERE deleted_at IS NULL ORDER BY sort_order, name')) {
      book.appendRow(_sLots, [
        IntCellValue(r['id'] as int),
        TextCellValue(r['name'] as String),
        TextCellValue((r['address'] as String?) ?? ''),
        r['capacity'] == null ? null : IntCellValue(r['capacity'] as int),
        TextCellValue((r['notes'] as String?) ?? ''),
        BoolCellValue((r['is_active'] as int) == 1),
      ]);
    }
  }

  Future<void> _vehicles(Excel book) async {
    _header(book, _sVehicles, [
      'ID', 'Bãi', 'Chủ xe', 'SĐT', 'Loại xe', 'Biển số', 'Giá/tháng',
      'Ngày bắt đầu', 'Ngày hết hạn', 'Số tháng đã đóng', 'Tổng đã thu',
      'Trạng thái', 'Ghi chú',
    ]);
    for (final r in await _rows('''
        SELECT v.*, l.name AS lot_name FROM vehicles v
        JOIN lots l ON l.id = v.lot_id
        WHERE v.deleted_at IS NULL ORDER BY l.name, v.plate''')) {
      book.appendRow(_sVehicles, [
        IntCellValue(r['id'] as int),
        TextCellValue(r['lot_name'] as String),
        TextCellValue(r['owner_name'] as String),
        TextCellValue((r['phone'] as String?) ?? ''),
        TextCellValue(
            vehicleTypeLabel(VehicleType.values[r['vehicle_type'] as int])),
        TextCellValue(r['plate'] as String),
        IntCellValue(r['monthly_price'] as int),
        _date(r['start_date']),
        _date(r['current_period_end']),
        IntCellValue(r['total_months_paid'] as int),
        IntCellValue(r['total_paid'] as int),
        TextCellValue(
            vehicleStatusLabel(VehicleStatus.values[r['status'] as int])),
        TextCellValue((r['notes'] as String?) ?? ''),
      ]);
    }
  }

  Future<void> _payments(Excel book) async {
    _header(book, _sPayments, [
      'ID', 'Bãi', 'Biển số', 'Chủ xe', 'Ngày thu', 'Số tháng', 'Đơn giá',
      'Số tiền', 'Từ ngày', 'Đến ngày', 'Hình thức', 'Ghi chú', 'Đã huỷ',
    ]);
    for (final r in await _rows('''
        SELECT p.*, l.name AS lot_name, v.plate, v.owner_name
        FROM payments p
        JOIN lots l ON l.id = p.lot_id
        JOIN vehicles v ON v.id = p.vehicle_id
        ORDER BY p.paid_at DESC''')) {
      book.appendRow(_sPayments, [
        IntCellValue(r['id'] as int),
        TextCellValue(r['lot_name'] as String),
        TextCellValue(r['plate'] as String),
        TextCellValue(r['owner_name'] as String),
        _date(r['paid_at']),
        IntCellValue(r['months_paid'] as int),
        IntCellValue(r['unit_price'] as int),
        IntCellValue(r['amount'] as int),
        _date(r['period_start']),
        _date(r['period_end']),
        TextCellValue(
            paymentMethodLabel(PaymentMethod.values[r['method'] as int])),
        TextCellValue((r['note'] as String?) ?? ''),
        BoolCellValue(r['voided_at'] != null),
      ]);
    }
  }

  Future<void> _allocations(Excel book) async {
    _header(book, _sAlloc,
        ['Tháng', 'Bãi', 'Biển số', 'ID thanh toán', 'Số tiền phân bổ']);
    for (final r in await _rows('''
        SELECT a.*, l.name AS lot_name, v.plate
        FROM payment_allocations a
        JOIN payments p ON p.id = a.payment_id AND p.voided_at IS NULL
        JOIN lots l ON l.id = a.lot_id
        JOIN vehicles v ON v.id = a.vehicle_id
        ORDER BY a.period_month, l.name''')) {
      book.appendRow(_sAlloc, [
        TextCellValue(r['period_month'] as String),
        TextCellValue(r['lot_name'] as String),
        TextCellValue(r['plate'] as String),
        IntCellValue(r['payment_id'] as int),
        IntCellValue(r['amount'] as int),
      ]);
    }
  }

  Future<void> _expenses(Excel book) async {
    _header(book, _sExpenses, [
      'ID', 'Bãi', 'Tháng', 'Ngày chi', 'Nhóm', 'Tên', 'Số tiền', 'Loại',
      'Đã xác nhận số', 'Ghi chú',
    ]);
    for (final r in await _rows('''
        SELECT e.*, l.name AS lot_name FROM expenses e
        JOIN lots l ON l.id = e.lot_id
        WHERE e.deleted_at IS NULL ORDER BY e.period_month DESC, e.incurred_on DESC''')) {
      book.appendRow(_sExpenses, [
        IntCellValue(r['id'] as int),
        TextCellValue(r['lot_name'] as String),
        TextCellValue(r['period_month'] as String),
        _date(r['incurred_on']),
        TextCellValue(
            costCategoryLabel(CostCategory.values[r['category'] as int])),
        TextCellValue(r['name'] as String),
        IntCellValue(r['amount'] as int),
        TextCellValue(expenseKindLabel(ExpenseKind.values[r['kind'] as int])),
        BoolCellValue((r['is_edited'] as int) == 1),
        TextCellValue((r['note'] as String?) ?? ''),
      ]);
    }
  }

  Future<void> _templates(Excel book) async {
    _header(book, _sTemplates, [
      'ID', 'Bãi', 'Tên', 'Nhóm', 'Số tiền/tháng', 'Ngày trong tháng',
      'Từ tháng', 'Đến tháng', 'Đang áp dụng',
    ]);
    for (final r in await _rows('''
        SELECT t.*, l.name AS lot_name FROM recurring_cost_templates t
        JOIN lots l ON l.id = t.lot_id ORDER BY l.name, t.name''')) {
      book.appendRow(_sTemplates, [
        IntCellValue(r['id'] as int),
        TextCellValue(r['lot_name'] as String),
        TextCellValue(r['name'] as String),
        TextCellValue(
            costCategoryLabel(CostCategory.values[r['category'] as int])),
        IntCellValue(r['amount'] as int),
        IntCellValue(r['day_of_month'] as int),
        TextCellValue(r['start_month'] as String),
        TextCellValue((r['end_month'] as String?) ?? ''),
        BoolCellValue((r['is_active'] as int) == 1),
      ]);
    }
  }

  /// Sheet đặt **hai cách tính doanh thu cạnh nhau**.
  ///
  /// Đây là câu trả lời tốt nhất cho mục 4 đặc tả: người dùng tự cộng lại trong
  /// Excel để kiểm chứng phép tính của ứng dụng. Với một app quản lý tiền, khả
  /// năng tự kiểm chứng đáng giá hơn nhiều so với việc bắt tin.
  Future<void> _monthly(Excel book) async {
    _header(book, _sMonthly, [
      'Tháng', 'DT thực thu', 'DT phân bổ', 'Chi phí', 'LN thực thu',
      'LN phân bổ',
    ]);
    final months = await _rows('''
      SELECT ym FROM (
        SELECT strftime('%Y-%m', paid_at, 'unixepoch') AS ym FROM payments
          WHERE voided_at IS NULL
        UNION SELECT period_month FROM payment_allocations
        UNION SELECT period_month FROM expenses WHERE deleted_at IS NULL
      ) ORDER BY ym''');

    for (final m in months) {
      final ym = m['ym'] as String;
      Future<int> one(String sql) async =>
          (await _rows(sql)).single['c'] as int;
      final cash = await one(
          "SELECT COALESCE(SUM(amount),0) c FROM payments WHERE voided_at IS NULL "
          "AND strftime('%Y-%m', paid_at, 'unixepoch') = '$ym'");
      final accrual = await one(
          'SELECT COALESCE(SUM(a.amount),0) c FROM payment_allocations a '
          'JOIN payments p ON p.id = a.payment_id AND p.voided_at IS NULL '
          "WHERE a.period_month = '$ym'");
      final cost = await one('SELECT COALESCE(SUM(amount),0) c FROM expenses '
          "WHERE deleted_at IS NULL AND period_month = '$ym'");
      book.appendRow(_sMonthly, [
        TextCellValue(ym),
        IntCellValue(cash),
        IntCellValue(accrual),
        IntCellValue(cost),
        IntCellValue(cash - cost),
        IntCellValue(accrual - cost),
      ]);
    }
  }

  /// Ngày lưu dạng epoch giây; xuất thành ô ngày thật để Excel lọc và sắp được.
  static CellValue? _date(Object? v) {
    if (v == null) return null;
    final d = v is DateTime
        ? v
        : DateTime.fromMillisecondsSinceEpoch((v as int) * 1000, isUtc: true);
    return DateCellValue(year: d.year, month: d.month, day: d.day);
  }
}
