---
description: "Standalone task list for Customizable UI Styles and Color Themes"
---

# Tasks: Customizable UI Styles and Color Themes

**Inputs**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md)  
**Method**: TDD Red → Green → Refactor  
**Scope**: Appearance customization only; no remote services or unrelated features.

## Phase 1: Theme foundation

- [x] T001 [Plan:1] Write failing tests for exactly three styles, six palettes, semantic
  tokens, and all 18 style/palette combinations in `test/core/theme/app_theme_test.dart`.
- [x] T002 [Plan:1] Implement immutable style definitions in
  `lib/core/theme/app_styles.dart`.
- [x] T003 [Plan:1] Implement six palette definitions and semantic colors in
  `lib/core/theme/theme_presets.dart`.
- [x] T004 [Plan:1] Implement `ThemeData` composition in `lib/core/theme/app_theme.dart`
  and make T001 pass.

## Phase 2: Local persistence

- [x] T005 [Plan:2] Write failing repository tests for missing, valid, invalid, independent
  updates, and restored style/palette preferences in
  `test/features/settings/data/theme_preferences_repository_test.dart`.
- [x] T006 [Plan:2] Add the independent `AppPreferences` Drift table and migration in
  `lib/features/sticky_notes/data/local/app_database.dart` without modifying `Notes`.
- [x] T007 [Plan:2] Implement `ThemePreferencesRepository` and generated Drift code, then
  make T005 pass.

## Phase 3: Theme state and application wiring

- [x] T008 [Plan:3] Write failing ViewModel tests for initial loading, safe defaults,
  independent selection changes, persistence, and reset in
  `test/features/settings/presentation/theme_view_model_test.dart`.
- [x] T009 [Plan:3] Implement `ThemeViewModel` in
  `lib/features/settings/presentation/theme_view_model.dart`.
- [x] T010 [Plan:3] Update `lib/app/app.dart` to load theme preferences before rendering
  `HomeShell`, provide `ThemeData` globally, and preserve localization and notes Provider.

## Phase 4: Settings UI

- [x] T011 [Plan:4] Write failing widget tests for the compact style dropdown, six palette
  swatches, selection indicators, reset, accessibility labels, and immediate updates in
  `test/features/settings/presentation/settings_page_test.dart`.
- [x] T012 [Plan:4] Implement responsive style/palette selectors in
  `lib/features/settings/presentation/settings_page.dart`.
- [x] T013 [Plan:4] Add localized strings for style and palette names in both JSON assets
  and verify the Settings widget uses them.
- [x] T020 [Plan:4] Replace the stacked style previews with one compact selector and
  localized descriptions in `lib/features/settings/presentation/settings_page.dart`.

## Phase 5: Global visual integration

- [x] T014 [Plan:5] Write regression assertions for Home, Sticky Notes, editor, cards,
  navigation, buttons, and inputs using the active ThemeData.
- [x] T015 [Plan:5] Replace conflicting hardcoded application UI colors, radii, elevation,
  and typography with active theme/component tokens while preserving sticky-note colors.
- [x] T016 [Plan:5] Verify small-screen responsive behavior and accessible contrast/tap
  targets for Settings and existing navigation.

## Phase 6: Quality and documentation

- [x] T017 [Plan:6] Update README with the style/palette architecture, persistence behavior,
  defaults, and Settings usage.
- [x] T018 [Plan:6] Run `dart format`, `flutter analyze`, and `flutter test`; resolve
  regressions and update this checklist only for verified tasks.
- [x] T019 [Plan:6] Run `git diff --check`, review scope, verify no secrets/generated
  databases are included, and record remaining limitations.
- [x] T021 [Plan:6] Centralize style typography and document the generic-family and
  licensing decision in `app_styles.dart`, `app_theme.dart`, and `research.md`.

## Dependencies

- T001 precedes T002–T004.
- T005 precedes T006–T007.
- T008 depends on T007 and precedes T009–T010.
- T011 depends on T010 and precedes T012–T013.
- T014–T016 depend on T004, T010, and T012.
- T017–T019 follow implementation and validation.

## Requirement Mapping

| Requirement | Tasks |
|---|---|
| REQ-001–004 | T001–T004 |
| REQ-005–009 | T001, T004, T011–T016 |
| REQ-010–013 | T005–T010 |
| REQ-014–015 | T011–T016, T018 |
| REQ-016 | T001–T004, T010, T015 |
