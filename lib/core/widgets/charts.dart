import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/palette.dart';

// ═════════════════════════════════════════════════════════════ Sparkline ══

/// Compact trend line with a soft area fill — used inside KPI tiles.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color = Palette.brand,
    this.height = 34,
    this.strokeWidth = 2,
    this.fill = true,
  });

  final List<double> values;
  final Color color;
  final double height;
  final double strokeWidth;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          values: values,
          color: color,
          strokeWidth: strokeWidth,
          fill: fill,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.fill,
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final range = (max - min) == 0 ? 1.0 : (max - min);
    final dx = size.width / (values.length - 1);

    Offset p(int i) => Offset(
          i * dx,
          size.height - 3 - ((values[i] - min) / range) * (size.height - 6),
        );

    final path = Path()..moveTo(p(0).dx, p(0).dy);
    for (var i = 1; i < values.length; i++) {
      final prev = p(i - 1), curr = p(i);
      final cx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // End-point dot
    final last = p(values.length - 1);
    canvas.drawCircle(last, strokeWidth + 1.2, Paint()..color = color);
    canvas.drawCircle(
        last, strokeWidth + 1.2, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.4);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
}

// ═══════════════════════════════════════════════════════════ Bar chart ══

/// Vertical bar chart with rounded tops and optional axis labels.
class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    super.key,
    required this.series,
    this.color = Palette.brand,
    this.height = 150,
    this.valueFormatter,
    this.highlightLast = true,
  });

  final List<SeriesPoint> series;
  final Color color;
  final double height;
  final String Function(double)? valueFormatter;
  final bool highlightLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < series.length; i++) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    valueFormatter?.call(series[i].value) ??
                        series[i].value.toStringAsFixed(0),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Tooltip(
                        message: '${series[i].label}: ${series[i].value}',
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (i == series.length - 1 && highlightLast)
                                    ? color
                                    : color.withValues(alpha: 0.55),
                                color.withValues(alpha: 0.30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(series[i].label,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (i != series.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════ Grouped bars ══

/// Multi-series grouped bar chart (legend rendered separately by caller).
class GroupedBarChart extends StatelessWidget {
  const GroupedBarChart({
    super.key,
    required this.groups, // labels
    required this.seriesList,
    this.height = 160,
    this.unitSuffix = '',
  });

  final List<String> groups;
  final List<MultiSeries> seriesList;
  final double height;
  final String unitSuffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxV = seriesList
        .expand((s) => s.points.map((p) => p.value))
        .reduce(math.max);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var g = 0; g < groups.length; g++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final s in seriesList)
                          Container(
                            width: 9,
                            height: math.max(
                                6,
                                (s.points[g].value / maxV) *
                                    (height - 34)),
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: s.color,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(groups[g],
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════ Line chart ══

/// Smoothed multi-series line chart with y-grid & labels.
class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.seriesList,
    this.height = 180,
    this.yLabelFormatter,
  });

  final List<MultiSeries> seriesList;
  final double height;
  final String Function(double)? yLabelFormatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;
    final muted = theme.colorScheme.onSurfaceVariant;

    if (seriesList.isEmpty || seriesList.first.points.isEmpty) {
      return SizedBox(height: height);
    }
    final labels = seriesList.first.points.map((p) => p.label).toList();
    final all = seriesList.expand((s) => s.points.map((p) => p.value));
    final maxV = all.reduce(math.max) * 1.12;
    final minV = 0.0;

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _LineChartPainter(
          seriesList: seriesList,
          labels: labels,
          maxV: maxV,
          minV: minV,
          gridColor: outline,
          labelColor: muted,
          yFormatter: yLabelFormatter,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.seriesList,
    required this.labels,
    required this.maxV,
    required this.minV,
    required this.gridColor,
    required this.labelColor,
    this.yFormatter,
  });

  final List<MultiSeries> seriesList;
  final List<String> labels;
  final double maxV, minV;
  final Color gridColor, labelColor;
  final String Function(double)? yFormatter;

  static const _padLeft = 40.0, _padBottom = 22.0, _padTop = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plotW = size.width - _padLeft;
    final plotH = size.height - _padBottom - _padTop;

    // Grid (4 horizontal lines)
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    final labelStyle = TextStyle(fontSize: 10, color: labelColor);
    for (var i = 0; i <= 4; i++) {
      final y = _padTop + plotH * i / 4;
      canvas.drawLine(Offset(_padLeft, y), Offset(size.width, y), gridPaint);
      final v = maxV - (maxV - minV) * i / 4;
      final tp = TextPainter(
        text: TextSpan(
            text: yFormatter?.call(v) ?? v.toStringAsFixed(0),
            style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_padLeft - tp.width - 6, y - tp.height / 2));
    }

    // X labels
    final dx = plotW / math.max(1, labels.length - 1);
    for (var i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(_padLeft + i * dx - tp.width / 2, size.height - _padBottom + 6));
    }

    // Series
    for (final s in seriesList) {
      final n = s.points.length;
      Offset p(int i) => Offset(
            _padLeft + (n == 1 ? plotW / 2 : i * plotW / (n - 1)),
            _padTop + plotH * (1 - (s.points[i].value - minV) / (maxV - minV)),
          );
      final path = Path()..moveTo(p(0).dx, p(0).dy);
      for (var i = 1; i < n; i++) {
        final a = p(i - 1), b = p(i);
        final cx = (a.dx + b.dx) / 2;
        path.cubicTo(cx, a.dy, cx, b.dy, b.dx, b.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
      for (var i = 0; i < n; i++) {
        canvas.drawCircle(p(i), 3, Paint()..color = s.color);
        canvas.drawCircle(
            p(i), 3, Paint()..color = Colors.white..strokeWidth = 1.4..style = PaintingStyle.stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => true;
}

// ══════════════════════════════════════════════════════════ Donut chart ══

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments, // value + color pairs
    required this.centerLabel,
    required this.centerValue,
    this.size = 132,
    this.thickness = 16,
  });

  final List<(double, Color)> segments;
  final String centerLabel;
  final String centerValue;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(segments: segments, thickness: thickness),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValue,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
              const SizedBox(height: 2),
              Text(centerLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.thickness});
  final List<(double, Color)> segments;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0.0, (s, e) => s + e.$1);
    if (total <= 0) return;
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;
    var start = -math.pi / 2;
    for (final (v, c) in segments) {
      final sweep = (v / total) * 2 * math.pi;
      stroke.color = c;
      canvas.drawArc(rect.deflate(thickness / 2 + 1), start, sweep, false, stroke);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.segments != segments;
}

// ═══════════════════════════════════════════════════════ Gauge / ring ══

/// Circular score ring (0..100) with gradient arc & center label.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.value, // 0..100
    required this.label,
    this.size = 74,
    this.color,
    this.sub,
  });

  final double value;
  final String label;
  final double size;
  final Color? color;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? _bandColor(value);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(value: value / 100, color: c),
              ),
              Text(value.toStringAsFixed(0),
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: c,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: theme.textTheme.labelSmall),
        if (sub != null)
          Text(sub!,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  static Color _bandColor(double v) {
    if (v >= 90) return Palette.success;
    if (v >= 75) return Palette.brand;
    if (v >= 60) return Palette.warning;
    return Palette.danger;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = color.withValues(alpha: 0.16);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * value.clamp(0.02, 1),
        colors: [color.withValues(alpha: 0.55), color],
        transform: const GradientRotation(0),
      ).createShader(Offset.zero & size);
    final ringRect = (Offset.zero & size).deflate(4);
    canvas.drawArc(ringRect, 0, 2 * math.pi, false, track);
    canvas.drawArc(ringRect, -math.pi / 2,
        2 * math.pi * value.clamp(0.0, 1), false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color;
}

// ═══════════════════════════════════════════════════ Linear progress ═══

/// Thin labeled progress bar (used for HOS, capacity, stock levels).
class LabeledProgress extends StatelessWidget {
  const LabeledProgress({
    super.key,
    required this.value, // 0..1
    required this.label,
    required this.trailing,
    this.color,
  });

  final double value;
  final String label;
  final String trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? (value > 0.9 ? Palette.danger : value > 0.75 ? Palette.warning : theme.colorScheme.primary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            Text(trailing,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: c, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(c),
          ),
        ),
      ],
    );
  }
}
