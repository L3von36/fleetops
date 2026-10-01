import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/dimens.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';

/// Driver app home (PRD §3.4) — glanceable, one-handed, offline-first.
/// Today's assignment · HOS ring · quick actions · stops timeline ·
/// scorecard · document wallet · SOS.
class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key, this.driverId = 'D-01'});

  final String driverId;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final theme = Theme.of(context);
    final me = s.liveVehicles.isNotEmpty ? driverById(driverId) : drivers.first;
    final myTrip = trips.where((t) => t.driverId == me.id && (t.status == TripStatus.inProgress || t.status == TripStatus.assigned)).firstOrNull ??
        trips.firstWhere((t) => t.driverId == me.id);
    final myVehicle = s.liveVehicles.where((v) => v.driverId == me.id).firstOrNull ?? vehicles.first;

    final body = SingleChildScrollView(
      padding: Dimens.pagePadding(MediaQuery.sizeOf(context).width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting + HOS ──────────────────────────────────────────
          Row(
            children: [
              const UserAvatar(name: 'Joseph Kimani', size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning, Joseph',
                        style: theme.textTheme.titleLarge),
                    Text('Duty day 4 of 5 · Vehicle ${myVehicle.plate}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              _HosRing(hoursLeft: me.hosRemainingH ?? 4.5),
            ],
          ),
          const SizedBox(height: 16),

          // ── Assignment card ─────────────────────────────────────────
          _AssignmentCard(trip: myTrip, vehicle: myVehicle),
          const SizedBox(height: 14),

          // ── Quick actions ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _QuickAction(icon: Icons.camera_alt_rounded, label: 'Scan POD', color: Palette.brand, onTap: () {}),
                    _QuickAction(icon: Icons.fact_check_rounded, label: 'Inspection', color: Palette.teal, onTap: () {}),
                    _QuickAction(icon: Icons.local_gas_station_rounded, label: 'Fuel log', color: Palette.info, onTap: () {}),
                    _QuickAction(icon: Icons.receipt_long_rounded, label: 'Expense', color: Palette.violet, onTap: () {}),
                    _QuickAction(icon: Icons.report_problem_rounded, label: 'Report issue', color: Palette.warning, onTap: () {}),
                    _QuickAction(icon: Icons.sos_rounded, label: 'SOS', color: Palette.danger, onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Stops timeline ──────────────────────────────────────────
          _StopsTimeline(trip: myTrip),
          const SizedBox(height: 16),

          // ── Scorecard ───────────────────────────────────────────────
          SectionCard(
            title: 'My scorecard',
            subtitle: 'Weekly rolling · rewards unlock at 90+',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ScoreRing(value: me.safetyScore, label: 'Safety', size: 64),
                ScoreRing(value: me.fuelScore, label: 'Fuel eco', size: 64),
                ScoreRing(value: me.punctuality, label: 'Punctuality', size: 64),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Documents wallet ────────────────────────────────────────
          SectionCard(
            title: 'Documents wallet',
            subtitle: 'License · permits · certificates (offline cached)',
            child: Column(
              children: [
                _docRow(context, Icons.badge_rounded, 'Driving licence — Class CE', 'Valid to ${me.licenseExpiry}', Palette.success),
                _docRow(context, Icons.approval_rounded, 'ADR / Hazmat certificate', 'Renew in 41 days', Palette.warning),
                _docRow(context, Icons.medical_services_rounded, 'Medical fitness', 'Valid to 2026-12-01', Palette.success),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 15, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Offline mode ready — trips, PODs and logs sync automatically when back online (FR: offline-first).',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // On wide screens, center the phone-first layout in a comfortable column.
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: body,
        ),
      ),
    );
  }

  Widget _docRow(BuildContext context, IconData icon, String title, String sub, Color c) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 18, color: c),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                Text(sub,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const IconAction(icon: Icons.chevron_right_rounded, tooltip: 'Open'),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════ HOS ring ══

class _HosRing extends StatelessWidget {
  const _HosRing({required this.hoursLeft});
  final double hoursLeft;

  @override
  Widget build(BuildContext context) {
    final c = hoursLeft < 2
        ? Palette.danger
        : hoursLeft < 4
            ? Palette.warning
            : Palette.success;
    return Column(
      children: [
        Stack(alignment: Alignment.center, children: [
          ScoreRing(value: hoursLeft / 11 * 100, label: '', size: 52),
          Text('HOS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 4),
        Text('${hoursLeft.toStringAsFixed(1)} h left',
            style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════ Assignment card ══

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.trip, required this.vehicle});

  final Trip trip;
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D3FB8), Color(0xFF2C5BF2)],
        ),
        boxShadow: [
          BoxShadow(
              color: Palette.brand.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('TODAY · ${trip.id}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4)),
              ),
              const Spacer(),
              StatusChip(label: trip.statusLabel, color: Colors.white, dense: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(trip.customer,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('${trip.origin} → ${trip.destination}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
          const Divider(height: 22, color: Colors.white24),
          Row(
            children: [
              Expanded(
                child: _whiteStat(context, Icons.place_rounded, 'Next stop', trip.destination),
              ),
              Expanded(
                child: _whiteStat(context, Icons.schedule_rounded, 'ETA', trip.etaTime),
              ),
              Expanded(
                child: _whiteStat(context, Icons.thermostat_rounded, 'Cargo',
                    vehicle.cargoTempC != null ? '${vehicle.cargoTempC} °C' : 'Ambient'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Palette.brandDeep,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text('Start navigation'),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  tooltip: 'Call dispatcher',
                  onPressed: () {},
                  icon: const Icon(Icons.call_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whiteStat(BuildContext context, IconData i, String l, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(i, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(l, style: TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
        const SizedBox(height: 3),
        Text(v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════ Quick actions ══

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 92,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 7),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════ Stops timeline ══

class _StopsTimeline extends StatelessWidget {
  const _StopsTimeline({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stops = [
      ('Depot A — loaded', '06:42', true),
      ('Highway checkpoint', '08:15', true),
      (trip.destination, trip.etaTime, false),
    ];

    return SectionCard(
      title: 'Trip stops',
      subtitle: 'Proof of delivery required at final stop',
      child: Column(
        children: [
          for (var i = 0; i < stops.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stops[i].$3 ? Palette.success : theme.colorScheme.primary,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: (stops[i].$3 ? Palette.success : theme.colorScheme.primary)
                                .withValues(alpha: 0.4), blurRadius: 6),
                          ],
                        ),
                        child: stops[i].$3
                            ? const Icon(Icons.check_rounded,
                                size: 12, color: Colors.white)
                            : const SizedBox(),
                      ),
                      if (i != stops.length - 1)
                        Expanded(
                          child: Container(width: 2, color: theme.colorScheme.outline),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stops[i].$1, style: theme.textTheme.labelLarge),
                                Text(
                                  stops[i].$3
                                      ? 'Completed ${stops[i].$2}'
                                      : 'Planned ${stops[i].$2}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          if (!stops[i].$3)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  minimumSize: Size.zero),
                              onPressed: () {},
                              child: const Text('Capture POD'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
