import 'package:flutter/material.dart';

import '../../core/state/app_scope.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/common.dart';

/// Settings — appearance, notification rules (FR-51), privacy (duty-hours
/// tracking), regional rule packs and integration status (FR-53/54).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppScope.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PageHeader(
            title: 'Settings',
            subtitle: 'Workspace preferences for ${s.role.label} role.',
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Appearance',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.isDark ? 'Dark operations theme' : 'Light operations theme',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Switch(value: s.isDark, onChanged: (_) => s.toggleTheme()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Notification rules',
            subtitle: 'Per alert type & severity · quiet hours (FR-51)',
            child: Column(
              children: [
                _toggle(context, 'SOS & crash alerts — always push', true),
                _toggle(context, 'Geofence breaches — push + email', true),
                _toggle(context, 'Fuel anomalies — email digest', true),
                _toggle(context, 'Idle warnings — in-app only', false),
                _toggle(context, 'Quiet hours 22:00–05:00 (non-critical)', true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Privacy & compliance',
            subtitle: 'Driver trust first — configurable retention & consent',
            child: Column(
              children: [
                _toggle(context, 'Track location only during duty hours', true),
                _toggle(context, 'Consent records enabled (GDPR-style)', true),
                _toggle(context, 'Regional data residency: East Africa', true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Integration health',
            subtitle: 'Open REST API + webhooks · connectors (FR-53/54)',
            child: Column(
              children: [
                _integration(context, Icons.api_rounded, 'REST API v1', 'Rate limit 600/min · OpenAPI docs', Palette.success),
                _integration(context, Icons.webhook_rounded, 'Webhooks — ERP / accounting', '12 endpoints · 99.98% delivery', Palette.success),
                _integration(context, Icons.map_rounded, 'Maps & traffic provider', 'Connected · p95 180 ms', Palette.success),
                _integration(context, Icons.sensors_rounded, 'IoT hub — MQTT ingestion', 'Device gateway: 2,410 msgs/min', Palette.success),
                _integration(context, Icons.credit_card_rounded, 'Fuel card feed', 'Sync paused — credentials expired', Palette.warning),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'About',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KeyValueLine(k: 'Platform', v: 'FleetOps v1.0.0 (demo)'),
                KeyValueLine(k: 'Client', v: 'Flutter · Android / iOS / Web / Desktop'),
                KeyValueLine(k: 'PRD', v: 'FMS v1.0 — draft for review'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.description_rounded, size: 17),
                      label: const Text('View PRD'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bug_report_rounded, size: 17),
                      label: const Text('Report issue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(BuildContext context, String label, bool initial) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Switch(value: initial, onChanged: (_) {}),
        ],
      ),
    );
  }

  Widget _integration(BuildContext context, IconData icon, String title,
      String sub, Color status) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: status.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: status),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                Text(sub,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.circle, size: 9, color: status),
        ],
      ),
    );
  }
}
