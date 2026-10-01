import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/palette.dart';

/// Stylized "operations map" — a lightweight, dependency-free canvas mock of
/// the live-tracking map (PRD FR-14/15): street grid, district blocks, depot
/// marker, geofence ring, animated route pulses and live vehicle markers.
///
/// Swap-in point: replace with google_maps_flutter / maplibre while keeping
/// this widget's public interface (vehicles, onTapVehicle).
class LiveMap extends StatefulWidget {
  const LiveMap({
    super.key,
    required this.vehicles,
    this.onTapVehicle,
    this.selectedVehicleId,
    this.showGeofence = true,
    this.showRoutes = true,
  });

  final List<Vehicle> vehicles;
  final void Function(Vehicle)? onTapVehicle;
  final String? selectedVehicleId;
  final bool showGeofence;
  final bool showRoutes;

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _MapPainter(
            vehicles: widget.vehicles,
            dark: dark,
            outline: theme.colorScheme.outline,
            t: _pulse.value,
            showGeofence: widget.showGeofence,
            showRoutes: widget.showRoutes,
            selectedId: widget.selectedVehicleId,
            onTapVehicle: widget.onTapVehicle,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.vehicles,
    required this.dark,
    required this.outline,
    required this.t,
    required this.showGeofence,
    required this.showRoutes,
    required this.selectedId,
    required this.onTapVehicle,
  });

  final List<Vehicle> vehicles;
  final bool dark;
  final Color outline;
  final double t;
  final bool showGeofence, showRoutes;
  final String? selectedId;
  final void Function(Vehicle)? onTapVehicle;

  static const List<List<OffsetXy>> routes = [
    [OffsetXy(0.08, 0.62), OffsetXy(0.22, 0.30), OffsetXy(0.40, 0.18), OffsetXy(0.55, 0.22)],
    [OffsetXy(0.55, 0.22), OffsetXy(0.70, 0.34), OffsetXy(0.70, 0.48), OffsetXy(0.82, 0.62)],
    [OffsetXy(0.14, 0.42), OffsetXy(0.30, 0.52), OffsetXy(0.40, 0.55), OffsetXy(0.62, 0.72)],
    [OffsetXy(0.33, 0.14), OffsetXy(0.42, 0.30), OffsetXy(0.47, 0.40)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // ── Base ──────────────────────────────────────────────────────────
    final base = Paint()
      ..color = dark ? const Color(0xFF0E1729) : const Color(0xFFE8EEF6);
    canvas.drawRect(Offset.zero & size, base);

    // District "blocks"
    final blockPaint = Paint()
      ..color = dark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.65);
    final rnd = math.Random(7);
    for (var i = 0; i < 46; i++) {
      final w = 18.0 + rnd.nextDouble() * 70;
      final h = 14.0 + rnd.nextDouble() * 54;
      final x = rnd.nextDouble() * (size.width - w);
      final y = rnd.nextDouble() * (size.height - h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(3)),
        blockPaint,
      );
    }

    // Street grid
    final street = Paint()
      ..color = dark ? Colors.white.withValues(alpha: 0.06) : Colors.white
      ..strokeWidth = 5;
    for (var i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), street);
      final y = size.height * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), street);
    }
    final avenue = Paint()
      ..color = dark ? Colors.white.withValues(alpha: 0.10) : Colors.white
      ..strokeWidth = 10;
    canvas.drawLine(Offset(0, size.height * 0.36), Offset(size.width, size.height * 0.30), avenue);
    canvas.drawLine(Offset(size.width * 0.55, 0), Offset(size.width * 0.62, size.height), avenue);

    // Park / water accents
    final park = Paint()..color = dark ? const Color(0xFF12351F) : const Color(0xFFDDEFDB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.05, size.height * 0.72, size.width * 0.16, size.height * 0.18),
          const Radius.circular(8)),
      park,
    );
    final water = Paint()..color = dark ? const Color(0xFF123047) : const Color(0xFFD8EAF7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.78, size.height * 0.76, size.width * 0.18, size.height * 0.16),
          const Radius.circular(10)),
      water,
    );

    Offset to(OffsetXy p) => Offset(p.x * size.width, p.y * size.height);

    // ── Routes ────────────────────────────────────────────────────────
    if (showRoutes) {
      for (final r in routes) {
        final path = Path()..moveTo(to(r.first).dx, to(r.first).dy);
        for (final p in r.skip(1)) {
          path.lineTo(to(p).dx, to(p).dy);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = Palette.brand.withValues(alpha: dark ? 0.35 : 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    // ── Geofence ──────────────────────────────────────────────────────
    if (showGeofence) {
      final c = to(const OffsetXy(0.47, 0.40));
      final r = size.width * 0.09;
      final fence = Paint()
        ..color = Palette.teal.withValues(alpha: 0.14)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(c, r, fence);
      canvas.drawCircle(
          c, r, Paint()..color = Palette.teal..style = PaintingStyle.stroke..strokeWidth = 1.6);
      canvas.drawCircle(
          c, r * (0.6 + 0.4 * t), Paint()..color = Palette.teal.withValues(alpha: 0.35 * (1 - t))..style = PaintingStyle.stroke..strokeWidth = 2);
      _label(canvas, 'Depot geofence', c + Offset(0, r + 12), dark);
    }

    // ── Depot marker ──────────────────────────────────────────────────
    final depot = to(const OffsetXy(0.08, 0.62));
    canvas.drawCircle(depot, 6, Paint()..color = Palette.violet);
    canvas.drawCircle(depot, 6,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    _label(canvas, 'Depot A', depot + const Offset(0, -14), dark);

    // ── Vehicle markers ───────────────────────────────────────────────
    for (final v in vehicles) {
      final p = to(v.mapPos);
      final c = Palette.statusColor(v.statusLabel);

      // pulse for moving vehicles
      if (v.status == VehicleStatus.onRoute) {
        canvas.drawCircle(p, 10 + 8 * t,
            Paint()..color = c.withValues(alpha: 0.30 * (1 - t)));
      }

      // halo for selection
      if (selectedId == v.id) {
        canvas.drawCircle(
            p, 16, Paint()..color = c.withValues(alpha: 0.22));
        canvas.drawCircle(
            p, 16, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 1.6);
      }

      // pin
      canvas.drawCircle(p, 7.5, Paint()..color = c);
      canvas.drawCircle(p, 7.5,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      if (v.status == VehicleStatus.onRoute) {
        // heading tick
        canvas.drawLine(
          p,
          p + const Offset(0, -11),
          Paint()
            ..color = c
            ..strokeWidth = 2.4
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _label(Canvas canvas, String text, Offset at, bool dark) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: dark ? Colors.white70 : const Color(0xFF33415C),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromCenter(
        center: at, width: tp.width + 10, height: tp.height + 6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        Paint()
          ..color = (dark ? Colors.black : Colors.white).withValues(alpha: 0.75));
    tp.paint(canvas, rect.topLeft + const Offset(5, 3));
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.t != t || old.vehicles != vehicles || old.selectedId != selectedId;
}
