import 'package:flutter/material.dart';

/// FleetOps design tokens — a single source of truth for color.
///
/// Palette direction: "Operations trust" — deep royal blue as the anchor,
/// teal/violet for data-series variety, and a traffic-light semantic set
/// (green / amber / red) tuned for both light & dark backgrounds.
abstract final class Palette {
  // ── Brand ────────────────────────────────────────────────────────────
  static const Color brand = Color(0xFF2C5BF2);
  static const Color brandDeep = Color(0xFF1D3FB8);
  static const Color brandSoft = Color(0xFFDCE5FF);
  static const Color brandBright = Color(0xFF4F7BFF);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color teal = Color(0xFF0E9394);
  static const Color violet = Color(0xFF7A5AF8);

  /// Signature brand gradient (logo, hero panels, primary accents).
  static const List<Color> brandGradient = [
    Color(0xFF1D3FB8),
    Color(0xFF2C5BF2),
    Color(0xFF4F7BFF),
  ];

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // ── Light neutrals (cool slate) ──────────────────────────────────────
  static const Color bgLight = Color(0xFFF5F7FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFEEF2F9);
  static const Color textLight = Color(0xFF101828);
  static const Color textMutedLight = Color(0xFF5D6B82);
  static const Color outlineLight = Color(0xFFE3E9F2);

  // ── Dark neutrals (deep navy) ────────────────────────────────────────
  static const Color bgDark = Color(0xFF0A101E);
  static const Color surfaceDark = Color(0xFF121C30);
  static const Color surfaceAltDark = Color(0xFF1A2740);
  static const Color textDark = Color(0xFFE7EEF9);
  static const Color textMutedDark = Color(0xFF8DA2BF);
  static const Color outlineDark = Color(0xFF25334F);

  /// Hairline highlight used to give dark cards a subtle top edge (glass).
  static const Color cardHighlightDark = Color(0x33FFFFFF);
  static const Color cardHighlightLight = Color(0x66FFFFFF);

  // ── Vehicle-status colors (used across map & dashboards) ─────────────
  static const Color statusOnRoute = Color(0xFF2C5BF2);
  static const Color statusIdle = Color(0xFFF59E0B);
  static const Color statusMaintenance = Color(0xFF7A5AF8);
  static const Color statusOffline = Color(0xFF94A3B8);

  /// Map a vehicle status string to its semantic color.
  static Color statusColor(String status) {
    switch (status) {
      case 'On route':
        return statusOnRoute;
      case 'Idle':
        return statusIdle;
      case 'Maintenance':
        return statusMaintenance;
      default:
        return statusOffline;
    }
  }

  /// Severity → color for the alerts feed.
  static Color severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return danger;
      case 'warning':
        return warning;
      default:
        return info;
    }
  }

  /// An ordered categorical series palette for charts.
  static const List<Color> series = [
    Color(0xFF2C5BF2),
    Color(0xFF0E9394),
    Color(0xFF7A5AF8),
    Color(0xFFF59E0B),
    Color(0xFFDC2626),
    Color(0xFF0284C7),
    Color(0xFF16A34A),
    Color(0xFFEC4899),
  ];
}
