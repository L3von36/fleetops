import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'dimens.dart';
import 'palette.dart';

/// FleetOps — **compact** theme builder (light & dark).
///
/// Rules of the system:
///  • 4 px spacing grid; 12 px card radius; 10 px input radius.
///  • Type ramp ≈ 85 % of Material 3 defaults — built for information-dense
///    operations tooling, not marketing pages.
///  • Controls live in the 36–40 px band ([Dimens]).
///  • Headings tightened (-0.3 .. -1.0 letter-spacing).
///  • Tabular figures for every numeric UI element (KPIs, tables).
abstract final class AppTheme {
  static const Radius _r = Radius.circular(Dimens.radiusLg);

  static const _tabular = [FontFeature.tabularFigures()];

  // ───────────────────────────────────────────────────────── Light ──
  static ThemeData light() => _build(
    brightness: Brightness.light,
    background: Palette.bgLight,
    surface: Palette.surfaceLight,
    surfaceAlt: Palette.surfaceAltLight,
    text: Palette.textLight,
    textMuted: Palette.textMutedLight,
    outline: Palette.outlineLight,
    primary: Palette.brand,
    onPrimary: Colors.white,
    primaryContainer: Palette.brandSoft,
    onPrimaryContainer: Palette.brandDeep,
    shadowOpacity: 0.10,
  );

  // ────────────────────────────────────────────────────────── Dark ──
  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    background: Palette.bgDark,
    surface: Palette.surfaceDark,
    surfaceAlt: Palette.surfaceAltDark,
    text: Palette.textDark,
    textMuted: Palette.textMutedDark,
    outline: Palette.outlineDark,
    primary: const Color(0xFF8AA6FF),
    onPrimary: const Color(0xFF0A1A4A),
    primaryContainer: const Color(0xFF24366B),
    onPrimaryContainer: const Color(0xFFDCE5FF),
    shadowOpacity: 0.45,
  );

  // ───────────────────────────────────────────────────────────── ──
  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color text,
    required Color textMuted,
    required Color outline,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required double shadowOpacity,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: Palette.teal,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? const Color(0xFF0E3A3B)
          : const Color(0xFFD8F2F2),
      onSecondaryContainer: isDark
          ? const Color(0xFFB8E8E8)
          : const Color(0xFF0A5C5D),
      tertiary: Palette.violet,
      onTertiary: Colors.white,
      tertiaryContainer: isDark
          ? const Color(0xFF372C6E)
          : const Color(0xFFE7E0FF),
      onTertiaryContainer: isDark
          ? const Color(0xFFD9CFFF)
          : const Color(0xFF4C31B8),
      error: isDark ? const Color(0xFFFF867C) : Palette.danger,
      onError: isDark ? const Color(0xFF4A0B06) : Colors.white,
      errorContainer: isDark
          ? const Color(0xFF5C1510)
          : const Color(0xFFFDE3E1),
      onErrorContainer: isDark
          ? const Color(0xFFFFC9C4)
          : const Color(0xFF93312B),
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surfaceAlt,
      onSurfaceVariant: textMuted,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
      inverseSurface: isDark ? Palette.textLight : Palette.bgDark,
      onInverseSurface: isDark ? Palette.bgLight : Palette.textDark,
      inversePrimary: isDark ? Palette.brand : const Color(0xFF8AA6FF),
      surfaceTint: primary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      splashFactory: InkSparkle.splashFactory,
    );

    final font = base.textTheme.apply(
      bodyColor: text,
      displayColor: text,
      fontFamilyFallback: const ['Inter', 'Segoe UI', 'SF Pro Text', 'Roboto'],
    );

    // ── Compact type ramp ──────────────────────────────────────────────
    final textTheme = font.copyWith(
      displayLarge: font.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        fontFeatures: _tabular,
      ),
      displayMedium: font.displayMedium?.copyWith(
        fontSize: 33,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        fontFeatures: _tabular,
      ),
      displaySmall: font.displaySmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
        fontFeatures: _tabular,
      ),
      headlineLarge: font.headlineLarge?.copyWith(
        fontSize: 24.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
        fontFeatures: _tabular,
      ),
      headlineMedium: font.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        fontFeatures: _tabular,
      ),
      headlineSmall: font.headlineSmall?.copyWith(
        fontSize: 19.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFeatures: _tabular,
      ),
      titleLarge: font.titleLarge?.copyWith(
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        fontFeatures: _tabular,
      ),
      titleMedium: font.titleMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        fontFeatures: _tabular,
      ),
      titleSmall: font.titleSmall?.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: font.bodyLarge?.copyWith(fontSize: 14, height: 1.45),
      bodyMedium: font.bodyMedium?.copyWith(fontSize: 13, height: 1.42),
      bodySmall: font.bodySmall?.copyWith(fontSize: 11.5, height: 1.35),
      labelLarge: font.labelLarge?.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: font.labelMedium?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      labelSmall: font.labelSmall?.copyWith(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );

    final outlineSide = BorderSide(color: outline);
    OutlineInputBorder inputBorder(double w, [Color? c]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimens.radiusMd),
      borderSide: c == null ? outlineSide : BorderSide(color: c, width: w),
    );

    return base.copyWith(
      textTheme: textTheme,
      visualDensity: VisualDensity.compact,
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.05),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: Dimens.appbarHeight,
        titleSpacing: 16,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(_r),
          side: outlineSide,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryContainer,
        height: Dimens.navBarHeight,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(
            color: textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 21,
            color: states.contains(WidgetState.selected)
                ? onPrimaryContainer
                : textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: primaryContainer,
        selectedIconTheme: IconThemeData(color: onPrimaryContainer, size: 21),
        unselectedIconTheme: IconThemeData(color: textMuted, size: 21),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: textMuted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceAlt : Palette.bgLight,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        constraints: const BoxConstraints(minHeight: Dimens.inputHeight),
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        border: inputBorder(1),
        enabledBorder: inputBorder(1),
        focusedBorder: inputBorder(1.6, primary),
        errorBorder: inputBorder(1, colorScheme.error),
        focusedErrorBorder: inputBorder(1.6, colorScheme.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size(0, Dimens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(0, Dimens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          side: outlineSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.radiusSm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(34, 34),
          padding: const EdgeInsets.all(7),
          iconSize: 19,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        side: outlineSide,
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        labelPadding: const EdgeInsets.symmetric(horizontal: 7),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        iconTheme: IconThemeData(size: 15, color: textMuted),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textMuted,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        dividerColor: outline,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? Palette.surfaceAltDark : Palette.textLight,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: textTheme.labelSmall?.copyWith(
          fontSize: 10.5,
          color: isDark ? Palette.textDark : Palette.surfaceLight,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Palette.surfaceAltDark : Palette.textLight,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? Palette.textDark : Palette.surfaceLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        dataTextStyle: textTheme.bodySmall?.copyWith(
          fontSize: 12.5,
          fontFeatures: _tabular,
        ),
        headingRowHeight: 38,
        dataRowMinHeight: 38,
        dataRowMaxHeight: 46,
        columnSpacing: 22,
        horizontalMargin: 14,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
        circularTrackColor: surfaceAlt,
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusXl),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      iconTheme: IconThemeData(color: textMuted, size: 20),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(isDark ? 6.0 : 7.0),
        thumbVisibility: const WidgetStatePropertyAll(false),
        radius: const Radius.circular(999),
        minThumbLength: 36,
        thumbColor: WidgetStatePropertyAll(
          textMuted.withValues(alpha: isDark ? 0.45 : 0.35),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? surfaceAlt : Palette.bgLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: inputBorder(1),
          enabledBorder: inputBorder(1),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 12 : 8,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.55 : 0.18),
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.radiusMd),
          side: outlineSide,
        ),
        textStyle: textTheme.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusMd),
            ),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.radiusSm),
            ),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: outline)),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(
          outline.withValues(alpha: 0.6),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: textMuted, width: 1.6),
      ),
    );
  }
}
