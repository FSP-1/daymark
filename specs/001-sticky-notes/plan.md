# Implementation Plan: Sticky Notes

**Date**: 2026-10-15 | **Spec**: [spec.md](./spec.md)

## Summary

Replace the starter counter screen with the first Daymark sticky-notes workflow: create and
view locally persisted notes, reject empty content, show an explicit empty state, record
creation metadata, support optional title/subtitle fields, and report local save failures
without false success. The implementation will establish the minimum
MVVM layers required by the Constitution, use a repository over Drift/SQLite for durable
offline storage, and inject dependencies so unit, persistence, and widget acceptance tests
can run without a network or remote service.

## Technical Context

**Language/Version**: Dart SDK `^3.13.5` with Flutter  
**Primary Dependencies**: Flutter Material, Provider/ChangeNotifier, Drift, drift_flutter;
`drift_dev` and `build_runner` as development tooling  
**Storage**: Local SQLite database accessed through Drift; no remote storage or sync  
**Testing**: `flutter_test` unit, repository/database, and widget acceptance tests  
**Target Platform**: Android-first Flutter application; preserve existing platform targets  
**Performance Goals**: Opening the notes view and displaying a small local collection must
complete within one user interaction without network access; no server latency is permitted  
**Constraints**: Offline-first; no Firebase, Firestore, authentication, remote databases, or
synchronization; only create/view/filter notes; no note content in logs; preserve MVVM boundaries
**Scale/Scope**: Initial local single-user collection suitable for ordinary personal notes;
no multi-user or cloud behavior in this feature

## Constitution Check

*GATE: Must pass. Re-check after design review.*

- **I. Arquitectura mantenible — PASS**: Add only the layers needed for a note model,
  repository, ChangeNotifier ViewModel, and presentation; business rules remain outside
  widgets and the persistence implementation.
- **II. TDD obligatorio — PASS**: Tasks sequence failing tests before production behavior;
  unit, persistence, and widget acceptance tests cover each new behavior.
- **III. SDD antes de implementar — PASS**: This plan consumes the approved spec, maps every
  requirement, preserves scope, and identifies acceptance evidence.
- **IV. Funcionamiento offline-first — PASS**: Drift/SQLite is the only source of truth;
  no network, Firebase, Firestore, remote database, or synchronization is introduced.
- **V. Calidad y pruebas — PASS**: Completion requires `dart format`, `flutter analyze`, and
  `flutter test`, including empty, error, boundary, restart, and offline scenarios.
- **VI. Seguridad y privacidad — PASS**: No authentication is added; note content is not
  logged; generated databases and secrets remain untracked.
- **VII. Documentación y Git — PASS**: Update README behavior guidance and record the
  persistence decision; keep the change focused.
- **VIII. Alcance y finalización — PASS**: Only create/view/persist/validate/error behavior
  is planned, with a completion report and explicit limitations.

## Applied Guidelines

No Flutter-specific migration guideline was present under the available `guidelines` skill
directory. The plan instead follows the Daymark Constitution, existing `flutter_lints`
configuration, Flutter test conventions, and the repository's current minimal structure.

## Implementation Steps

### Step 1: [Cross-cutting] Establish persistence dependencies and test seams

- **Requirements**: REQ-006, REQ-007, REQ-010, REQ-013
- **Design inputs**: `research.md`; `pubspec.yaml`; Constitution IV and V
- **Description**: Add only the justified Drift/SQLite runtime and code-generation
  dependencies. Define an injectable database/repository construction path so production
  uses a durable local database while tests can use isolated in-memory or temporary stores.
  Keep generated database code out of hand edits and ensure local database files are ignored.

### Step 2: [Cross-cutting] Define the note domain and repository contract

- **Requirements**: REQ-001, REQ-002, REQ-004, REQ-005, REQ-006, REQ-008, REQ-013
- **Design inputs**: `spec.md` entities and edge cases; Constitution I and IV
- **Description**: Define the note entity and the repository contract for creating and
  listing notes. Centralize the non-whitespace validation rule in domain/application logic,
  define typed success/failure results, and keep the contract independent of Flutter and
  Drift implementation details.

### Step 3: [Cross-cutting] Implement and test local SQLite persistence

- **Requirements**: REQ-005, REQ-006, REQ-007, REQ-008, REQ-010, REQ-012
- **Design inputs**: `research.md` persistence decision; `spec.md` persistence and error
  acceptance scenarios
- **Description**: Create the Drift table and database access needed for note insertion and
  listing. Implement the repository adapter with explicit error propagation and no logging
  of note content. Add repository/database tests for insert/list, empty collections,
  whitespace rejection path, injected save failures, offline operation, isolation, and
  persistence across a reopened database instance.

### Step 4: [Cross-cutting] Add the ChangeNotifier ViewModel

- **Requirements**: REQ-002, REQ-003, REQ-004, REQ-005, REQ-008, REQ-009, REQ-010,
  REQ-011, REQ-013
- **Design inputs**: `spec.md` user stories and error behavior; Constitution I, II, and V
- **Description**: Implement presentation state and actions for loading notes, creating a
  note, validation feedback, empty state, success state, and save failure state. Ensure
  failed saves never add an item to visible success state and existing notes remain
  available. Expose only presentation-ready state to the view.

### Step 5: [US1] Build the create-and-view notes UI

- **Requirements**: REQ-001, REQ-003, REQ-004, REQ-005, REQ-008, REQ-009, REQ-011
- **Design inputs**: `spec.md` User Stories 1, 2, and 4; existing `lib/main.dart`
- **Description**: Replace the starter counter screen with a focused notes screen. Provide
  text entry and an explicit create action, render saved notes, show the empty state,
  display understandable validation and save-error feedback, and avoid adding controls for
  editing, deletion, search, pinning, colors, reminders, tasks, authentication, or sync.
  Wire the ViewModel through Provider without placing business rules in widgets.

### Step 6: [US2] Verify restart and offline acceptance behavior

- **Requirements**: REQ-005, REQ-006, REQ-007, REQ-008, REQ-009, REQ-010, REQ-011
- **Design inputs**: `spec.md` User Stories 2–4; `research.md` testing decision
- **Description**: Add acceptance coverage that creates a valid note, closes/reconstructs
  the application against the same local store, and confirms the note remains visible.
  Exercise empty collections, offline operation, invalid input, and injected persistence
  failures. Confirm no test depends on a network or remote service.

### Step 7: [Cross-cutting] Complete quality gates and documentation

- **Requirements**: REQ-011, REQ-012, REQ-013
- **Design inputs**: Constitution V, VII, and VIII; `spec.md` assumptions and scope
- **Description**: Remove or update the starter counter test, update README behavior
  documentation, record the Drift/SQLite decision under `docs/decisions/`, format all
  changed Dart files, run analyzer and full tests, review generated/untracked artifacts,
  and report commands, results, changed files, and remaining limitations.

### Step 8: [Cross-cutting] Add reusable metadata filtering

- **Requirements**: REQ-014, REQ-015, REQ-016, REQ-017, REQ-018, REQ-019, REQ-020,
  REQ-021
- **Design inputs**: Amended `spec.md`; Constitution I, III, IV, and VIII
- **Description**: Extend the local note schema, domain entity, repository, ViewModel, and
  editor with creation timestamp, optional title, and optional subtitle. Add a generic
  filtering utility outside the Sticky Notes feature that accepts text/date selectors and
  applies all active criteria with AND semantics. Keep it reusable for other features and
  avoid embedding note-specific behavior in the utility. Add unit, persistence, ViewModel,
  and widget tests for metadata, localized date display, text/date/combined filters, and
  clearing filters.

### Step 9: [Cross-cutting] Add bounded date filtering and creative note editor

- **Requirements**: REQ-022, REQ-023, REQ-024, REQ-025
- **Description**: Bound date-range selection to the current local day, add a Flutter-only
  freehand canvas with erase and clear operations, serialize strokes for local Drift
  persistence, and present notes in post-it-style cards. Keep drawing state in the
  editor/ViewModel boundary and avoid logging or remote transmission.

### Step 10: [Cross-cutting] Add the Home navigation shell

- **Requirements**: REQ-026, REQ-027
- **Description**: Replace the direct notes root with a Home shell using bottom navigation.
  Provide a Sticky Notes destination and clearly marked future-feature placeholders while
  preserving the existing injected repository and Provider composition.

## Project Structure

```text
lib/
├── main.dart
├── app/
│   └── app.dart
└── features/
    ├── core/
    │   ├── filtering/
    │   │   └── search_filter.dart
    │   └── drawing/
    │       ├── drawing_stroke.dart
    │       └── drawing_canvas.dart
    └── features/
        ├── home/
        │   └── presentation/home_shell.dart
        └── sticky_notes/
        ├── data/
        │   ├── local/
        │   │   ├── app_database.dart
        │   │   └── app_database.g.dart          # generated
        │   └── sticky_notes_repository.dart
        ├── domain/
        │   ├── sticky_note.dart
        │   └── sticky_notes_repository.dart
        ├── presentation/
        │   ├── sticky_notes_view_model.dart
        │   └── sticky_notes_page.dart
        └── widgets/
            └── note_editor.dart
test/
├── features/
│   └── sticky_notes/
│       ├── domain/
│       │   └── sticky_note_test.dart
│       ├── data/
│       │   └── sticky_notes_repository_test.dart
│       └── presentation/
│           ├── sticky_notes_view_model_test.dart
│           └── sticky_notes_page_test.dart
└── test_support/
    └── sticky_notes_fixtures.dart
docs/
└── decisions/
    └── 001-sticky-notes-local-persistence.md
```

**Structure Decision**: Use a single Flutter application with a feature-first sticky-notes
slice. Domain contracts remain independent, data owns Drift/SQLite, presentation owns
Provider/ChangeNotifier state, and widgets remain focused on rendering and interaction.

## Testing Strategy

- **appType**: Mobile/desktop Flutter application with local persistence
- **Critical user journeys**:
  1. Create a valid note and see it in the list while offline.
  2. Open an empty collection and see the explicit empty state.
  3. Reject empty and whitespace-only input without persistence.
  4. Save a note, reopen the application/local store, and see the same note.
  5. Surface a save failure without false success while keeping existing notes visible.
- **primaryValidationStack**: `flutter_test` for unit, persistence, ViewModel, and widget
  acceptance tests; `flutter analyze` and `dart format` for static quality.
- **fallbackMatrix**:
  - `infra-tier`: Drift in-memory/test database → isolated temporary SQLite database.
    Prerequisite: Flutter/Dart SQLite support available on the target test environment.
  - `browser-tier`: Not applicable; this feature is validated through Flutter widget tests,
    not a browser flow.
- **Environment requirements**: Flutter SDK, Dart SDK compatible with `pubspec.yaml`, and
  generated Drift sources produced by `build_runner`; no Docker, Node.js, network, or remote
  credentials.
- **knownGaps**: Widget acceptance tests do not prove every native filesystem failure mode;
  repository tests cover deterministic injected failures, while a reopened local database
  verifies durable persistence semantics.
- **Test data strategy**: Use unique, deterministic note fixtures per test; create an
  isolated database/repository per test; close databases in teardown; never use production
  database files.
- **Acceptance criteria**: All five critical journeys pass, `flutter analyze` reports no
  errors, `flutter test` passes, and no remote-service dependency is added.
- **Validation review expectations**: Reviewer confirms Red-Green-Refactor evidence, every
  REQ is covered, no out-of-scope controls or services exist, and failure states do not
  report success or log note content.

## Complexity Tracking

No constitution violations are planned. The repository layer and Drift code-generation
tooling are justified by the Constitution's required separation of concerns and durable
offline persistence; a simpler in-memory or key-value approach cannot satisfy restart
persistence and typed failure testing as reliably.

## Task Breakdown

The standalone executable task list is maintained in
[`tasks.md`](./tasks.md). It is organized by user story and is the authoritative
implementation checklist; this plan remains the source for technical decisions and
plan-item traceability.
