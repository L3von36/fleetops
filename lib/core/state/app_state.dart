import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

/// Supported operator roles (PRD §2.1). Each role maps to a nav plan.
enum Role {
  superAdmin('Super Admin'),
  fleetManager('Fleet Manager'),
  dispatcher('Dispatcher'),
  driver('Driver'),
  maintenance('Maintenance'),
  safety('Safety & Compliance'),
  finance('Finance'),
  fuelManager('Fuel Manager'),
  depot('Depot Manager'),
  customer('Customer'),
  executive('Executive'),
  auditor('Auditor');

  const Role(this.label);
  final String label;
}

/// Root application state: signed-in role, theme mode, and the simulated
/// real-time telemetry heartbeat (positions, speeds, incoming alerts).
class AppState extends ChangeNotifier {
  AppState() {
    _heartbeat = Timer.periodic(const Duration(seconds: 2), (_) => _onTick());
  }

  late final Timer _heartbeat;

  @override
  void dispose() {
    _heartbeat.cancel();
    super.dispose();
  }

  // ── Session ──────────────────────────────────────────────────────────
  Role _role = Role.fleetManager;
  Role get role => _role;
  bool get signedIn => _signedIn;
  bool _signedIn = false;
  bool _isDark = false;
  bool get isDark => _isDark;

  void signIn(Role role) {
    _role = role;
    _signedIn = true;
    notifyListeners();
  }

  void signOut() {
    _signedIn = false;
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // ── Live telemetry simulation ────────────────────────────────────────
  List<Vehicle> _liveVehicles = List.of(vehicles);
  List<FleetAlert> _liveAlerts = List.of(alerts);
  final Random _rng = Random();

  List<Vehicle> get liveVehicles => _liveVehicles;
  List<FleetAlert> get liveAlerts => _liveAlerts;

  int get onRouteCount =>
      _liveVehicles.where((v) => v.status == VehicleStatus.onRoute).length;
  int get idleCount => _liveVehicles.where((v) => v.status == VehicleStatus.idle).length;
  int get maintCount =>
      _liveVehicles.where((v) => v.status == VehicleStatus.maintenance).length;
  int get offlineCount =>
      _liveVehicles.where((v) => v.status == VehicleStatus.offline).length;

  void _onTick() {
    _liveVehicles = tick(_liveVehicles, _rng);
    notifyListeners();
  }

  void acknowledgeAlert(String id) {
    _liveAlerts = [
      for (final a in _liveAlerts) if (a.id == id) a.ack() else a
    ];
    notifyListeners();
  }

  // ── Derived KPI helpers (mock values consistent with PRD targets) ────
  double get onTimePct => 94.2;
  double get utilizationPct =>
      _liveVehicles.isEmpty ? 0 : onRouteCount / _liveVehicles.length * 100;
  double get fuelCostToday => 1862.0;
  double get costPerKm => 1.19;
}
