import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fleetops/features/dashboard/dashboards.dart';
import 'package:fleetops/features/shell/app_shell.dart';
import 'package:fleetops/main.dart';

/// Pumps `frames` frames without pumpAndSettle — the app intentionally runs
/// repeating animations (map pulse) and a telemetry heartbeat timer.
Future<void> pumpFrames(WidgetTester tester,
    {int frames = 4, Duration step = const Duration(milliseconds: 500)}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

void main() {
  testWidgets('login → command center → dark mode smoke test', (tester) async {
    // Large desktop-like surface so the whole form is on screen.
    tester.view.physicalSize = const Size(1600, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FleetOpsApp());
    await tester.pumpAndSettle();

    // 1. Login screen is shown.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('FleetOps'), findsWidgets);

    // 2. Sign in via the Fleet Manager demo chip.
    await tester.ensureVisible(find.text('Fleet Manager'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fleet Manager'));
    await pumpFrames(tester, frames: 6);

    // 3. Command center renders with KPI tiles and live map.
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(FleetManagerDashboard), findsOneWidget);
    expect(find.text('Command Center'), findsWidgets);
    expect(find.text('Live map'), findsOneWidget);
    expect(find.text('Alert feed'), findsOneWidget);

    // 4. Toggle dark theme from the top bar.
    final darkToggle = find.byIcon(Icons.dark_mode_rounded);
    expect(darkToggle, findsOneWidget);
    await tester.tap(darkToggle);
    await pumpFrames(tester);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    // 5. Navigate to another destination (Dispatch on desktop sidebar).
    final dispatch = find.text('Dispatch');
    if (dispatch.evaluate().isNotEmpty) {
      await tester.tap(dispatch.first);
      await pumpFrames(tester, frames: 4);
      expect(find.byType(DispatcherDashboard), findsOneWidget);
    }
  });

  testWidgets('mobile viewport — compact single-pane login → shell',
      (tester) async {
    // iPhone 14-class surface (logical 390×844).
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FleetOpsApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    // Any RenderFlex overflow above fails the test automatically.
    await tester.ensureVisible(find.text('Dispatcher'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dispatcher'));
    await pumpFrames(tester, frames: 6);
    expect(find.byType(AppShell), findsOneWidget);
  });

  testWidgets('foldable viewport — login survives 280 px width',
      (tester) async {
    tester.view.physicalSize = const Size(560, 1306);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FleetOpsApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
