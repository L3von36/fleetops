import 'package:flutter/material.dart';

import 'core/state/app_scope.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/app_shell.dart';

void main() {
  runApp(const FleetOpsApp());
}

class FleetOpsApp extends StatefulWidget {
  const FleetOpsApp({super.key});

  @override
  State<FleetOpsApp> createState() => _FleetOpsAppState();
}

class _FleetOpsAppState extends State<FleetOpsApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) => MaterialApp(
          title: 'FleetOps — Fleet Management System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _state.isDark ? ThemeMode.dark : ThemeMode.light,
          home: _state.signedIn
              ? AppShell(state: _state)
              : LoginScreen(onSignIn: _state.signIn),
        ),
      ),
    );
  }
}
