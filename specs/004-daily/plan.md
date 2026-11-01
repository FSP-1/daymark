# Implementation Plan: Daily Activities

**Date**: 2026-11-01 | **Spec**: [spec.md](./spec.md)

## Summary

Add a local Daily activity workflow with recurring activities, date-keyed completion
history, optional local notifications for Specific time activities, and a reusable
platform-independent notification architecture. The implementation must extend the
existing Drift migration boundary without changing Notes, preserve MVVM/Provider and
centralized themes/localization, and remain useful when notification permission or
platform support is unavailable.

## Technical Context

**Language/Version**: Dart SDK `^3.13.5`, Flutter  
**Primary dependencies**: Existing Flutter Material, Provider, Drift/SQLite; candidate
notification packages are deferred pending compatibility verification  
**Storage**: Existing Drift database with new Daily activity/completion tables in a
versioned migration; no remote storage  
**State management**: MVVM with Provider/ChangeNotifier  
**Testing**: `flutter_test`, Drift repository tests, fake clock/calendar, fake
notification service/event bus, widget and regression tests  
**Target platform**: Android-first Flutter; preserve other Flutter targets and degrade
notification capability where unsupported  
**Constraints**: Offline-first, no Firebase/cloud sync, no Notes schema changes, no
notification implementation in this phase, and no assistant-run Android debug build

## Constitution Check

*GATE: Must pass before implementation and again before completion.*

- **Maintainable architecture — PASS**: Daily domain, repository, ViewModel, and views
  remain separate; platform notification code stays in a core adapter.
- **TDD — PASS**: Each behavior begins with failing domain, repository, ViewModel,
  notification, or widget tests.
- **SDD — PASS**: This spec, research, plan, tasks, and checklist precede coding.
- **Offline-first — PASS**: Activities and completion are local; notifications are an
  optional local capability and never the source of truth.
- **Quality — PASS**: Tests cover empty/loading/success/error, date boundaries,
  permission outcomes, localization, themes, migrations, and regressions.
- **Privacy/security — PASS**: No accounts, remote services, credential handling, or
  sensitive activity-content logging.
- **Documentation/Git — PASS**: Decisions and package/platform limitations are recorded;
  generated databases, build output, and secrets remain excluded.
- **Scope — PASS**: Only Daily and reusable notification infrastructure are planned.

## Architecture

```text
lib/
├── core/
│   ├── localization/
│   ├── theme/
│   └── notifications/
│       ├── notification_service.dart
│       ├── notification_event_bus.dart
│       ├── notification_models.dart
│       └── platform_notification_service.dart
└── features/
    └── daily/
        ├── domain/
        │   ├── daily_activity.dart
        │   ├── daily_completion.dart
        │   ├── daily_repository.dart
        │   └── daily_schedule.dart
        ├── data/
        │   ├── daily_repository.dart
        │   └── daily_notification_coordinator.dart
        └── presentation/
            ├── daily_page.dart
            ├── daily_editor.dart
            └── daily_view_model.dart
```

`AppDatabase` remains the persistence owner. The Daily repository owns activity and
completion queries but not widget state. `DailyViewModel` owns idle/loading/success/
error state and today's completion projection. `DailyNotificationCoordinator` maps
validated activity changes to the global notification contract. The platform adapter
is the only layer allowed to import the selected notification plugin.

## Data and migration design

1. Add `DailyActivities` with stable activity ID, name, schedule mode, nullable hour/
   minute, notification flag, and timestamps.
2. Add `DailyCompletions` with activity ID, canonical local date key, optional
   completion timestamp, and unique `(activityId, localDate)`.
3. Add a Drift schema migration and generated code through the existing build process.
4. Ensure delete cleanup via foreign-key cascade or explicit repository transaction.
5. Keep notification IDs derived from a namespace and activity ID; never store
   plugin-specific payloads as the Daily source of truth.
6. Inject a clock/calendar into repository/ViewModel/coordinator tests; production
   uses the device's local calendar policy.

## Notification lifecycle

- On Specific time + enable: request/check permission, schedule one stable ID, then
  persist enabled state only on a successful service result.
- On disable: cancel stable ID, then persist disabled state; failure remains retryable.
- On time change with enabled state: cancel old ID, schedule new time, and surface
  replacement failure without claiming success.
- On Specific time → Anytime: cancel and force notification disabled.
- On delete: cancel first when needed, then delete activity and completions in a local
  transaction or explicit compensating path.
- On unsupported/denied capability: retain activity and time; show localized state.

## Implementation steps

### Step 1: Foundational contracts and test seams

- **Requirements**: REQ-001–004, REQ-007–015, NFR-001–006
- Define Daily entities, schedule invariants, date-key/calendar interfaces, repository
  contracts, notification models, stable IDs, service results, and typed observer
  events. Write failing tests first.

### Step 2: Persistence and completion history

- **Requirements**: REQ-001, REQ-005–010, REQ-018
- Add Drift tables/migration, repository CRUD, completion upsert/delete/query, and
  migration/reopen tests. Verify Notes behavior and schema remain unchanged.

### Step 3: Global notification architecture

- **Requirements**: REQ-011–015, NFR-005–006
- Verify the selected package/toolchain compatibility, add only approved dependencies,
  implement the platform adapter, event bus, typed outcomes, permission handling,
  scheduling/replacement/cancellation, and fake-service tests. No Daily UI imports
  plugin APIs.

### Step 4: Daily ViewModel and notification coordinator

- **Requirements**: REQ-001–010, REQ-012–015
- Add explicit idle/loading/success/error state, CRUD actions, completion toggles,
  retryability, and coordinator integration. Ensure notification failures do not
  roll back unrelated local activity/completion capabilities.

### Step 5: Daily UI and navigation

- **Requirements**: REQ-001–004, REQ-016–019, NFR-003–004
- Replace the existing Tasks placeholder with Daily, add localized list/editor states,
  schedule mode controls, conditional notification controls, completion semantics,
  delete/edit confirmations, empty/error feedback, and all required resource keys.
  Use existing theme tokens and responsive Material patterns.

### Step 6: Cross-cutting validation and documentation

- **Requirements**: REQ-016–019, NFR-001–006
- Run `dart format`, `flutter analyze`, focused tests, and `flutter test`. Review
  migration, localization, dependency, privacy, and scope diffs. Android platform
  permission/emulator verification is for the implementation owner; the assistant
  must not run an Android debug build.

## Testing strategy

- Domain: schedule validation, name validation, date key, notification eligibility,
  stable ID and idempotence.
- Repository: CRUD, completion history, uniqueness, cleanup, migrations, reopen,
  offline and failure paths.
- Notification: fake platform service and event bus; granted/denied/unavailable,
  request ordering, replacement, cancellation, collision isolation, disposal.
- ViewModel: state transitions, retry, local success despite notification failure,
  no false enabled state, and current-date projection.
- Widget: Daily empty/list/editor, Anytime/Specific time, notification messaging,
  completed/incomplete semantics, both locales, 18 theme combinations, responsive
  constraints, and accessible controls.
- Regression: Sticky Notes, Settings, navigation, localization, and existing full suite.

## Requirement mapping

| Requirement | Plan steps | Evidence |
|---|---:|---|
| REQ-001–006 | 1, 2, 4, 5 | Domain/repository/ViewModel/widget tests |
| REQ-007–010 | 1, 2, 4 | Calendar, completion, migration, reopen tests |
| REQ-011–015 | 1, 3, 4 | Service/event/fake-platform tests |
| REQ-016–017 | 1, 5, 6 | JSON resources, localized widget tests |
| REQ-018 | 2, 6 | Migration and Sticky Notes regression tests |
| REQ-019 | 1–6 | Quality-gate and full-suite evidence |
| NFR-001–006 | 1–6 | Failure, privacy, accessibility, and performance evidence |

## Complexity tracking

No constitution violation is planned. The observer mechanism is intentionally narrow
and typed; a general-purpose event bus, remote notification system, or global Daily
state manager is not justified.
