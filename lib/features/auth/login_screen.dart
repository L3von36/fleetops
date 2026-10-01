import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/dimens.dart';
import '../../core/theme/palette.dart';

/// Sign-in — compact split layout (brand story + credential form).
///
/// Responsiveness contract:
///  • ≥ 880 px  → two-pane layout, brand panel adapts to height.
///  • <  880 px → single centered column (max 380 px) inside [SafeArea].
///  • Any height → scrolls; keyboard insets never hide the form.
/// Mirrors PRD FR-1 (email/phone + password, OTP hint, biometric unlock)
/// and FR-2 (role-based entry point).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSignIn});

  final void Function(Role) onSignIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'demo@fleetops.io');
  final _password = TextEditingController(text: '••••••••');
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
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= Dimens.bpLoginSplit;

    final form = _buildForm(context, size);

    if (!wide) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: Dimens.xl,
              ),
              child: form,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // ── Brand story panel ────────────────────────────────────────
          Expanded(flex: 5, child: _BrandPanel(height: size.height)),
          // ── Form panel ───────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: Dimens.xl,
                  ),
                  child: form,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────── Form ──
  Widget _buildForm(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final wide = size.width >= Dimens.bpLoginSplit;

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Welcome back', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 3),
        Text(
          'Sign in to your fleet workspace.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Dimens.lg),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email or phone',
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 17),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _password,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 17),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: Checkbox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v ?? false),
              ),
            ),
            const SizedBox(width: 7),
            // Flexible keeps the row compressible on narrow screens.
            Flexible(
              child: Text(
                'Remember me',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            Flexible(
              child: TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                onPressed: () {},
                child: const Text(
                  'Forgot password?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimens.sm),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _busy ? null : () => _submit(null),
            icon: _busy
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.login_rounded, size: 15),
            label: Text(
              _busy ? 'Signing in…' : 'Sign in',
              style: theme.textTheme.labelLarge,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : () {},
            icon: const Icon(Icons.fingerprint_rounded, size: 18),
            label: const Text('Unlock with biometrics'),
          ),
        ),
      ],
    );

    final demo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outline)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'ENTER AS',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.colorScheme.outline)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (r, icon) in _demoRoles)
              ActionChip(
                avatar: Icon(icon, size: 14, color: theme.colorScheme.primary),
                label: Text(r.label),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: _busy ? null : () => _submit(r),
              ),
          ],
        ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Dimens.formMaxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandMark(onGradient: false),
          const SizedBox(height: Dimens.xl),
          if (wide) ...[
            // Elevated card keeps the form contained on desktop.
            Container(
              padding: const EdgeInsets.all(Dimens.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(Dimens.radiusXl),
                border: Border.all(color: theme.colorScheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.3 : 0.06,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  fields,
                  const SizedBox(height: Dimens.lg),
                  demo,
                ],
              ),
            ),
          ] else ...[
            fields,
            const SizedBox(height: Dimens.xl),
            demo,
          ],
          const SizedBox(height: Dimens.lg),
          Center(
            child: Text(
              'Protected workspace · SSO & 2FA available for enterprise plans',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════ Brand panel ══

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = height < 620; // hide secondary layers on short windows
    final tiny = height < 480; // keep only headline + version

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16266B), Color(0xFF1D3FB8), Color(0xFF2C5BF2)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 32,
                ),
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(40, 32, 40, compact ? 24 : 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandMark(onGradient: true),
                  const Spacer(),
                  Text(
                    'One platform.\nEvery stakeholder.',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      height: 1.12,
                    ),
                  ),
                  if (!tiny) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Live GPS, telematics and manual inputs feed role-specific\ndashboards for managers, dispatchers, drivers, safety,\nfinance and customers.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.55,
                      ),
                    ),
                  ],
                  if (!compact) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _StatTile('10 s', 'position latency')),
                        _verticalDivider(),
                        Expanded(child: _StatTile('99.9%', 'platform uptime')),
                        _verticalDivider(),
                        Expanded(child: _StatTile('12', 'role dashboards')),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Text(
                    'FleetOps Platform v1.2 — 12 role dashboards · PRD-aligned demo build',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
    width: 1,
    height: 30,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: Colors.white.withValues(alpha: 0.25),
  );
}

// ═════════════════════════════════════════════════ Brand mark ══

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.onGradient});
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: onGradient
                ? const LinearGradient(
                    colors: [Colors.white, Color(0xFFDCE5FF)],
                  )
                : const LinearGradient(
                    colors: [Palette.brand, Palette.brandDeep],
                  ),
            boxShadow: [
              BoxShadow(
                color: Palette.brand.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.local_shipping_rounded,
            color: onGradient ? Palette.brandDeep : Colors.white,
            size: 19,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          'FleetOps',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 17,
            color: onGradient ? Colors.white : null,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════ Stat tile ══

class _StatTile extends StatelessWidget {
  const _StatTile(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 15,
            color: Colors.white,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            height: 1.25,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}
