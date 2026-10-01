import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';

/// Safety & Compliance dashboard (PRD §3.6): fleet safety gauge, harsh-event
/// trend, driver risk ranking, HOS violations, expiring docs, incidents.
class SafetyDashboard extends StatelessWidget {
  const SafetyDashboard({super.key});

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
              title: 'Safety & Compliance',
              subtitle:
                  'Reduce risk, avoid fines — behavior scoring, HOS/ELD packs and document control.',
              actions: [
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.picture_as_pdf_rounded, size: 17),
                  label: RegulatorExportLabel(),
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.school_rounded, size: 18),
                  label: Text('Assign coaching'),
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
                KpiTile(label: 'Fleet safety score', value: '87', unit: '/100', delta: '+2', icon: Icons.health_and_safety_rounded, accent: Palette.success),
                KpiTile(label: 'Harsh events / 1,000 km', value: '6.4', delta: '-30%', deltaGood: true, icon: Icons.speed_rounded, accent: Palette.warning, sparkData: [14, 11, 16, 9, 12, 6, 4]),
                KpiTile(label: 'HOS violations (30 d)', value: '2', delta: '-4', deltaGood: true, icon: Icons.gavel_rounded, accent: Palette.violet),
                KpiTile(label: 'Docs expiring ≤ 30 d', value: '3', icon: Icons.event_note_rounded, accent: Palette.danger),
              ],
            ),
            const SizedBox(height: 16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 5,
                    child: SectionCard(
                      title: 'Harsh events trend',
                      subtitle: 'Braking · acceleration · cornering per 1,000 km',
                      child: SizedBox(
                        height: 190,
                        child: BarChartWidget(
                          series: harshEvents7d,
                          color: Palette.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _RiskRanking()),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _HosPanel()),
                ],
              )
            else ...[
              SectionCard(
                title: 'Harsh events trend',
                subtitle: 'Braking · acceleration · cornering per 1,000 km',
                child: SizedBox(
                  height: 190,
                  child: BarChartWidget(series: harshEvents7d, color: Palette.warning),
                ),
              ),
              const SizedBox(height: 16),
              _RiskRanking(),
              const SizedBox(height: 16),
              _HosPanel(),
            ],
            const SizedBox(height: 16),
            _IncidentWorkflow(),
          ],
        ),
      ),
    );
  }
}

class RegulatorExportLabel extends StatelessWidget {
  const RegulatorExportLabel({super.key});

  @override
  Widget build(BuildContext context) => const Text('Export ELD/HOS');
}

class _RiskRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ranked = [...drivers]..sort((a, b) => a.safetyScore.compareTo(b.safetyScore));
    return SectionCard(
      title: 'Driver risk ranking',
      subtitle: 'Lowest safety scores — coaching candidates',
      child: Column(
        children: [
          for (final d in ranked.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  UserAvatar(name: d.name, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: theme.textTheme.labelLarge),
                        Text(
                          '${d.safetyScore.toStringAsFixed(0)} safety · ${d.punctuality.toStringAsFixed(0)} punctual',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: d.safetyScore / 100,
                        minHeight: 7,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          d.safetyScore >= 90
                              ? Palette.success
                              : d.safetyScore >= 75
                                  ? Palette.warning
                                  : Palette.danger,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const IconAction(icon: Icons.school_rounded, tooltip: 'Coach'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HosPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppScope.of(context);
    final driving = drivers.where((d) => d.status == DriverStatus.driving).toList();
    return SectionCard(
      title: 'HOS monitor',
      subtitle: 'Duty-hours tracking · violation prevention alerts (FR-39)',
      child: Column(
        children: [
          for (final d in driving.take(4)) ...[
            LabeledProgress(
              value: d.hoursDrivenToday / d.hoursLimit,
              label: '${d.name.split(' ').first} · ${d.id}',
              trailing: '${(d.hoursLimit - d.hoursDrivenToday).toStringAsFixed(1)} h left',
            ),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Palette.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.rule_rounded, color: Palette.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rule pack: East-Africa HOS (configurable per region)',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                Text(s.onTimePct > 90 ? 'active' : 'review',
                    style: const TextStyle(
                        color: Palette.success,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IncidentWorkflow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const incidents = [
      ('INC-118', 'Lane-departure near-miss', 'D-09 · Brian K. — coaching assigned', Palette.warning, 'In review'),
      ('INC-117', 'Rear-end collision (minor)', 'D-06 · Daniel M. — claim filed', Palette.danger, 'Open claim'),
      ('INC-116', 'Cargo door alarm', 'V-102 · reefer — resolved on-site', Palette.info, 'Closed'),
    ];
    return SectionCard(
      title: 'Incident & claims workflow',
      subtitle: 'Crash detection auto-reports (FR-38) · video events attached where dashcam installed (FR-41)',
      child: Column(
        children: [
          for (final (id, title, sub, color, status) in incidents)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
                color: color.withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: Text(id,
                        style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.labelLarge),
                        Text(sub,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  StatusChip(label: status, color: color, dense: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
