import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'palette.dart';

/// FleetOps — professional theme builder (light & dark).
///
/// Rules of the system:
///  • 4 px spacing grid; 16 px card radius; 12 px input radius.
///  • Headings tightened (-0.5 .. -1.0 letter-spacing), body airy.
///  • Tabular figures for every numeric UI element (KPIs, tables).
abstract final class AppTheme {
  static const Radius _r = Radius.circular(16);

  static const _tabular = [
    FontFeature.tabularFigures(),
  ];

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
      secondaryContainer: isDark ? const Color(0xFF0E3A3B) : const Color(0xFFD8F2F2),
      onSecondaryContainer: isDark ? const Color(0xFFB8E8E8) : const Color(0xFF0A5C5D),
      tertiary: Palette.violet,
      onTertiary: Colors.white,
      tertiaryContainer: isDark ? const Color(0xFF372C6E) : const Color(0xFFE7E0FF),
      onTertiaryContainer: isDark ? const Color(0xFFD9CFFF) : const Color(0xFF4C31B8),
      error: isDark ? const Color(0xFFFF867C) : Palette.danger,
      onError: isDark ? const Color(0xFF4A0B06) : Colors.white,
      errorContainer: isDark ? const Color(0xFF5C1510) : const Color(0xFFFDE3E1),
      onErrorContainer: isDark ? const Color(0xFFFFC9C4) : const Color(0xFF93312B),
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

    TextTheme tune(TextTheme t) => t.copyWith(
          displaySmall: t.displaySmall?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -1.0, fontFeatures: _tabular),
          headlineMedium: t.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -0.8, fontFeatures: _tabular),
          headlineSmall: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -0.6, fontFeatures: _tabular),
          titleLarge: t.titleLarge?.copyWith(
              fontWeight: FontWeight.w700, letterSpacing: -0.4, fontFeatures: _tabular),
          titleMedium: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w600, letterSpacing: -0.2, fontFeatures: _tabular),
          titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          bodyMedium: t.bodyMedium?.copyWith(height: 1.45),
          bodySmall: t.bodySmall?.copyWith(height: 1.38),
          labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
        );

    final textTheme = tune(font);

    return base.copyWith(
      textTheme: textTheme,
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.05),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
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
          side: BorderSide(color: outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryContainer,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(
              color: textMuted, fontWeight: FontWeight.w600, fontSize: 11),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: 23,
              color: states.contains(WidgetState.selected) ? onPrimaryContainer : textMuted,
            )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: primaryContainer,
        selectedIconTheme: IconThemeData(color: onPrimaryContainer, size: 23),
        unselectedIconTheme: IconThemeData(color: textMuted, size: 23),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: text, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceAlt : Palette.bgLight,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 14.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 14.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? Palette.surfaceAltDark : Palette.textLight,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.labelSmall?.copyWith(
            color: isDark ? Palette.textDark : Palette.surfaceLight),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Palette.surfaceAltDark : Palette.textLight,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
            color: isDark ? Palette.textDark : Palette.surfaceLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.labelMedium?.copyWith(
            color: textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.4),
        dataTextStyle: textTheme.bodyMedium?.copyWith(fontFeatures: _tabular),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
        circularTrackColor: surfaceAlt,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: IconThemeData(color: textMuted, size: 22),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStatePropertyAll(isDark ? 7.0 : 8.0),
        thumbVisibility: const WidgetStatePropertyAll(false),
        radius: Radius.circular(999),
        thumbColor: WidgetStatePropertyAll(
            textMuted.withValues(alpha: isDark ? 0.45 : 0.35)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? surfaceAlt : Palette.bgLight,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: outline),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 12 : 8,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.55 : 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: outline),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14))),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))),
          side: WidgetStatePropertyAll(BorderSide(color: outline)),
          textStyle: WidgetStatePropertyAll(
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor:
            WidgetStatePropertyAll(outline.withValues(alpha: 0.6)),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: textMuted, width: 1.6),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
