import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/palette.dart';

/// Sign-in — split hero (brand story) + credential form.
/// Mirrors PRD FR-1 (email/phone + password, OTP hint, biometric unlock)
/// and FR-2 (role-based entry point).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSignIn});

  final void Function(Role) onSignIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'ops.manager@fleetops.io');
  final _password = TextEditingController(text: '••••••••••');
  bool _remember = true;
  bool _busy = false;

  static const _demoRoles = [
    (Role.fleetManager, Icons.dashboard_rounded),
    (Role.dispatcher, Icons.hub_rounded),
    (Role.driver, Icons.local_shipping_rounded),
    (Role.superAdmin, Icons.admin_panel_settings_rounded),
    (Role.maintenance, Icons.build_rounded),
    (Role.safety, Icons.health_and_safety_rounded),
    (Role.finance, Icons.payments_rounded),
    (Role.depot, Icons.warehouse_rounded),
    (Role.customer, Icons.inventory_2_rounded),
    (Role.executive, Icons.insights_rounded),
    (Role.auditor, Icons.plagiarism_rounded),
    (Role.fuelManager, Icons.local_gas_station_rounded),
  ];

  Future<void> _submit(Role? role) async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onSignIn(role ?? Role.fleetManager);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 980;

    final form = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!wide) _BrandMark(compact: true),
            if (!wide) const SizedBox(height: 40),
            Text('Welcome back', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Sign in to your fleet workspace.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 28),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email or phone',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: Icon(Icons.visibility_off_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('Remember me')),
                TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _submit(null),
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Colors.white))
                    : const Icon(Icons.login_rounded, size: 18),
                label: Text(_busy ? 'Signing in…' : 'Sign in'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {},
              icon: const Icon(Icons.fingerprint_rounded, size: 22),
              label: const Text('Unlock with biometrics'),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: Divider(color: theme.colorScheme.outline)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('QUICK DEMO — ENTER AS',
                      style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.6,
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
                Expanded(child: Divider(color: theme.colorScheme.outline)),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final (r, icon) in _demoRoles)
                  ActionChip(
                    avatar: Icon(icon, size: 17, color: Palette.brand),
                    label: Text(r.label),
                    onPressed: _busy ? null : () => _submit(r),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Protected workspace · SSO & 2FA available for enterprise plans',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );

    if (!wide) {
      return Scaffold(
        body: SafeArea(child: Center(child: SingleChildScrollView(child: form))),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // ── Brand story panel ────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16266B), Color(0xFF1D3FB8), Color(0xFF2C5BF2)],
                ),
              ),
              child: Stack(
                children: [
                  // decorative rings
                  Positioned(
                    right: -80,
                    top: -60,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08), width: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -60,
                    bottom: -90,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _BrandMark(),
                        const Spacer(),
                        Text(
                          'One platform.\nEvery stakeholder.',
                          style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white, height: 1.15),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Live GPS, telematics and manual inputs feed role-specific\ndashboards for managers, dispatchers, drivers, safety,\nfinance and customers.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              height: 1.6),
                        ),
                        const SizedBox(height: 34),
                        Row(
                          children: [
                            _StatTile('10 s', 'position latency'),
                            _verticalDivider(),
                            _StatTile('99.9%', 'platform uptime'),
                            _verticalDivider(),
                            _StatTile('12', 'role dashboards'),
                          ],
                        ),
                        const Spacer(),
                        Text('FleetOps Platform v1.1 — 12 role dashboards · PRD-aligned demo build',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.55))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Form panel ───────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Center(child: SingleChildScrollView(child: form)),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
      width: 1, height: 34, color: Colors.white.withValues(alpha: 0.25));
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final onDark = compact == false;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: onDark
                ? const LinearGradient(colors: [Colors.white, Color(0xFFDCE5FF)])
                : const LinearGradient(colors: [Palette.brand, Palette.brandDeep]),
            boxShadow: [
              BoxShadow(
                  color: Palette.brand.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Icon(Icons.local_shipping_rounded,
              color: onDark ? Palette.brandDeep : Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          'FleetOps',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: onDark ? Colors.white : null,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.65))),
        ],
      ),
    );
  }
}
