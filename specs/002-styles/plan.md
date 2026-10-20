# Implementation Plan: Customizable UI Styles and Color Themes

**Date**: 2026-10-20 | **Spec**: [spec.md](./spec.md)

## Technical Context

**Language/Framework**: Dart SDK `^3.13.5`, Flutter  
**State management**: Provider and ChangeNotifier  
**Persistence**: Existing Drift/SQLite `AppDatabase`, extended with an independent
`AppPreferences` table; Notes schema remains unchanged  
**Theme integration**: One `ThemeData` factory composed from immutable style and palette
definitions and passed to `MaterialApp`  
**Testing**: `flutter_test` unit, repository, ViewModel, widget, and regression tests  
**Offline constraint**: No network, authentication, cloud, or synchronization

## Architecture

1. `lib/core/theme/theme_presets.dart` defines the six palettes and immutable semantic
   color tokens.
2. `lib/core/theme/app_styles.dart` defines Soft, Playful, and Minimal component
   treatment tokens.
3. `lib/core/theme/app_theme.dart` composes a selected style and palette into `ThemeData`.
4. `lib/features/settings/data/theme_preferences_repository.dart` isolates Drift
   persistence for two preference identifiers.
5. `lib/features/settings/presentation/theme_view_model.dart` owns loading, selection,
   reset, validation, and persistence state.
6. `DaymarkApp` loads the ViewModel before rendering `HomeShell`, and supplies the
   resulting `ThemeData` to `MaterialApp`.
7. `SettingsPage` renders one compact style dropdown, a localized description of
   the current style, palette swatches, current selection, and a resulting-theme
   and does not render a separate preview card or three large style previews.

## Implementation Steps

### Step 1: Centralize style and palette definitions

- **Requirements**: REQ-001, REQ-002, REQ-003, REQ-004, REQ-008, REQ-009, REQ-016
- Add immutable enums/models, exactly six palette definitions, exactly three style
  definitions, semantic tokens, and a tested composition function.

### Step 2: Add local appearance preference persistence

- **Requirements**: REQ-010, REQ-011, REQ-013, REQ-015
- Add an `AppPreferences` Drift table and migration without changing `Notes`.
  Implement a repository that reads a singleton row, validates identifiers, and writes
  independent style/palette values.

### Step 3: Add ThemeViewModel and pre-render initialization

- **Requirements**: REQ-003, REQ-006, REQ-010, REQ-011, REQ-012, REQ-016
- Load preferences before the main shell, expose immutable active configuration, persist
  each change independently, and use safe defaults for invalid/missing records.

### Step 4: Build Settings selection UI

- **Requirements**: REQ-005, REQ-006, REQ-014
- Replace the language-only Settings content with one compact style dropdown,
  selected-style description, palette selectors, reset action,
  responsive wrapping, and accessible labels.
- Centralize style typography in `AppStyleTokens` and compose heading/body families
  through `ThemeData`; use documented Android generic families and fallbacks rather
  than an unlicensed bundled font.

### Step 5: Apply global theme and remove conflicting hardcoded styling

- **Requirements**: REQ-006, REQ-007, REQ-008, REQ-009, REQ-014, REQ-015
- Wire `MaterialApp.theme` to the active configuration and update Home, Sticky Notes,
  editor, cards, navigation, and inputs to use theme tokens or component themes.
  Preserve recognizable sticky-note colors while deriving surrounding UI colors from
  the active palette.

### Step 6: Validate and document

- **Requirements**: REQ-004, REQ-010, REQ-011, REQ-012, REQ-015, REQ-016
- Run formatting, analysis, full tests, regression checks, and update README and task
  completion status with actual evidence.

## Project Structure

```text
lib/core/theme/
├── app_styles.dart
├── app_theme.dart
└── theme_presets.dart

lib/features/settings/
├── data/theme_preferences_repository.dart
└── presentation/
    ├── settings_page.dart
    └── theme_view_model.dart

lib/features/sticky_notes/data/local/app_database.dart
test/core/theme/
test/features/settings/
```

## Constitution Check

- MVVM and Provider/ChangeNotifier: PASS.
- TDD Red → Green → Refactor: required in task order.
- Offline-first Drift/SQLite persistence: PASS.
- No remote services or authentication: PASS.
- Centralized styles and semantic palettes: PASS.
- Accessibility, responsive layout, formatting, analysis, and tests: required gates.

## Requirement Mapping

| Requirement | Plan items | Evidence |
|---|---|---|
| REQ-001–004 | 1 | `app_styles.dart`, `theme_presets.dart`, `app_theme.dart` |
| REQ-005–009 | 1, 4, 5 | theme tests and Settings widgets |
| REQ-010–013 | 2, 3 | preferences repository and ViewModel tests |
| REQ-014–015 | 4, 5, 6 | responsive Settings and regression suite |
| REQ-016 | 1, 3, 5 | centralized theme composition |
