import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/dimens.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';

/// Executive / Analyst dashboard (PRD §3.11) — read-only strategic BI:
/// OKR KPIs, cost & utilization trends, OTIF donut, branch comparison, CO₂.
class ExecutiveDashboard extends StatelessWidget {
  const ExecutiveDashboard({super.key});

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
              title: 'Executive BI',
              subtitle:
                  'Strategic view — 12-month targets from the PRD success metrics.',
              actions: [
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.mail_rounded, size: 17),
                  label: Text('Schedule email export'),
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.tune_rounded, size: 18),
                  label: Text('Custom report'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: wide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: wide ? 1.35 : 1.1,
              children: const [
                KpiTile(label: 'Fuel cost per km (YTD)', value: '-9.6', unit: '%', delta: 'target −8…−12%', deltaGood: true, icon: Icons.local_gas_station_rounded, accent: Palette.brand),
                KpiTile(label: 'Unplanned downtime', value: '-21', unit: '%', delta: 'target −25%', deltaGood: true, icon: Icons.build_rounded, accent: Palette.warning),
                KpiTile(label: 'On-time delivery', value: '94.2', unit: '%', delta: 'target ≥95%', deltaGood: true, icon: Icons.event_available_rounded, accent: Palette.success, sparkData: [91, 92, 93, 91, 94, 95, 94.2]),
                KpiTile(label: 'Admin hours / vehicle', value: '-38', unit: '%', delta: 'target −40%', deltaGood: true, icon: Icons.schedule_rounded, accent: Palette.violet),
              ],
            ),
            const SizedBox(height: 16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: SectionCard(
                      title: 'Utilization & OTIF trend',
                      subtitle: 'Fleet utilization % · on-time-in-full % · last 7 days',
                      trailing: _TrendLegend(),
                      child: SizedBox(
                        height: 210,
                        child: LineChartWidget(
                          seriesList: [
                            const MultiSeries('Utilization', utilization7d, Palette.brand),
                            const MultiSeries('OTIF', otdTrend7d, Palette.success),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 4,
                    child: _BranchDonut(),
                  ),
                ],
              )
            else ...[
              SectionCard(
                title: 'Utilization & OTIF trend',
                subtitle: 'Fleet utilization % · on-time-in-full % · last 7 days',
                child: SizedBox(
                  height: 210,
                  child: LineChartWidget(
                    seriesList: [
                      const MultiSeries('Utilization', utilization7d, Palette.brand),
                      const MultiSeries('OTIF', otdTrend7d, Palette.success),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _BranchDonut(),
            ],
            const SizedBox(height: 16),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _BranchComparison()),
                  SizedBox(width: 16),
                  Expanded(flex: 4, child: _Co2Card()),
                ],
              )
            else ...[
              _BranchComparison(),
              const SizedBox(height: 16),
              _Co2Card(),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _dot('Utilization', Palette.brand, muted),
      const SizedBox(width: 12),
      _dot('OTIF', Palette.success, muted),
    ]);
  }

  Widget _dot(String l, Color c, Color muted) => Row(children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(l, style: TextStyle(fontSize: 11, color: muted)),
      ]);
}

class _BranchDonut extends StatelessWidget {
  const _BranchDonut();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Fleet composition',
      subtitle: 'Active vehicles by status — live',
      child: Builder(builder: (context) {
        final s = AppScope.of(context);
        return Column(
          children: [
            Center(
              child: DonutChart(
                segments: [
                  (s.onRouteCount.toDouble(), Palette.statusOnRoute),
                  (s.idleCount.toDouble(), Palette.statusIdle),
                  (s.maintCount.toDouble(), Palette.statusMaintenance),
                  (s.offlineCount.toDouble(), Palette.statusOffline),
                ],
                centerLabel: 'vehicles',
                centerValue: '${s.liveVehicles.length}',
                size: 150,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(context, 'On route', Palette.statusOnRoute),
                const SizedBox(width: 12),
                _legend(context, 'Idle', Palette.statusIdle),
                const SizedBox(width: 12),
                _legend(context, 'Maint.', Palette.statusMaintenance),
                const SizedBox(width: 12),
                _legend(context, 'Offline', Palette.statusOffline),
              ],
            ),
            const SizedBox(height: 6),
            Text('Utilization ${s.utilizationPct.toStringAsFixed(0)}% · refreshes live',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        );
      }),
    );
  }

  Widget _legend(BuildContext context, String l, Color c) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(l, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    ]);
  }
}

class _BranchComparison extends StatelessWidget {
  const _BranchComparison();

  @override
  Widget build(BuildContext context) {
    const branches = [
      ('Nairobi Hub', 0.91),
      ('Mombasa Port', 0.84),
      ('Kisumu Depot', 0.78),
      ('Namanga Border', 0.69),
      ('Arusha Partner', 0.62),
    ];
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Branch utilization comparison',
      subtitle: 'Share of vehicles on active duty · October MTD',
      child: Column(
        children: [
          for (final (name, v) in branches) ...[
            LabeledProgress(
              value: v,
              label: name,
              trailing: '${(v * 100).round()}%',
              color: v >= 0.85
                  ? Palette.success
                  : v >= 0.7
                      ? Palette.brand
                      : Palette.warning,
            ),
            const SizedBox(height: 10),
          ],
          Text('Namanga & Arusha flagged — review idle windows and cross-docking capacity.',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Co2Card extends StatelessWidget {
  const _Co2Card();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Sustainability',
      subtitle: 'Green-initiative tracking (FR-29) · ESG report ready',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ScoreRing(value: 78, label: 'Green score', size: 78),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyValueLine(k: 'CO₂ this month', v: '412 t'),
                    KeyValueLine(k: 'CO₂ / km', v: '0.71 kg', vColor: Palette.success),
                    KeyValueLine(k: 'Idle minutes', v: '8.9k', vColor: Palette.warning),
                    KeyValueLine(k: 'Paperless ops', v: '94%'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Palette.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, color: Palette.teal, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'EV share target: 15% by Q3 — currently 10% of fleet.',
                    style: theme.textTheme.labelSmall,
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
