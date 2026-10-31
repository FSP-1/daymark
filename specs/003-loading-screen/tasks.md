# Tasks: Global Branded Loading Screen

Implementation tasks are intentionally unchecked. They must not be marked complete
until implementation and validation are performed.

## Phase 1: Setup and startup seams

- [ ] T001 [P] [Plan:1.1] Add `assets/branding/daymark-symbol.png`, `assets/branding/daymark-icon.png`, and `assets/branding/daymark-icon-foreground.png` to the Flutter asset declarations in `pubspec.yaml` without adding generated or unrelated files.
- [ ] T002 [P] [Plan:1.1] Add or confirm localized loading strings `Loading...` and `Cargando...` in `assets/i18n/en.json`, `assets/i18n/es.json`, and the `AppLocalizations` fallback.
- [ ] T003 [Plan:1.1] Write startup-gate tests around `lib/app/app.dart` that inject delayed, successful, and failing appearance/resource initialization and assert loading-to-main-shell transitions before changing production code.
- [ ] T004 [Plan:1.1] Replace the temporary unbranded startup progress branch in `lib/app/app.dart` with the planned branded loading entry point while preserving safe theme fallback and exception observability.

## Phase 2: User Story 1 — Branded animated composition

- [ ] T005 [P] [US1] [Plan:2.1] Add failing widget tests under `test/core/loading/app_loading_screen_test.dart` for the official symbol asset, exact message, centered layout, theme background, style typography, responsive constraints, and safe-area behavior.
- [ ] T006 [US1] [Plan:2.1] Implement `lib/core/loading/app_loading_screen.dart` with the official symbol asset, localized `Loading...`/`Cargando...` message, theme-derived background/text styling, contained responsive sizing, and semantic loading labeling.
- [ ] T007 [P] [US1] [Plan:2.1] Add animation lifecycle tests for linear repetition, the approximately 10-second duration, reduced-motion behavior, and disposal of the controller.
- [ ] T008 [US1] [Plan:2.1] Implement the single-controller rotation, reduced-motion handling, and disposal behavior in `lib/core/loading/app_loading_screen.dart`.
- [ ] T009 [US1] [Plan:2.1] Add parameterized theme tests covering all 18 Feature 002 style/palette combinations and verify loading uses existing `ThemeData` tokens rather than duplicate maps.

## Phase 3: User Story 2 — Full-screen and local operations

- [ ] T010 [P] [US2] [Plan:3.1] Add failing widget tests under `test/core/loading/loading_overlay_test.dart` proving a blocking overlay absorbs interaction and a local loading presentation leaves unrelated controls usable.
- [ ] T011 [US2] [Plan:3.1] Implement `lib/core/loading/loading_overlay.dart` with safe-area-aware visual composition, interaction/semantics blocking, and no fabricated progress.
- [ ] T012 [P] [US2] [Plan:3.1] Add ViewModel tests for idle/loading/success/error transitions, retryability, and dismissal in `finally` when fake repository operations succeed or throw.
- [ ] T013 [US2] [Plan:3.1] Adapt the relevant ViewModel operation seams to use local or full-screen loading intentionally, preserving existing Sticky Notes statuses and error feedback.
- [ ] T014 [US2] [Plan:3.1] Decide from the tested use cases whether `lib/core/loading/loading_controller.dart` is needed; if needed, implement narrowly scoped global coordination, otherwise document its omission.

## Phase 4: User Story 3 — Android launcher branding

- [ ] T015 [P] [US3] [Plan:4.1] Verify the current compatible `flutter_launcher_icons` version and inspect `assets/branding/daymark-icon-foreground.png` for adaptive foreground safe-zone suitability before changing `pubspec.yaml`.
- [ ] T016 [US3] [Plan:4.1] Add the approved launcher generator configuration or justified Android resource configuration using `assets/branding/daymark-icon.png` as the source, `assets/branding/daymark-icon-foreground.png` as the foreground, and a documented separate solid brand background.
- [ ] T017 [US3] [Plan:4.1] Generate Android launcher resources and verify the manifest, adaptive XML/mipmap outputs, proportions, and distinction from `daymark-symbol.png`; do not commit transient build output.
- [ ] T018 [US3] [Plan:4.1] Inspect the launcher on an Android emulator under circular, rounded-square, and squircle-like masks and record safe-zone/cropping results.

## Phase 5: Cross-cutting validation and documentation

- [ ] T019 [P] [Plan:5.1] Add startup lifecycle regression tests confirming native launch is separate from Flutter loading, no default-theme flash occurs, readiness removes loading, and initialization failures remain recoverable.
- [ ] T020 [P] [Plan:5.1] Add or update Sticky Notes widget/ViewModel regression tests to confirm existing local persistence, empty/loading/success/error behavior, and navigation remain intact.
- [ ] T021 [Plan:5.1] Run `dart format` on changed Dart files and resolve formatting without changing unrelated files.
- [ ] T022 [Plan:5.1] Run `flutter analyze` and the focused loading/startup/ViewModel tests; fix only issues caused by this feature.
- [ ] T023 [Plan:5.1] Run `flutter test`, Android build/launcher verification, and any approved emulator startup check; capture actual commands and results.
- [ ] T024 [Plan:5.1] Review the final diff for Notes schema changes, Firebase/remote dependencies, generated databases, secrets, asset substitution, indefinite loading paths, and untracked build artifacts.
- [ ] T025 [Plan:5.1] Update this feature's checkpoints and implementation evidence only after tests and acceptance criteria pass; report remaining limitations and exact changed files.

## User Story Dependencies

- Phase 1 blocks the startup integration and Flutter asset loading.
- Phase 2 depends on the asset declaration and theme contract from Phase 1.
- Phase 3 depends on the branded component from Phase 2 but can test local ViewModel
  state in parallel with launcher investigation.
- Phase 4 depends only on verified icon assets and can proceed in parallel with Phase 3.
- Phase 5 depends on all implemented behavior and is the final quality gate.

## Requirement Traceability

| Requirement | Tasks |
|---|---|
| REQ-001–004 | T005–T008 |
| REQ-005–006 | T005, T006, T009 |
| REQ-007–009 | T003, T004, T019 |
| REQ-010–011 | T010, T011, T013 |
| REQ-012–014 | T012–T014 |
| REQ-015 | T013, T020, T024 |
| REQ-016 | T001, T005, T006, T009 |
| REQ-017–018 | T015–T018 |
| REQ-019 | T001, T014, T024 |
| REQ-020 | T005, T007, T009–T012, T019–T023 |
