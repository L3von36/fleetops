import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/common.dart';
import '../dashboard/dashboards.dart';
import '../settings/settings_screen.dart';

class _NavDest {
  const _NavDest(this.label, this.icon, this.selectedIcon, this.builder);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
}

/// Adaptive application shell:
///   • Desktop ≥1100 px  → expandable navigation sidebar + top bar
///   • Tablet  700–1100  → navigation rail
///   • Mobile  <700 px   → bottom navigation + overflow drawer
/// Destinations are filtered by the signed-in role (PRD §2.2 simplified).
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _sidebarExpanded = true;

  List<_NavDest> _destinationsFor(Role role) {
    final overview = _NavDest('Command Center', Icons.space_dashboard_outlined,
        Icons.space_dashboard_rounded, (_) => const FleetManagerDashboard());
    final dispatch = _NavDest('Dispatch', Icons.hub_outlined, Icons.hub_rounded,
        (_) => const DispatcherDashboard());
    final driverApp = _NavDest('Driver App', Icons.local_shipping_outlined,
        Icons.local_shipping_rounded, (_) => const DriverDashboard());
    final maint = _NavDest('Maintenance', Icons.build_outlined,
        Icons.build_rounded, (_) => const MaintenanceDashboard());
    final safety = _NavDest('Safety', Icons.health_and_safety_outlined,
        Icons.health_and_safety_rounded, (_) => const SafetyDashboard());
    final finance = _NavDest('Finance', Icons.payments_outlined,
        Icons.payments_rounded, (_) => const FinanceDashboard());
    final fuel = _NavDest('Fuel & Energy', Icons.local_gas_station_outlined,
        Icons.local_gas_station_rounded, (_) => const FuelDashboard());
    final exec = _NavDest('Executive BI', Icons.insights_outlined,
        Icons.insights_rounded, (_) => const ExecutiveDashboard());
    final settings = _NavDest('Settings', Icons.settings_outlined,
        Icons.settings_rounded, (_) => const SettingsScreen());

    return switch (role) {
      Role.superAdmin => [overview, dispatch, driverApp, maint, safety, finance, fuel, exec, settings],
      Role.fleetManager => [overview, dispatch, driverApp, maint, safety, finance, fuel, exec, settings],
      Role.dispatcher => [dispatch, overview, driverApp, maint, settings],
      Role.driver => [driverApp, safety, settings],
      Role.maintenance => [maint, overview, settings],
      Role.safety => [safety, overview, settings],
      Role.finance => [finance, overview, settings],
      Role.fuelManager => [fuel, overview, settings],
      Role.depot => [overview, dispatch, settings],
      Role.customer => [overview, settings],
      Role.executive => [exec, overview, settings],
      Role.auditor => [overview, settings],
    };
  }

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final dests = _destinationsFor(widget.state.role);
    if (_index >= dests.length) _index = 0;

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final desktop = w >= 1100;
        final tablet = w >= 700 && w < 1100;

        final page = IndexedStack(
          index: _index,
          children: [for (final d in dests) Builder(key: ValueKey(d.label), builder: d.builder)],
        );

        if (desktop) {
          return Row(
            children: [
              _Sidebar(
                dests: dests,
                index: _index,
                onGo: _go,
                expanded: _sidebarExpanded,
                onToggle: () =>
                    setState(() => _sidebarExpanded = !_sidebarExpanded),
                state: widget.state,
              ),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(state: widget.state, compact: false),
                    Expanded(child: page),
                  ],
                ),
              ),
            ],
          );
        }

        if (tablet) {
          return Scaffold(
            body: Row(
              children: [
                _Rail(dests: dests, index: _index, onGo: _go),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(state: widget.state, compact: true),
                      Expanded(child: page),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile
        final overflow = dests.length > 5;
        final navDests = overflow ? dests.sublist(0, 4) : dests;
        final mobileIndex = _index < navDests.length ? _index : 0;
        return Scaffold(
          appBar: _TopBar(state: widget.state, compact: true),
          drawer: overflow
              ? _DrawerOverflow(
                  dests: dests, index: _index, onGo: _go, state: widget.state)
              : null,
          body: page,
          bottomNavigationBar: NavigationBar(
            selectedIndex: mobileIndex,
            onDestinationSelected: _go,
            destinations: [
              for (final d in navDests)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label.split(' ').first,
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════ Sidebar ══

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.dests,
    required this.index,
    required this.onGo,
    required this.expanded,
    required this.onToggle,
    required this.state,
  });

  final List<_NavDest> dests;
  final int index;
  final void Function(int) onGo;
  final bool expanded;
  final VoidCallback onToggle;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Fixed width keeps the inner Expanded rows bounded when the sidebar
    // sits as a non-flex child of the desktop Row.
    return SizedBox(
      width: expanded ? 264.0 : 78.0,
      child: Material(
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                        colors: [Palette.brand, Palette.brandDeep]),
                    boxShadow: [
                      BoxShadow(
                          color: Palette.brand.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping_rounded,
                      color: Colors.white, size: 22),
                ),
                if (expanded) ...[
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text('FleetOps',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: expanded ? double.infinity : 44,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded,
                      size: 14,
                      color: theme.colorScheme.onPrimaryContainer),
                  if (expanded) ...[
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        state.role.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < dests.length; i++)
                  _SidebarItem(
                    dest: dests[i],
                    selected: i == index,
                    expanded: expanded,
                    onTap: () => onGo(i),
                  ),
              ],
            ),
          ),
          const Divider(indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 18),
            child: _UserBlock(state: state, expanded: expanded),
          ),
        ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.dest,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final _NavDest dest;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.75)
        : Colors.transparent;
    final fg = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(selected ? dest.selectedIcon : dest.icon, size: 21, color: fg),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(dest.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: fg,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w600)),
                  ),
                  if (selected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primary, shape: BoxShape.circle),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════ Rail ══

class _Rail extends StatelessWidget {
  const _Rail({required this.dests, required this.index, required this.onGo});

  final List<_NavDest> dests;
  final int index;
  final void Function(int) onGo;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onGo,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [Palette.brand, Palette.brandDeep]),
          ),
          child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22),
        ),
      ),
      destinations: [
        for (final d in dests)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label.split(' ').first),
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════ TopBar ══

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({required this.state, required this.compact});

  final AppState state;
  final bool compact;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (compact && Scaffold.of(context).hasDrawer)
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          if (!compact) ...[
            Text('Live operations',
                style: theme.textTheme.titleMedium),
            const SizedBox(width: 10),
            StatusChip(label: 'Real-time', color: Palette.success, dense: true),
          ],
          const Spacer(),
          if (!compact)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextField(
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search vehicles, drivers, trips…',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded, size: 19),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: state.isDark ? 'Light mode' : 'Dark mode',
            onPressed: state.toggleTheme,
            icon: Icon(state.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Palette.danger, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const UserAvatar(name: 'Ops User', size: 34),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════ User blocks ══

class _UserBlock extends StatelessWidget {
  const _UserBlock({required this.state, required this.expanded});

  final AppState state;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showMenu(context),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const UserAvatar(name: 'Ops User', size: 36),
            if (expanded) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ops User',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge),
                    Text(state.role.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.unfold_more_rounded, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) async {
    final action = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(280, 600, 20, 0),
      items: const [
        PopupMenuItem(value: 'profile', height: 44, child: Text('My profile')),
        PopupMenuItem(value: 'theme', height: 44, child: Text('Appearance')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'signout', height: 44, child: Text('Sign out')),
      ],
    );
    if (action == 'signout' && context.mounted) state.signOut();
  }
}

class _DrawerOverflow extends StatelessWidget {
  const _DrawerOverflow({
    required this.dests,
    required this.index,
    required this.onGo,
    required this.state,
  });

  final List<_NavDest> dests;
  final int index;
  final void Function(int) onGo;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                          colors: [Palette.brand, Palette.brandDeep]),
                    ),
                    child: const Icon(Icons.local_shipping_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 11),
                  Text('FleetOps', style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < dests.length; i++)
              ListTile(
                leading: Icon(i == index ? dests[i].selectedIcon : dests[i].icon),
                title: Text(dests[i].label),
                selected: i == index,
                selectedTileColor:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                onTap: () {
                  onGo(i);
                  Navigator.of(context).pop();
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Sign out'),
              onTap: state.signOut,
            ),
          ],
        ),
      ),
    );
  }
}
