import 'dart:math';

import 'package:flutter/material.dart';

import '../models/models.dart';

// ─────────────────────────────────────────────────────────── Vehicles ──

final List<Vehicle> vehicles = [
  Vehicle(id: 'V-101', plate: 'FMS-4821', model: 'Volvo FH16', type: 'Truck', status: VehicleStatus.onRoute, driverId: 'D-01', speedKph: 78, fuelPct: 0.62, odometerKm: 214380, nextStop: 'Nairobi Hub', etaMinutes: 34, mapPos: const OffsetXy(0.22, 0.30)),
  Vehicle(id: 'V-102', plate: 'FMS-5107', model: 'Scania R450', type: 'Reefer', status: VehicleStatus.onRoute, driverId: 'D-02', speedKph: 64, fuelPct: 0.41, odometerKm: 187220, nextStop: 'Cold Store 4', etaMinutes: 12, mapPos: const OffsetXy(0.55, 0.22), cargoTempC: -18.2),
  Vehicle(id: 'V-103', plate: 'FMS-2288', model: 'Isuzu NPR', type: 'Van', status: VehicleStatus.idle, driverId: 'D-03', speedKph: 0, fuelPct: 0.88, odometerKm: 96410, nextStop: '—', etaMinutes: 0, mapPos: const OffsetXy(0.40, 0.55)),
  Vehicle(id: 'V-104', plate: 'FMS-7345', model: 'Mercedes Actros', type: 'Truck', status: VehicleStatus.onRoute, driverId: 'D-04', speedKph: 92, fuelPct: 0.55, odometerKm: 301540, nextStop: 'Border Gate', etaMinutes: 78, mapPos: const OffsetXy(0.70, 0.48)),
  Vehicle(id: 'V-105', plate: 'FMS-6690', model: 'BYD eTruck 8T', type: 'EV', status: VehicleStatus.onRoute, driverId: 'D-05', speedKph: 55, fuelPct: 0.72, odometerKm: 42890, nextStop: 'Dock B2', etaMinutes: 21, mapPos: const OffsetXy(0.62, 0.72)),
  Vehicle(id: 'V-106', plate: 'FMS-3120', model: 'Hino 300', type: 'Van', status: VehicleStatus.maintenance, driverId: 'D-06', speedKph: 0, fuelPct: 0.30, odometerKm: 158930, nextStop: 'Workshop 1', etaMinutes: 0, mapPos: const OffsetXy(0.12, 0.68)),
  Vehicle(id: 'V-107', plate: 'FMS-8842', model: 'Scania P320', type: 'Truck', status: VehicleStatus.offline, driverId: 'D-07', speedKph: 0, fuelPct: 0.24, odometerKm: 245010, nextStop: '—', etaMinutes: 0, mapPos: const OffsetXy(0.85, 0.25)),
  Vehicle(id: 'V-108', plate: 'FMS-9014', model: 'Isuzu FVR', type: 'Bus', status: VehicleStatus.onRoute, driverId: 'D-08', speedKph: 48, fuelPct: 0.67, odometerKm: 121700, nextStop: 'Central Station', etaMinutes: 9, mapPos: const OffsetXy(0.33, 0.14)),
  Vehicle(id: 'V-109', plate: 'FMS-4471', model: 'MAN TGX', type: 'Truck', status: VehicleStatus.idle, driverId: 'D-09', speedKph: 0, fuelPct: 0.51, odometerKm: 289340, nextStop: '—', etaMinutes: 0, mapPos: const OffsetXy(0.47, 0.40)),
  Vehicle(id: 'V-110', plate: 'FMS-5526', model: 'Scania R450', type: 'Reefer', status: VehicleStatus.onRoute, driverId: 'D-10', speedKph: 70, fuelPct: 0.35, odometerKm: 176520, nextStop: 'Cold Store 1', etaMinutes: 45, mapPos: const OffsetXy(0.14, 0.42), cargoTempC: 3.8),
];

// ───────────────────────────────────────────────────────────── Drivers ──

final List<Driver> drivers = [
  Driver(id: 'D-01', name: 'Joseph Kimani', phone: '+254 712 004 821', status: DriverStatus.driving, safetyScore: 94, fuelScore: 88, punctuality: 96, hoursDrivenToday: 6.5, hoursLimit: 11, licenseExpiry: '2027-03-14', hosRemainingH: 4.5),
  Driver(id: 'D-02', name: 'Grace Achieng', phone: '+254 720 118 340', status: DriverStatus.driving, safetyScore: 91, fuelScore: 93, punctuality: 89, hoursDrivenToday: 4.0, hoursLimit: 11, licenseExpiry: '2026-11-02', hosRemainingH: 7.0),
  Driver(id: 'D-03', name: 'Peter Otieno', phone: '+254 733 902 114', status: DriverStatus.available, safetyScore: 78, fuelScore: 71, punctuality: 84, hoursDrivenToday: 2.5, hoursLimit: 11, licenseExpiry: '2026-08-19', hosRemainingH: 8.5),
  Driver(id: 'D-04', name: 'Ali Hassan', phone: '+254 701 556 902', status: DriverStatus.driving, safetyScore: 88, fuelScore: 82, punctuality: 92, hoursDrivenToday: 8.0, hoursLimit: 11, licenseExpiry: '2027-01-30', hosRemainingH: 3.0),
  Driver(id: 'D-05', name: 'Sarah Wanjiru', phone: '+254 799 341 726', status: DriverStatus.driving, safetyScore: 97, fuelScore: 95, punctuality: 98, hoursDrivenToday: 3.5, hoursLimit: 11, licenseExpiry: '2028-05-22', hosRemainingH: 7.5),
  Driver(id: 'D-06', name: 'Daniel Mutua', phone: '+254 726 480 019', status: DriverStatus.resting, safetyScore: 85, fuelScore: 79, punctuality: 81, hoursDrivenToday: 9.5, hoursLimit: 11, licenseExpiry: '2026-06-08', hosRemainingH: 1.5),
  Driver(id: 'D-07', name: 'Michael Njoroge', phone: '+254 738 214 660', status: DriverStatus.offDuty, safetyScore: 82, fuelScore: 74, punctuality: 77, hoursDrivenToday: 0, hoursLimit: 11, licenseExpiry: '2026-04-17', hosRemainingH: 11),
  Driver(id: 'D-08', name: 'Esther Mwikali', phone: '+254 745 003 512', status: DriverStatus.driving, safetyScore: 90, fuelScore: 86, punctuality: 94, hoursDrivenToday: 5.0, hoursLimit: 11, licenseExpiry: '2027-09-25', hosRemainingH: 6.0),
  Driver(id: 'D-09', name: 'Brian Kiptoo', phone: '+254 711 780 234', status: DriverStatus.available, safetyScore: 76, fuelScore: 68, punctuality: 88, hoursDrivenToday: 1.5, hoursLimit: 11, licenseExpiry: '2026-12-11', hosRemainingH: 9.5),
  Driver(id: 'D-10', name: 'Lucy Nasimiyu', phone: '+254 758 662 190', status: DriverStatus.driving, safetyScore: 93, fuelScore: 90, punctuality: 91, hoursDrivenToday: 7.0, hoursLimit: 11, licenseExpiry: '2027-07-04', hosRemainingH: 4.0),
];

Driver driverById(String id) => drivers.firstWhere((d) => d.id == id, orElse: () => drivers.first);

// ─────────────────────────────────────────────────────────────── Trips ──

final List<Trip> trips = [
  Trip(id: 'TRP-9041', customer: 'FreshLine Markets', origin: 'Depot A', destination: 'Cold Store 4', status: TripStatus.inProgress, driverId: 'D-02', vehicleId: 'V-102', progress: 0.72, etaTime: '11:24', distanceKm: 148, revenue: 1450, priority: 'High', windowStart: '09:00', windowEnd: '12:00'),
  Trip(id: 'TRP-9042', customer: 'BuildCo Ltd', origin: 'Port Yard', destination: 'Site 12 — Industrial', status: TripStatus.inProgress, driverId: 'D-01', vehicleId: 'V-101', progress: 0.45, etaTime: '12:05', distanceKm: 302, revenue: 2280, priority: 'Normal', windowStart: '08:00', windowEnd: '13:00'),
  Trip(id: 'TRP-9043', customer: 'TransBorder AG', origin: 'Nairobi Hub', destination: 'Border Gate — Namanga', status: TripStatus.delayed, driverId: 'D-04', vehicleId: 'V-104', progress: 0.31, etaTime: '14:40', distanceKm: 540, revenue: 3900, priority: 'High', windowStart: '07:30', windowEnd: '13:30'),
  Trip(id: 'TRP-9044', customer: 'City Transit Co.', origin: 'Garage C', destination: 'Central Station', status: TripStatus.inProgress, driverId: 'D-08', vehicleId: 'V-108', progress: 0.88, etaTime: '10:52', distanceKm: 26, revenue: 320, priority: 'Low', windowStart: '09:30', windowEnd: '11:30'),
  Trip(id: 'TRP-9045', customer: 'GreenCharge Logistics', origin: 'Depot B', destination: 'Dock B2', status: TripStatus.inProgress, driverId: 'D-05', vehicleId: 'V-105', progress: 0.58, etaTime: '11:36', distanceKm: 64, revenue: 540, priority: 'Normal', windowStart: '10:00', windowEnd: '12:30'),
  Trip(id: 'TRP-9046', customer: 'ArcticFoods Ltd', origin: 'Depot A', destination: 'Cold Store 1', status: TripStatus.assigned, driverId: 'D-10', vehicleId: 'V-110', progress: 0.05, etaTime: '13:10', distanceKm: 190, revenue: 1720, priority: 'High', windowStart: '12:00', windowEnd: '15:00'),
  Trip(id: 'TRP-9047', customer: 'Kilimall Express', origin: 'Sort Center', destination: 'Rural Route 9', status: TripStatus.unassigned, driverId: '', vehicleId: '', progress: 0, etaTime: '—', distanceKm: 88, revenue: 640, priority: 'Normal', windowStart: '13:00', windowEnd: '17:00'),
  Trip(id: 'TRP-9048', customer: 'MedSupply Co.', origin: 'Pharmacy Hub', destination: 'County Hospital', status: TripStatus.unassigned, driverId: '', vehicleId: '', progress: 0, etaTime: '—', distanceKm: 42, revenue: 880, priority: 'High', windowStart: '12:30', windowEnd: '14:30'),
  Trip(id: 'TRP-9035', customer: 'FreshLine Markets', origin: 'Depot A', destination: 'Cold Store 4', status: TripStatus.completed, driverId: 'D-02', vehicleId: 'V-102', progress: 1, etaTime: '09:58', distanceKm: 148, revenue: 1450, priority: 'Normal', windowStart: '06:00', windowEnd: '10:00'),
  Trip(id: 'TRP-9036', customer: 'BuildCo Ltd', origin: 'Quarry 3', destination: 'Site 7', status: TripStatus.completed, driverId: 'D-09', vehicleId: 'V-109', progress: 1, etaTime: '08:40', distanceKm: 96, revenue: 760, priority: 'Low', windowStart: '05:30', windowEnd: '09:00'),
];

// ────────────────────────────────────────────────────────────── Alerts ──

final List<FleetAlert> alerts = [
  FleetAlert(id: 'A-1', severity: 'critical', type: 'SOS', message: 'SOS button pressed — driver confirmed safe, assistance dispatched', subject: 'V-107 · FMS-8842', timeAgo: '2m'),
  FleetAlert(id: 'A-2', severity: 'critical', type: 'Engine fault', message: 'DTC P0128 — coolant thermostat below regulating temp', subject: 'V-104 · FMS-7345', timeAgo: '9m'),
  FleetAlert(id: 'A-3', severity: 'warning', type: 'Speeding', message: '96 km/h in an 80 km/h zone for 45 s', subject: 'V-104 · FMS-7345', timeAgo: '12m'),
  FleetAlert(id: 'A-4', severity: 'warning', type: 'Geofence', message: 'Exited yard geofence outside scheduled window', subject: 'V-109 · FMS-4471', timeAgo: '26m'),
  FleetAlert(id: 'A-5', severity: 'warning', type: 'Harsh braking', message: '3 harsh-braking events within 15 minutes', subject: 'D-09 · Brian K.', timeAgo: '41m'),
  FleetAlert(id: 'A-6', severity: 'warning', type: 'Fuel anomaly', message: 'Tank dropped 18 L while ignition off — possible siphoning', subject: 'V-110 · FMS-5526', timeAgo: '1h'),
  FleetAlert(id: 'A-7', severity: 'info', type: 'Idle', message: 'Idling 22 min at depot (fuel waste 2.4 L)', subject: 'V-103 · FMS-2288', timeAgo: '1h'),
  FleetAlert(id: 'A-8', severity: 'info', type: 'Cold chain', message: 'Reefer temp briefly above −15 °C during door open', subject: 'V-102 · FMS-5107', timeAgo: '2h'),
];

// ─────────────────────────────────────────────────────── Work orders ────

final List<WorkOrder> workOrders = [
  WorkOrder(id: 'WO-310', vehicleId: 'V-106 · FMS-3120', title: 'Brake pads replacement — front axle', priority: 'High', status: 'In shop', dueIn: 'Today', costEstimate: 420, vendor: 'AutoCare Central'),
  WorkOrder(id: 'WO-311', vehicleId: 'V-104 · FMS-7345', title: 'Coolant thermostat (DTC P0128)', priority: 'High', status: 'Scheduled', dueIn: 'Tomorrow', costEstimate: 180, vendor: 'Scania Service'),
  WorkOrder(id: 'WO-312', vehicleId: 'V-101 · FMS-4821', title: '60,000 km preventive service', priority: 'Medium', status: 'Scheduled', dueIn: 'In 3 days', costEstimate: 890, vendor: 'Volvo Depot'),
  WorkOrder(id: 'WO-313', vehicleId: 'V-110 · FMS-5526', title: 'Reefer unit annual inspection', priority: 'Medium', status: 'Open', dueIn: 'In 5 days', costEstimate: 350, vendor: 'ThermoKing Partner'),
  WorkOrder(id: 'WO-314', vehicleId: 'V-103 · FMS-2288', title: 'Tire rotation & alignment', priority: 'Low', status: 'Open', dueIn: 'In 8 days', costEstimate: 140, vendor: 'AutoCare Central'),
  WorkOrder(id: 'WO-315', vehicleId: 'V-107 · FMS-8842', title: 'Battery diagnostic — repeated low voltage', priority: 'High', status: 'Open', dueIn: 'Today', costEstimate: 95, vendor: 'Field Mech — Unit 2'),
];

// ─────────────────────────────────────────────────────────── Finance ────

final List<Invoice> invoices = [
  Invoice(id: 'INV-2201', customer: 'FreshLine Markets', amount: 12480, dueIn: 'Due in 4 d', status: 'Outstanding'),
  Invoice(id: 'INV-2198', customer: 'TransBorder AG', amount: 24350, dueIn: 'Overdue 6 d', status: 'Overdue'),
  Invoice(id: 'INV-2196', customer: 'BuildCo Ltd', amount: 8920, dueIn: 'Due in 12 d', status: 'Outstanding'),
  Invoice(id: 'INV-2190', customer: 'City Transit Co.', amount: 3410, dueIn: 'Paid', status: 'Paid'),
  Invoice(id: 'INV-2188', customer: 'MedSupply Co.', amount: 5675, dueIn: 'Overdue 2 d', status: 'Overdue'),
];

final List<ExpenseClaim> expenseClaims = [
  ExpenseClaim(id: 'EXP-501', driverId: 'D-04', category: 'Toll', amount: 45, note: 'Namanga corridor x2'),
  ExpenseClaim(id: 'EXP-502', driverId: 'D-01', category: 'Parking', amount: 12, note: 'Port Yard overnight'),
  ExpenseClaim(id: 'EXP-503', driverId: 'D-08', category: 'Repairs', amount: 130, note: 'Tire puncture — roadside'),
  ExpenseClaim(id: 'EXP-504', driverId: 'D-02', category: 'Loading fee', amount: 25, note: 'Cold Store 4'),
];

// ─────────────────────────────────────────────────────────────── Fuel ──

final List<FuelEvent> fuelEvents = [
  FuelEvent(id: 'F-901', vehicleId: 'V-101 · FMS-4821', liters: 210, cost: 336, station: 'Total — Mombasa Rd', timeAgo: '08:12', anomalyScore: 0.05),
  FuelEvent(id: 'F-902', vehicleId: 'V-110 · FMS-5526', liters: 60, cost: 98, station: 'Unknown — informal', timeAgo: '07:40', anomalyScore: 0.92),
  FuelEvent(id: 'F-903', vehicleId: 'V-104 · FMS-7345', liters: 260, cost: 410, station: 'Rubis — Namanga', timeAgo: '06:55', anomalyScore: 0.11),
  FuelEvent(id: 'F-904', vehicleId: 'V-102 · FMS-5107', liters: 140, cost: 224, station: 'Shell — industrial', timeAgo: '06:20', anomalyScore: 0.03),
  FuelEvent(id: 'F-905', vehicleId: 'V-109 · FMS-4471', liters: 180, cost: 288, station: 'Total — Thika Rd', timeAgo: '05:44', anomalyScore: 0.18),
  FuelEvent(id: 'F-906', vehicleId: 'V-107 · FMS-8842', liters: 320, cost: 505, station: 'OiLibya — depot', timeAgo: '05:02', anomalyScore: 0.68),
];

// ───────────────────────────────────────────────────── Expiring docs ────

final List<ExpiringDoc> expiringDocs = [
  ExpiringDoc(name: 'Daniel Mutua', kind: 'License', owner: 'D-06', daysLeft: 18),
  ExpiringDoc(name: 'FMS-5526 insurance', kind: 'Insurance', owner: 'V-110', daysLeft: 27),
  ExpiringDoc(name: 'TransBorder permit', kind: 'Permit', owner: 'ORG', daysLeft: 41),
  ExpiringDoc(name: 'FMS-7345 inspection', kind: 'Inspection', owner: 'V-104', daysLeft: 58),
  ExpiringDoc(name: 'Michael Njoroge', kind: 'License', owner: 'D-07', daysLeft: 83),
];

// ─────────────────────────────────────────────────────────── Shipments ──

final List<Shipment> shipments = [
  Shipment(id: 'SHP-77120', customer: 'FreshLine Markets', route: 'Depot A → Cold Store 4', status: 'In transit', eta: '11:24', progress: 0.72, tempC: -18.2),
  Shipment(id: 'SHP-77118', customer: 'ArcticFoods Ltd', route: 'Depot A → Cold Store 1', status: 'Out for delivery', eta: '13:10', progress: 0.05, tempC: 3.8),
  Shipment(id: 'SHP-77109', customer: 'BuildCo Ltd', route: 'Port Yard → Site 12', status: 'In transit', eta: '12:05', progress: 0.45, tempC: 24.0),
  Shipment(id: 'SHP-77098', customer: 'MedSupply Co.', route: 'Pharmacy Hub → County Hospital', status: 'Delivered', eta: '09:32', progress: 1, tempC: 5.5),
];

// ─────────────────────────────────────────────── Chart series (static) ──

const List<SeriesPoint> fuelTrend7d = [
  SeriesPoint('Mon', 812), SeriesPoint('Tue', 786), SeriesPoint('Wed', 841),
  SeriesPoint('Thu', 798), SeriesPoint('Fri', 762), SeriesPoint('Sat', 585),
  SeriesPoint('Sun', 421),
];

const List<SeriesPoint> utilization7d = [
  SeriesPoint('Mon', 82), SeriesPoint('Tue', 86), SeriesPoint('Wed', 79),
  SeriesPoint('Thu', 88), SeriesPoint('Fri', 91), SeriesPoint('Sat', 74),
  SeriesPoint('Sun', 62),
];

const List<SeriesPoint> harshEvents7d = [
  SeriesPoint('Mon', 14), SeriesPoint('Tue', 11), SeriesPoint('Wed', 16),
  SeriesPoint('Thu', 9), SeriesPoint('Fri', 12), SeriesPoint('Sat', 6),
  SeriesPoint('Sun', 4),
];

const List<SeriesPoint> costPerKm6m = [
  SeriesPoint('May', 1.42), SeriesPoint('Jun', 1.38), SeriesPoint('Jul', 1.31),
  SeriesPoint('Aug', 1.35), SeriesPoint('Sep', 1.24), SeriesPoint('Oct', 1.19),
];

const List<SeriesPoint> otdTrend7d = [
  SeriesPoint('Mon', 93), SeriesPoint('Tue', 95), SeriesPoint('Wed', 91),
  SeriesPoint('Thu', 96), SeriesPoint('Fri', 94), SeriesPoint('Sat', 97),
  SeriesPoint('Sun', 95),
];

const List<MultiSeries> revenueVsCost6m = [
  MultiSeries('Revenue', [
    SeriesPoint('May', 184), SeriesPoint('Jun', 192), SeriesPoint('Jul', 205),
    SeriesPoint('Aug', 198), SeriesPoint('Sep', 214), SeriesPoint('Oct', 228),
  ], Color(0xFF2C5BF2)),
  MultiSeries('Operating cost', [
    SeriesPoint('May', 152), SeriesPoint('Jun', 158), SeriesPoint('Jul', 164),
    SeriesPoint('Aug', 161), SeriesPoint('Sep', 168), SeriesPoint('Oct', 171),
  ], Color(0xFF0E9394)),
];

const List<MultiSeries> fuelVsEvEnergy7d = [
  MultiSeries('Diesel (kL)', [
    SeriesPoint('Mon', 8.2), SeriesPoint('Tue', 7.9), SeriesPoint('Wed', 8.4),
    SeriesPoint('Thu', 8.0), SeriesPoint('Fri', 7.6), SeriesPoint('Sat', 5.9),
    SeriesPoint('Sun', 4.2),
  ], Color(0xFF2C5BF2)),
  MultiSeries('EV (MWh)', [
    SeriesPoint('Mon', 1.1), SeriesPoint('Tue', 1.2), SeriesPoint('Wed', 1.0),
    SeriesPoint('Thu', 1.3), SeriesPoint('Fri', 1.2), SeriesPoint('Sat', 0.9),
    SeriesPoint('Sun', 0.7),
  ], Color(0xFF0E9394)),
];

/// Route polylines for the stylized live map (normalized 0..1 space).
const List<List<OffsetXy>> mapRoutes = [
  [OffsetXy(0.08, 0.62), OffsetXy(0.22, 0.30), OffsetXy(0.40, 0.18), OffsetXy(0.55, 0.22)],
  [OffsetXy(0.55, 0.22), OffsetXy(0.70, 0.34), OffsetXy(0.70, 0.48), OffsetXy(0.82, 0.62)],
  [OffsetXy(0.14, 0.42), OffsetXy(0.30, 0.52), OffsetXy(0.40, 0.55), OffsetXy(0.62, 0.72)],
  [OffsetXy(0.33, 0.14), OffsetXy(0.42, 0.30), OffsetXy(0.47, 0.40)],
];

const OffsetXy depotPos = OffsetXy(0.08, 0.62);
const OffsetXy geofenceCenter = OffsetXy(0.47, 0.40);

/// Simulated tick — nudges vehicle positions along their heading & jitters
/// speed/fuel to emulate a live telemetry feed (PRD: ≤10 s latency).
List<Vehicle> tick(List<Vehicle> list, Random rng) {
  return list.map((v) {
    if (v.status != VehicleStatus.onRoute) return v;
    final dx = (rng.nextDouble() - 0.35) * 0.012;
    final dy = (rng.nextDouble() - 0.5) * 0.010;
    var nx = (v.mapPos.x + dx).clamp(0.03, 0.95);
    var ny = (v.mapPos.y + dy).clamp(0.05, 0.92);
    final speed = (v.speedKph + (rng.nextDouble() - 0.5) * 12).clamp(18, 105).toDouble();
    final fuel = max(0.05, v.fuelPct - rng.nextDouble() * 0.004);
    final eta = max(1, v.etaMinutes + (rng.nextDouble() < 0.5 ? -1 : 1));
    return v.copyWith(
        mapPos: OffsetXy(nx, ny), speedKph: speed, fuelPct: fuel, etaMinutes: eta);
  }).toList();
}
