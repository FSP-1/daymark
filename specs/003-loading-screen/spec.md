# Feature Specification: Global Branded Loading Screen

**Feature Branch**: `003-loading-screen`  
**Created**: 2026-10-31  
**Status**: Draft for implementation  
**Input**: Daymark Feature 003 request

## Scope and Boundaries

### In scope

- A reusable branded Flutter loading presentation using the official Daymark symbol
  from `assets/branding/daymark-symbol.png`.
- The localized loading message `Loading...` in English and `Cargando...` in Spanish,
  maintained alongside the existing resources under `assets/i18n/`.
- A slow, linear, continuous symbol rotation that is disposed with its widget and
  respects reduced-motion accessibility preferences.
- Theme-aware background and typography for all 3 UI styles and 6 palettes from
  Feature 002.
- A startup lifecycle that distinguishes the native Android launch screen from the
  animated Flutter loading screen and avoids a default-theme flash.
- Full-screen loading for operations that must block interaction.
- Local loading affordances for controls, cards, and lists that do not require a
  global interaction block.
- Explicit idle, loading, success, and error state handling in the relevant
  ViewModel or screen; the loading components display loading only.
- MVVM, Provider/ChangeNotifier, repository boundaries, offline-first local
  behavior, and `try/finally` dismissal around asynchronous operations.
- Android launcher icon configuration using the separate official
  `daymark-icon.png` asset, including adaptive-icon foreground/background treatment.
- Widget, ViewModel, startup, theme-combination, accessibility, and regression tests.

### Out of scope

- Changing the Sticky Notes database schema or note behavior.
- Adding Firebase, Firestore, authentication, synchronization, or another remote
  service.
- Inventing progress percentages where an operation cannot report progress.
- Replacing the official symbol or icon with an emoji, illustration, or one another.
- Animating the entire screen or text unnecessarily.
- Making every database operation full-screen.
- Implementing the feature during this documentation phase.

### Dependencies and prerequisites

- Feature 002's `buildAppTheme`, `AppStyleTokens`, and `AppPaletteTokens` remain the
  source of active theme values.
- The current symbol, icon, and copied adaptive foreground files are present, but
  branding assets are not currently listed in `pubspec.yaml`; implementation must
  declare them before use.
- The current Android project has `@mipmap/ic_launcher` resources but no adaptive icon
  XML or launcher-icon generator configuration.
- Launcher-icon generation requires verifying a compatible `flutter_launcher_icons`
  version. The adaptive foreground is prepared at
  `assets/branding/daymark-icon-foreground.png` as an exact copy of the official
  transparent icon; no artwork was redrawn or regenerated.

## User Stories and Acceptance Scenarios

### User Story 1 - See a branded startup transition (Priority: P1)

As a Daymark user, I want the application to show a branded loading experience while
it prepares itself so startup feels intentional and trustworthy.

**Independent Test**: Construct the app with delayed theme/resource initialization and
verify that Flutter renders the branded state before the main shell, then transitions
to the themed shell exactly once after initialization succeeds.

**Acceptance Scenarios**:

1. **Given** the Android process is launching, **when** the native launch screen is
   visible, **then** it remains a native/static launch surface and is not treated as
   the animated Flutter loading screen.
2. **Given** Flutter has rendered and saved appearance preferences are still loading,
   **when** the user views the app, **then** the branded Flutter loading state is
   visible with the active/default-safe theme and no main content is interactive.
3. **Given** appearance preferences and required local resources finish successfully,
   **when** the startup lifecycle completes, **then** the loading state is removed and
   the main application is shown without a second unnecessary loading screen.
4. **Given** preference loading fails, **when** startup continues, **then** a
   documented safe appearance fallback is used and the exception is surfaced through
   the existing error/reporting path rather than silently swallowed.

### User Story 2 - Experience the official branded animation (Priority: P1)

As a user waiting for Daymark, I want the official symbol to rotate calmly above the
localized loading message without distortion or distracting resets.

**Independent Test**: Pump the loading widget with each style and palette, inspect the
asset and layout, advance animation time, and dispose the widget.

**Acceptance Scenarios**:

1. **Given** the branded loading widget is mounted, **when** it renders, **then** it
   displays `daymark-symbol.png`, centers the symbol and localized message as one
   composition, and places `Loading...`/`Cargando...` below the symbol according to
   the active locale.
2. **Given** loading remains active, **when** time advances, **then** the symbol
   rotates continuously with a linear curve and no per-cycle visual jump.
3. **Given** the widget is disposed, **when** its animation resources are released,
   **then** no animation controller remains active and no post-disposal notification
   occurs.
4. **Given** a device or test environment requests reduced motion, **when** the
   loading widget renders, **then** it avoids continuous motion while preserving the
   branded symbol, message, layout, and loading semantics.
5. **Given** a narrow, large, or inset display, **when** the widget lays out, **then**
   the image preserves its aspect ratio, respects safe areas, and remains usable
   without clipping or stretching.

### User Story 3 - Match the selected appearance (Priority: P1)

As a user, I want loading to feel like the rest of Daymark regardless of my selected
style and palette.

**Independent Test**: Render all 18 Feature 002 style/palette combinations and compare
the loading background and text styles to the composed `ThemeData`.

**Acceptance Scenarios**:

1. **Given** any of the six palettes is active, **when** the loading screen renders,
   **then** its background uses the active palette's semantic background color.
2. **Given** any of the three styles is active, **when** the loading message renders,
   **then** its typography uses the active theme's centralized style tokens.
3. **Given** any valid style/palette combination, **when** loading is shown, **then**
   the composition has readable foreground/background contrast and no hardcoded
   palette-specific branch is required.
4. **Given** appearance preferences are being restored, **when** the loading state is
   shown, **then** the user does not see a flash of an incorrect default theme before
   the restored configuration is applied.

### User Story 4 - Reuse loading at operation boundaries (Priority: P1)

As a user, I want Daymark to prevent accidental repeated actions when a blocking
operation is running, while keeping small operations local to their affected control.

**Independent Test**: Drive fake asynchronous operations through ViewModels and render
both full-screen and local loading presentations.

**Acceptance Scenarios**:

1. **Given** a blocking operation is active, **when** a full-screen loading overlay is
   shown, **then** it covers the current screen, prevents pointer/semantic actions
   from reaching the underlying content, and uses the branded presentation where
   appropriate.
2. **Given** a local save action is active, **when** its button is loading, **then**
   only the relevant control reflects loading and unrelated screen content remains
   usable.
3. **Given** an operation succeeds, **when** its completion path runs, **then** the
   loading state returns to idle and the relevant screen handles success feedback.
4. **Given** an operation throws, **when** its error path runs, **then** `finally`
   dismisses loading, the exception is surfaced through the existing ViewModel/screen
   error path, and the user can retry or continue.
5. **Given** an operation cannot report measurable progress, **when** it is loading,
   **then** the UI shows indeterminate loading and does not invent a percentage.

### User Story 5 - Preserve independent branding responsibilities (Priority: P1)

As a user, I want the Android launcher icon and in-app loading symbol to remain the
correct, distinct Daymark assets.

**Independent Test**: Build/install the Android app, inspect the launcher icon under
multiple adaptive masks, and render the Flutter loading screen.

**Acceptance Scenarios**:

1. **Given** Android displays the launcher, **when** the app icon is shown in home,
   app-drawer, and recent-app surfaces, **then** it uses the official icon asset and
   not the loading symbol.
2. **Given** an adaptive launcher icon is generated, **when** Android applies circular,
   rounded-square, or squircle masks, **then** important artwork remains inside the
   safe zone and the image is neither cropped nor distorted.
3. **Given** Flutter loads the animated loading screen, **when** its central image is
   inspected, **then** it uses the official symbol asset and not `ic_launcher`.
4. **Given** the app is rebuilt, **when** generated launcher resources are refreshed,
   **then** the configured icon remains stable and reproducible from documented source
   assets.

## Functional Requirements

- **REQ-001**: The application MUST provide a reusable Flutter branded loading
  component that renders the official Daymark symbol and the localized loading
  message (`Loading...` in English, `Cargando...` in Spanish).
- **REQ-002**: The loading composition MUST center the symbol and message, preserve
  the source image aspect ratio, adapt its size to available constraints, and respect
  safe areas.
- **REQ-003**: The symbol MUST rotate continuously and slowly using Flutter's animation
  system, a linear curve, and an indefinite repeat while loading.
- **REQ-004**: The animation MUST be disposed with its widget, avoid unnecessary
  duplicate controllers, and provide reduced-motion behavior.
- **REQ-005**: The loading background MUST use the active Feature 002 palette's
  semantic background color for all six palettes.
- **REQ-006**: Loading text MUST use the active Feature 002 style's centralized
  typography for all three styles, with accessible contrast.
- **REQ-007**: Startup MUST distinguish the native Android launch screen from the
  animated Flutter loading screen and define the lifecycle native launch → Flutter
  initialization → preference restoration → required local resources → main shell.
- **REQ-008**: Startup MUST not expose interactive main content or show an incorrect
  default-theme flash while required appearance preferences are loading.
- **REQ-009**: Startup MUST remove the custom loading state after readiness and MUST
  provide a documented safe fallback/error path if initialization fails.
- **REQ-010**: The system MUST support full-screen loading that blocks interaction
  during operations that require exclusive user attention.
- **REQ-011**: The system MUST support local loading for controls, cards, and lists
  without unnecessarily blocking unrelated content.
- **REQ-012**: Relevant ViewModels MUST represent idle, loading, success, and error
  states; loading components MUST NOT own success/error feedback.
- **REQ-013**: Async operations using shared loading state MUST use a guaranteed
  dismissal path such as `try/finally`, including failure and retry behavior.
- **REQ-014**: Operations without measurable progress MUST display indeterminate
  loading rather than fabricated progress percentages.
- **REQ-015**: The implementation MUST preserve MVVM, Provider/ChangeNotifier,
  repository boundaries, offline-first local behavior, and existing Sticky Notes
  functionality without changing its database schema.
- **REQ-016**: The Flutter asset pipeline MUST load the symbol from the actual
  repository asset and document its path, PNG format, transparency, and recommended
  display sizing; loading text MUST be localized in both existing languages.
- **REQ-017**: The Android launcher MUST use the separate official icon asset and the
  prepared transparent `daymark-icon-foreground.png` foreground, preserve proportions,
  support an appropriate adaptive foreground/background configuration, and keep artwork
  within the adaptive safe zone.
- **REQ-018**: Launcher icon generation MUST be reproducible through documented project
  tooling, with generated resources verified after a rebuild.
- **REQ-019**: The system MUST not add Firebase, Firestore, synchronization, or another
  remote dependency as part of this feature.
- **REQ-020**: Widget and ViewModel tests MUST cover branding, theme combinations,
  animation lifecycle, interaction blocking/local loading, success/error dismissal,
  startup transitions, launcher configuration evidence, and Sticky Notes regression.

## Measurable Success Criteria

- **SC-001**: Widget tests find the symbol asset and exact loading message in the
  branded loading composition.
- **SC-002**: Tests verify the loading background equals each of the six palette
  background tokens and typography follows each of the three style configurations.
- **SC-003**: Animation tests verify linear repeating rotation, reduced-motion behavior,
  and controller disposal.
- **SC-004**: Overlay tests verify underlying controls cannot be activated when blocking
  loading is active, while local loading leaves unrelated controls available.
- **SC-005**: ViewModel tests verify loading returns to idle after both successful and
  failed operations and that failures remain recoverable.
- **SC-006**: Startup tests verify native/Flutter lifecycle boundaries, no default-theme
  flash, readiness transition, and safe initialization failure behavior.
- **SC-007**: Android verification confirms the launcher icon is distinct from the
  loading symbol, preserves artwork under adaptive masks, and survives a clean rebuild.
- **SC-008**: Existing Sticky Notes, theme, navigation, analyzer, formatting, and full
  Flutter test gates remain green; no Notes schema change is introduced.

## Technical Decisions to Confirm During Planning

- Place reusable loading code under `lib/core/loading/`, following the proposed
  `app_loading_screen.dart`, `loading_overlay.dart`, and `loading_controller.dart`
  names unless existing naming conventions require a better equivalent.
- Use one `AnimationController` per mounted branded loading widget, a linear
  `CurvedAnimation`, and a documented slow duration of approximately 10 seconds per
  turn.
  The implementation must validate the perceived speed on an Android emulator.
- Use `MediaQuery.disableAnimations` (or the supported Flutter accessibility signal)
  to disable motion without removing loading semantics.
- Keep global blocking coordination separate from local ViewModel state; do not make a
  global controller mandatory for simple button/card/list loading.
- Prefer existing `ThemeData`, `ColorScheme`, and `AppStyleTokens` rather than adding
  a loading-specific color or typography system.
- Evaluate `flutter_launcher_icons` only after verifying the current compatible version;
  use the prepared `assets/branding/daymark-icon-foreground.png` as the foreground and
  a separate solid brand color as the adaptive background.

## Security, Privacy, and Reliability

- Loading must not log note content, credentials, or remote payloads.
- Exceptions must remain observable through the established error path; broad catches
  and success-shaped fallbacks are prohibited.
- Full-screen blocking must be removed in all terminal paths so a failed operation
  cannot strand the user behind an indefinite overlay.
- Startup fallback must not silently discard saved appearance preferences or local data.
