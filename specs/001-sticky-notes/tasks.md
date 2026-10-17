---
description: "Standalone task list for the Sticky Notes feature"
---

# Tasks: Sticky Notes

**Input artifacts**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md)  
**Tests**: Required by the specification and Constitution; follow Red-Green-Refactor ordering.  
**Scope**: Create, view, and filter locally persisted notes with optional metadata; no remote services, authentication, synchronization, or unrelated behavior.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the approved persistence dependencies and injectable application seams.

- [ ] T001 [Plan:1.1] Update `pubspec.yaml` with justified `drift` and `drift_flutter` runtime dependencies plus `drift_dev` and `build_runner` development dependencies; update `pubspec.lock` with the Flutter package manager.
- [ ] T002 [P] [Plan:1.1] Add ignore rules in `.gitignore` for generated Drift output and local SQLite/database artifacts without ignoring checked-in source or test fixtures.
- [ ] T003 [Plan:1.1] Define the production/test dependency construction seam in `lib/app/app.dart` and `test/test_support/sticky_notes_fixtures.dart` without implementing note behavior.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define domain contracts and persistence seams before any user-story implementation.

- [ ] T004 [Plan:2.1] Write failing domain tests in `test/features/sticky_notes/domain/sticky_note_test.dart` for valid text, empty text rejection, whitespace-only rejection, and preservation of valid surrounding whitespace semantics.
- [ ] T005 [Plan:2.1] Define `StickyNote`, validation/result types, and the Flutter- and Drift-independent repository interface in `lib/features/sticky_notes/domain/sticky_note.dart` and `lib/features/sticky_notes/domain/sticky_notes_repository.dart`, then make T004 pass.
- [ ] T006 [Plan:3.1] [P] Write failing persistence tests in `test/features/sticky_notes/data/sticky_notes_repository_test.dart` after T005: cover insert/list, empty collections, reopened-database durability, deterministic injected save failure, and create/list operation with no network client or remote service.
- [ ] T007 [Plan:3.1] Implement the Drift notes table/database in `lib/features/sticky_notes/data/local/app_database.dart`, generate `lib/features/sticky_notes/data/local/app_database.g.dart`, and implement the repository adapter in `lib/features/sticky_notes/data/sticky_notes_repository.dart` so T006 passes without logging note content.

**Checkpoint**: Domain contract and durable local repository are tested and available to all user stories.

## Phase 3: User Story 1 — Create a valid note (Priority: P1) 🎯 MVP

**Goal**: Enter non-whitespace text and create a note that appears in the collection offline.

**Independent Test**: With an empty injected repository and no network, enter valid text, confirm creation, and verify the note appears exactly once.

- [ ] T008 [US1] [Plan:4.1] Write failing ViewModel unit tests in `test/features/sticky_notes/presentation/sticky_notes_view_model_test.dart` for initial loading, successful creation, list refresh, and no duplicate visible note on refresh.
- [ ] T009 [US1] [Plan:4.1] Implement ChangeNotifier state and create/load actions in `lib/features/sticky_notes/presentation/sticky_notes_view_model.dart`, exposing presentation-ready state while keeping validation and repository concerns out of widgets.
- [ ] T010 [US1] [Plan:5.1] Write failing widget acceptance tests in `test/features/sticky_notes/presentation/sticky_notes_page_test.dart` for text entry, explicit create action, successful list rendering, and offline creation using an injected repository.
- [ ] T011 [US1] [Plan:5.1] Implement `lib/features/sticky_notes/presentation/sticky_notes_page.dart` and `lib/features/sticky_notes/widgets/note_editor.dart`, wiring Provider to the ViewModel and providing only approved create/view controls.
- [ ] T012 [US1] [Plan:5.1] Replace the starter counter composition in `lib/main.dart` with the notes application composition and production local database/repository wiring.

**Checkpoint**: A valid note can be created and displayed independently of later restart/failure scenarios.

## Phase 4: User Story 2 — View notes and empty state (Priority: P1)

**Goal**: Display every locally saved note or a clear non-error empty state.

**Independent Test**: Render the page once with an empty repository and once with multiple saved notes; verify the empty message or every note, with no network.

- [ ] T013 [US2] [Plan:4.1,5.1] Write failing ViewModel and widget assertions in `test/features/sticky_notes/presentation/sticky_notes_view_model_test.dart` and `test/features/sticky_notes/presentation/sticky_notes_page_test.dart` for the explicit empty state, all locally saved notes, and no exception for an empty collection.
- [ ] T014 [US2] [Plan:4.1,5.1] Implement and refine empty/list rendering in `lib/features/sticky_notes/presentation/sticky_notes_view_model.dart` and `lib/features/sticky_notes/presentation/sticky_notes_page.dart` until T013 passes without adding out-of-scope controls.

**Checkpoint**: Viewing an empty or populated local collection is independently testable.

## Phase 5: User Story 3 — Preserve notes across restart (Priority: P1)

**Goal**: Keep a successfully saved note available after closing and reopening against the same local store.

**Independent Test**: Save through one repository/database instance, close it, construct a second instance against the same isolated database, and verify the note remains visible while offline.

- [ ] T015 [US3] [Plan:6.1] Write the failing restart acceptance test in `test/features/sticky_notes/presentation/sticky_notes_page_test.dart` that reconstructs the application against the same isolated local database and verifies the saved note after reopening.
- [ ] T016 [US3] [Plan:6.1] Add the reopened-store fixture and application reconstruction support in `test/test_support/sticky_notes_fixtures.dart`, then make the restart test pass without using a network or production database file.

**Checkpoint**: Restart durability is proven separately from ordinary offline rendering.

## Phase 6: User Story 4 — Handle invalid input and save failures (Priority: P1)

**Goal**: Reject invalid content and report save failures without false success while preserving existing notes.

**Independent Test**: Attempt empty and whitespace-only saves, then inject a save failure after a valid existing note; verify feedback, no invalid/failed note, and continued access to the existing note.

- [ ] T017 [US4] [Plan:4.1] Write failing ViewModel tests in `test/features/sticky_notes/presentation/sticky_notes_view_model_test.dart` for empty/whitespace validation feedback, no persistence on validation failure, injected save failure, no false success state, and retained existing notes.
- [ ] T018 [US4] [Plan:5.1,6.1] Write failing widget acceptance assertions in `test/features/sticky_notes/presentation/sticky_notes_page_test.dart` for understandable validation feedback and save-error feedback, including retry/continued viewing of an existing note.
- [ ] T019 [US4] [Plan:4.1] Implement validation, typed failure handling, retry-safe state transitions, and retained-list behavior in `lib/features/sticky_notes/presentation/sticky_notes_view_model.dart`; make T017 pass without logging note content.
- [ ] T020 [US4] [Plan:5.1] Render validation and persistence-error feedback in `lib/features/sticky_notes/presentation/sticky_notes_page.dart` and `lib/features/sticky_notes/widgets/note_editor.dart`; make T018 pass without presenting failed saves as created.

**Checkpoint**: Invalid input and deterministic persistence failure behavior are independently verified.

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Complete documentation, scope, privacy, and quality gates.

- [ ] T021 [Plan:7.1] Remove or replace the default counter assertions in `test/widget_test.dart` so the suite covers only approved Daymark behavior.
- [ ] T022 [P] [Plan:7.1] Update `README.md` with local sticky-notes behavior, offline operation, persistence limitations, and explicitly out-of-scope remote features.
- [ ] T023 [P] [Plan:7.1] Record the Drift/SQLite decision and rejected alternatives in `docs/decisions/001-sticky-notes-local-persistence.md`.
- [ ] T024 [Plan:7.1] Run `dart format` on changed files under `lib/` and `test/`, then run `flutter analyze` and `flutter test`; resolve failures without expanding feature scope.
- [ ] T025 [Plan:7.1] Review `git diff` for `lib/`, `test/`, `pubspec.yaml`, `.gitignore`, `README.md`, and `docs/decisions/001-sticky-notes-local-persistence.md`; verify no note content, credentials, secrets, or generated local databases are logged or committed, and record commands, results, changed files, and limitations in the feature completion report.

## Phase 8: User Story 5 — Metadata and reusable filtering

**Purpose**: Add creation metadata and reusable text/date filtering while preserving the
offline repository and MVVM boundaries.

- [ ] T026 [Plan:8.1] Write failing domain, persistence, and reusable-filter tests for creation dates, optional title/subtitle, inclusive date ranges, combined text/date criteria, and clearing criteria.
- [ ] T027 [Plan:8.1] Extend `StickyNote`, the Drift schema/migration, repository mapping, and fixtures for nullable title/subtitle and persisted creation timestamps; make the metadata tests pass.
- [ ] T028 [Plan:8.1] Implement the generic `SearchFilter` and `filterItems<T>` utility under `lib/core/filtering/`, independent of Sticky Notes, and make its focused tests pass.
- [ ] T029 [Plan:8.1] Add ViewModel filter state and visible-note projection with AND semantics across text and date criteria; make focused ViewModel tests pass.
- [ ] T030 [Plan:8.1] Add optional title/subtitle inputs, localized creation-date display, text search, date-range selection, clear-filter behavior, and a distinct no-match state to the notes UI; make widget acceptance tests pass.
- [ ] T031 [Plan:8.1] Update README, traceability checkpoints, and task status for REQ-014 through REQ-021, then run formatting, analysis, the full test suite, and final scope/security review.

## Phase 9: Bounded dates, drawing, and post-it presentation

- [ ] T032 [Plan:9.1] Write failing tests for rejecting future date ranges, drawing stroke serialization, erase/clear behavior, and drawing persistence.
- [ ] T033 [Plan:9.1] Add the reusable drawing stroke model and canvas interaction layer under `lib/core/drawing/`, with tests independent of Sticky Notes widgets.
- [ ] T034 [Plan:9.1] Migrate the Drift schema to store optional serialized drawing data and map it through the domain model and repository.
- [ ] T035 [Plan:9.1] Extend the note editor with a post-it visual treatment, drawing canvas, erase mode, and clear action; add widget coverage for the new controls.
- [ ] T036 [Plan:9.1] Bound `showDateRangePicker` to today and reject programmatic future ranges in the filtering boundary.

## Phase 10: Home navigation shell

- [ ] T037 [Plan:10.1] Write failing widget tests for Home bottom navigation, Sticky Notes routing, and future-feature placeholders.
- [ ] T038 [Plan:10.1] Implement `lib/features/home/presentation/home_shell.dart` and update `lib/app/app.dart` to compose Home without bypassing Provider/MVVM.
- [ ] T039 [Plan:10.1] Update README, decision documentation, traceability checkpoints, and run all quality gates.

## Phase 11: Session language settings and filter placement

**Purpose**: Make the search flow easier to scan and add the approved Spanish/English
session setting without introducing remote configuration or preference persistence.

- [ ] T040 [Plan:11.1] Write failing localization tests for loading `assets/i18n/es.json` and
  `assets/i18n/en.json`, required current UI keys, and switching the active locale without
  network access.
- [ ] T041 [Plan:11.1] Implement `lib/core/localization/app_localizations.dart`, register
  both JSON assets in `pubspec.yaml`, and configure Flutter's supported locale delegates in
  `lib/app/app.dart`.
- [ ] T042 [Plan:11.1] Write failing widget tests for the Settings destination and Spanish/English
  selector, then implement `lib/features/settings/presentation/settings_page.dart` and wire
  the session-scoped locale through `lib/features/home/presentation/home_shell.dart`.
- [ ] T043 [Plan:11.1] Move the search/date filter controls below the note editor in
  `lib/features/sticky_notes/presentation/sticky_notes_page.dart`; verify filtered results
  render below the controls and localize the affected labels and messages.
- [ ] T044 [Plan:11.1] Update README and requirement traceability for REQ-028 through REQ-032,
  run `dart format`, `flutter analyze`, `flutter test`, and verify no generated files or
  remote dependencies were introduced.

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** has no prerequisites.
- **Foundational (Phase 2)** depends on Setup and blocks all user stories.
- **User Stories 1–4** depend on the Foundational checkpoint; they may proceed in parallel after the shared foundation, although the MVP order is US1 → US2 → US3 → US4.
- **Polish (Phase 7)** depends on all selected user stories.

### User Story Dependencies

- **US1** depends only on the Foundational checkpoint.
- **US2** depends on the Foundational checkpoint and the shared presentation shell from US1.
- **US3** depends on the repository implementation and application composition from US1; it is distinct from ordinary offline rendering.
- **US4** depends on the repository failure seam and ViewModel/UI shell from US1; it is distinct from restart and offline coverage.

### Within Each User Story

Tests MUST be authored before their implementation and initially fail. Domain/repository contracts precede persistence tests; persistence tests precede persistence implementation. ViewModel state precedes UI wiring, and implementation must remain within the approved create/view scope.

## Parallel Execution Examples

### Foundational

```text
After T005: T006 (persistence tests) can proceed while setup documentation is finalized.
After T006: T007 is the implementation gate; do not begin persistence implementation earlier.
```

### User Stories

```text
After Phase 2: T008, T010, and T013 may be authored in parallel in separate test files.
After T009: T011 can implement the create/view shell while T015 remains gated on the restart fixture.
T022 and T023 can run in parallel with each other after the feature code stabilizes.
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and the Phase 2 foundation.
2. Complete US1 and run its unit/widget tests.
3. Stop and validate that valid notes can be created and displayed offline.

### Incremental Delivery

1. Add US2 empty/list behavior without changing persistence contracts.
2. Add US3 reopened-store proof for durable restart behavior.
3. Add US4 validation and save-failure behavior.
4. Complete Phase 7 quality, privacy, documentation, and traceability checks.

## Traceability Summary

| Requirement | Covered by tasks |
|---|---|
| REQ-001 | T010–T012 |
| REQ-002 | T004–T005, T017–T020 |
| REQ-003 | T017–T020 |
| REQ-004 | T008–T012 |
| REQ-005 | T006–T012 |
| REQ-006 | T006–T007, T015–T016 |
| REQ-007 | T006, T010, T015–T016 |
| REQ-008 | T006–T007, T013–T014 |
| REQ-009 | T013–T014 |
| REQ-010 | T006–T007, T017–T020 |
| REQ-011 | T011, T014, T020–T025 |
| REQ-012 | T007, T019, T023, T025 |
| REQ-013 | T003–T005, T009, T011, T019 |
| REQ-014 | T026–T027 |
| REQ-015 | T026–T027 |
| REQ-016 | T026–T030 |
| REQ-017 | T026–T028 |
| REQ-018 | T026, T029–T030 |
| REQ-019 | T026, T028–T030 |
| REQ-020 | T026, T029–T030 |
| REQ-021 | T026, T029–T031 |
| REQ-022 | T032, T036 |
| REQ-023 | T032–T035 |
| REQ-024 | T032–T035 |
| REQ-025 | T035 |
| REQ-026 | T037–T038 |
| REQ-027 | T037–T039 |
| REQ-028 | T043–T044 |
| REQ-029 | T042–T044 |
| REQ-030 | T040–T042 |
| REQ-031 | T040–T041 |
| REQ-032 | T041–T044 |

Every REQ-001 through REQ-027 is mapped to at least one executable task.
