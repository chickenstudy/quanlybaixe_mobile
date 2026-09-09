/// Biểu đồ của màn hình báo cáo tài chính.
///
///
/// ### Vì sao TÁCH làm hai biểu đồ
///
/// Ba đại lượng nằm ở ba dải giá trị rời nhau: doanh thu 0–7 triệu, chi phí
/// 27–31 triệu, lãi/lỗ −24 đến −28 triệu. Vẽ chung một trục thì trục phải trải
/// từ −40tr tới +40tr, hơn nửa chiều cao là khoảng trống, và đường doanh thu bị
/// ép gần như phẳng — đúng thứ chủ bãi cần đọc thì lại không đọc được.
///
/// Hai trục riêng trên cùng một khung là điều **cấm**: người đọc không có cách
/// nào biết hai thang đo lệch nhau bao nhiêu. Cách đúng là tách thành hai biểu
/// đồ dùng chung trục hoành:
///
/// - [RevenueExpenseChart] — cột nhóm, so **độ lớn** giữa thu và chi. Cùng dải
///   dương nên dùng trọn chiều cao.
/// - [ProfitChart] — cột **phân kỳ** quanh mốc 0, thể hiện **cực tính** lãi/lỗ.
///   Vị trí trên/dưới vạch 0 tự nó đã là một tầng mã hoá, không phụ thuộc màu.
///
/// ### Vì sao CỘT chứ không phải đường
///
/// Báo cáo thường có 4–12 mốc. Ở mật độ đó cột đọc chính xác hơn đường: mỗi giá
/// trị là một chiều dài đo được từ mốc 0, thay vì một điểm phải ước lượng theo
/// độ dốc. Đường chỉ hơn khi có vài chục mốc trở lên.
///
/// ### Không có vùng tô
///
/// Vùng tô dưới đường chỉ dùng cho **một** series. Ba vùng tô chồng nhau tạo
/// một mảng xám không mang thông tin gì, và che mất chính các đường.

library;

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/money/money_format.dart';
import '../../../core/strings/strings.dart';
import '../../../core/time/day.dart';
import '../../../core/time/year_month.dart';
import '../data/report_repository.dart';
import 'reports_strings.dart';

/// Nhãn đầy đủ của một mốc, dùng cho bảng chi tiết và cho chú thích khi chạm.
///
/// `2026-08-01` → `01/08/2026` · `2026-08` → `Tháng 8/2026` ·
/// `2026-Q3` → `Quý 3/2026` · `2026` → `Năm 2026`.
String reportPeriodLabel(String key, ReportGranularity granularity) {
  switch (granularity) {
    case ReportGranularity.day:
      return formatDay(Day.parseIso(key));
    case ReportGranularity.month:
      return formatMonth(YearMonth.parse(key));
    case ReportGranularity.quarter:
      return formatQuarterKey(key);
    case ReportGranularity.year:
      return formatYear(int.parse(key));
  }
}

/// Nhãn **rút gọn** cho trục hoành: `01/08` · `T8/26` · `Q3/26` · `2026`.
///
/// Nhãn đầy đủ ("Tháng 8/2026") dài gấp ba lần chỗ có trên trục; nhét vào là
/// chữ chồng lên nhau. Bản đầy đủ vẫn còn nguyên ở bảng chi tiết và ở chú
/// thích khi chạm vào biểu đồ.
String reportPeriodAxisLabel(String key, ReportGranularity granularity) {
  switch (granularity) {
    case ReportGranularity.day:
      return formatDayShort(Day.parseIso(key));
    case ReportGranularity.month:
      final m = YearMonth.parse(key);
      return 'T${m.month}/${(m.year % 100).toString().padLeft(2, '0')}';
    case ReportGranularity.quarter:
      final year = int.parse(key.substring(0, 4));
      return 'Q${key.substring(6, 7)}/${(year % 100).toString().padLeft(2, '0')}';
    case ReportGranularity.year:
      return key;
  }
}

/// Bảng màu ba chuỗi số liệu, chọn theo nền sáng / nền tối.
///
/// Giá trị viết thẳng bằng mã hex chứ không lấy từ `ColorScheme`: màu của
/// `ColorScheme` sinh ra từ một màu gốc duy nhất nên `primary`, `secondary`,
/// `tertiary` nằm quá gần nhau trên vòng màu — ba đường vẽ bằng chúng gần như
/// không phân biệt được, càng không phân biệt được với mắt mù màu.
@immutable

/// Bảng màu của biểu đồ báo cáo.
///
/// **Mọi cặp màu ở đây đã chạy qua bộ kiểm tra**, không phải chọn bằng mắt.
/// Chỉ số quan trọng nhất là ΔE dưới mắt người mù màu deutan (khoảng 8% nam
/// giới) — dưới 8 là hai màu dính vào nhau với họ.
///
/// | Cặp | deutan ΔE |
/// |---|---|
/// | Doanh thu / Chi phí — nền sáng `#2A78D6` `#EB6834` | 24,7 |
/// | Doanh thu / Chi phí — nền tối `#3987E5` `#D95926` | 26,8 |
/// | Lãi / Lỗ — nền sáng `#0E8FA0` `#C0332B` | 15,9 |
/// | Lãi / Lỗ — nền tối `#2AA3B5` `#DE5744` | 16,0 |
///
/// **Vì sao lãi KHÔNG dùng màu xanh lá.** Cặp xanh lá/đỏ của `AppStatusColors`
/// chỉ đạt deutan ΔE 7,2 ở nền sáng và **2,3** ở nền tối — ở nền tối là gần như
/// không phân biệt được. Cặp đó được chọn cho *chữ*, không phải cho vệt biểu đồ.
/// Đổi sang xanh mòng két nâng độ tách lên hơn gấp đôi.
///
/// Màu không bao giờ là tín hiệu duy nhất: cột lãi/lỗ còn nằm trên hoặc dưới
/// vạch 0, và các ô tổng luôn kèm dấu cùng chữ "Lãi"/"Lỗ".
class RevenueChartPalette {
  const RevenueChartPalette({
    required this.revenue,
    required this.expense,
    required this.profit,
    required this.loss,
    required this.grid,
    required this.axisText,
  });

  final Color revenue;
  final Color expense;

  /// Cực dương của thang phân kỳ lãi/lỗ.
  final Color profit;

  /// Cực âm của thang phân kỳ lãi/lỗ.
  final Color loss;

  final Color grid;
  final Color axisText;

  static const RevenueChartPalette light = RevenueChartPalette(
    revenue: Color(0xFF2A78D6),
    expense: Color(0xFFEB6834),
    profit: Color(0xFF0E8FA0),
    loss: Color(0xFFC0332B),
    grid: Color(0x1F000000),
    axisText: Color(0xFF5F6368),
  );

  static const RevenueChartPalette dark = RevenueChartPalette(
    revenue: Color(0xFF3987E5),
    expense: Color(0xFFD95926),
    profit: Color(0xFF2AA3B5),
    loss: Color(0xFFDE5744),
    grid: Color(0x2EFFFFFF),
    axisText: Color(0xFFB0B3B8),
  );

  static RevenueChartPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  Color forProfit(int amount) => amount < 0 ? loss : profit;
}

/// Bề rộng dành cho mỗi mốc trên trục hoành. Hẹp hơn thì cột dính vào nhau.
const double _slotWidth = 56;

/// Khoảng chừa cho nhãn trục tung, tính theo chuỗi dài nhất thực tế.
const double _minAxisReserve = 44;

/// Cột nhóm so sánh doanh thu và chi phí theo từng mốc.
class RevenueExpenseChart extends StatelessWidget {
  const RevenueExpenseChart({
    super.key,
    required this.points,
    required this.granularity,
    this.height = 200,
  });

  final List<ReportPoint> points;
  final ReportGranularity granularity;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _ChartEmptyState();
    final theme = Theme.of(context);
    final palette = RevenueChartPalette.of(context);

    final maxValue = points
        .map((p) => math.max(p.revenue, p.expense))
        .fold<int>(0, math.max)
        .toDouble();
    final bounds = _AxisBounds.forMax(maxValue);
    final reserve = _reserveFor(context, bounds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chú giải luôn có mặt khi từ hai series trở lên — danh tính không bao
        // giờ chỉ dựa vào màu.
        _Legend(items: [
          (palette.revenue, Strings.reportRevenue),
          (palette.expense, Strings.reportExpense),
        ]),
        const SizedBox(height: 12),
        _ScrollableChart(
          count: points.length,
          height: height,
          reserve: reserve,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: bounds.max,
              minY: 0,
              barTouchData: _touch(context, palette, isProfit: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: bounds.interval,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: palette.grid, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: _titles(context, palette, bounds, reserve),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(
                    x: i,
                    // Khe 2px giữa hai cột cạnh nhau — tách bằng khoảng nền chứ
                    // không vẽ viền quanh cột.
                    barsSpace: 2,
                    barRods: [
                      _rod(points[i].revenue.toDouble(), palette.revenue),
                      _rod(points[i].expense.toDouble(), palette.expense),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (points.length * _slotWidth > MediaQuery.sizeOf(context).width)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(ReportsStrings.chartScrollHint,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
      ],
    );
  }

  BarChartRodData _rod(double value, Color color) => BarChartRodData(
        toY: value,
        color: color,
        width: 14,
        // Bo 4px ở đầu cột, chân cột vuông để dính vào mốc 0.
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      );

  double _reserveFor(BuildContext context, _AxisBounds b) =>
      _measureAxisWidth(context, b.labels);

  FlTitlesData _titles(BuildContext context, RevenueChartPalette palette,
          _AxisBounds bounds, double reserve) =>
      _sharedTitles(context, palette, bounds, reserve, points, granularity);

  BarTouchData _touch(BuildContext context, RevenueChartPalette palette,
          {required bool isProfit}) =>
      _sharedTouch(context, points, granularity, isProfit: isProfit);
}

/// Cột phân kỳ quanh mốc 0 cho lãi/lỗ.
class ProfitChart extends StatelessWidget {
  const ProfitChart({
    super.key,
    required this.points,
    required this.granularity,
    this.height = 150,
  });

  final List<ReportPoint> points;
  final ReportGranularity granularity;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const _ChartEmptyState();
    final palette = RevenueChartPalette.of(context);

    final values = points.map((p) => p.profit.toDouble()).toList();
    final bounds = _AxisBounds.forRange(
      values.reduce(math.min),
      values.reduce(math.max),
    );
    final reserve = _measureAxisWidth(context, bounds.labels);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Một series thì không cần hộp chú giải — tiêu đề mục đã gọi tên nó.
        // Hai màu ở đây là hai CỰC của cùng một đại lượng, không phải hai
        // series, nên chú thích ngắn nói rõ nghĩa của cực.
        _Legend(items: [
          (palette.profit, ReportsStrings.polePositive),
          (palette.loss, ReportsStrings.poleNegative),
        ]),
        const SizedBox(height: 12),
        _ScrollableChart(
          count: points.length,
          height: height,
          reserve: reserve,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: bounds.max,
              minY: bounds.min,
              barTouchData: _sharedTouch(context, points, granularity,
                  isProfit: true),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: bounds.interval,
                getDrawingHorizontalLine: (v) => FlLine(
                  // Vạch mốc 0 đậm hơn: đó là ranh giới giữa lãi và lỗ.
                  color: v == 0 ? palette.axisText : palette.grid,
                  strokeWidth: v == 0 ? 1.4 : 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: _sharedTitles(
                  context, palette, bounds, reserve, points, granularity),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: points[i].profit.toDouble(),
                        color: palette.forProfit(points[i].profit),
                        width: 18,
                        borderRadius: points[i].profit < 0
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(4))
                            : const BorderRadius.vertical(
                                top: Radius.circular(4)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bọc biểu đồ cho cuộn ngang khi nhiều mốc, nhưng **giữ trục tung đứng yên**.
///
/// Cuộn cả trục tung theo nội dung là một lỗi hay gặp: người dùng cuộn sang
/// phải là mất luôn thang đo, và các cột còn lại thành vô nghĩa.
class _ScrollableChart extends StatelessWidget {
  const _ScrollableChart({
    required this.count,
    required this.height,
    required this.reserve,
    required this.child,
  });

  final int count;
  final double height;
  final double reserve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final needed = count * _slotWidth + reserve;
        final width = math.max(constraints.maxWidth, needed);
        return SizedBox(
          height: height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: width, child: child),
          ),
        );
      },
    );
  }
}

/// Nhãn hai trục, dùng chung cho cả hai biểu đồ nên chúng thẳng hàng nhau.
FlTitlesData _sharedTitles(
  BuildContext context,
  RevenueChartPalette palette,
  _AxisBounds bounds,
  double reserve,
  List<ReportPoint> points,
  ReportGranularity granularity,
) {
  final style = Theme.of(context)
      .textTheme
      .bodySmall
      ?.copyWith(color: palette.axisText, fontFeatures: const [
    FontFeature.tabularFigures(),
  ]);

  // Thưa nhãn trục hoành cho tới khi không còn chồng chữ. Đo bằng TextPainter
  // thay vì cắm hằng số, vì cỡ chữ đổi theo cài đặt trợ năng của người dùng.
  final labels = [
    for (final p in points) reportPeriodAxisLabel(p.key, granularity),
  ];
  final widest = _measureText(context, _longest(labels), style);
  // Làm tròn LÊN. Chia lấy nguyên là sai: nhãn rộng 45px trong ô 56px cho ra
  // step = 1, tức không thưa gì cả, và nhãn vẫn chạm nhau.
  final step = math.max(1, ((widest + 12) / _slotWidth).ceil());

  return FlTitlesData(
    show: true,
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: bounds.interval,
        reservedSize: reserve,
        getTitlesWidget: (value, meta) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Text(formatVndCompact(value.round()),
              style: style, textAlign: TextAlign.right),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        getTitlesWidget: (value, meta) {
          final i = value.round();
          if (i < 0 || i >= points.length) return const SizedBox.shrink();
          final last = points.length - 1;
          // Luôn giữ nhãn mốc CUỐI — đó là mốc người dùng quan tâm nhất — và
          // BỎ nhãn theo nhịp nếu nó rơi quá sát mốc cuối. Chỉ ép giữ mốc cuối
          // mà không bỏ cái trước nó thì hai nhãn chồng lên nhau đúng ở chỗ dễ
          // thấy nhất: 24 mốc với nhịp 2 sẽ đặt nhãn 22 và 23 cách nhau đúng
          // một ô, hẹp hơn bề rộng chữ.
          final keep = i == last || (i % step == 0 && last - i >= step);
          if (!keep) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(labels[i], style: style),
          );
        },
      ),
    ),
  );
}

/// Chạm vào cột thì hiện số đầy đủ. Không in số lên từng cột: một con số cạnh
/// mỗi cột là rối và chẳng ai đọc.
BarTouchData _sharedTouch(
  BuildContext context,
  List<ReportPoint> points,
  ReportGranularity granularity, {
  required bool isProfit,
}) {
  final scheme = Theme.of(context).colorScheme;
  return BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (_) => scheme.inverseSurface,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final p = points[group.x];
        final head = reportPeriodLabel(p.key, granularity);
        final body = isProfit
            ? '${Strings.reportProfit}: ${formatVndSigned(p.profit)}'
            : (rodIndex == 0
                ? '${Strings.reportRevenue}: ${formatVnd(p.revenue)}'
                : '${Strings.reportExpense}: ${formatVnd(p.expense)}');
        return BarTooltipItem(
          '$head\n',
          TextStyle(
            color: scheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(
              text: body,
              style: TextStyle(color: scheme.onInverseSurface),
            ),
          ],
        );
      },
    ),
  );
}

double _measureAxisWidth(BuildContext context, List<String> labels) {
  final style = Theme.of(context).textTheme.bodySmall;
  final w = _measureText(context, _longest(labels), style);
  return math.max(_minAxisReserve, w + 10);
}

double _measureText(BuildContext context, String text, TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  return painter.width;
}

String _longest(List<String> values) {
  var best = '';
  for (final v in values) {
    if (v.length > best.length) best = v;
  }
  return best;
}

/// Cận trục đã làm tròn về mốc "đẹp".
class _AxisBounds {
  const _AxisBounds(this.min, this.max, this.interval);

  final double min;
  final double max;
  final double interval;

  factory _AxisBounds.forMax(double maxValue) {
    if (maxValue <= 0) return const _AxisBounds(0, 1, 1);
    final interval = _niceInterval(maxValue / 4);
    return _AxisBounds(0, (maxValue / interval).ceil() * interval, interval);
  }

  factory _AxisBounds.forRange(double minValue, double maxValue) {
    // Luôn ôm lấy mốc 0: biểu đồ phân kỳ mà không thấy vạch 0 thì mất ý nghĩa.
    final lo = math.min(0.0, minValue);
    final hi = math.max(0.0, maxValue);
    if (lo == hi) return const _AxisBounds(-1, 1, 1);
    final interval = _niceInterval((hi - lo) / 4);
    return _AxisBounds(
      (lo / interval).floor() * interval,
      (hi / interval).ceil() * interval,
      interval,
    );
  }

  List<String> get labels => [
        formatVndCompact(min.round()),
        formatVndCompact(max.round()),
      ];

  static double _niceInterval(double rough) {
    if (rough <= 0) return 1;
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor())
        .toDouble();
    final norm = rough / magnitude;
    final nice = norm <= 1
        ? 1.0
        : norm <= 2
            ? 2.0
            : norm <= 5
                ? 5.0
                : 10.0;
    return nice * magnitude;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.items});

  final List<(Color, String)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final (color, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              // Chữ mặc màu chữ, không mặc màu series — vệt màu bên cạnh mới là
              // thứ mang danh tính.
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
      ],
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(Strings.reportEmpty,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }
}
