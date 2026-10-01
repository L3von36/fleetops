import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// Lightweight inherited wrapper around [AppState] so every dashboard can
/// read the live simulated telemetry. (Swap for Riverpod `ProviderScope`
/// when wiring the real backend — PRD §6.1 recommends Riverpod.)
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
