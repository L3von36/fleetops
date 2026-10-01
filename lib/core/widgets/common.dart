import 'package:flutter/material.dart';

import '../theme/palette.dart';
import 'charts.dart';

// ══════════════════════════════════════════════════════════════ Section ══

/// Card with a titled header + optional trailing action. The workhorse
/// container of every dashboard panel.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(18),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle case final sub?)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(sub,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════ KPI tile ══

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.delta, // e.g. '+4.2%' or '-8%'
    this.deltaGood = true,
    this.icon,
    this.accent = Palette.brand,
    this.spark,
    this.sparkData = const [],
  });

  final String label;
  final String value;
  final String? unit;
  final String? delta;
  final bool deltaGood;
  final IconData? icon;
  final Color accent;
  final Widget? spark;
  final List<double> sparkData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final good = deltaGood;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null)
                    GradientIconBox(icon: icon!, accent: accent),
                  if (icon != null) const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.25),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0),
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(unit!,
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (delta != null) ...[
                    TrendPill(delta: delta!, good: good),
                    const SizedBox(width: 7),
                  ],
                  Expanded(
                    child: Text('vs last period',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ],
              ),
              if (sparkData.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 26,
                  child: Sparkline(
                      values: sparkData,
                      color: accent,
                      strokeWidth: 1.8,
                      height: 26),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════ Trend pill ══

/// Compact rounded pill for period-over-period deltas.
class TrendPill extends StatelessWidget {
  const TrendPill({super.key, required this.delta, required this.good});

  final String delta;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final c = good ? Palette.success : Palette.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            good ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 13,
            color: c,
          ),
          const SizedBox(width: 3),
          Text(delta,
              style: TextStyle(
                  color: c, fontSize: 11.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════ Gradient icon box ══

/// Softly-glowing tinted square that hosts an icon — used in KPI tiles,
/// list leading slots and empty states.
class GradientIconBox extends StatelessWidget {
  const GradientIconBox({
    super.key,
    required this.icon,
    this.accent = Palette.brand,
    this.size = 36,
    this.iconSize = 19,
  });

  final IconData icon;
  final Color accent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            accent.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.30),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Icon(icon, size: iconSize, color: accent),
    );
  }
}

// ═════════════════════════════════════════════════════════ Empty state ══

/// Friendly placeholder for empty panels / filters with no rows.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientIconBox(icon: icon, size: 56, iconSize: 28),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════ Chips ══

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color, this.dense = false});

  final String label;
  final Color color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final h = dense ? 4.0 : 7.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final c = switch (priority) {
      'High' => Palette.danger,
      'Medium' => Palette.warning,
      _ => Palette.info,
    };
    return StatusChip(label: priority, color: c, dense: true);
  }
}

// ══════════════════════════════════════════════════════════════ Avatar ══

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.size = 38, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .map((p) => p.isEmpty ? '' : p[0])
        .take(2)
        .join()
        .toUpperCase();
    // Deterministic pastel from the name.
    final hue = (name.hashCode % 360).toDouble();
    final bg = color ??
        HSLColor.fromAHSL(1, hue, 0.55, 0.82).toColor();
    final fg = HSLColor.fromAHSL(1, hue, 0.55, 0.30).toColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════ Page header ══

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: 12),
          Wrap(spacing: 10, runSpacing: 10, children: actions!),
        ],
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════ Misc ═════

class IconAction extends StatelessWidget {
  const IconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Icon(
            icon,
            size: 18,
            color: destructive
                ? Palette.danger
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class KeyValueLine extends StatelessWidget {
  const KeyValueLine({super.key, required this.k, required this.v, this.vColor});

  final String k;
  final String v;
  final Color? vColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(v,
              style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: vColor)),
        ],
      ),
    );
  }
}

/// Severity-coded icon for the alert feed.
class SeverityIcon extends StatelessWidget {
  const SeverityIcon({super.key, required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final c = Palette.severityColor(severity);
    final icon = switch (severity) {
      'critical' => Icons.error_rounded,
      'warning' => Icons.warning_amber_rounded,
      _ => Icons.info_rounded,
    };
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.13),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: c, size: 19),
    );
  }
}
