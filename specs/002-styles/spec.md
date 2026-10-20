# Feature Specification: Customizable UI Styles and Color Themes

**Feature Branch**: `002-styles`  
**Created**: 2026-10-20  
**Status**: Draft for implementation

## Scope and Boundaries

### In scope

- Three UI styles: Soft, Playful, and Minimal.
- Six palettes: Vanilla, Sage, Rose, Sky, Lavender, and Peach.
- Independent selection of style and palette from Settings.
- Immediate application to Home, Sticky Notes, editor, saved note cards, navigation,
  buttons, inputs, and Settings.
- Local persistence and restoration across application restarts.
- Safe defaults for missing or invalid saved values.
- Responsive and accessible selection controls and a compact current-theme preview.
- A compact UI Style dropdown with exactly one selected style visible at a time.
- A localized description of the selected style; the three large style previews must
  not be rendered simultaneously.
- Distinct centralized typography for each style. Playful uses the Android generic
  `cursive` family with a sans-serif fallback; Soft uses a warm serif heading
  treatment; Minimal uses a neutral sans-serif hierarchy.

### Out of scope

- User accounts, cloud synchronization, Firebase, Firestore, or remote preferences.
- Per-note theme overrides or changing the meaning of individual sticky-note colors.
- Custom font downloads or a new typography dependency. Device-independent font
  assets are intentionally deferred until an appropriately licensed asset is approved.
- New functional features unrelated to appearance.

## User Stories and Acceptance Scenarios

### User Story 1 — Choose a visual style

As a user, I want to select Soft, Playful, or Minimal so Daymark matches my preferred
visual personality.

1. Given Settings is open, when the user selects Soft, then rounded shapes, gentle
   elevation, comfortable spacing, and calm typography are applied.
2. When Playful is selected, expressive typography, distinctive shapes, and creative
   note details are applied.
3. When Minimal is selected, restrained decoration, simple shapes, subtle elevation,
   and clean hierarchy are applied.
4. Changing style does not change the selected palette or navigation behavior.

### User Story 2 — Choose a color palette

As a user, I want to select one of six palettes so the whole application uses colors
that feel coherent.

1. Settings displays Vanilla, Sage, Rose, Sky, Lavender, and Peach.
2. Each palette shows a visual swatch and a selected state.
3. Changing palette updates semantic background, surface, primary, secondary, accent,
   text, border, divider, and button colors.
4. Changing palette does not change the selected style.

### User Story 3 — Preview and apply appearance

As a user, I want to preview the resulting appearance and see changes immediately.

1. Settings shows a preview using the current style and palette.
2. Selecting either preference updates `MaterialApp` without restarting.
3. The active theme applies consistently to existing screens and controls.
4. Layout remains usable on small and large Android screens.

### User Story 4 — Restore appearance after restart

As a user, I want my appearance choices to remain after closing and reopening Daymark.

1. Given valid saved values, reopening restores both independently.
2. Given missing values, documented defaults are used.
3. Given invalid values, invalid values are ignored and safe defaults are used.
4. The application does not visibly render the default theme before loading saved values.
5. Persistence works without Internet access.

## Functional Requirements

- **REQ-001**: The application MUST define exactly three UI styles: Soft, Playful,
  and Minimal.
- **REQ-002**: The application MUST define exactly six palettes: Vanilla, Sage,
  Rose, Sky, Lavender, and Peach.
- **REQ-003**: Style and palette MUST be independent preferences.
- **REQ-004**: Every style/palette combination MUST produce a valid `ThemeData`.
- **REQ-005**: Settings MUST provide accessible controls for all three styles and six
  palettes, including selected-state indication and visual previews.
- **REQ-006**: Selecting a style or palette MUST update the active application theme
  immediately without restarting.
- **REQ-007**: The active theme MUST apply consistently to Home, Sticky Notes, note
  editor, saved note cards, navigation, buttons, inputs, and Settings.
- **REQ-008**: Style definitions MUST change visual treatment beyond colors, including
  typography, radii, borders, elevation, spacing, or decorative treatment.
- **REQ-009**: Each palette MUST define complete semantic colors for background, surface,
  primary, secondary, accent, text, border, divider, and readable foregrounds.
- **REQ-010**: Appearance preferences MUST persist locally and restore after restart.
- **REQ-011**: Missing or invalid persisted values MUST fall back safely to documented
  defaults without crashing.
- **REQ-012**: Initial preference loading MUST avoid a visible default-theme flash.
- **REQ-013**: Appearance persistence MUST work offline and MUST NOT use remote services.
- **REQ-014**: The layout MUST remain responsive and controls MUST meet accessible
  touch-target and contrast expectations.
- **REQ-015**: Sticky Notes behavior, local note persistence, and existing navigation
  functionality MUST remain intact.
- **REQ-016**: Theme configuration MUST be centralized so future styles or palettes
  do not require hardcoded changes in every screen.
- **REQ-017**: Settings MUST render one compact UI Style selector with exactly the
  three supported options and only the selected style's description.
- **REQ-018**: The three styles MUST use distinct centralized heading typography and
  component metrics without hardcoded font families in feature screens.
- **REQ-019**: Any future bundled font MUST have a documented open license and be
  registered centrally; the current implementation MUST remain functional without
  downloading fonts or relying on Comic Sans MS being installed.

## Measurable Success Criteria

- **SC-001**: Automated tests confirm exactly 3 styles and 6 palettes are available.
- **SC-002**: Automated tests confirm all 18 combinations produce valid semantic themes.
- **SC-003**: Settings tests confirm both controls update the active theme immediately.
- **SC-004**: Persistence tests confirm style and palette survive reopening the local
  database and invalid/missing values use defaults.
- **SC-005**: Existing Sticky Notes tests remain green with no schema changes to Notes.
- **SC-006**: No new network, authentication, cloud, or synchronization dependency is added.
- **SC-007**: Settings selection controls expose selected values and previews in widget tests.
- **SC-008**: Widget tests confirm a single style dropdown exposes exactly three
  options and displays the selected style description.
- **SC-009**: Theme tests confirm the style tokens and heading font families differ
  between Soft, Playful, and Minimal.

## Constraints and Privacy

- Use MVVM, Provider/ChangeNotifier, repository boundaries, and Drift/SQLite.
- Do not log preference contents beyond non-sensitive identifiers needed for diagnostics.
- Do not store note content in theme preference records.
- Do not add generated databases or secrets to the repository.
