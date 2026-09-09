import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/day.dart';
import 'package:quan_ly_bai_xe/src/core/xlsx.dart';
import 'package:quan_ly_bai_xe/src/features/backup/data/excel_exporter.dart';
import 'package:quan_ly_bai_xe/src/features/payments/data/payment_repository.dart';

void main() {
  late AppDatabase db;
  late ExcelExporter exporter;
  late Directory tmp;
  final clock = FixedClock(DateTime(2026, 9, 8, 14, 5));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    exporter = ExcelExporter(db, clock);
    tmp = await Directory.systemTemp.createTemp('qlbx_xlsx');
  });
  tearDown(() async {
    await db.close();
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  /// Dựng đúng ví dụ tháng 8 của đặc tả.
  Future<void> seedSpec() async {
    final lotId = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi Nguyễn Trãi',
          nameFold: 'bai nguyen trai',
          createdAt: DateTime.utc(2026, 8, 1),
          updatedAt: DateTime.utc(2026, 8, 1),
        ));
    final pay = PaymentRepository(db, clock);
    for (final (plate, months) in const [
      ('59A-111.11', 1),
      ('59A-222.22', 2),
      ('59A-333.33', 3),
    ]) {
      final id = await db.into(db.vehicles).insert(VehiclesCompanion.insert(
            lotId: lotId,
            ownerName: 'Nguyễn Văn $months',
            ownerNameFold: 'nguyen van',
            vehicleType: VehicleType.motorbike,
            plate: plate,
            plateNormalized: plate.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''),
            monthlyPrice: 100000,
            startDate: const Day(2026, 8, 1),
            anchorDay: 1,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ));
      await pay.recordPayment(
          vehicleId: id, months: months, paidAt: const Day(2026, 8, 1));
    }
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
          lotId: lotId,
          name: 'Tiền điện',
          category: CostCategory.electricity,
          kind: ExpenseKind.adhoc,
          amount: 850000,
          incurredOn: const Day(2026, 8, 10),
          periodMonth: '2026-08',
          createdAt: DateTime.utc(2026, 8, 10),
          updatedAt: DateTime.utc(2026, 8, 10),
        ));
  }

  /// Đọc lại file đã ghi — kiểm chứng bằng cách mở thật, không tin vào bộ ghi.
  Future<Excel> readBack() async {
    final f = await exporter.export(dir: tmp);
    expect(f.existsSync(), isTrue);
    return Excel.decodeBytes(await f.readAsBytes());
  }

  test('tạo đủ 8 sheet, không còn sheet trắng mặc định', () async {
    await seedSpec();
    final b = await readBack();
    expect(b.tables.keys, containsAll(<String>[
      'Tong quan', 'Bai xe', 'Xe', 'Thanh toan',
      'Phan bo doanh thu', 'Chi phi', 'Chi phi co dinh', 'Bao cao thang',
    ]));
    expect(b.tables.keys, isNot(contains('Sheet1')));
  });

  test('sheet Báo cáo tháng đặt HAI cách tính cạnh nhau, khớp đặc tả', () async {
    await seedSpec();
    final b = await readBack();
    final rows = b.tables['Bao cao thang']!.rows;
    final aug = rows.firstWhere((r) => r.first?.value?.toString() == '2026-08');

    expect(aug[1]?.value?.toString(), '600000', reason: 'thực thu tháng 8');
    expect(aug[2]?.value?.toString(), '300000', reason: 'phân bổ tháng 8');
    expect(aug[3]?.value?.toString(), '850000', reason: 'chi phí');
    expect(aug[4]?.value?.toString(), '${600000 - 850000}');
    expect(aug[5]?.value?.toString(), '${300000 - 850000}');

    final sep = rows.firstWhere((r) => r.first?.value?.toString() == '2026-09');
    expect(sep[1]?.value?.toString(), '0', reason: 'tháng 9 không thu đồng nào');
    expect(sep[2]?.value?.toString(), '200000', reason: 'nhưng có phân bổ');
  });

  test('tiền xuất thành SỐ để Excel cộng được, không phải chữ', () async {
    await seedSpec();
    final b = await readBack();
    final cell = b.tables['Bao cao thang']!.rows
        .firstWhere((r) => r.first?.value?.toString() == '2026-08')[1];
    expect(cell?.value, isA<IntCellValue>(),
        reason: 'là chữ thì người dùng không SUM được trong Excel');
  });

  test('giữ nguyên dấu tiếng Việt trong nội dung', () async {
    await seedSpec();
    final b = await readBack();
    final names =
        b.tables['Bai xe']!.rows.map((r) => r[1]?.value?.toString()).toList();
    expect(names, contains('Bãi Nguyễn Trãi'));
  });

  test('sheet Phân bổ doanh thu cho người dùng tự kiểm chứng phép tính',
      () async {
    await seedSpec();
    final b = await readBack();
    final rows = b.tables['Phan bo doanh thu']!.rows.skip(1);
    expect(rows.length, 6, reason: '1 + 2 + 3 tháng');
    final total = rows.fold<int>(
        0, (s, r) => s + int.parse(r.last!.value.toString()));
    expect(total, 600000, reason: 'tổng phân bổ phải khớp tổng đã thu');
  });

  test('tên file chỉ ASCII, có mốc thời gian', () async {
    await seedSpec();
    final name = (await exporter.export(dir: tmp)).path.split('/').last;
    expect(name, matches(RegExp(r'^[A-Za-z0-9_.\-]+$')));
    expect(name, 'BaoCao_QuanLyBaiXe_20260908_1405.xlsx');
  });

  test('sheet Tổng quan nói rõ Excel KHÔNG dùng để khôi phục', () async {
    await seedSpec();
    final b = await readBack();
    final text = b.tables['Tong quan']!.rows
        .expand((r) => r)
        .map((c) => c?.value?.toString() ?? '')
        .join(' ');
    expect(text, contains('.qlbx'),
        reason: 'người dùng hay tưởng file Excel nhập lại được');
  });

  test('biên lai đã huỷ vẫn có trong sheet nhưng được đánh dấu', () async {
    await seedSpec();
    final p = await db.select(db.payments).get();
    await PaymentRepository(db, clock).voidPayment(p.first.id);

    final b = await readBack();
    final rows = b.tables['Thanh toan']!.rows.skip(1).toList();
    expect(rows.length, 3, reason: 'không ẩn, để còn dấu vết');
    expect(rows.any((r) => r.last?.value.toString() == 'true'), isTrue);
    // Nhưng phải biến khỏi báo cáo tháng.
    final aug = b.tables['Bao cao thang']!.rows
        .firstWhere((r) => r.first?.value?.toString() == '2026-08');
    expect(aug[1]?.value?.toString(), '500000');
  });

  test('không có dữ liệu vẫn xuất được file hợp lệ', () async {
    final b = await readBack();
    expect(b.tables['Bai xe']!.rows.length, 1, reason: 'chỉ còn dòng tiêu đề');
  });
}
