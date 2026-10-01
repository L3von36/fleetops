# FleetOps — Fleet Management System (Flutter, Mobile + Desktop)

[![Build & Release](https://github.com/L3von36/fleetops/actions/workflows/release.yml/badge.svg)](https://github.com/L3von36/fleetops/actions/workflows/release.yml)

A professional, role-based fleet management platform built with **Flutter** from the
*Fleet Management System PRD v1.0*. One codebase targets **Android, iOS, Web,
Windows, macOS and Linux**.

> Demo build — all data is mocked in-memory and a telemetry simulator streams
> live vehicle positions/speeds every 2 s to emulate the real-time backbone
> (PRD target: position latency ≤ 10 s).

## 🆕 v1.1 highlights

- **All 12 PRD role dashboards** — new: Super Admin (platform governance),
  Depot & Yard (docks, geofence check-ins, cold chain), Customer Portal
  (shipments, POD, invoices, SLA), Auditor (read-only, time-boxed access).
- **UI/UX overhaul** — grouped navigation sidebar with collapse, live
  notifications sheet, role switcher (12 workspaces in one tap), redesigned
  KPI tiles with trend pills & gradient icon chips, new empty states,
  page transitions, polished menus/scrollbars/segmented buttons.
- **SafeArea everywhere** — notch/gesture-bar aware on phones (sidebar,
  top bar, bottom nav, sheets, drawer).
- **Custom launcher icon set** — generated per platform (adaptive Android,
  iOS/macOS asset catalogs, web + maskable, Windows .ico).
- **Native splash screens** — Android 12+ & legacy, iOS, web.
- **Signed Android releases** — CI decodes a keystore from repo secrets
  (`ANDROID_KEYSTORE_*`), signs the APK **and** publishes a Play-ready
  `.aab`. Local builds fall back to debug signing automatically.

## 🌐 Live web demo & 📦 downloads

- **Live demo (GitHub Pages):** <https://l3von36.github.io/fleetops/>
- **Installers (GitHub Releases):** <https://github.com/L3von36/fleetops/releases>
  - `FleetOps-Android-*.apk` — Android 7.0+ (sideload)
  - `FleetOps-Windows-*.zip` — Windows 10/11 x64 → run `fleetops.exe`
  - `FleetOps-macOS-*.zip` — macOS → right-click `fleetops.app` → Open (unsigned)
  - `FleetOps-Linux-*.tar.gz` — Linux x64 (GTK) bundle
  - `FleetOps-Web-*.zip` — static web build, host anywhere

## ⚙️ CI/CD (GitHub Actions)

The workflow `.github/workflows/release.yml` runs on every push:

| Trigger | What happens |
| --- | --- |
| Push to `main` | Builds **Android APK** + **Web**, deploys web demo to GitHub Pages |
| Push tag `v*` | Builds **Android, Web, Windows, Linux, macOS**, then publishes a **GitHub Release** with all installers attached |
| `workflow_dispatch` | Full platform matrix on demand |

Flutter toolchain is pinned (`3.47.5 stable`) with pub/cache enabled, so builds are reproducible.

---

## Feature coverage (mapped to the PRD)

| PRD § | Delivered |
| --- | --- |
| §2 Roles & permissions | 12 roles defined; navigation destinations filtered per role (simplified RBAC); quick demo sign-in as Fleet Manager, Dispatcher, Driver or Executive |
| §3 Dashboards | **Fleet Manager command center** (KPIs, live map, alert feed, trips timeline, docs expiring, driver leaderboard), **Dispatcher** (unassigned queue + auto-dispatch suggestions, HOS availability board, exceptions, live ETA board), **Driver app** (assignment card, HOS ring, POD/inspection/fuel/expense/SOS quick actions, stops timeline, scorecard, document wallet), **Maintenance** (work orders, DTC feed, parts stock), **Safety & Compliance** (harsh events, risk ranking, HOS monitor, incidents), **Finance** (revenue vs cost, invoices, expense approvals, budget), **Fuel & Energy** (spend, anomaly flags, eco leaderboard, EV readiness), **Executive BI** (OKR tiles, utilization/OTIF trends, branch comparison, CO₂) |
| §4 Functional | UI coverage of FR-14/15 (live map + geofence mock), FR-19..24 (orders, dispatch, ETA, POD capture points), FR-30..33 (maintenance/DVIR), FR-36..40 (safety/compliance), FR-47..49 (finance automation), FR-51..54 (notifications & integration status in Settings) |
| §5 Non-functional | Adaptive layout (phone / tablet / desktop), light + dark themes, tabular-figure numerics, WCAG-friendly contrast, offline-ready messaging |
| §6 Architecture | Feature-first structure (`core/` + `features/`), models mirror PRD §6.4 entities, `LiveMap` widget is the drop-in point for `google_maps_flutter`/MapLibre, state via `ChangeNotifier` + `InheritedNotifier` (swap-ready for Riverpod per PRD §6.1) |

## Design system

- **Palette** — "operations trust": royal blue `#2C5BF2` anchor, teal/violet series,
  traffic-light semantics; tuned light & dark (deep navy) variants (`core/theme/`).
- **Typography** — tightened headings, tabular figures for all numerics.
- **Layout** — 4 px spacing grid, 16 px card radius; breakpoints: mobile <700,
  tablet 700–1100 (nav rail), desktop ≥1100 (sidebar).
- **Custom data-viz** — zero third-party packages: sparklines, bar / grouped-bar /
  multi-series line charts, donut, score rings, progress meters, and an animated
  stylized live map (custom-painted) — all in `core/widgets/`.

## Run it

```bash
flutter pub get

# Phone / tablet
flutter run                     # pick device, or: flutter run -d <device-id>

# Desktop (Windows / macOS / Linux)
flutter run -d windows          # or macos / linux

# Web
flutter run -d chrome
```

Sign in with any credentials (mocked) or use the **Quick demo** chips.
Tip: toggle dark mode from the top bar — the operations dashboards look great on it.

## Project layout

```
lib/
├── main.dart                  # app entry, theme wiring
├── core/
│   ├── theme/                 # palette + Material 3 theme (light/dark)
│   ├── models/                # Vehicle, Driver, Trip, Alert, WorkOrder, …
│   ├── data/                  # deterministic mock repository + telemetry tick
│   ├── state/                 # AppState (role, theme, live sim) + AppScope
│   └── widgets/               # design-system components & custom charts/map
└── features/
    ├── auth/                  # login (split hero, 12 quick-enter roles)
    ├── shell/                 # adaptive sidebar / rail / bottom-nav shell
    ├── dashboard/             # 12 role dashboards (full PRD §3 coverage)
    └── settings/              # notifications, privacy, integrations
```

## 🔐 Android release signing

The keystore is **not** committed. CI reads repo secrets:

| Secret | Purpose |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | base64 of the `.jks` keystore |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | key alias (`fleetops`) |
| `ANDROID_KEY_PASSWORD` | key password |

Local release builds without `android/key.properties` fall back to debug
signing, so `flutter run --release` keeps working.

## Next steps toward production (per PRD §6)

1. Replace `core/data/mock_data.dart` with the REST/WebSocket client (`dio` +
   OpenAPI-generated models); keep the same model shapes.
2. Swap `LiveMap` for `google_maps_flutter` / MapLibre — the widget interface
   (`vehicles`, `onTapVehicle`) is designed as the seam.
3. Introduce Riverpod + go_router (PRD §6.1) — `AppScope` isolates the current
   state access so migration is mechanical.
4. Add Drift offline store + sync queue for the driver app (PRD FR/offline NFR).
