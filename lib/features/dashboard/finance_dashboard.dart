import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';

/// Finance dashboard (PRD §3.7): TCO, cost/km, revenue vs cost, invoice
/// pipeline, expense approvals, budget tracking.
class FinanceDashboard extends StatelessWidget {
  const FinanceDashboard({super.key});

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
              title: 'Finance',
              subtitle:
                  'Control cost & revenue — trip-based invoicing, expense approvals and budget tracking.',
              actions: [
                OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.sync_alt_rounded, size: 17),
                  label: Text('Export to accounting'),
                ),
                FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.receipt_rounded, size: 18),
                  label: Text('Generate invoices'),
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
                KpiTile(label: 'Total cost of ownership', value: '486K', unit: 'USD / yr', delta: '-3%', deltaGood: true, icon: Icons.account_balance_rounded, accent: Palette.brand),
                KpiTile(label: 'Cost per km', value: '1.19', unit: 'USD', delta: '-4.5%', deltaGood: true, icon: Icons.speed_rounded, accent: Palette.teal, sparkData: [1.42, 1.38, 1.31, 1.35, 1.24, 1.19]),
                KpiTile(label: 'Outstanding invoices', value: '51.4K', unit: 'USD', delta: '+8.2K', deltaGood: false, icon: Icons.pending_actions_rounded, accent: Palette.danger),
                KpiTile(label: 'Payroll accrual', value: '96.1K', unit: 'USD / mo', delta: '+1.2%', deltaGood: false, icon: Icons.groups_rounded, accent: Palette.violet),
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
                      title: 'Revenue vs operating cost',
                      subtitle: 'k USD · last 6 months',
                      trailing: _Legend(),
                      child: GroupedBarChart(
                        groups: revenueVsCost6m.first.points.map((p) => p.label).toList(),
                        seriesList: revenueVsCost6m,
                        height: 190,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    flex: 4,
                    child: SectionCard(
                      title: 'Cost per km trend',
                      subtitle: 'USD · 6 months · target ≤ 1.25',
                      child: SizedBox(
                        height: 190,
                        child: LineChartWidget(seriesList: [
                          MultiSeries('Cost / km', costPerKm6m, Palette.teal),
                        ]),
                      ),
                    ),
                  ),
                ],
              )
            else ...[
              SectionCard(
                title: 'Revenue vs operating cost',
                subtitle: 'k USD · last 6 months',
                child: GroupedBarChart(
                  groups: revenueVsCost6m.first.points.map((p) => p.label).toList(),
                  seriesList: revenueVsCost6m,
                  height: 190,
                ),
              ),
              const SizedBox(height: 16),
              const SectionCard(
                title: 'Cost per km trend',
                subtitle: 'USD · 6 months · target ≤ 1.25',
                child: SizedBox(
                  height: 190,
                  child: LineChartWidget(seriesList: [
                    MultiSeries('Cost / km', costPerKm6m, Palette.teal),
                  ]),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 5, child: _Invoices()),
                  const SizedBox(width: 16),
                  const Expanded(flex: 5, child: _ExpenseApprovals()),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _BudgetCard()),
                ],
              )
            else ...[
              _Invoices(),
              const SizedBox(height: 16),
              _ExpenseApprovals(),
              const SizedBox(height: 16),
              _BudgetCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in revenueVsCost6m)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(children: [
              Container(width: 9, height: 9,
                  decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 5),
              Text(s.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
      ],
    );
  }
}

class _Invoices extends StatelessWidget {
  const _Invoices();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Invoices',
      subtitle: 'Auto-generated from completed trips & rate cards (FR-47)',
      child: Column(
        children: [
          for (final inv in invoices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${inv.id} · ${inv.customer}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                        Text(inv.dueIn,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text(
                    'USD ${inv.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(width: 10),
                  StatusChip(
                    label: inv.status,
                    color: inv.status == 'Paid'
                        ? Palette.success
                        : inv.status == 'Overdue'
                            ? Palette.danger
                            : Palette.info,
                    dense: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpenseApprovals extends StatelessWidget {
  const _ExpenseApprovals();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Expense approval queue',
      subtitle: 'Driver claims — tolls, parking, repairs (FR-48)',
      child: Column(
        children: [
          for (final e in expenseClaims)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${driverById(e.driverId).name} · ${e.category}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                        Text(e.note,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('USD ${e.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.labelLarge),
                  const SizedBox(width: 10),
                  const IconAction(icon: Icons.check_rounded, tooltip: 'Approve'),
                  const SizedBox(width: 6),
                  IconAction(
                      icon: Icons.close_rounded,
                      tooltip: 'Reject',
                      destructive: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Budget vs actual',
      subtitle: 'October · fleet operating budget',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DonutChart(
                  segments: const [(68, Palette.brand), (32, Palette.brandSoft)],
                  centerLabel: 'consumed',
                  centerValue: '68%',
                  size: 110,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyValueLine(k: 'Budget', v: 'USD 320K'),
                    KeyValueLine(k: 'Actual', v: 'USD 218K'),
                    KeyValueLine(k: 'Forecast', v: 'USD 305K', vColor: Palette.success),
                    const SizedBox(height: 4),
                    Text('On track — projected 5% under budget.',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
