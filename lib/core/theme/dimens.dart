import 'package:flutter/material.dart';

/// FleetOps **compact** design tokens — one source of truth for metrics.
///
/// The system targets information-dense operations tooling: controls sit in
/// the 32–40 px band, the type ramp is ~85 % of Material 3 defaults, and all
/// spacing follows a 4 px grid. Every widget should pull metrics from here
/// instead of hard-coding numbers so density stays consistent app-wide.
abstract final class Dimens {
  // ── Spacing (4 px grid) ──────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Standard screen gutter (mobile → desktop widens via [pagePadding]).
  static const double gutter = 16;

  /// Responsive screen padding used by every dashboard page.
  static EdgeInsets pagePadding(double width) => EdgeInsets.fromLTRB(
    width >= 1200 ? 20 : 14,
    14,
    width >= 1200 ? 20 : 14,
    20,
  );

  // ── Radii ────────────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 10;
  static const double radiusLg = 12;
  static const double radiusXl = 16;

  // ── Control heights (compact band) ───────────────────────────────────
  static const double buttonHeight = 38;
  static const double inputHeight = 40;
  static const double chipHeight = 28;
  static const double tileHeight = 44;
  static const double appbarHeight = 52;
  static const double navBarHeight = 58;

  // ── Navigation ───────────────────────────────────────────────────────
  static const double railWidth = 88;
  static const double sidebarWidth = 216;
  static const double sidebarCollapsedWidth = 64;

  // ── Breakpoints (mirror AppShell thresholds) ─────────────────────────
  static const double bpPhone = 700;
  static const double bpDesktop = 1100;

  /// Login splits into a two-pane layout above this width.
  static const double bpLoginSplit = 880;

  /// Content max width for centered forms.
  static const double formMaxWidth = 380;
}
