/// FleetOps domain models — mirroring PRD §6.4 core entities (subset used
/// by the dashboards). All data is mock; shapes match the future REST API.
library;

import 'dart:ui';

// ─────────────────────────────────────────────────────────── Vehicle ──

enum VehicleStatus { onRoute, idle, maintenance, offline }

class Vehicle {
  const Vehicle({
    required this.id,
    required this.plate,
    required this.model,
    required this.type,
    required this.status,
    required this.driverId,
    required this.speedKph,
    required this.fuelPct,
    required this.odometerKm,
    required this.nextStop,
    required this.etaMinutes,
    required this.mapPos,
    this.cargoTempC,
  });

  final String id;
  final String plate;
  final String model;
  final String type; // Truck / Van / Reefer / Bus / EV
  final VehicleStatus status;
  final String driverId;
  final double speedKph;
  final double fuelPct;
  final double odometerKm;
  final String nextStop;
  final int etaMinutes;
  final OffsetXy mapPos;
  final double? cargoTempC;

  String get statusLabel => switch (status) {
        VehicleStatus.onRoute => 'On route',
        VehicleStatus.idle => 'Idle',
        VehicleStatus.maintenance => 'Maintenance',
        VehicleStatus.offline => 'Offline',
      };

  Vehicle copyWith({
    VehicleStatus? status,
    double? speedKph,
    double? fuelPct,
    OffsetXy? mapPos,
    int? etaMinutes,
  }) =>
      Vehicle(
        id: id,
        plate: plate,
        model: model,
        type: type,
        status: status ?? this.status,
        driverId: driverId,
        speedKph: speedKph ?? this.speedKph,
        fuelPct: fuelPct ?? this.fuelPct,
        odometerKm: odometerKm,
        nextStop: nextStop,
        etaMinutes: etaMinutes ?? this.etaMinutes,
        mapPos: mapPos ?? this.mapPos,
        cargoTempC: cargoTempC,
      );
}

/// Simple 2-D point in normalized map space (0..1) — decouples UI mock map
/// from real geo coordinates until the mapping SDK is integrated.
class OffsetXy {
  const OffsetXy(this.x, this.y);
  final double x;
  final double y;
}

// ───────────────────────────────────────────────────────────── Driver ──

enum DriverStatus { available, onDuty, driving, resting, offDuty }

class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.safetyScore,
    required this.fuelScore,
    required this.punctuality,
    required this.hoursDrivenToday,
    required this.hoursLimit,
    required this.licenseExpiry,
    this.hosRemainingH,
  });

  final String id;
  final String name;
  final String phone;
  final DriverStatus status;
  final double safetyScore; // 0..100
  final double fuelScore; // 0..100
  final double punctuality; // 0..100
  final double hoursDrivenToday;
  final double hoursLimit;
  final String licenseExpiry;
  final double? hosRemainingH;

  String get initials {
    final parts = name.split(' ');
    return parts.map((p) => p.isEmpty ? '' : p[0]).take(2).join();
  }

  String get statusLabel => switch (status) {
        DriverStatus.available => 'Available',
        DriverStatus.onDuty => 'On duty',
        DriverStatus.driving => 'Driving',
        DriverStatus.resting => 'Resting',
        DriverStatus.offDuty => 'Off duty',
      };
}

// ─────────────────────────────────────────────────────────────── Trip ──

enum TripStatus { unassigned, assigned, inProgress, completed, delayed }

class Trip {
  const Trip({
    required this.id,
    required this.customer,
    required this.origin,
    required this.destination,
    required this.status,
    required this.driverId,
    required this.vehicleId,
    required this.progress,
    required this.etaTime,
    required this.distanceKm,
    required this.revenue,
    required this.priority,
    required this.windowStart,
    required this.windowEnd,
  });

  final String id;
  final String customer;
  final String origin;
  final String destination;
  final TripStatus status;
  final String driverId; // '' when unassigned
  final String vehicleId;
  final double progress; // 0..1
  final String etaTime; // HH:mm
  final double distanceKm;
  final double revenue;
  final String priority; // High / Normal / Low
  final String windowStart;
  final String windowEnd;

  String get statusLabel => switch (status) {
        TripStatus.unassigned => 'Unassigned',
        TripStatus.assigned => 'Assigned',
        TripStatus.inProgress => 'In transit',
        TripStatus.completed => 'Completed',
        TripStatus.delayed => 'Delayed',
      };
}

// ────────────────────────────────────────────────────────────── Alert ──

class FleetAlert {
  const FleetAlert({
    required this.id,
    required this.severity, // critical | warning | info
    required this.type, // Speeding, Geofence, Harsh braking, Idle, SOS…
    required this.message,
    required this.subject, // vehicle plate or driver
    required this.timeAgo,
    this.acknowledged = false,
  });

  final String id;
  final String severity;
  final String type;
  final String message;
  final String subject;
  final String timeAgo;
  final bool acknowledged;

  FleetAlert ack() => FleetAlert(
      id: id,
      severity: severity,
      type: type,
      message: message,
      subject: subject,
      timeAgo: timeAgo,
      acknowledged: true);
}

// ────────────────────────────────────────────────────── Work order ────

class WorkOrder {
  const WorkOrder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.priority, // High / Medium / Low
    required this.status, // Open / Scheduled / In shop / Done
    required this.dueIn,
    required this.costEstimate,
    required this.vendor,
  });

  final String id;
  final String vehicleId;
  final String title;
  final String priority;
  final String status;
  final String dueIn;
  final double costEstimate;
  final String vendor;
}

// ──────────────────────────────────────────────────────── Finance ─────

class Invoice {
  const Invoice({
    required this.id,
    required this.customer,
    required this.amount,
    required this.dueIn,
    required this.status, // Outstanding / Overdue / Paid
  });

  final String id;
  final String customer;
  final double amount;
  final String dueIn;
  final String status;
}

class ExpenseClaim {
  const ExpenseClaim({
    required this.id,
    required this.driverId,
    required this.category,
    required this.amount,
    required this.note,
  });

  final String id;
  final String driverId;
  final String category;
  final double amount;
  final String note;
}

// ─────────────────────────────────────────────────────────── Fuel ─────

class FuelEvent {
  const FuelEvent({
    required this.id,
    required this.vehicleId,
    required this.liters,
    required this.cost,
    required this.station,
    required this.timeAgo,
    required this.anomalyScore, // 0..1, ≥0.75 → suspicious
  });

  final String id;
  final String vehicleId;
  final double liters;
  final double cost;
  final String station;
  final String timeAgo;
  final double anomalyScore;

  bool get suspicious => anomalyScore >= 0.75;
}

// ─────────────────────────────────────────────────────────── Document ─

class ExpiringDoc {
  const ExpiringDoc({
    required this.name,
    required this.kind, // License / Insurance / Permit / Inspection
    required this.owner,
    required this.daysLeft,
  });

  final String name;
  final String kind;
  final String owner;
  final int daysLeft;
}

// ────────────────────────────────────────────────────────── Shipment ──

class Shipment {
  const Shipment({
    required this.id,
    required this.customer,
    required this.route,
    required this.status, // In transit / Out for delivery / Delivered
    required this.eta,
    required this.progress,
    required this.tempC, // cold-chain
  });

  final String id;
  final String customer;
  final String route;
  final String status;
  final String eta;
  final double progress;
  final double tempC;
}

// ────────────────────────────────────────────── Chart data containers ─

class SeriesPoint {
  const SeriesPoint(this.label, this.value);
  final String label;
  final double value;
}

class MultiSeries {
  const MultiSeries(this.name, this.points, this.color);
  final String name;
  final List<SeriesPoint> points;
  final Color color;
}
