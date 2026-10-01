import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/common.dart';

/// Warehouse / Depot Manager dashboard (PRD §3.9): dock allocation,
/// inbound/outbound schedule, yard geofence check-ins and cold-chain alerts.
class DepotDashboard extends StatelessWidget {
  const DepotDashboard({super.key});

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
              title: 'Depot & Yard',
              subtitle:
                  'Docks, loading status and yard movements — Industrial Area Hub.',
              actions: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Scan parcels'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.local_shipping_rounded, size: 18),
                  label: const Text('Release vehicle'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: wide ? 5 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: wide ? 1.25 : 1.05,
              children: const [
                KpiTile(label: 'Inbound today', value: '14', unit: 'vehicles', delta: '+3', icon: Icons.south_west_rounded, accent: Palette.brand, sparkData: [9, 11, 10, 12, 13, 12, 14]),
                KpiTile(label: 'Outbound today', value: '17', unit: 'vehicles', delta: '+2', icon: Icons.north_east_rounded, accent: Palette.teal, sparkData: [12, 13, 15, 14, 16, 15, 17]),
                KpiTile(label: 'Docks occupied', value: '4/6', unit: 'slots', delta: '+1', icon: Icons.warehouse_rounded, accent: Palette.violet),
                KpiTile(label: 'Yard check-ins (2 h)', value: '5', unit: 'geofence', delta: '0', icon: Icons.pin_drop_rounded, accent: Palette.cyan),
                KpiTile(label: 'Cold-chain alerts', value: '1', unit: 'open', delta: '-1', deltaGood: true, icon: Icons.ac_unit_rounded, accent: Palette.danger),
              ],
            ),
            const SizedBox(height: 16),
            const _DockGrid(),
            const SizedBox(height: 16),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _SchedulePanel()),
                  SizedBox(width: 16),
                  Expanded(flex: 4, child: _YardPanel()),
                ],
              )
            else ...[
              const _SchedulePanel(),
              const SizedBox(height: 16),
              const _YardPanel(),
            ],
            const SizedBox(height: 16),
            const _ColdChainPanel(),
          ],
        ),
      ),
    );
  }
}

// ── Dock allocation grid ────────────────────────────────────────────────

class _DockGrid extends StatelessWidget {
  const _DockGrid();

  static Color _color(DockState s) => switch (s) {
        DockState.free => Palette.success,
        DockState.loading => Palette.brand,
        DockState.done => Palette.teal,
        DockState.blocked => Palette.danger,
      };

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Dock & bay allocation',
      subtitle: 'Tap a slot to confirm loading or release the vehicle',
      trailing: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final s in DockState.values)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: _color(s), shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(s.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
        ],
      ),
      child: LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth >= 760 ? 4 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: cols == 4 ? 2.5 : 2.1,
          children: [
            for (final d in dockSlots) _DockCell(slot: d, color: _color(d.state)),
          ],
        );
      }),
    );
  }
}

class _DockCell extends StatelessWidget {
  const _DockCell({required this.slot, required this.color});

  final DockSlot slot;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(slot.id,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                StatusChip(label: slot.state.label, color: color, dense: true),
                const Spacer(),
                Text(slot.window,
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const Spacer(),
            if (slot.vehicleId.isEmpty)
              Text('Available for scheduling',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
            else ...[
              Row(
                children: [
                  Icon(Icons.local_shipping_rounded,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('${slot.vehicleId} · ${driverById((vehicles.firstWhere((v) => v.id == slot.vehicleId, orElse: () => vehicles.first)).driverId).name}',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: slot.loadPct,
                  minHeight: 5,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Inbound / outbound schedule ─────────────────────────────────────────

class _SchedulePanel extends StatelessWidget {
  const _SchedulePanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Vehicle schedule',
      subtitle: 'Next arrivals and departures at this hub',
      child: Column(
        children: [
          for (final (trip, customer, detail) in dockSchedule) ...[
            Builder(builder: (context) {
              final linked = trips.firstWhere((t) => t.id == trip,
                  orElse: () => trips.first);
              final delayed =
                  linked.status == TripStatus.delayed;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    GradientIconBox(
                      icon: detail.startsWith('Inbound')
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      accent: detail.startsWith('Inbound')
                          ? Palette.brand
                          : Palette.teal,
                      size: 34,
                      iconSize: 17,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$trip · $customer',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge),
                          Text(detail,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: delayed ? 'delayed' : 'on time',
                      color: delayed ? Palette.warning : Palette.success,
                      dense: true,
                    ),
                  ],
                ),
              );
            }),
            if (trip != dockSchedule.last.$1) const Divider(),
          ],
        ],
      ),
    );
  }
}

// ── Yard check-ins (geofence) ───────────────────────────────────────────

class _YardPanel extends StatelessWidget {
  const _YardPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Yard movements',
      subtitle: 'Geofence auto check-in / check-out (PRD FR-15)',
      child: Column(
        children: [
          for (final e in yardEvents) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (e.direction == 'in' ? Palette.brand : Palette.violet)
                          .withValues(alpha: 0.13),
                    ),
                    child: Icon(
                      e.direction == 'in'
                          ? Icons.login_rounded
                          : Icons.logout_rounded,
                      size: 17,
                      color: e.direction == 'in'
                          ? Palette.brand
                          : Palette.violet,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.plate,
                            style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700)),
                        Text('${e.direction == 'in' ? 'Arrived' : 'Departed'} via ${e.gate} · ${e.timeAgo}',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: e.onTime ? 'on schedule' : 'off window',
                    color: e.onTime ? Palette.success : Palette.warning,
                    dense: true,
                  ),
                ],
              ),
            ),
            if (e != yardEvents.last) const Divider(),
          ],
        ],
      ),
    );
  }
}

// ── Cold-chain cargo condition ──────────────────────────────────────────

class _ColdChainPanel extends StatelessWidget {
  const _ColdChainPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Cargo condition',
      subtitle: 'Temperature / humidity sensors (PRD FR-44)',
      child: Column(
        children: [
          for (final r in cargoReadings) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  GradientIconBox(
                    icon: Icons.thermostat_rounded,
                    accent: r.inRange ? Palette.teal : Palette.danger,
                    size: 34,
                    iconSize: 17,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.vehicleId} — ${r.cargo}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                        Text(
                            'target ${r.targetC.toStringAsFixed(0)}°C · humidity ${r.humidityPct.toStringAsFixed(0)}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text(
                    '${r.tempC.toStringAsFixed(1)}°C',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: r.inRange ? Palette.success : Palette.danger,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  StatusChip(
                    label: r.inRange ? 'in range' : 'excursion',
                    color: r.inRange ? Palette.success : Palette.danger,
                    dense: true,
                  ),
                ],
              ),
            ),
            if (r != cargoReadings.last) const Divider(),
          ],
        ],
      ),
    );
  }
}
