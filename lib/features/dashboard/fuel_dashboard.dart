import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/theme/dimens.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';

/// Fuel & Energy dashboard (PRD §3.8): consumption KPIs, spend trend,
/// anomaly/theft flags, eco-driving leaderboard, EV charging.
class FuelDashboard extends StatelessWidget {
  const FuelDashboard({super.key});

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
              title: 'Fuel & Energy',
              subtitle:
                  'Fuel is the 2nd-largest fleet cost — consumption, fraud alerts and eco-driving.',
              actions: [
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.credit_card_rounded, size: 17),
                  label: Text('Reconcile fuel cards'),
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.flag_rounded, size: 18),
                  label: Text('Flag anomalies'),
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
                KpiTile(label: 'Fuel consumed (7 d)', value: '5.0', unit: 'kL', delta: '-6%', deltaGood: true, icon: Icons.local_gas_station_rounded, accent: Palette.brand, sparkData: [8.2, 7.9, 8.4, 8.0, 7.6, 5.9, 4.2]),
                KpiTile(label: 'Avg. efficiency', value: '3.2', unit: 'km/L', delta: '+0.2', deltaGood: true, icon: Icons.bolt_rounded, accent: Palette.teal),
                KpiTile(label: 'Idle fuel waste', value: '142', unit: 'L / wk', delta: '-18 L', deltaGood: true, icon: Icons.hourglass_bottom_rounded, accent: Palette.warning),
                KpiTile(label: 'Anomaly flags', value: '2', unit: 'open', delta: '+1', deltaGood: false, icon: Icons.gpp_maybe_rounded, accent: Palette.danger),
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
                      title: 'Diesel vs EV energy',
                      subtitle: 'kL diesel · MWh electric · last 7 days (EV-ready, FR-28)',
                      trailing: _SeriesLegend(),
                      child: GroupedBarChart(
                        groups: fuelVsEvEnergy7d.first.points.map((p) => p.label).toList(),
                        seriesList: fuelVsEvEnergy7d,
                        height: 190,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: SectionCard(
                      title: 'Fuel spend trend',
                      subtitle: 'USD per day · last 7 days',
                      child: SizedBox(
                        height: 190,
                        child: BarChartWidget(series: fuelTrend7d, color: Palette.info, valueFormatter: (v) => v.round().toString()),
                      ),
                    ),
                  ),
                ],
              )
            else ...[
              SectionCard(
                title: 'Diesel vs EV energy',
                subtitle: 'kL diesel · MWh electric · last 7 days (EV-ready, FR-28)',
                child: GroupedBarChart(
                  groups: fuelVsEvEnergy7d.first.points.map((p) => p.label).toList(),
                  seriesList: fuelVsEvEnergy7d,
                  height: 190,
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Fuel spend trend',
                subtitle: 'USD per day · last 7 days',
                child: SizedBox(
                  height: 190,
                  child: BarChartWidget(series: fuelTrend7d, color: Palette.info, valueFormatter: (v) => v.round().toString()),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _RefuelEvents()),
                  SizedBox(width: 16),
                  Expanded(flex: 4, child: _EcoLeaderboard()),
                ],
              )
            else ...[
              _RefuelEvents(),
              const SizedBox(height: 16),
              _EcoLeaderboard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeriesLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (final s in fuelVsEvEnergy7d)
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(children: [
            Container(width: 9, height: 9,
                decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 5),
            Text(s.name, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: muted)),
          ]),
        ),
    ]);
  }
}

class _RefuelEvents extends StatelessWidget {
  const _RefuelEvents();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Refuel events vs tank telemetry',
      subtitle: 'Card transactions cross-checked with GPS position & tank-level drops (FR-26)',
      child: Column(
        children: [
          for (final f in fuelEvents)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: f.suspicious
                        ? Palette.danger.withValues(alpha: 0.4)
                        : theme.colorScheme.outline),
                color: f.suspicious ? Palette.danger.withValues(alpha: 0.05) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (f.suspicious ? Palette.danger : Palette.brand)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                        f.suspicious
                            ? Icons.report_rounded
                            : Icons.local_gas_station_rounded,
                        size: 18,
                        color: f.suspicious ? Palette.danger : Palette.brand),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('${f.vehicleId} · ${f.liters.toStringAsFixed(0)} L',
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge),
                            ),
                            Text('USD ${f.cost.toStringAsFixed(0)}',
                                style: theme.textTheme.labelLarge),
                          ],
                        ),
                        Text(
                          f.suspicious
                              ? '${f.station} · ${f.timeAgo} · anomaly ${f.anomalyScore.toStringAsFixed(2)} — possible siphoning'
                              : '${f.station} · ${f.timeAgo} · anomaly ${f.anomalyScore.toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: f.suspicious
                                  ? Palette.danger
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: f.suspicious ? FontWeight.w700 : null),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconAction(icon: f.suspicious ? Icons.gavel_rounded : Icons.check_rounded,
                      tooltip: f.suspicious ? 'Open investigation' : 'Verify', destructive: f.suspicious),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EcoLeaderboard extends StatelessWidget {
  const _EcoLeaderboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ranked = [...drivers]..sort((a, b) => b.fuelScore.compareTo(a.fuelScore));
    return Column(
      children: [
        SectionCard(
          title: 'Eco-driving leaderboard',
          subtitle: 'Fuel score = consumption vs route baseline · rewards monthly',
          child: Column(
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text('#${i + 1}',
                            style: theme.textTheme.labelLarge?.copyWith(
                                color: i < 3 ? Palette.success : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w800)),
                      ),
                      UserAvatar(name: ranked[i].name, size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(ranked[i].name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                      ),
                      SizedBox(
                        width: 60,
                        child: ScoreRing(value: ranked[i].fuelScore, label: '', size: 32),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'EV readiness',
          subtitle: 'Fleet: 1 eTruck in service · 4 chargers at Depot B (FR-28/29)',
          child: Column(
            children: [
              LabeledProgress(value: 0.72, label: 'BYD eTruck — state of charge', trailing: '72% · 148 km range', color: Palette.teal),
              const SizedBox(height: 10),
              LabeledProgress(value: 0.31, label: 'Charger 2 — session active', trailing: '31 kW', color: Palette.teal),
              const SizedBox(height: 10),
              KeyValueLine(k: 'Energy consumed (7 d)', v: '7.4 MWh'),
              KeyValueLine(k: 'CO₂ avoided vs diesel', v: '3.9 t', vColor: Palette.success),
            ],
          ),
        ),
      ],
    );
  }
}
