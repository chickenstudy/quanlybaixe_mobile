import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_bai_xe/src/core/db/database.dart';
import 'package:quan_ly_bai_xe/src/core/db/enums.dart';
import 'package:quan_ly_bai_xe/src/core/time/clock.dart';
import 'package:quan_ly_bai_xe/src/core/time/year_month.dart';
import 'package:quan_ly_bai_xe/src/features/expenses/data/recurring_cost_materializer.dart';

void main() {
  late AppDatabase db;
  late RecurringCostMaterializer mat;
  late int lotId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mat = RecurringCostMaterializer(db, FixedClock(DateTime(2026, 10, 15, 9)));
    lotId = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi test',
          nameFold: 'bai test',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ));
  });
  tearDown(() => db.close());

  Future<int> template({
    required String name,
    required CostCategory cat,
    required int amount,
    required String from,
    String? to,
    bool active = true,
  }) =>
      db.into(db.recurringCostTemplates).insert(
            RecurringCostTemplatesCompanion.insert(
              lotId: lotId,
              name: name,
              category: cat,
              amount: amount,
              startMonth: from,
              endMonth: Value(to),
              isActive: Value(active),
              createdAt: DateTime.utc(2026, 1, 1),
              updatedAt: DateTime.utc(2026, 1, 1),
            ),
          );

  Future<List<ExpenseRow>> expenses() =>
      (db.select(db.expenses)..orderBy([(e) => OrderingTerm.asc(e.periodMonth)]))
          .get();

  test('sinh đủ các tháng từ tháng bắt đầu tới tháng chỉ định', () async {
    await template(
        name: 'Tiền thuê mặt bằng',
        cat: CostCategory.rent,
        amount: 5000000,
        from: '2026-08');

    final created = await mat.materializeUpTo(const YearMonth(2026, 10));
    expect(created, 3);

    final rows = await expenses();
    expect(rows.map((e) => e.periodMonth), ['2026-08', '2026-09', '2026-10']);
    expect(rows.every((e) => e.amount == 5000000), isTrue);
    expect(rows.every((e) => e.kind == ExpenseKind.recurring), isTrue);
    expect(rows.every((e) => e.isEdited == false), isTrue);
  });

  test('IDEMPOTENT — chạy nhiều lần không sinh dòng trùng', () async {
    await template(
        name: 'Điện', cat: CostCategory.electricity, amount: 800000, from: '2026-08');

    expect(await mat.materializeUpTo(const YearMonth(2026, 10)), 3);
    expect(await mat.materializeUpTo(const YearMonth(2026, 10)), 0);
    expect(await mat.materializeUpTo(const YearMonth(2026, 10)), 0);
    expect((await expenses()).length, 3);
  });

  test('KHÔNG đè lên số tiền người dùng đã sửa — lý do tồn tại của cả cơ chế',
      () async {
    await template(
        name: 'Điện', cat: CostCategory.electricity, amount: 800000, from: '2026-08');
    await mat.materializeUpTo(const YearMonth(2026, 09));

    // Tiền điện tháng 8 thực tế là 1.150.000, không phải ước tính 800.000.
    final aug = (await expenses()).firstWhere((e) => e.periodMonth == '2026-08');
    await (db.update(db.expenses)..where((e) => e.id.equals(aug.id))).write(
        const ExpensesCompanion(
            amount: Value(1150000), isEdited: Value(true)));

    // Chạy lại bộ sinh cho các tháng sau.
    await mat.materializeUpTo(const YearMonth(2026, 12));

    final rows = await expenses();
    final augAfter = rows.firstWhere((e) => e.periodMonth == '2026-08');
    expect(augAfter.amount, 1150000, reason: 'số tiền đã sửa phải được giữ nguyên');
    expect(augAfter.isEdited, isTrue);
    // Các tháng mới vẫn dùng ước tính của mẫu.
    expect(rows.firstWhere((e) => e.periodMonth == '2026-11').amount, 800000);
  });

  test('không tạo cho tháng tương lai', () async {
    await template(
        name: 'Nước', cat: CostCategory.water, amount: 300000, from: '2026-08');
    await mat.materializeUpTo(const YearMonth(2026, 10));
    final months = (await expenses()).map((e) => e.periodMonth).toList();
    expect(months, isNot(contains('2026-11')));
  });

  test('materializeCurrentMonth dừng đúng ở tháng hiện tại của đồng hồ', () async {
    // FixedClock đặt ở 15/10/2026.
    await template(
        name: 'Internet', cat: CostCategory.internet, amount: 250000, from: '2026-08');
    await mat.materializeCurrentMonth();
    final months = (await expenses()).map((e) => e.periodMonth).toList();
    expect(months, ['2026-08', '2026-09', '2026-10']);
  });

  test('tôn trọng endMonth của mẫu', () async {
    await template(
        name: 'Bảo vệ',
        cat: CostCategory.security,
        amount: 4000000,
        from: '2026-08',
        to: '2026-09');
    await mat.materializeUpTo(const YearMonth(2026, 12));
    expect((await expenses()).map((e) => e.periodMonth), ['2026-08', '2026-09']);
  });

  test('mẫu đã tắt thì không sinh gì thêm, nhưng lịch sử vẫn còn', () async {
    final id = await template(
        name: 'Nhân viên', cat: CostCategory.staff, amount: 6000000, from: '2026-08');
    await mat.materializeUpTo(const YearMonth(2026, 09));
    expect((await expenses()).length, 2);

    await (db.update(db.recurringCostTemplates)..where((t) => t.id.equals(id)))
        .write(const RecurringCostTemplatesCompanion(isActive: Value(false)));
    await mat.invalidate();
    await mat.materializeUpTo(const YearMonth(2026, 12));

    expect((await expenses()).length, 2, reason: 'lịch sử phải được giữ lại');
  });

  test('THÊM MẪU MỚI sau khi đã chạy thì mẫu đó VẪN được sinh', () async {
    // Lỗi thật đã gặp: mốc chỉ ghi tháng, nên thêm mẫu trong cùng tháng thì
    // materializeCurrentMonth bỏ qua và toàn bộ chi phí cố định biến mất khỏi
    // báo cáo — không có lỗi nào được báo.
    await mat.materializeCurrentMonth();
    expect(await expenses(), isEmpty);

    await template(
        name: 'Điện', cat: CostCategory.electricity, amount: 800000, from: '2026-10');

    expect(await mat.materializeCurrentMonth(), 1,
        reason: 'mẫu thêm sau phải được nhận ra');
    expect((await expenses()).single.name, 'Điện');
  });

  test('SỬA số tiền của mẫu thì lần chạy sau nhận ra tập mẫu đã đổi', () async {
    final id = await template(
        name: 'Điện', cat: CostCategory.electricity, amount: 800000, from: '2026-10');
    await mat.materializeCurrentMonth();
    expect(await mat.isUpToDate(const YearMonth(2026, 10)), isTrue);

    await (db.update(db.recurringCostTemplates)..where((t) => t.id.equals(id)))
        .write(RecurringCostTemplatesCompanion(
            amount: const Value(950000), updatedAt: Value(DateTime.utc(2026, 10, 20))));

    expect(await mat.isUpToDate(const YearMonth(2026, 10)), isFalse,
        reason: 'vân tay phải đổi khi mẫu bị sửa');
  });

  test('mốc tối ưu hỏng vẫn ra đúng trạng thái', () async {
    await template(
        name: 'Điện', cat: CostCategory.electricity, amount: 800000, from: '2026-08');
    await mat.materializeUpTo(const YearMonth(2026, 10));

    // Cố tình ghi mốc sai.
    await db.into(db.appSettings).insertOnConflictUpdate(
        const AppSettingRow(key: 'last_recurring_materialized_month', value: '1999-01'));

    expect(await mat.materializeUpTo(const YearMonth(2026, 10)), 0,
        reason: 'tính đúng đắn nằm ở chỉ số duy nhất, không ở mốc tối ưu');
    expect((await expenses()).length, 3);
  });

  test('nhiều mẫu trên nhiều bãi cùng lúc', () async {
    final lot2 = await db.into(db.lots).insert(LotsCompanion.insert(
          name: 'Bãi 2',
          nameFold: 'bai 2',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ));
    await template(
        name: 'Điện', cat: CostCategory.electricity, amount: 800000, from: '2026-09');
    await db.into(db.recurringCostTemplates).insert(
          RecurringCostTemplatesCompanion.insert(
            lotId: lot2,
            name: 'Thuê mặt bằng',
            category: CostCategory.rent,
            amount: 9000000,
            startMonth: '2026-09',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );

    expect(await mat.materializeUpTo(const YearMonth(2026, 10)), 4);
    expect(await mat.materializeUpTo(const YearMonth(2026, 10)), 0);
  });

  test('ngày trong tháng được kẹp về 1..28 để tháng 2 cũng có', () async {
    await db.into(db.recurringCostTemplates).insert(
          RecurringCostTemplatesCompanion.insert(
            lotId: lotId,
            name: 'Thuê mặt bằng',
            category: CostCategory.rent,
            amount: 5000000,
            dayOfMonth: const Value(31),
            startMonth: '2026-02',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    await mat.materializeUpTo(const YearMonth(2026, 02));
    final feb = (await expenses()).single;
    expect(feb.incurredOn.day, 28);
    expect(feb.incurredOn.month, 2);
  });

  test('không có mẫu nào thì không lỗi', () async {
    expect(await mat.materializeUpTo(const YearMonth(2026, 10)), 0);
    expect(await expenses(), isEmpty);
  });
}
