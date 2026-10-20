# Research: Customizable UI Styles and Color Themes

## Existing architecture

- Flutter/Dart Android-first application.
- `Provider` and `ChangeNotifier` are already used for presentation state.
- `DaymarkApp` owns `MaterialApp`, locale state, the local `AppDatabase`, and the
  `DriftStickyNotesRepository`.
- `HomeShell` owns bottom navigation and already exposes a Settings destination.
- Sticky Notes uses Drift/SQLite through `AppDatabase`; no remote service exists.
- Existing tests use `flutter_test` with in-memory Drift databases.

## Decisions

### Persist appearance preferences in Drift

**Decision:** Add an `AppPreferences` Drift table containing one singleton row with
the selected style and palette identifiers.

**Rationale:**

- Drift is already the approved local persistence mechanism.
- It avoids introducing a second persistence technology for two small values.
- The notes table and note serialization remain unchanged.
- In-memory database tests can verify missing, invalid, save, and restore cases.

**Alternatives considered:**

- `shared_preferences`: lightweight, but introduces a new runtime dependency and a
  second persistence API without an existing project convention.
- JSON/file storage: less structured and unnecessary for two scalar preferences.
- Remote storage: prohibited by the Constitution and feature scope.

### Compose themes from independent configuration objects

**Decision:** Define immutable style and palette models, then compose them into
  `ThemeData` through one app-theme factory.

**Rationale:**

- All 18 combinations share the same composition path.
- Adding a palette or style changes centralized configuration rather than screens.
- Semantic tokens can be tested independently from widget rendering.

### Load preferences before the main application content

**Decision:** Initialize the theme state before rendering `HomeShell`, while showing
  a minimal loading surface during the asynchronous read.

**Rationale:**

- Prevents a visible default-theme flash.
- Keeps `MaterialApp` as the single source of active theme state.
- Invalid or missing values can safely use documented defaults.

### Typography and font licensing

**Decision:** Use Android generic font families, centrally configured in
`AppStyleTokens`, and vary heading/body family, weight, size, and letter spacing per
style. Playful uses `cursive` with a `sans-serif` fallback; Soft uses `serif` for
headings; Minimal uses `sans-serif`. No font package or downloaded asset is added.

**Rationale:**

- Generic families are resolved by the platform and avoid shipping an unverified or
  copyrighted font asset.
- Comic Sans MS is not assumed to exist on Android.
- The fallback keeps text readable if a generic family is unavailable.
- A future bundled font can be added only after its license is documented.

### Compact style selection

**Decision:** Settings uses one `DropdownButtonFormField<AppStyle>` and displays only
the selected style description. Palette swatches remain compact and all six remain
visible.

**Rationale:** This avoids a long stack of duplicate previews while preserving
discoverability, selected-state semantics, and responsive behavior.

## Testing strategy

- Pure tests for the three styles, six palettes, semantic tokens, and all combinations.
- Repository tests for persistence, restoration, invalid values, and missing values.
- ViewModel tests for independent updates and reset behavior.
- Widget tests for Settings selection, the single dropdown, and selected-state indicators.
  immediate theme updates.
- Full regression suite for Sticky Notes and Home navigation.
