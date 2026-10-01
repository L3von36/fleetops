import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/palette.dart';
import '../../core/widgets/common.dart';
import '../dashboard/dashboards.dart';
import '../settings/settings_screen.dart';

enum _Section { operations, fleet, business, system }

extension _SectionLabel on _Section {
  String get label => switch (this) {
    _Section.operations => 'Operations',
    _Section.fleet => 'Fleet & Compliance',
    _Section.business => 'Business',
    _Section.system => 'System',
  };
}

class _NavDest {
  const _NavDest(
    this.label,
    this.icon,
    this.selectedIcon,
    this.builder, {
    this.section = _Section.operations,
  });
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
  final _Section section;

  String get shortLabel => label.split(' ').first;
}

/// Adaptive application shell:
///   • Desktop ≥1100 px  → grouped navigation sidebar + top bar
///   • Tablet  700–1100  → navigation rail + top bar
///   • Mobile  <700 px   → AppBar + bottom navigation + overflow drawer
/// Destinations are filtered by the signed-in role (PRD §2.2 simplified).
/// All chrome sits inside [SafeArea] so notches and system bars never
/// overlap content (PRD §5 — accessibility & mobile quality bar).
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _sidebarExpanded = true;
  Role _lastRole = Role.fleetManager;

  List<_NavDest> _destinationsFor(Role role) {
    final overview = _NavDest(
      'Command Center',
      Icons.space_dashboard_outlined,
      Icons.space_dashboard_rounded,
      (_) => const FleetManagerDashboard(),
    );
    final dispatch = _NavDest(
      'Dispatch',
      Icons.hub_outlined,
      Icons.hub_rounded,
      (_) => const DispatcherDashboard(),
    );
    final driverApp = _NavDest(
      'Driver App',
      Icons.local_shipping_outlined,
      Icons.local_shipping_rounded,
      (_) => const DriverDashboard(),
    );
    final maint = _NavDest(
      'Maintenance',
      Icons.build_outlined,
      Icons.build_rounded,
      (_) => const MaintenanceDashboard(),
      section: _Section.fleet,
    );
    final safety = _NavDest(
      'Safety',
      Icons.health_and_safety_outlined,
      Icons.health_and_safety_rounded,
      (_) => const SafetyDashboard(),
      section: _Section.fleet,
    );
    final finance = _NavDest(
      'Finance',
      Icons.payments_outlined,
      Icons.payments_rounded,
      (_) => const FinanceDashboard(),
      section: _Section.business,
    );
    final fuel = _NavDest(
      'Fuel & Energy',
      Icons.local_gas_station_outlined,
      Icons.local_gas_station_rounded,
      (_) => const FuelDashboard(),
      section: _Section.fleet,
    );
    final exec = _NavDest(
      'Executive BI',
      Icons.insights_outlined,
      Icons.insights_rounded,
      (_) => const ExecutiveDashboard(),
      section: _Section.business,
    );
    final settings = _NavDest(
      'Settings',
      Icons.settings_outlined,
      Icons.settings_rounded,
      (_) => const SettingsScreen(),
      section: _Section.system,
    );
    final platformAdmin = _NavDest(
      'Platform Admin',
      Icons.admin_panel_settings_outlined,
      Icons.admin_panel_settings_rounded,
      (_) => const SuperAdminDashboard(),
      section: _Section.business,
    );
    final depot = _NavDest(
      'Depot & Yard',
      Icons.warehouse_outlined,
      Icons.warehouse_rounded,
      (_) => const DepotDashboard(),
    );
    final customerPortal = _NavDest(
      'My Shipments',
      Icons.inventory_2_outlined,
      Icons.inventory_2_rounded,
      (_) => const CustomerPortalDashboard(),
    );
    final auditorView = _NavDest(
      'Audit Access',
      Icons.plagiarism_outlined,
      Icons.plagiarism_rounded,
      (_) => const AuditorDashboard(),
    );

    return switch (role) {
      Role.superAdmin => [
        platformAdmin,
        overview,
        dispatch,
        driverApp,
        depot,
        maint,
        safety,
        fuel,
        finance,
        exec,
        settings,
      ],
      Role.fleetManager => [
        overview,
        dispatch,
        driverApp,
        depot,
        maint,
        safety,
        fuel,
        finance,
        exec,
        settings,
      ],
      Role.dispatcher => [dispatch, overview, driverApp, depot, settings],
      Role.driver => [driverApp, safety, settings],
      Role.maintenance => [maint, overview, settings],
      Role.safety => [safety, overview, settings],
      Role.finance => [finance, overview, settings],
      Role.fuelManager => [fuel, overview, settings],
      Role.depot => [depot, overview, dispatch, settings],
      Role.customer => [customerPortal, settings],
      Role.executive => [exec, overview, settings],
      Role.auditor => [auditorView, settings],
    };
  }

  void _go(int i) => setState(() => _index = i);

  List<_NavDest> get _currentDests => _destinationsFor(widget.state.role);

  /// Current selected destination (read by the top bar via ancestor lookup).
  int get index => _index;

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Role switched (via demo switcher) → land on that role's dashboard.
    if (widget.state.role != _lastRole) {
      _lastRole = widget.state.role;
      _index = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dests = _destinationsFor(widget.state.role);
    if (_index >= dests.length) _index = 0;

    // Outer Scaffold provides the Material ancestor for the desktop/tablet
    // chrome and for dashboard pages (they are plain scroll views).
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final desktop = w >= 1100;
          final tablet = w >= 700 && w < 1100;

          final page = IndexedStack(
            index: _index,
            children: [
              for (final d in dests)
                Builder(key: ValueKey(d.label), builder: d.builder),
            ],
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
                      SafeArea(
                        bottom: false,
                        child: _TopBar(state: widget.state, compact: false),
                      ),
                      Expanded(child: page),
                    ],
                  ),
                ),
              ],
            );
          }

          if (tablet) {
            return Scaffold(
              body: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    // Scrollable so roles with many destinations (Super Admin)
                    // never overflow on short tablet landscape viewports.
                    SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: _Rail(dests: dests, index: _index, onGo: _go),
                      ),
                    ),
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
              ),
            );
          }

          // Mobile — AppBar owns the top safe area; NavigationBar owns the
          // bottom inset. Body content only needs horizontal protection.
          final overflow = dests.length > 5;
          final navDests = overflow ? dests.sublist(0, 4) : dests;
          final mobileIndex = _index < navDests.length ? _index : 0;
          return Scaffold(
            appBar: _TopBar(state: widget.state, compact: true),
            drawer: _DrawerOverflow(
              dests: dests,
              index: _index,
              onGo: _go,
              state: widget.state,
            ),
            body: page,
            bottomNavigationBar: NavigationBar(
              selectedIndex: mobileIndex,
              onDestinationSelected: _go,
              destinations: [
                for (final d in navDests)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.shortLabel,
                  ),
              ],
            ),
          );
        },
      ),
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
      width: expanded ? 268.0 : 78.0,
      child: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 12, 6),
                child: Row(
                  children: [
                    const _BrandBadge(),
                    if (expanded) ...[
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FleetOps', style: theme.textTheme.titleLarge),
                            Text(
                              'Fleet Management System',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: _RolePill(state: state, expanded: expanded),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  children: _groupedItems(theme),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Material(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(11),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            expanded
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          if (expanded) ...[
                            const SizedBox(width: 10),
                            Text(
                              'Collapse',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: _UserBlock(state: state, expanded: expanded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _groupedItems(ThemeData theme) {
    final items = <Widget>[];
    _Section? last;
    for (var i = 0; i < dests.length; i++) {
      final d = dests[i];
      if (d.section != last) {
        last = d.section;
        items.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
            child: Text(
              expanded ? d.section.label.toUpperCase() : '•',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.75,
                ),
              ),
            ),
          ),
        );
      }
      items.add(
        _SidebarItem(
          dest: d,
          selected: i == index,
          expanded: expanded,
          onTap: () => onGo(i),
        ),
      );
    }
    return items;
  }
}

/// Gradient brand badge used by sidebar, rail and drawer.
class _BrandBadge extends StatelessWidget {
  const _BrandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Palette.brandGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.brand.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_shipping_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

/// Role context pill under the brand mark.
class _RolePill extends StatelessWidget {
  const _RolePill({required this.state, required this.expanded});

  final AppState state;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expanded ? double.infinity : 44,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          if (expanded) ...[
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                '${state.role.label} workspace',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? dest.selectedIcon : dest.icon,
                      size: 21,
                      color: fg,
                    ),
                    if (expanded) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dest.label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: fg,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
            ],
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
      leading: const Padding(
        padding: EdgeInsets.only(top: 14, bottom: 10),
        child: _BrandBadge(),
      ),
      destinations: [
        for (final d in dests)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.shortLabel),
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

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shell = context.findAncestorStateOfType<_AppShellState>();
    final dests = shell?._currentDests ?? const [];
    final idx = shell?.index ?? 0;
    final title = (dests.isNotEmpty && idx < dests.length)
        ? dests[idx].label
        : 'FleetOps';

    return Container(
      height: _height,
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
          if (compact) ...[const _BrandBadge(), const SizedBox(width: 10)],
          if (!compact) ...[
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(width: 10),
            const StatusChip(
              label: 'Live',
              color: Palette.success,
              dense: true,
            ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: state.isDark ? 'Light mode' : 'Dark mode',
            onPressed: state.toggleTheme,
            icon: Icon(
              state.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.notifications_outlined),
              ),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Palette.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          _UserMenu(state: state),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final theme = Theme.of(context);
    final alerts = state.liveAlerts
        .where((a) => !a.acknowledged)
        .take(5)
        .toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          children: [
            Row(
              children: [
                Text('Notifications', style: theme.textTheme.titleMedium),
                const Spacer(),
                StatusChip(
                  label: '${alerts.length} new',
                  color: Palette.danger,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 26),
                child: EmptyState(
                  icon: Icons.notifications_off_rounded,
                  title: 'All clear',
                  message: 'No unread alerts right now.',
                ),
              ),
            for (final a in alerts) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SeverityIcon(severity: a.severity),
                title: Text(
                  '${a.type} · ${a.subject}',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
                subtitle: Text(
                  a.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                trailing: TextButton(
                  onPressed: () {
                    state.acknowledgeAlert(a.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Ack'),
                ),
              ),
              if (a != alerts.last) const Divider(),
            ],
          ],
        ),
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
    return _UserMenu(
      state: state,
      // No InkWell here — PopupMenuButton handles the tap on its child;
      // a nested gesture widget would steal the tap and break the menu.
      block: (onTap) => Padding(
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
                    Text(
                      'Ops User',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      state.role.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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
}

/// Avatar + menu with the full role switcher (demo superpower) and
/// sign-out. Used by both the top bar and the sidebar footer.
class _UserMenu extends StatelessWidget {
  const _UserMenu({required this.state, this.block});

  final AppState state;
  final Widget Function(void Function() onTap)? block;

  static const _roleIcons = <Role, IconData>{
    Role.superAdmin: Icons.admin_panel_settings_rounded,
    Role.fleetManager: Icons.space_dashboard_rounded,
    Role.dispatcher: Icons.hub_rounded,
    Role.driver: Icons.local_shipping_rounded,
    Role.maintenance: Icons.build_rounded,
    Role.safety: Icons.health_and_safety_rounded,
    Role.finance: Icons.payments_rounded,
    Role.fuelManager: Icons.local_gas_station_rounded,
    Role.depot: Icons.warehouse_rounded,
    Role.customer: Icons.inventory_2_rounded,
    Role.executive: Icons.insights_rounded,
    Role.auditor: Icons.plagiarism_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final trigger =
        block ??
        (onTap) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: UserAvatar(name: 'Ops User', size: 34),
        );

    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'signout') {
          state.signOut();
          return;
        }
        final role = Role.values.where((r) => r.name == v).firstOrNull;
        if (role != null) state.signIn(role);
      },
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      constraints: const BoxConstraints(minWidth: 250, maxHeight: 480),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'SWITCH WORKSPACE (DEMO)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final r in Role.values)
          PopupMenuItem<String>(
            value: r.name,
            height: 42,
            child: Row(
              children: [
                Icon(
                  _roleIcons[r],
                  size: 18,
                  color: r == state.role
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    r.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: r == state.role
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (r == state.role)
                  const Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: Palette.success,
                  ),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'profile',
          height: 42,
          child: Row(
            children: [
              Icon(Icons.person_rounded, size: 18),
              SizedBox(width: 10),
              Text('My profile'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'signout',
          height: 42,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      child: trigger(() {}),
    );
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
    // Build grouped rows up-front so section headers can be interleaved
    // without leaking non-Widget values into the children list.
    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const _BrandBadge(),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FleetOps', style: theme.textTheme.titleLarge),
                Text(
                  state.role.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ];
    _Section? last;
    for (var i = 0; i < dests.length; i++) {
      if (dests[i].section != last) {
        last = dests[i].section;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(
              last.label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      rows.add(
        ListTile(
          leading: Icon(i == index ? dests[i].selectedIcon : dests[i].icon),
          title: Text(dests[i].label),
          selected: i == index,
          selectedTileColor: theme.colorScheme.primaryContainer.withValues(
            alpha: 0.6,
          ),
          onTap: () {
            onGo(i);
            Navigator.of(context).pop();
          },
        ),
      );
    }
    rows.addAll([
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout_rounded),
        title: const Text('Sign out'),
        onTap: state.signOut,
      ),
    ]);
    return Drawer(
      child: SafeArea(
        child: ListView(padding: const EdgeInsets.all(12), children: rows),
      ),
    );
  }
}
