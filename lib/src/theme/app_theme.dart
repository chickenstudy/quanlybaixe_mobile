/// Chủ đề Material 3 của ứng dụng, sáng và tối.
///
/// Ba ràng buộc của riêng ứng dụng này định hình mọi lựa chọn bên dưới:
///
/// 1. **Người dùng đứng ngoài trời, phần lớn đã lớn tuổi.** Cỡ chữ nền tối
///    thiểu 16 và vùng chạm tối thiểu 48dp không phải khuyến nghị mà là sàn
///    cứng — mọi `TextTheme` và `ButtonStyle` dưới đây đều bị kẹp lên trên sàn
///    đó, kể cả khi Material mặc định nhỏ hơn.
/// 2. **Màn hình toàn số tiền.** Chữ số phải cùng bề rộng
///    ([FontFeature.tabularFigures]) thì cột tiền mới thẳng hàng; nếu không,
///    số 1 hẹp hơn số 8 và mắt không so sánh được hai dòng liền nhau.
/// 3. **Ngoại tuyến 100%.** Vì vậy **không dùng `google_fonts`**: gói đó tải
///    font qua mạng ở lần dùng đầu và âm thầm rơi về font hệ thống khi không có
///    mạng — nghĩa là giao diện đổi hình dạng tuỳ tình trạng sóng. Ứng dụng
///    dùng thẳng font hệ thống (SF Pro trên iOS) qua [Typography] mặc định:
///    không byte nào phải tải, chữ Việt có dấu hiển thị đúng, và người dùng
///    quen mắt sẵn.
library;

import 'package:flutter/material.dart';

/// Sàn cứng của vùng chạm, theo hướng dẫn tiếp cận của cả Material và iOS.
const double kMinTapTarget = 48;

/// Sàn cứng của cỡ chữ nền.
const double kMinFontSize = 16;

/// Chữ số cùng bề rộng — bắt buộc cho mọi con số tiền.
const List<FontFeature> kTabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

/// Tiện ích gắn [kTabularFigures] vào một kiểu chữ có sẵn.
///
/// ```dart
/// Text(formatVnd(amount), style: context.textTheme.titleLarge?.tabular)
/// ```
///
/// Chủ đề đã bật chữ số cùng bề rộng cho **toàn bộ** `TextTheme` rồi, nên
/// phần mở rộng này chỉ cần dùng khi bạn tự dựng một [TextStyle] từ đầu.
extension TabularFiguresX on TextStyle {
  TextStyle get tabular => copyWith(fontFeatures: kTabularFigures);
}

/// Màu ngữ nghĩa không nằm trong [ColorScheme].
///
/// [ColorScheme] của Material chỉ có `error` cho trạng thái xấu; ứng dụng này
/// cần ba mức hạn (còn hạn / sắp hết hạn / đã hết hạn) và hai chiều kết quả
/// (lãi / lỗ). Gói vào [ThemeExtension] thay vì hằng số toàn cục để chúng tự
/// đổi theo chế độ sáng–tối và tự nội suy khi chuyển chủ đề.
///
/// **Màu không bao giờ là tín hiệu duy nhất.** Khoảng 8% nam giới không phân
/// biệt được đỏ với xanh lá, nên mọi chỗ dùng các màu này phải kèm biểu tượng
/// hoặc chữ ("còn 3 ngày", "quá hạn 5 ngày" — xem `formatDaysRemaining`).
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.valid,
    required this.validContainer,
    required this.onValidContainer,
    required this.expiring,
    required this.expiringContainer,
    required this.onExpiringContainer,
    required this.expired,
    required this.expiredContainer,
    required this.onExpiredContainer,
    required this.profit,
    required this.loss,
  });

  /// Còn hạn — xe đã đóng tiền và chưa tới hạn.
  final Color valid;
  final Color validContainer;
  final Color onValidContainer;

  /// Sắp hết hạn — trong ngưỡng nhắc trước do người dùng đặt.
  final Color expiring;
  final Color expiringContainer;
  final Color onExpiringContainer;

  /// Đã hết hạn — đã qua ngày `periodEnd`.
  final Color expired;
  final Color expiredContainer;
  final Color onExpiredContainer;

  /// Số dương của lãi/lỗ.
  final Color profit;

  /// Số âm của lãi/lỗ.
  final Color loss;

  /// Màu ứng với một trạng thái hạn, chọn theo số ngày còn lại.
  ///
  /// [daysLeft] lấy thẳng từ `daysRemaining(today, periodEnd)`.
  /// [warnBefore] là ngưỡng nhắc trước trong cài đặt.
  Color forDaysRemaining(int daysLeft, {int warnBefore = 7}) {
    if (daysLeft <= 0) return expired;
    if (daysLeft <= warnBefore) return expiring;
    return valid;
  }

  /// Màu nền ứng với một trạng thái hạn, đi kèm [forDaysRemaining].
  Color containerForDaysRemaining(int daysLeft, {int warnBefore = 7}) {
    if (daysLeft <= 0) return expiredContainer;
    if (daysLeft <= warnBefore) return expiringContainer;
    return validContainer;
  }

  /// Màu của một số lãi/lỗ. Số 0 dùng màu chữ thường nên trả `null`.
  Color? forProfit(int amount) {
    if (amount > 0) return profit;
    if (amount < 0) return loss;
    return null;
  }

  static const AppStatusColors lightScheme = AppStatusColors(
    valid: Color(0xFF1B6B3A),
    validContainer: Color(0xFFD5F2E0),
    onValidContainer: Color(0xFF06331A),
    expiring: Color(0xFF8A5300),
    expiringContainer: Color(0xFFFFE6BE),
    onExpiringContainer: Color(0xFF2C1A00),
    expired: Color(0xFFB3261E),
    expiredContainer: Color(0xFFF9DEDC),
    onExpiredContainer: Color(0xFF410E0B),
    profit: Color(0xFF1B6B3A),
    loss: Color(0xFFB3261E),
  );

  static const AppStatusColors darkScheme = AppStatusColors(
    valid: Color(0xFF7CDCA1),
    validContainer: Color(0xFF0B4A26),
    onValidContainer: Color(0xFFB6F5CC),
    expiring: Color(0xFFF5C46B),
    expiringContainer: Color(0xFF593C00),
    onExpiringContainer: Color(0xFFFFE0A6),
    expired: Color(0xFFF2B8B5),
    expiredContainer: Color(0xFF8C1D18),
    onExpiredContainer: Color(0xFFF9DEDC),
    profit: Color(0xFF7CDCA1),
    loss: Color(0xFFF2B8B5),
  );

  @override
  AppStatusColors copyWith({
    Color? valid,
    Color? validContainer,
    Color? onValidContainer,
    Color? expiring,
    Color? expiringContainer,
    Color? onExpiringContainer,
    Color? expired,
    Color? expiredContainer,
    Color? onExpiredContainer,
    Color? profit,
    Color? loss,
  }) {
    return AppStatusColors(
      valid: valid ?? this.valid,
      validContainer: validContainer ?? this.validContainer,
      onValidContainer: onValidContainer ?? this.onValidContainer,
      expiring: expiring ?? this.expiring,
      expiringContainer: expiringContainer ?? this.expiringContainer,
      onExpiringContainer: onExpiringContainer ?? this.onExpiringContainer,
      expired: expired ?? this.expired,
      expiredContainer: expiredContainer ?? this.expiredContainer,
      onExpiredContainer: onExpiredContainer ?? this.onExpiredContainer,
      profit: profit ?? this.profit,
      loss: loss ?? this.loss,
    );
  }

  @override
  AppStatusColors lerp(covariant AppStatusColors? other, double t) {
    if (other == null) return this;
    return AppStatusColors(
      valid: Color.lerp(valid, other.valid, t)!,
      validContainer: Color.lerp(validContainer, other.validContainer, t)!,
      onValidContainer:
          Color.lerp(onValidContainer, other.onValidContainer, t)!,
      expiring: Color.lerp(expiring, other.expiring, t)!,
      expiringContainer:
          Color.lerp(expiringContainer, other.expiringContainer, t)!,
      onExpiringContainer:
          Color.lerp(onExpiringContainer, other.onExpiringContainer, t)!,
      expired: Color.lerp(expired, other.expired, t)!,
      expiredContainer: Color.lerp(expiredContainer, other.expiredContainer, t)!,
      onExpiredContainer:
          Color.lerp(onExpiredContainer, other.onExpiredContainer, t)!,
      profit: Color.lerp(profit, other.profit, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
    );
  }
}

/// Lối tắt đọc chủ đề trong `build`.
extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Màu trạng thái hạn và lãi/lỗ. Luôn có mặt vì [AppTheme] đăng ký sẵn.
  AppStatusColors get statusColors =>
      Theme.of(this).extension<AppStatusColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppStatusColors.darkScheme
          : AppStatusColors.lightScheme);
}

/// Nơi dựng [ThemeData] sáng và tối.
abstract final class AppTheme {
  /// Màu gốc: xanh dương đậm. Trung tính về nghiệp vụ, tương phản tốt dưới
  /// nắng, và không đụng vào dải xanh lá / hổ phách / đỏ đã dành cho trạng thái
  /// hạn — nếu màu thương hiệu cũng là xanh lá thì thẻ "còn hạn" sẽ chìm nghỉm.
  static const Color seedColor = Color(0xFF00639B);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    // Dựng nền trước để lấy đúng `Typography` của nền tảng — chính là chỗ font
    // hệ thống được nạp vào, và là lý do không cần `fontFamily` nào cả.
    final base = ThemeData(brightness: brightness, colorScheme: scheme);
    final textTheme = _textTheme(base.textTheme);
    final statusColors = brightness == Brightness.dark
        ? AppStatusColors.darkScheme
        : AppStatusColors.lightScheme;

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[statusColors],

      // `padded` bơm vùng chạm của mọi nút/checkbox lên tối thiểu 48dp kể cả
      // khi phần vẽ nhỏ hơn; `standard` chặn iOS tự co giao diện lại.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarThemeData(
        centerTitle: false,
        toolbarHeight: 56,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),

      filledButtonTheme: FilledButtonThemeData(style: _buttonStyle(textTheme)),
      elevatedButtonTheme:
          ElevatedButtonThemeData(style: _buttonStyle(textTheme)),
      outlinedButtonTheme:
          OutlinedButtonThemeData(style: _buttonStyle(textTheme)),
      textButtonTheme: TextButtonThemeData(style: _buttonStyle(textTheme)),
      segmentedButtonTheme:
          SegmentedButtonThemeData(style: _buttonStyle(textTheme)),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size.square(kMinTapTarget),
          ),
          iconSize: const WidgetStatePropertyAll<double>(26),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        extendedTextStyle: textTheme.labelLarge,
      ),

      // 56dp: một dòng tiêu đề 18 + dòng phụ 16 vẫn chạm được thoải mái.
      listTileTheme: ListTileThemeData(
        minTileHeight: 56,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // Ô nhập cao 56dp và chữ 18: gõ biển số, số điện thoại, số tiền dưới
      // nắng mà vẫn đọc lại được ngay.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: textTheme.bodyLarge,
        hintStyle:
            textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: textTheme.bodyMedium?.copyWith(color: scheme.error),
      ),

      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const StadiumBorder(),
      ),

      dialogTheme: DialogThemeData(
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        contentTextStyle:
            textTheme.bodyLarge?.copyWith(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Nhãn luôn hiện: biểu tượng không có chữ là rào cản lớn nhất với người
      // dùng lớn tuổi. Cỡ chữ 12pt chuẩn cho 5 mục thanh dưới, cố định height
      // và state resolution để không bao giờ bị nhảy dòng hay co rụt chữ.
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            height: 1.2,
            letterSpacing: 0.1,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: isSelected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),

      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant,
      ),

      switchTheme: const SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      checkboxTheme: const CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
      radioTheme: const RadioThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  static ButtonStyle _buttonStyle(TextTheme textTheme) => ButtonStyle(
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(64, kMinTapTarget),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
        tapTargetSize: MaterialTapTargetSize.padded,
      );

  /// Bảng chữ đã kẹp lên sàn 16 và bật chữ số cùng bề rộng ở **mọi** ô.
  ///
  /// Bật tabular figures cho cả bảng chứ không chỉ cho ô tiền là chủ ý: chỗ nào
  /// quên gọi cũng vẫn thẳng hàng, và cái giá phải trả — chữ số trong câu văn
  /// rộng bằng nhau — gần như không thấy được trong một ứng dụng mà phần lớn
  /// chữ số đều là tiền hoặc ngày.
  ///
  /// Hệ quả của sàn 16: `bodySmall`, `labelMedium`, `labelSmall` bị đôn lên
  /// bằng nhau nên mất bậc phân cấp theo cỡ chữ. Phân cấp được dựng lại bằng
  /// độ đậm và màu (`onSurfaceVariant`) thay vì bằng cỡ — đánh đổi có ý thức,
  /// chữ 11pt ngoài nắng thì không ai đọc nổi.
  static TextTheme _textTheme(TextTheme base) => TextTheme(
        displayLarge: _style(base.displayLarge, 57),
        displayMedium: _style(base.displayMedium, 45),
        displaySmall: _style(base.displaySmall, 36),
        headlineLarge: _style(base.headlineLarge, 32),
        headlineMedium: _style(base.headlineMedium, 28),
        headlineSmall: _style(base.headlineSmall, 24),
        titleLarge: _style(base.titleLarge, 22, weight: FontWeight.w600),
        titleMedium: _style(base.titleMedium, 18, weight: FontWeight.w600),
        titleSmall: _style(base.titleSmall, kMinFontSize,
            weight: FontWeight.w600),
        bodyLarge: _style(base.bodyLarge, 18),
        bodyMedium: _style(base.bodyMedium, kMinFontSize),
        bodySmall: _style(base.bodySmall, kMinFontSize),
        labelLarge: _style(base.labelLarge, kMinFontSize,
            weight: FontWeight.w600),
        labelMedium: _style(base.labelMedium, kMinFontSize),
        labelSmall: _style(base.labelSmall, kMinFontSize),
      );

  static TextStyle _style(TextStyle? base, double size, {FontWeight? weight}) =>
      (base ?? const TextStyle()).copyWith(
        fontSize: size < kMinFontSize ? kMinFontSize : size,
        fontWeight: weight,
        fontFeatures: kTabularFigures,
      );
}
