---
description: "Standalone task list for the Daily activities feature"
---

# Tasks: Daily Activities

**Input artifacts**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md)  
**Tests**: Required by the specification and project constitution; use Red-Green-Refactor.  
**Scope**: Local recurring Daily activities, date-keyed completion, and reusable optional
local notifications. No Firebase, cloud sync, or unrelated Sticky Notes changes.

## Phase 1: Specification and implementation seams

- [ ] T001 [Plan:1.1] Confirm the selected notification package version and Flutter/
  Android compatibility without installing or modifying the project in this phase.
- [ ] T002 [P] [Plan:1.1] Define the Daily domain types and schedule invariants in
  `lib/features/daily/domain/` through failing unit tests first.
- [ ] T003 [P] [Plan:1.1] Define the injected local clock/calendar contract and tests for
  canonical date keys, midnight, DST, and timezone-boundary behavior.
- [ ] T004 [P] [Plan:1.1] Define notification models, stable namespaced identifiers,
  typed capability/results, and the narrow observer/event contract in
  `lib/core/notifications/`, with failing tests.

**Checkpoint**: Contracts and date/notification seams are approved before persistence.

## Phase 2: Daily persistence

- [ ] T005 [Plan:2.1] Write failing Drift repository tests for activity CRUD, schedule
  invariants, empty collections, and reopened local database behavior.
- [ ] T006 [Plan:2.1] Add versioned `DailyActivities` and `DailyCompletions` tables and
  migration without modifying the existing `Notes` table; generate Drift code through
  the repository's existing tooling.
- [ ] T007 [Plan:2.1] Implement the Daily repository for CRUD, today's completion
  projection, idempotent complete/uncomplete, history preservation, and delete cleanup.
- [ ] T008 [P] [Plan:2.1] Add migration, uniqueness, date isolation, failure, offline,
  and database-reopen regression tests.

**Checkpoint**: Daily data is durable locally and completion history is date-specific.

## Phase 3: Global notification infrastructure

- [ ] T009 [Plan:3.1] Add only the approved notification dependencies after compatibility
  verification; document platform setup and permission limitations.
- [ ] T010 [P] [Plan:3.1] Implement the platform-independent `NotificationService`
  contract and typed availability/permission/scheduling outcomes.
- [ ] T011 [P] [Plan:3.1] Implement the narrow typed `NotificationEventBus` with
  subscription disposal and tests for observer isolation and error propagation.
- [ ] T012 [Plan:3.1] Implement `PlatformNotificationService` as the sole plugin adapter,
  including initialization, permission request, timezone-aware scheduling, replacement,
  and cancellation.
- [ ] T013 [Plan:3.1] Add fake-service tests for granted, denied, unavailable,
  initialization failure, schedule failure, replace ordering, cancel ordering, and
  stable ID collision isolation.

**Checkpoint**: Future features can use notifications without importing plugin APIs.

## Phase 4: Daily ViewModel and notification integration

- [ ] T014 [Plan:4.1] Write failing ViewModel tests for idle/loading/success/error,
  validation, retry, CRUD, date completion toggles, and notification failure states.
- [ ] T015 [Plan:4.1] Implement `DailyViewModel` with explicit state ownership,
  repository actions, injected calendar, and no user-facing hardcoded strings.
- [ ] T016 [Plan:4.1] Write failing coordinator tests for Anytime suppression,
  Specific time enable/disable, time replacement, deletion cancellation, and permission
  denial without blocking local activity operations.
- [ ] T017 [Plan:4.1] Implement `DailyNotificationCoordinator` using the global service/
  event contracts and deterministic activity-scoped notification IDs.

**Checkpoint**: Daily behavior is testable without widgets or a real notification platform.

## Phase 5: Daily UI, localization, and navigation

- [ ] T018 [Plan:5.1] Add all English and Spanish Daily, schedule, completion,
  notification, permission, error, empty-state, and confirmation resource keys.
- [ ] T019 [Plan:5.1] Write failing Daily widget tests for empty/list/editor states,
  create/edit/delete, Anytime/Specific time controls, conditional notification UI,
  completion semantics, and error/retry feedback.
- [ ] T020 [Plan:5.1] Implement the Daily page/editor using existing theme tokens,
  Provider, accessible controls, responsive layout, and localized strings.
- [ ] T021 [Plan:5.1] Replace the HomeShell Tasks placeholder with the Daily entry point
  while preserving existing Notes, Home, Dates, and Settings navigation behavior.
- [ ] T022 [P] [Plan:5.1] Add widget coverage for both locales and all 18 style/palette
  combinations, including narrow constraints and non-color completion signals.

**Checkpoint**: Daily is usable in English/Spanish and visually consistent with Daymark.

## Phase 6: Quality gates and regression

- [ ] T023 [P] [Plan:6.1] Add Sticky Notes, settings, localization, navigation, and
  database migration regression assertions; verify no Notes schema change.
- [ ] T024 [Plan:6.1] Run `dart format` on changed Dart files and inspect the diff for
  hardcoded user-facing strings, secrets, generated databases, and unrelated changes.
- [ ] T025 [Plan:6.1] Run `flutter analyze`, focused Daily tests, and `flutter test`;
  fix only failures caused by the Daily implementation.
- [ ] T026 [Plan:6.1] Document observed permission/platform limitations and implementation
  evidence. Do not run an Android debug build; Android verification is owned by the
  user/implementation operator.

## Requirement traceability

| Requirement | Tasks |
|---|---|
| REQ-001–006 | T002, T005–T007, T014–T021 |
| REQ-007–010 | T003, T005–T008, T014–T015 |
| REQ-011–015 | T004, T009–T017 |
| REQ-016–017 | T018–T022 |
| REQ-018 | T006, T008, T023–T024 |
| REQ-019 | T002–T026 |
| NFR-001–006 | T003, T004, T008, T013–T026 |
