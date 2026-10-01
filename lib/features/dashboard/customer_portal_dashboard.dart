import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/common.dart';

/// Customer / Shipper portal (PRD §3.10): shipment tracking with live ETA,
/// proof of delivery, invoices & statements, SLA reports and support tickets.
/// Only the signed-in customer's data is visible.
class CustomerPortalDashboard extends StatelessWidget {
  const CustomerPortalDashboard({super.key});

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
              title: 'Hi FreshLine Markets 👋',
              subtitle:
                  'Track shipments, review deliveries and manage billing — your data only.',
              actions: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Statements'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => _raiseTicket(context),
                  icon: const Icon(Icons.support_agent_rounded, size: 18),
                  label: const Text('Raise a ticket'),
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
                KpiTile(label: 'Active shipments', value: '2', icon: Icons.local_shipping_outlined, accent: Palette.brand),
                KpiTile(label: 'Delivered this month', value: '38', delta: '+9', icon: Icons.check_circle_outline_rounded, accent: Palette.success, sparkData: [24, 27, 29, 31, 34, 36, 38]),
                KpiTile(label: 'On-time rate', value: '96.8', unit: '%', delta: '+1.2 pt', icon: Icons.schedule_rounded, accent: Palette.teal),
                KpiTile(label: 'Open claims', value: '1', unit: 'in review', delta: '-1', deltaGood: true, icon: Icons.gavel_rounded, accent: Palette.warning),
              ],
            ),
            const SizedBox(height: 16),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _ShipmentList()),
                  SizedBox(width: 16),
                  Expanded(flex: 4, child: _PodCard()),
                ],
              )
            else ...[
              const _ShipmentList(),
              const SizedBox(height: 16),
              const _PodCard(),
            ],
            const SizedBox(height: 16),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _InvoicesCard()),
                  SizedBox(width: 16),
                  Expanded(flex: 5, child: _SlaCard()),
                  SizedBox(width: 16),
                  Expanded(flex: 4, child: _ClaimsCard()),
                ],
              )
            else ...[
              const _InvoicesCard(),
              const SizedBox(height: 16),
              const _SlaCard(),
              const SizedBox(height: 16),
              const _ClaimsCard(),
            ],
          ],
        ),
      ),
    );
  }

  void _raiseTicket(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raise a claim or ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Related shipment (optional)',
                hintText: 'SHP-…',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What went wrong?',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Ticket received — our support team replies within 4 h.')));
              },
              child: const Text('Submit')),
        ],
      ),
    );
  }
}

// ── Shipments ───────────────────────────────────────────────────────────

class _ShipmentList extends StatelessWidget {
  const _ShipmentList();

  Color _statusColor(String s) => switch (s) {
        'In transit' => Palette.brand,
        'Out for delivery' => Palette.cyan,
        _ => Palette.success,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'My shipments',
      subtitle: 'Live ETA recalculated on every delay (PRD FR-23)',
      trailing: IconAction(
          icon: Icons.my_location_rounded, tooltip: 'Track on map', onTap: () {}),
      child: Column(
        children: [
          for (final s in myShipments) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      GradientIconBox(
                        icon: s.status == 'Delivered'
                            ? Icons.task_alt_rounded
                            : Icons.route_rounded,
                        accent: _statusColor(s.status),
                        size: 36,
                        iconSize: 18,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s.id} · ${s.route}',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge),
                            const SizedBox(height: 2),
                            Text(
                                s.status == 'Delivered'
                                    ? 'Delivered ${s.eta}'
                                    : 'ETA ${s.eta} · ${s.status}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      StatusChip(
                          label: s.status,
                          color: _statusColor(s.status),
                          dense: true),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: s.progress,
                            minHeight: 6,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: _statusColor(s.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(s.progress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                              fontWeight: FontWeight.w700)),
                      if (s.tempC != 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.ac_unit_rounded,
                            size: 14,
                            color: s.tempC > 10
                                ? Palette.warning
                                : Palette.cyan),
                        const SizedBox(width: 3),
                        Text('${s.tempC.toStringAsFixed(1)}°C',
                            style: theme.textTheme.labelSmall?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (s != myShipments.last) const Divider(),
          ],
        ],
      ),
    );
  }
}

// ── Proof of delivery ───────────────────────────────────────────────────

class _PodCard extends StatelessWidget {
  const _PodCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Proof of delivery',
      subtitle: 'Geotagged photo, e-signature & QR scans (PRD FR-24)',
      child: Column(
        children: [
          for (final p in podRecords) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline),
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Palette.brand.withValues(alpha: 0.22),
                          Palette.teal.withValues(alpha: 0.16),
                        ],
                      ),
                    ),
                    child: Icon(
                        p.method == 'Signature'
                            ? Icons.draw_rounded
                            : Icons.photo_camera_rounded,
                        color: Palette.brand),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.shipmentId} — ${p.method}',
                            style: theme.textTheme.labelLarge),
                        Text('Signed by ${p.signedBy}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        Text('${p.location} · ${p.time}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_rounded,
                      color: Palette.success, size: 20),
                ],
              ),
            ),
            if (p != podRecords.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.history_rounded, size: 18),
            label: const Text('View all deliveries'),
          ),
        ],
      ),
    );
  }
}

// ── Invoices ────────────────────────────────────────────────────────────

class _InvoicesCard extends StatelessWidget {
  const _InvoicesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color c(String s) => switch (s) {
          'Paid' => Palette.success,
          'Overdue' => Palette.danger,
          _ => Palette.warning,
        };
    return SectionCard(
      title: 'Invoices & statements',
      subtitle: 'Auto-generated from completed trips (PRD FR-47)',
      child: Column(
        children: [
          for (final i in myInvoices) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.id,
                            style: theme.textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(i.dueIn,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('\$${i.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  StatusChip(label: i.status, color: c(i.status), dense: true),
                ],
              ),
            ),
            if (i != myInvoices.last) const Divider(),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, size: 17),
              label: const Text('Download statement (PDF)'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SLA / service report ────────────────────────────────────────────────

class _SlaCard extends StatelessWidget {
  const _SlaCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Service level report',
      subtitle: 'Rolling 30 days vs agreed SLA',
      child: Column(
        children: [
          _SlaRow(
              label: 'On-time delivery', value: 96.8, target: 95, good: true),
          _SlaRow(
              label: 'ETA accuracy (±10 min)',
              value: 92.5,
              target: 90,
              good: true),
          _SlaRow(
              label: 'Cold-chain compliance',
              value: 99.1,
              target: 99,
              good: true),
          _SlaRow(
              label: 'Damage-free deliveries',
              value: 98.2,
              target: 99,
              good: false),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Palette.success.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Palette.success, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Overall SLA score 96.4 — "Gold partner" tier maintained.',
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Palette.success),
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

class _SlaRow extends StatelessWidget {
  const _SlaRow(
      {required this.label, required this.value, required this.target, required this.good});

  final String label;
  final double value;
  final double target;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label, style: theme.textTheme.labelMedium)),
              Text(
                '${value.toStringAsFixed(1)}%  /  target ${target.toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: good ? Palette.success : Palette.warning,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: good ? Palette.success : Palette.warning,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Claims ──────────────────────────────────────────────────────────────

class _ClaimsCard extends StatelessWidget {
  const _ClaimsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color c(String s) =>
        s == 'Resolved' ? Palette.success : Palette.warning;
    return SectionCard(
      title: 'Claims & tickets',
      subtitle: 'Damages, credits and service issues',
      child: Column(
        children: [
          for (final cl in claims) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  GradientIconBox(
                      icon: Icons.receipt_long_rounded,
                      accent: c(cl.status),
                      size: 34,
                      iconSize: 17),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cl.subject,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge),
                        Text('${cl.id} · opened ${cl.opened}',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('\$${cl.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  StatusChip(
                      label: cl.status, color: c(cl.status), dense: true),
                ],
              ),
            ),
            if (cl != claims.last) const Divider(),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.star_rounded, size: 17),
              label: const Text('Rate last delivery'),
            ),
          ),
        ],
      ),
    );
  }
}
