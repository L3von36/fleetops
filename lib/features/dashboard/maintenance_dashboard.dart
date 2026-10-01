import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/theme/dimens.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';

/// Maintenance dashboard (PRD §3.5): service KPIs, work-order pipeline,
/// DTC fault feed, parts stock, service calendar.
class MaintenanceDashboard extends StatelessWidget {
  const MaintenanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: Dimens.pagePadding(MediaQuery.sizeOf(context).width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Maintenance',
              subtitle:
                  'Keep every vehicle available — preventive schedules, work orders and defect triage.',
              actions: [
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.post_add_rounded, size: 18),
                  label: Text('New work order'),
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
                KpiTile(label: 'Due / overdue', value: '3', unit: 'vehicles', delta: '-2', deltaGood: true, icon: Icons.event_busy_rounded, accent: Palette.warning),
                KpiTile(label: 'Open work orders', value: '6', icon: Icons.build_circle_rounded, accent: Palette.brand, sparkData: [8, 9, 7, 8, 6, 7, 6]),
                KpiTile(label: 'Avg. repair time', value: '3.4', unit: 'h MTTR', delta: '-0.6 h', deltaGood: true, icon: Icons.timer_rounded, accent: Palette.teal),
                KpiTile(label: 'Downtime (month)', value: '2.8', unit: '%', delta: '-0.9 pt', deltaGood: true, icon: Icons.power_off_rounded, accent: Palette.danger),
                KpiTile(label: 'Maint. cost / vehicle', value: '412', unit: 'USD', delta: '+4%', deltaGood: false, icon: Icons.payments_rounded, accent: Palette.violet),
              ],
            ),
            const SizedBox(height: 16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 6, child: _WorkOrders()),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _DtcFeed(),
                        const SizedBox(height: 16),
                        _PartsStock(),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _WorkOrders(),
              const SizedBox(height: 16),
              _DtcFeed(),
              const SizedBox(height: 16),
              _PartsStock(),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkOrders extends StatelessWidget {
  const _WorkOrders();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Work orders',
      subtitle: 'Auto-created from schedules & driver DVIR defects (FR-30/31)',
      child: Column(
        children: [
          for (final w in workOrders)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  PriorityChip(priority: w.priority),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.title,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                        Text('${w.vehicleId} · ${w.vendor} · due ${w.dueIn}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip(label: w.status, color: _statusColor(w.status), dense: true),
                      const SizedBox(height: 4),
                      Text('USD ${w.costEstimate.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontFeatures: const [FontFeature.tabularFigures()],
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
        'In shop' => Palette.violet,
        'Scheduled' => Palette.brand,
        'Open' => Palette.warning,
        _ => Palette.success,
      };
}

class _DtcFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const dtcs = [
      ('P0128', 'Coolant thermostat', 'V-104 · FMS-7345', '9 min ago'),
      ('P0401', 'EGR insufficient flow', 'V-109 · FMS-4471', '1 h ago'),
      ('C1095', 'ABS hydraulic pump', 'V-106 · FMS-3120', '3 h ago'),
    ];
    return SectionCard(
      title: 'Diagnostic trouble codes',
      subtitle: 'Ingested live from OBD-II / CAN (FR-33)',
      child: Column(
        children: [
          for (final (code, desc, veh, time) in dtcs)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Palette.danger.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Palette.danger.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Palette.danger.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(code,
                        style: const TextStyle(
                            color: Palette.danger,
                            fontWeight: FontWeight.w800,
                            fontSize: 11)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(desc, style: theme.textTheme.labelLarge),
                        Text('$veh · $time',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const IconAction(icon: Icons.build_rounded, tooltip: 'Create work order'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PartsStock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const parts = [
      ('Brake pads (front)', 0.22),
      ('Oil filters 15W-40', 0.58),
      ('Air filters', 0.34),
      ('Trailer tires 385/65', 0.12),
      ('Coolant 20 L', 0.81),
    ];
    return SectionCard(
      title: 'Parts inventory',
      subtitle: 'Low-stock alerts trigger purchase requests',
      child: Column(
        children: [
          for (final (name, level) in parts) ...[
            LabeledProgress(
              value: level,
              label: name,
              trailing: '${(level * 100).round()}% of par',
              color: level < 0.25
                  ? Palette.danger
                  : level < 0.4
                      ? Palette.warning
                      : null,
            ),
            const SizedBox(height: 10),
          ],
          Text('Reorder automation via procurement API — pilot',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
