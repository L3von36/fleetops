import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/dimens.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/common.dart';

/// Super Admin / Platform Owner dashboard (PRD §3.1): govern the platform —
/// tenants, devices, integration health, feature flags and the audit log.
class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1180;
    final st = AppScope.of(context);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: Dimens.pagePadding(MediaQuery.sizeOf(context).width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Platform Administration',
              subtitle:
                  'Govern tenants, devices and integrations across the whole platform.',
              actions: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export data'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                  label: const Text('Invite user'),
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
              children: [
                KpiTile(
                    label: 'Tenants / orgs',
                    value: '${tenants.length}',
                    delta: '+2',
                    icon: Icons.corporate_fare_rounded,
                    accent: Palette.brand),
                KpiTile(
                    label: 'Active users (24 h)',
                    value: '1,284',
                    delta: '+6.4%',
                    icon: Icons.group_rounded,
                    accent: Palette.teal,
                    sparkData: [980, 1042, 1103, 1150, 1188, 1227, 1284]),
                KpiTile(
                    label: 'Devices online',
                    value: '${st.liveVehicles.length}/10',
                    unit: 'trackers',
                    delta: '100%',
                    icon: Icons.router_rounded,
                    accent: Palette.cyan),
                KpiTile(
                    label: 'API calls today',
                    value: '2.4M',
                    delta: '+11%',
                    icon: Icons.api_rounded,
                    accent: Palette.violet,
                    sparkData: [1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4]),
                KpiTile(
                    label: 'Storage used',
                    value: '612',
                    unit: 'GB of 1 TB',
                    delta: '+3%',
                    icon: Icons.storage_rounded,
                    accent: Palette.warning),
              ],
            ),
            const SizedBox(height: 16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 6, child: _TenantTable()),
                  const SizedBox(width: 16),
                  const Expanded(flex: 4, child: _IntegrationHealth()),
                ],
              )
            else ...[
              const _TenantTable(),
              const SizedBox(height: 16),
              const _IntegrationHealth(),
            ],
            const SizedBox(height: 16),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _AuditLog()),
                  SizedBox(width: 16),
                  Expanded(flex: 4, child: _FlagsPanel()),
                ],
              )
            else ...[
              const _FlagsPanel(),
              const SizedBox(height: 16),
              const _AuditLog(),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Tenants table ───────────────────────────────────────────────────────

class _TenantTable extends StatelessWidget {
  const _TenantTable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Organizations & branches',
      subtitle: 'Multi-tenant registry (PRD FR-2) — plan, seats and status',
      trailing: IconAction(
          icon: Icons.add_rounded, tooltip: 'New tenant', onTap: () {}),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 26,
          columns: const [
            DataColumn(label: Text('ORGANIZATION')),
            DataColumn(label: Text('PLAN')),
            DataColumn(label: Text('SEATS')),
            DataColumn(label: Text('FLEET')),
            DataColumn(label: Text('REGION')),
            DataColumn(label: Text('STATUS')),
          ],
          rows: [
            for (final t in tenants)
              DataRow(cells: [
                DataCell(Text(t.name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600))),
                DataCell(Text(t.plan)),
                DataCell(Text('${t.seatsUsed}/${t.seatsTotal}')),
                DataCell(Text('${t.vehicles}')),
                DataCell(Text(t.region)),
                DataCell(StatusChip(
                  label: t.status,
                  color: switch (t.status) {
                    'Active' => Palette.success,
                    'Trial' => Palette.info,
                    _ => Palette.danger,
                  },
                  dense: true,
                )),
              ]),
          ],
        ),
      ),
    );
  }
}

// ── Integration health ──────────────────────────────────────────────────

class _IntegrationHealth extends StatelessWidget {
  const _IntegrationHealth();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Integration health',
      subtitle: 'ERP, geo, finance & notification connectors (FR-53/54)',
      trailing: const StatusChip(label: '1 degraded', color: Palette.warning, dense: true),
      child: Column(
        children: [
          for (final i in integrations) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  GradientIconBox(
                    icon: switch (i.kind) {
                      'IoT' => Icons.sensors_rounded,
                      'Geo' => Icons.map_rounded,
                      'ERP' => Icons.domain_rounded,
                      'Finance' => Icons.account_balance_rounded,
                      _ => Icons.notifications_rounded,
                    },
                    accent: i.ok ? Palette.teal : Palette.warning,
                    size: 34,
                    iconSize: 17,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                        Text(i.detail,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${i.latencyMs} ms',
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: i.ok
                            ? theme.colorScheme.onSurfaceVariant
                            : Palette.warning,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i.ok ? Palette.success : Palette.warning,
                      boxShadow: [
                        BoxShadow(
                            color: (i.ok ? Palette.success : Palette.warning)
                                .withValues(alpha: 0.4),
                            blurRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != integrations.last) const Divider(),
          ],
        ],
      ),
    );
  }
}

// ── Audit log ───────────────────────────────────────────────────────────

class _AuditLog extends StatelessWidget {
  const _AuditLog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Audit log',
      subtitle: 'Every sensitive action is recorded (PRD FR-4)',
      trailing: IconAction(
          icon: Icons.filter_list_rounded, tooltip: 'Filter', onTap: () {}),
      child: Column(
        children: [
          for (final e in auditLog.take(6)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.5),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 11),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: switch (e.result) {
                        'success' => Palette.success,
                        'denied' => Palette.danger,
                        _ => Palette.warning,
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(e.actor,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600))),
                  Expanded(
                    flex: 3,
                    child: Text(e.action,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontFamilyFallback: const ['monospace'],
                            color: theme.colorScheme.onSurfaceVariant))),
                  Expanded(
                    flex: 3,
                    child: Text(e.target,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                  Text(e.time,
                      style: theme.textTheme.labelSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (e != auditLog.take(6).last) const Divider(),
          ],
        ],
      ),
    );
  }
}

// ── Feature flags ───────────────────────────────────────────────────────

class _FlagsPanel extends StatefulWidget {
  const _FlagsPanel();

  @override
  State<_FlagsPanel> createState() => _FlagsPanelState();
}

class _FlagsPanelState extends State<_FlagsPanel> {
  late List<FeatureFlag> _flags = List.of(featureFlags);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Feature flags',
      subtitle: 'Progressive rollout of PRD roadmap capabilities',
      child: Column(
        children: [
          for (final f in _flags) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.key,
                            style: theme.textTheme.labelMedium?.copyWith(
                                fontFamilyFallback: const ['monospace'],
                                fontWeight: FontWeight.w700)),
                        Text(f.description,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: Switch(
                      value: f.enabled,
                      onChanged: (v) => setState(() {
                        _flags = [
                          for (final x in _flags)
                            if (x.key == f.key) x.toggle(v) else x
                        ];
                      }),
                    ),
                  ),
                ],
              ),
            ),
            if (f != _flags.last) const Divider(),
          ],
        ],
      ),
    );
  }
}
