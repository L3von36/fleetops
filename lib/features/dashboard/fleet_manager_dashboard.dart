import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/live_map.dart';

/// Fleet Manager — primary command center (PRD §3.2).
/// KPI tiles · live map with vehicle cards · alert feed · docs expiring ·
/// driver leaderboard · active trips timeline.
class FleetManagerDashboard extends StatelessWidget {
  const FleetManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 1180;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Command Center',
              subtitle:
                  'Monday, 6 Oct · All systems nominal · ${state.liveVehicles.length} vehicles reporting',
              actions: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.ios_share_rounded, size: 17),
                  label: const Text('Export'),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_road_rounded, size: 18),
                  label: const Text('New trip'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _KpiRow(),
            const SizedBox(height: 16),
            if (wide)
              SizedBox(
                height: 460,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 7, child: _MapPanel()),
                    const SizedBox(width: 16),
                    const Expanded(flex: 3, child: _AlertsPanel()),
                  ],
                ),
              )
            else ...[
              SizedBox(height: 340, child: _MapPanel()),
              const SizedBox(height: 16),
              SizedBox(height: 420, child: _AlertsPanel()),
            ],
            const SizedBox(height: 16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 7, child: _TripsPanel()),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _DocsPanel(),
                        const SizedBox(height: 16),
                        _DriverLeaderboard(),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              const _TripsPanel(),
              const SizedBox(height: 16),
              _DocsPanel(),
              const SizedBox(height: 16),
              _DriverLeaderboard(),
            ],
            const SizedBox(height: 8),
            Text(
              'Position latency ≤ 10 s · map clustering active · demo telemetry simulated every 2 s',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════ KPIs ══

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final tiles = [
      KpiTile(
        label: 'Vehicles on route',
        value: '${s.onRouteCount}',
        unit: 'of ${s.liveVehicles.length}',
        delta: '+6%',
        icon: Icons.route_rounded,
        accent: Palette.statusOnRoute,
        sparkData: [3, 4, 4, 5, 6, 5, 6],
      ),
      KpiTile(
        label: 'Idle',
        value: '${s.idleCount}',
        delta: '-12%',
        deltaGood: true,
        icon: Icons.pause_circle_outline_rounded,
        accent: Palette.statusIdle,
        sparkData: [4, 3, 4, 2, 3, 2, 2],
      ),
      KpiTile(
        label: 'In maintenance',
        value: '${s.maintCount}',
        icon: Icons.build_rounded,
        accent: Palette.statusMaintenance,
        sparkData: [2, 2, 1, 1, 2, 1, 1],
      ),
      KpiTile(
        label: 'On-time delivery',
        value: s.onTimePct.toStringAsFixed(1),
        unit: '%',
        delta: '+1.8 pt',
        icon: Icons.event_available_rounded,
        accent: Palette.success,
        sparkData: [91, 92, 93, 91, 94, 95, 94.2],
      ),
      KpiTile(
        label: 'Fuel cost today',
        value: s.fuelCostToday.toStringAsFixed(0),
        unit: 'USD',
        delta: '-3.4%',
        deltaGood: true,
        icon: Icons.local_gas_station_rounded,
        accent: Palette.info,
        sparkData: [2050, 1980, 2010, 1930, 1900, 1875, 1862],
      ),
      KpiTile(
        label: 'Open alerts',
        value: '${s.liveAlerts.where((a) => !a.acknowledged).length}',
        delta: '-8',
        deltaGood: true,
        icon: Icons.notifications_active_rounded,
        accent: Palette.danger,
        sparkData: [14, 12, 13, 11, 10, 9, 8],
      ),
    ];

    return GridView.count(
      crossAxisCount: wide ? 6 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: wide ? 1.05 : 0.92,
      children: tiles,
    );
  }
}

// ════════════════════════════════════════════════════════════════ Map ══

class _MapPanel extends StatelessWidget {
  const _MapPanel();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Live map', style: theme.textTheme.titleMedium),
                ),
                for (final (label, color) in const [
                  ('On route', Palette.statusOnRoute),
                  ('Idle', Palette.statusIdle),
                  ('Maint.', Palette.statusMaintenance),
                  ('Offline', Palette.statusOffline),
                ])
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(label, style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: LayoutBuilder(builder: (context, box) {
                final isWide = box.maxWidth > 620;
                final map = LiveMap(vehicles: s.liveVehicles);
                if (!isWide) {
                  return Stack(children: [
                    Positioned.fill(child: map),
                    Positioned(
                      right: 10, bottom: 10,
                      child: _VehicleCard(compact: true),
                    ),
                  ]);
                }
                return Stack(children: [
                  Positioned.fill(child: map),
                  Positioned(
                    right: 10, bottom: 10, left: 220,
                    child: _VehicleCard(),
                  ),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final theme = Theme.of(context);
    final v = s.liveVehicles.first;
    final d = driverById(v.driverId);
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: compact
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.local_shipping_rounded, size: 18, color: Palette.brand),
                const SizedBox(width: 8),
                Text(v.plate, style: theme.textTheme.labelLarge),
                const SizedBox(width: 8),
                Text('${v.speedKph.round()} km/h',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ])
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      StatusChip(label: v.statusLabel, color: Palette.statusColor(v.statusLabel), dense: true),
                      const Spacer(),
                      Text(v.plate, style: theme.textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(v.model, style: theme.textTheme.titleSmall),
                  Text('Driver ${d.name}', style: theme.textTheme.bodySmall),
                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _mapStat(context, Icons.speed_rounded, '${v.speedKph.round()}', 'km/h'),
                      _mapStat(context, Icons.local_gas_station_rounded, '${(v.fuelPct * 100).round()}%', 'fuel'),
                      _mapStat(context, Icons.schedule_rounded, '${v.etaMinutes}', 'min ETA'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  KeyValueLine(k: 'Next stop', v: v.nextStop),
                ],
              ),
      ),
    );
  }

  Widget _mapStat(BuildContext context, IconData i, String v, String l) {
    final theme = Theme.of(context);
    return Row(children: [
      Icon(i, size: 15, color: theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 4),
      Text(v, style: theme.textTheme.labelLarge),
      const SizedBox(width: 3),
      Text(l, style: theme.textTheme.labelSmall
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════ Alerts ══

class _AlertsPanel extends StatelessWidget {
  const _AlertsPanel();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Alert feed', style: theme.textTheme.titleMedium)),
                TextButton(onPressed: () {}, child: const Text('View all')),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: s.liveAlerts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final a = s.liveAlerts[i];
                  return _AlertTile(alert: a, onAck: () => s.acknowledgeAlert(a.id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.onAck});
  final FleetAlert alert;
  final VoidCallback onAck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = Palette.severityColor(alert.severity);
    return Opacity(
      opacity: alert.acknowledged ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: alert.acknowledged
                  ? theme.colorScheme.outline
                  : c.withValues(alpha: 0.35)),
          color: alert.acknowledged ? null : c.withValues(alpha: 0.06),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeverityIcon(severity: alert.severity),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(alert.type,
                          style: theme.textTheme.labelLarge?.copyWith(color: c)),
                      const Spacer(),
                      Text(alert.timeAgo,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(alert.message, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(alert.subject,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              height: 30, width: 30,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Acknowledge',
                onPressed: alert.acknowledged ? null : onAck,
                icon: Icon(alert.acknowledged
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded, size: 19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════ Trips ══

class _TripsPanel extends StatelessWidget {
  const _TripsPanel();

  @override
  Widget build(BuildContext context) {
    final activeTrips = trips.where((t) => t.status == TripStatus.inProgress || t.status == TripStatus.delayed).toList();
    return SectionCard(
      title: 'Active trips timeline',
      subtitle: 'Today · Gantt view with planned vs live windows',
      trailing: TextButton(onPressed: () {}, child: const Text('Dispatch board')),
      child: Column(
        children: [
          for (final t in activeTrips)
            _TripTimelineRow(trip: t, vehicles: vehicles),
        ],
      ),
    );
  }
}

class _TripTimelineRow extends StatelessWidget {
  const _TripTimelineRow({required this.trip, required this.vehicles});
  final Trip trip;
  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delayed = trip.status == TripStatus.delayed;
    Vehicle? vehicle;
    for (final v in vehicles) {
      if (v.id == trip.vehicleId) vehicle = v;
    }
    final live = vehicle?.status == VehicleStatus.onRoute;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.customer, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelLarge),
                Text('${trip.origin} → ${trip.destination}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: trip.progress.clamp(0.02, 1),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(colors: delayed
                              ? [Palette.warning.withValues(alpha: 0.6), Palette.warning]
                              : [Palette.brand.withValues(alpha: 0.6), Palette.brand]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text('${(trip.progress * 100).round()}% · ${trip.distanceKm.toStringAsFixed(0)} km',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    if (delayed)
                      StatusChip(label: 'Delayed', color: Palette.warning, dense: true)
                    else if (live)
                      StatusChip(label: 'ETA ${trip.etaTime}', color: Palette.success, dense: true)
                    else
                      StatusChip(label: 'ETA ${trip.etaTime}', color: Palette.info, dense: true),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 84,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('USD ${trip.revenue.toStringAsFixed(0)}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════ Documents & drivers ══

class _DocsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Documents expiring',
      subtitle: 'Reminders fire at 60 / 30 / 7 days (FR-40)',
      child: Column(
        children: [
          for (final d in expiringDocs.take(4))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    switch (d.kind) {
                      'License' => Icons.badge_rounded,
                      'Insurance' => Icons.verified_user_rounded,
                      'Permit' => Icons.approval_rounded,
                      _ => Icons.fact_check_rounded,
                    },
                    size: 19,
                    color: d.daysLeft <= 30 ? Palette.danger : Palette.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                        Text('${d.kind} · ${d.owner}',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: (d.daysLeft <= 30 ? Palette.danger : Palette.warning)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${d.daysLeft} d',
                      style: TextStyle(
                          color: d.daysLeft <= 30 ? Palette.danger : Palette.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
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

class _DriverLeaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ranked = [...drivers]..sort((a, b) => b.safetyScore.compareTo(a.safetyScore));
    return SectionCard(
      title: 'Top drivers — safety score',
      trailing: TextButton(onPressed: () {}, child: const Text('Rankings')),
      child: Column(
        children: [
          for (final d in ranked.take(4))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  UserAvatar(name: d.name, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: theme.textTheme.labelLarge),
                        Text(d.statusLabel,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    child: ScoreRing(value: d.safetyScore, label: '', size: 38, sub: null),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
