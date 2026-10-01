import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/theme/dimens.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/common.dart';

/// Auditor / Inspector view (PRD §3.12): time-limited, read-only, fully
/// access-logged scope over logs, documents and inspection history.
class AuditorDashboard extends StatelessWidget {
  const AuditorDashboard({super.key});

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
            const _AccessBanner(),
            const SizedBox(height: 18),
            PageHeader(
              title: 'Audit & Inspection Access',
              subtitle:
                  'Read-only scope assigned by TransTech Authority — every view is logged.',
              actions: [
                const IconAction(
                    icon: Icons.lock_rounded, tooltip: 'Read-only access'),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('Export evidence pack'),
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
              childAspectRatio: wide ? 1.5 : 1.05,
              children: const [
                KpiTile(label: 'Records in scope', value: '1,204', unit: 'entries', icon: Icons.inventory_2_outlined, accent: Palette.brand),
                KpiTile(label: 'Documents visible', value: '86', unit: 'files', icon: Icons.folder_open_rounded, accent: Palette.teal),
                KpiTile(label: 'Inspections reviewed', value: '12', unit: 'this visit', delta: '+4', icon: Icons.fact_check_outlined, accent: Palette.cyan),
                KpiTile(label: 'Your views logged', value: '31', unit: 'events', icon: Icons.visibility_outlined, accent: Palette.violet),
              ],
            ),
            const SizedBox(height: 16),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _AuditTrail()),
                  SizedBox(width: 16),
                  Expanded(flex: 4, child: _ScopeCard()),
                ],
              )
            else ...[
              const _AuditTrail(),
              const SizedBox(height: 16),
              const _ScopeCard(),
            ],
            const SizedBox(height: 16),
            const _InspectionHistory(),
          ],
        ),
      ),
    );
  }
}

// ── Access banner ───────────────────────────────────────────────────────

class _AccessBanner extends StatelessWidget {
  const _AccessBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Palette.warning.withValues(alpha: 0.14),
            Palette.warning.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const GradientIconBox(
              icon: Icons.timer_rounded,
              accent: Palette.warning,
              size: 40,
              iconSize: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Temporary audit access — expires Oct 08, 17:00',
                    style: theme.textTheme.titleSmall),
                Text(
                    'Scoped to: HOS/ELD logs · inspections · documents · trip history. Downloads and mutations are disabled.',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TrendPill(delta: '7d left', good: true),
        ],
      ),
    );
  }
}

// ── Audit trail (what the auditor has viewed) ───────────────────────────

class _AuditTrail extends StatelessWidget {
  const _AuditTrail();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Access log — this visit',
      subtitle:
          'Every record you open is written here and visible to the operator (PRD §3.12)',
      child: Column(
        children: [
          for (final e in auditorTrail) ...[
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.action,
                            style: theme.textTheme.labelMedium?.copyWith(
                                fontFamilyFallback: const ['monospace'],
                                fontWeight: FontWeight.w700)),
                    Text(e.target,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text(e.time,
                      style: theme.textTheme.labelSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (e != auditorTrail.last) const Divider(),
          ],
        ],
      ),
    );
  }
}

// ── Scope summary ───────────────────────────────────────────────────────

class _ScopeCard extends StatelessWidget {
  const _ScopeCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scopes = {
      ('HOS / ELD logs', 'Driver duty status, 90 days'): true,
      ('Inspection history (DVIR)', 'All vehicles, 12 months'): true,
      ('Vehicle documents', 'Insurance, permits, inspections'): true,
      ('Trip & stop history', '90 days, geo + timestamps'): true,
      ('Payroll & driver pay', ''): false,
      ('Invoices & customer data', ''): false,
    };
    return SectionCard(
      title: 'What you can see',
      subtitle: 'Granted vs denied scopes — configurable per engagement',
      child: Column(
        children: [
          for (final (label, sub) in scopes.keys) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    scopes[(label, sub)]!
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 19,
                    color: scopes[(label, sub)]!
                        ? Palette.success
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: scopes[(label, sub)]!
                                    ? null
                                    : theme.colorScheme.onSurfaceVariant)),
                        if (sub.isNotEmpty && scopes[(label, sub)]!)
                          Text(sub,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (!scopes[(label, sub)]!)
                    Text('denied',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            if ((label, sub) != scopes.keys.last) const Divider(),
          ],
        ],
      ),
    );
  }
}

// ── Inspection history ──────────────────────────────────────────────────

class _InspectionHistory extends StatelessWidget {
  const _InspectionHistory();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Inspection history (DVIR)',
      subtitle: 'Driver vehicle inspection reports and annual checks (PRD FR-31)',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 26,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('VEHICLE')),
            DataColumn(label: Text('TYPE')),
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('DEFECTS')),
            DataColumn(label: Text('RESULT')),
            DataColumn(label: Text('INSPECTOR')),
          ],
          rows: [
            for (final r in inspections)
              DataRow(cells: [
                DataCell(Text(r.id)),
                DataCell(Text(r.vehicleId)),
                DataCell(Text(r.kind)),
                DataCell(Text(r.date)),
                DataCell(Text('${r.defects}')),
                DataCell(StatusChip(
                  label: r.passed ? 'Pass' : 'Fail',
                  color: r.passed ? Palette.success : Palette.danger,
                  dense: true,
                )),
                DataCell(Text(r.inspector)),
              ]),
          ],
        ),
      ),
    );
  }
}
