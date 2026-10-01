import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';

/// Dispatcher dashboard (PRD §3.3):
/// unassigned orders queue → assign flow, driver availability board with
/// HOS bars, live ETA board, auto-dispatch suggestions, exception list.
class DispatcherDashboard extends StatelessWidget {
  const DispatcherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Dispatch',
              subtitle:
                  'Plan and run today\'s operations — assign orders, monitor ETAs, resolve exceptions.',
              actions: [
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.upload_file_rounded, size: 17),
                  label: Text('Import CSV'),
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text('Auto-dispatch all'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 5, child: _UnassignedQueue()),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _AvailabilityBoard(),
                        const SizedBox(height: 16),
                        _Exceptions(),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              const _UnassignedQueue(),
              const SizedBox(height: 16),
              _AvailabilityBoard(),
              const SizedBox(height: 16),
              _Exceptions(),
            ],
            const SizedBox(height: 16),
            const _EtaBoard(),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════ Unassigned queue ══

class _UnassignedQueue extends StatelessWidget {
  const _UnassignedQueue();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queue = trips.where((t) => t.status == TripStatus.unassigned).toList();

    return SectionCard(
      title: 'Unassigned orders (${queue.length})',
      subtitle: 'Tap a suggestion to assign the best driver & vehicle',
      trailing: TextButton(onPressed: () {}, child: const Text('Board view')),
      child: Column(
        children: [
          for (final t in queue) ...[
            _OrderCard(trip: t),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: theme.colorScheme.outline, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded,
                    size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('Drag new orders here · CSV import · API',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ranked auto-dispatch suggestion (mock logic per FR-22).
    final suggestions = _suggest(trip);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PriorityChip(priority: trip.priority),
              const SizedBox(width: 8),
              Expanded(
                child: Text(trip.customer,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
              ),
              Text('USD ${trip.revenue.toStringAsFixed(0)}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
            ],
          ),
          const SizedBox(height: 4),
          Text('${trip.origin} → ${trip.destination} · ${trip.distanceKm.toStringAsFixed(0)} km · window ${trip.windowStart}–${trip.windowEnd}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          for (final (d, v, score) in suggestions.take(2))
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  UserAvatar(name: d.name, size: 30),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: theme.textTheme.labelLarge),
                        Text('${v.model} · ${v.plate} · HOS ${d.hosRemainingH?.toStringAsFixed(1) ?? "—"} h left',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('match ${score.round()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: Palette.success, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      textStyle: theme.textTheme.labelMedium,
                    ),
                    onPressed: () => _assign(context, d, v),
                    child: const Text('Assign'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<(Driver, Vehicle, double)> _suggest(Trip t) {
    // Proximity + HOS + safety heuristic — purely illustrative (FR-22).
    final scored = <(Driver, Vehicle, double)>[];
    for (final v in vehicles) {
      if (v.status != VehicleStatus.idle) continue;
      final d = driverById(v.driverId);
      final score = (d.safetyScore * 0.4 +
              (d.hosRemainingH ?? 0) * 100 / 11 * 0.3 +
              (100 - d.hoursDrivenToday * 6) * 0.3)
          .clamp(0, 100)
          .toDouble();
      scored.add((d, v, score));
    }
    scored.sort((a, b) => b.$3.compareTo(a.$3));
    return scored;
  }

  void _assign(BuildContext context, Driver d, Vehicle v) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('TRP assigned to ${d.name} — ${v.plate} (demo)'),
        behavior: SnackBarBehavior.floating,
        width: 380,
      ),
    );
  }
}

// ═════════════════════════════════════════════ Availability board ══

class _AvailabilityBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final idleVehicles =
        vehicles.where((v) => v.status == VehicleStatus.idle).toList();

    return SectionCard(
      title: 'Driver & vehicle availability',
      subtitle: 'HOS hours remaining · eligibility · suitability (FR-20)',
      child: Column(
        children: [
          if (idleVehicles.isEmpty)
            Text('No idle vehicles right now — all units committed.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          for (final v in idleVehicles) ...[
            Builder(builder: (_) {
              final d = driverById(v.driverId);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        UserAvatar(name: d.name, size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.name, style: theme.textTheme.labelLarge),
                              Text('${v.model} · ${v.plate} · ${d.statusLabel}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        StatusChip(label: 'Eligible', color: Palette.success, dense: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LabeledProgress(
                      value: d.hoursDrivenToday / d.hoursLimit,
                      label: 'HOS used today',
                      trailing:
                          '${(d.hoursLimit - d.hoursDrivenToday).toStringAsFixed(1)} h left',
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════ Exceptions ══

class _Exceptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exceptions = [
      ('Trip delayed — border congestion', 'TRP-9043 · TransBorder AG', Palette.warning, Icons.schedule_rounded),
      ('Breakdown reported', 'V-106 · FMS-3120 — workshop ETA 20 min', Palette.danger, Icons.report_problem_rounded),
      ('ETA drift > 15 min', 'TRP-9042 · BuildCo Ltd', Palette.warning, Icons.trending_down_rounded),
    ];
    return SectionCard(
      title: 'Exceptions',
      subtitle: 'Delays, breakdowns & anomalies need action',
      child: Column(
        children: [
          for (final (title, sub, color, icon) in exceptions)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withValues(alpha: 0.07),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 19),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.labelLarge),
                        Text(sub,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const IconAction(icon: Icons.more_horiz_rounded, tooltip: 'Resolve'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════ ETA board ══

class _EtaBoard extends StatelessWidget {
  const _EtaBoard();

  @override
  Widget build(BuildContext context) {
    final inTransit = trips
        .where((t) => t.status == TripStatus.inProgress || t.status == TripStatus.delayed)
        .toList();

    return SectionCard(
      title: 'Live ETA board',
      subtitle: 'Recalculated from traffic every 10 s · customers auto-notified (FR-23)',
      trailing: TextButton(onPressed: () {}, child: const Text('Notify log')),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.sizeOf(context).width - (MediaQuery.sizeOf(context).width >= 1180 ? 340 : 72)),
          child: DataTable(
            columnSpacing: 34,
            columns: const [
              DataColumn(label: Text('TRIP')),
              DataColumn(label: Text('CUSTOMER')),
              DataColumn(label: Text('ROUTE')),
              DataColumn(label: Text('VEHICLE')),
              DataColumn(label: Text('LIVE SPEED'), numeric: true),
              DataColumn(label: Text('ETA')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: [
              for (final t in inTransit)
                DataRow(cells: [
                  DataCell(Text(t.id,
                      style: const TextStyle(fontWeight: FontWeight.w700))),
                  DataCell(Text(t.customer)),
                  DataCell(Text('${t.origin} → ${t.destination}')),
                  DataCell(Text(t.vehicleId)),
                  DataCell(Text(_speedOf(context, t.vehicleId))),
                  DataCell(Text(t.etaTime)),
                  DataCell(t.status == TripStatus.delayed
                      ? const StatusChip(label: 'Delayed', color: Palette.warning, dense: true)
                      : const StatusChip(label: 'On time', color: Palette.success, dense: true)),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  String _speedOf(BuildContext context, String vehicleId) {
    final st = AppScope.of(context);
    for (final v in st.liveVehicles) {
      if (v.id == vehicleId) return '${v.speedKph.round()} km/h';
    }
    return '—';
  }
}
