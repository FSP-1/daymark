# Implementation Plan: Global Branded Loading Screen

**Date**: 2026-10-31 | **Spec**: [spec.md](./spec.md)

## Summary

Replace the current unbranded startup progress indicator with a reusable, theme-aware
Daymark loading system. The implementation will render the separate official symbol
from the Flutter asset pipeline, rotate it slowly and linearly, expose full-screen and
local loading patterns, and preserve explicit operation outcomes in existing ViewModels.
Startup will keep the Android native launch surface separate from the Flutter animation,
restore appearance before main content, and avoid a default-theme flash. Android launcher
icon generation will use the separate official icon and adaptive-safe-zone validation.

No loading code, launcher configuration, dependency, or database change is part of this
documentation phase.

## Technical Context

**Language/Version**: Dart SDK `^3.13.5`, Flutter  
**Primary dependencies**: Flutter Material/widgets, Provider/ChangeNotifier, existing
Drift/SQLite; no new runtime dependency expected. `flutter_launcher_icons` is a
candidate dev-only generator pending compatibility verification.  
**Storage**: Existing local Drift/SQLite database; Notes schema unchanged  
**State management**: MVVM with Provider and ChangeNotifier  
**Testing**: `flutter_test`, ViewModel tests, widget tests, startup/integration evidence,
  `flutter analyze`, `dart format`, and `flutter test`  
**Target platform**: Android-first; preserve current Flutter platform targets  
**Performance goals**: One animation controller per mounted branded loading widget,
  smooth linear rotation, no unnecessary rebuild or global state churn, and no
  interaction with the underlying screen during blocking loading  
**Constraints**: Offline-first; no Firebase/Firestore/remote service; no fake progress;
  no Notes schema changes; no loading-symbol substitution for launcher icon; assets and
  generated outputs must be reproducible and documented

## Constitution Check

*GATE: Must pass. Re-check after design review and before implementation.*

- **I. Arquitectura mantenible — PASS**: Reusable widgets remain in `lib/core/loading`;
  ViewModels own operation state; repositories remain unchanged and independent.
- **II. TDD obligatorio — PASS**: Tasks require failing widget/ViewModel tests before
  behavior implementation and require actual test execution.
- **III. SDD antes de implementar — PASS**: This spec, research, plan, tasks, and
  checklist define scope, states, accessibility, branding separation, and traceability.
- **IV. Funcionamiento offline-first — PASS**: Startup and local loading use existing
  local resources; no remote dependency is introduced.
- **V. Calidad y pruebas — PASS**: Tests cover loading, success, error, empty/local
  behavior, reduced motion, startup, and Sticky Notes regressions; required quality
  commands remain gates.
- **VI. Seguridad y privacidad — PASS**: Loading does not log content or credentials;
  failures remain observable and no secrets/assets of that kind are added.
- **VII. Documentación y Git — PASS**: Asset paths, Android responsibilities, and
  implementation evidence are documented; no generated resources are created now.
- **VIII. Alcance y finalización — PASS**: Only the approved reusable loading and
  launcher-branding scope is planned; Firebase and schema work remain excluded.

## Applied Guidelines

No Flutter-specific migration guideline is present in the available guideline catalog.
The plan follows the Daymark Constitution, existing `flutter_lints`, current Provider/
ChangeNotifier conventions, Flutter animation lifecycle rules, and Android adaptive icon
safe-zone requirements.

## Architecture

```text
lib/
├── app/
│   └── app.dart                         # Startup gate and MaterialApp theme
├── core/
│   └── loading/
│       ├── app_loading_screen.dart      # Branded centered composition + animation
│       ├── loading_overlay.dart         # Optional blocking overlay over current UI
│       ├── loading_controller.dart      # Only if global coordination is justified
│       └── loading_state.dart           # Shared state/value types if needed
├── core/theme/                          # Existing Feature 002 source of truth
└── features/*/presentation/             # Local operation state in ViewModels
```

`AppLoadingScreen` owns rendering and animation disposal. `LoadingOverlay` owns
interaction blocking and delegates visual treatment to the branded loading component.
`LoadingController`, if implemented, coordinates only genuinely global blocking work;
simple local operations stay in their owning ViewModel. ViewModels expose idle/loading/
success/error and use `try/finally` around repository calls. The loading widgets do not
interpret repository exceptions or display success/error feedback.

## Startup lifecycle

1. Android displays the existing native `LaunchTheme`/launch background while the
   process and Flutter engine start.
2. Flutter binds and starts `runApp`; the app renders a Flutter `MaterialApp` loading
   shell rather than waiting before the first frame.
3. Appearance preferences are restored through the existing `ThemeViewModel` and a
   safe, documented fallback is used if values are absent or invalid.
4. Required local resources are initialized (the existing local database and any
   explicitly approved future local initializer). Firebase is not added by this plan.
5. The active `ThemeData` is supplied to the app and `HomeShell` is rendered.
6. The custom loading screen is removed once readiness is true and is not shown again
   for already-completed startup work.

The native launch screen is static and cannot provide the reusable animated Flutter
experience. The custom screen begins only after Flutter can render widgets.

## Implementation Steps

### Step 1: [Cross-cutting] Establish asset and startup seams

- **Requirements**: REQ-007, REQ-008, REQ-009, REQ-016, REQ-017, REQ-018
- **Design inputs**: `research.md`; `lib/main.dart`; `lib/app/app.dart`;
  Android launch resources; `pubspec.yaml`
- **Description**: Declare the two existing branding assets in Flutter, preserve their
  separate responsibilities, replace the temporary startup indicator at the existing
  readiness gate, and define explicit startup success/fallback behavior without
  changing the Notes schema.

### Step 2: [US1] Build the branded loading composition

- **Requirements**: REQ-001, REQ-002, REQ-003, REQ-004, REQ-005, REQ-006, REQ-016
- **Design inputs**: Feature 002 theme tokens; `research.md` animation and asset decisions
- **Description**: Add the reusable loading widget under `lib/core/loading/`, use
  `ThemeData` for background and typography, contain the symbol responsively, animate
  one controller linearly at the proposed slow duration, and implement reduced-motion
  and disposal behavior.

### Step 3: [US2] Add full-screen and local loading patterns

- **Requirements**: REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015
- **Design inputs**: Existing Sticky Notes and settings ViewModels; MVVM constitution
- **Description**: Add an interaction-blocking overlay and, only where justified, a
  global controller. Document and wire local loading examples through existing
  ViewModel state. Use `try/finally`, preserve exception/error paths, and avoid
  forcing full-screen animation for small database operations.

### Step 4: [US3] Configure the separate Android launcher icon

- **Requirements**: REQ-017, REQ-018
- **Design inputs**: `daymark-icon.png`; Android manifest and mipmap resources;
  launcher-tooling verification
- **Description**: Verify a compatible `flutter_launcher_icons` version or document a
  justified alternative, configure the prepared transparent
  `assets/branding/daymark-icon-foreground.png` foreground with a separate solid
  brand-color background, generate resources, inspect safe-zone behavior under
  representative masks, and ensure the launcher remains distinct from the loading
  symbol.

### Step 5: [Cross-cutting] Validate, regress, and document implementation evidence

- **Requirements**: REQ-003, REQ-004, REQ-005, REQ-006, REQ-007, REQ-008, REQ-009,
  REQ-010, REQ-011, REQ-012, REQ-013, REQ-014, REQ-015, REQ-020
- **Design inputs**: All acceptance scenarios; Constitution V, VII, and VIII
- **Description**: Run formatting, analyzer, focused tests, full tests, Android build/
  emulator verification, and startup/launcher checks. Confirm no generated databases,
  secrets, Firebase dependencies, or Notes schema modifications are introduced. Update
  implementation documentation only with observed results.

## Project Structure

```text
specs/003-loading-screen/
├── spec.md
├── plan.md
├── research.md
├── tasks.md
├── requirements-checklist.md
└── checkpoints/
    ├── spec-to-plan.yaml
    └── plan-to-tasks.yaml

lib/core/loading/
├── app_loading_screen.dart
├── loading_overlay.dart
├── loading_controller.dart       # only if required after local-state review
└── loading_state.dart            # only if shared state needs a type

test/core/loading/
test/app/
test/features/
android/app/src/main/res/
```

## Testing Strategy

- **appType**: Android-first Flutter mobile application.
- **Critical user journeys**:
  1. Launch with delayed preferences and transition from native/Flutter loading to
     themed HomeShell.
  2. Render all 18 style/palette combinations with the correct asset, background,
     typography, message, and responsive layout.
  3. Run a blocking operation and verify the overlay prevents interaction.
  4. Run a local operation and verify unrelated content remains available.
  5. Complete operations through success and error paths and verify dismissal/retry.
  6. Install/build Android and verify separate launcher icon and loading symbol.
- **primaryValidationStack**: `flutter_test`, ViewModel fakes, widget tests,
  `flutter analyze`, `dart format`, Android build/emulator inspection.
- **fallbackMatrix**:
  - `animation-tier`: widget `FakeAsync`/`pump` timing → deterministic static
    reduced-motion test. Gap: no physical frame-pacing measurement.
  - `android-tier`: emulator adaptive-mask inspection → generated-resource and
    manifest/build verification. Gap: device-mask visual coverage is reduced.
  - `startup-tier`: injected delayed/failing initializer → app widget lifecycle test.
    Gap: platform process cold-start timing is not fully simulated.
- **Environment requirements**: Flutter SDK, Android SDK/emulator for launcher and
  startup checks, no network or Firebase service.
- **Test data strategy**: Use deterministic fake initializers/repositories and existing
  in-memory Drift fixtures. Do not write local databases or generated build artifacts
  into tracked source.
- **Acceptance criteria**: Every SC-001 through SC-008 passes, existing tests remain
  green, and the implementation report includes commands and observed results.
- **Validation review expectations**: Confirm exact asset paths, no symbol/icon
  substitution, safe-area/responsive behavior, reduced-motion handling, error
  observability, no indefinite overlay, and no scope expansion.

## Complexity Tracking

No Constitution violation is planned. A global controller is explicitly optional and
must be rejected if local ViewModel state covers the approved use cases without it.

## Requirement Mapping

| REQ ID | Description | Plan Items | Implementation Evidence |
|---|---|---|---|
| REQ-001–004 | Reusable branded composition and animation lifecycle | 2, 5 | `lib/core/loading/app_loading_screen.dart`, loading widget tests |
| REQ-005–006 | Palette background and style typography | 2, 5 | Theme-combination tests and `ThemeData` assertions |
| REQ-007–009 | Startup lifecycle, no flash, readiness/fallback | 1, 5 | `lib/app/app.dart`, startup widget/ViewModel tests |
| REQ-010–011 | Full-screen blocking and local loading | 3, 5 | `loading_overlay.dart`, local loading widget tests |
| REQ-012–014 | State ownership, guaranteed dismissal, indeterminate behavior | 3, 5 | ViewModel tests and operation integration tests |
| REQ-015 | Architecture, offline behavior, Notes preservation | 1, 3, 5 | Existing architecture and Sticky Notes regression suite |
| REQ-016 | Actual symbol asset documentation/loading | 1, 2 | `pubspec.yaml`, asset widget tests |
| REQ-017–018 | Distinct adaptive launcher icon and reproducible generation | 1, 4, 5 | Android resources, generator config, emulator/build evidence |
| REQ-019 | No remote service introduction | 1, 3, 5 | Dependency review and scope review |
| REQ-020 | Complete validation coverage | 5 | Focused/full test reports and Android verification |
