# Research: Global Branded Loading Screen

## Existing project findings

### Architecture and startup

- Daymark is an Android-first Flutter/Dart app using MVVM with Provider and
  `ChangeNotifier`.
- [`lib/main.dart`](../../lib/main.dart) calls `WidgetsFlutterBinding.ensureInitialized()`
  and immediately constructs `AppDatabase.production()` before running `DaymarkApp`.
- [`lib/app/app.dart`](../../lib/app/app.dart) constructs the repositories and
  `ThemeViewModel`, calls `load()`, and currently returns a temporary `MaterialApp`
  containing `Scaffold` and `CircularProgressIndicator` while `isLoading` is true.
- Once theme preferences load, `MaterialApp.theme` is composed by
  [`lib/core/theme/app_theme.dart`](../../lib/core/theme/app_theme.dart) and the main
  shell is rendered. This existing gate is the correct starting point for the custom
  Flutter loading lifecycle.
- Android's [`styles.xml`](../../android/app/src/main/res/values/styles.xml) assigns
  `LaunchTheme` to the activity and removes the launch background when Flutter draws
  its first frame. [`launch_background.xml`](../../android/app/src/main/res/drawable/launch_background.xml)
  currently contains only a white background. This native surface must remain distinct
  from the animated Flutter screen.

### Theme and state

- [`lib/core/theme/theme_presets.dart`](../../lib/core/theme/theme_presets.dart) defines
  exactly six palettes and their semantic `background`, `surface`, text, border,
  divider, and foreground tokens.
- [`lib/core/theme/app_styles.dart`](../../lib/core/theme/app_styles.dart) defines
  Soft, Playful, and Minimal style tokens, including body and heading font families,
  weight, spacing, and radii.
- [`lib/features/settings/presentation/theme_view_model.dart`](../../lib/features/settings/presentation/theme_view_model.dart)
  exposes the current appearance and an `isLoading` flag. Its current load path has no
  explicit error state, so implementation must preserve exceptions through a
  documented startup policy rather than hiding them.
- [`lib/features/sticky_notes/presentation/sticky_notes_view_model.dart`](../../lib/features/sticky_notes/presentation/sticky_notes_view_model.dart)
  already models loading, empty/ready, validation error, and error states. Its current
  save flow is a relevant integration point for local loading, but this feature must
  not change note schema or behavior.

### Existing loading and test conventions

- Current loading UI is an unbranded `CircularProgressIndicator` in `DaymarkApp`.
- Sticky Notes uses a local `CircularProgressIndicator` while list work is active.
- Existing tests are under `test/core/` and `test/features/`, use `flutter_test`, and
  inject in-memory Drift repositories/databases.
- There is no existing global loading controller or overlay abstraction.

## Branding asset inventory

| Responsibility | Current asset | Format and dimensions | Transparency | Current Flutter/Android registration |
|---|---|---|---|---|
| Animated Flutter loading symbol | `assets/branding/daymark-symbol.png` | PNG, 1024×1024 | Yes; sampled corners are transparent | Not declared in `pubspec.yaml` |
| Android launcher source | `assets/branding/daymark-icon.png` | PNG, 1024×1024 | Yes; sampled corners are transparent | Android currently uses generated `android/app/src/main/res/mipmap-*/ic_launcher.png`, not this source |
| Android adaptive foreground | `assets/branding/daymark-icon-foreground.png` | PNG, 1024×1024 | Yes; exact byte-for-byte copy of icon source | Prepared; not yet configured in Android |

The symbol has an approximate nontransparent sampled content bound of
`168,168–856,852`, leaving transparent breathing room suitable for a contained
display. The icon has an approximate sampled content bound of `16,60–1012,976`.
Implementation must inspect the supplied artwork visually and preserve its original
proportions. The launcher source and prepared foreground are derived from the icon;
neither may be substituted for the loading symbol.

Recommended initial Flutter display sizing is a responsive square constrained to
`min(28% of the shortest viewport dimension, 192 logical pixels)` with a practical
minimum of 96 logical pixels, subject to emulator review. This is a starting design
token, not an artificial fixed size requirement.

## Decisions

### Use the existing theme composition

**Decision:** Read `Theme.of(context).scaffoldBackgroundColor` or the active
`ColorScheme` background and use the active `TextTheme` for the localized loading
message (`Loading...`/`Cargando...`).

**Rationale:** This preserves all 18 Feature 002 combinations and avoids duplicating
palette/style logic in the loading package. The loading component remains usable if
the theme composition evolves.

**Alternatives considered:** A loading-specific color map was rejected because it
would drift from Feature 002 and multiply test combinations. Hardcoded white/vanilla
styling was rejected because it would be incorrect for selected palettes.

### Keep startup loading at the existing app gate

**Decision:** Replace the temporary `CircularProgressIndicator` branch in `DaymarkApp`
with a themed `AppLoadingScreen`, and extend the initialization coordinator only as
needed for required local resources.

**Rationale:** It is already the point where preferences are loaded before the main
shell, so it avoids rendering the wrong theme. The native Android launch background
remains static and ends when Flutter draws its first frame.

**Alternatives considered:** Blocking in `main()` before `runApp` was rejected because
the custom Flutter screen cannot render before Flutter starts. A platform splash
animation was rejected because it would conflate native launch and reusable in-app
loading.

### Separate global blocking and local loading

**Decision:** Provide a reusable full-screen overlay and a lightweight local state
pattern. A controller is optional for genuinely global operations; ViewModels retain
ownership of local operation state.

**Rationale:** Full-screen loading prevents duplicate actions only when necessary,
while local buttons/cards/lists remain responsive. This follows MVVM and avoids
global mutable state for every repository call.

### Animation

**Decision:** Start with one `AnimationController` using an approximately 10-second duration, linear
curve, and indefinite repetition. Disable motion when Flutter reports that animations
should be disabled.

**Rationale:** Approximately ten seconds is slow enough to keep the symbol calm while making
progress visible. A linear curve avoids acceleration/deceleration and an indefinite
controller avoids abrupt reset logic. The duration must be validated on Android.

**Alternatives considered:** A short spinner-like duration was rejected as distracting.
Animating text/background was rejected as unnecessary visual noise. Fabricated progress
was rejected because repository operations do not provide measurable progress.

### Launcher icon tooling

**Decision:** Evaluate `flutter_launcher_icons` as a dev-only generation tool, with
the official icon as source, the prepared transparent
`daymark-icon-foreground.png` as adaptive foreground, and a brand-matching solid
adaptive background. Verify the current package version and generated resources
before adding it.

**Rationale:** Reproducible generation is preferable to manually editing each density.
The existing Android resources are generated-looking legacy launcher assets and lack
an explicit adaptive icon source configuration.

**Alternatives considered:** Manual density edits were rejected as error-prone.
Reusing the loading symbol was explicitly rejected because the responsibilities are
different.

## Open implementation checks

- Confirm the exact visual difference between `daymark-symbol.png` and
  `daymark-icon.png` with the project owner or visual review before generating launcher
  resources; the foreground copy itself is prepared and is not missing artwork.
- Confirm whether Android API-level adaptive icon XML is required in addition to
  generated mipmap resources.
- Confirm the initialization resources that belong in the startup coordinator beyond
  theme preference restoration and the existing local database construction.
- Confirm the responsive symbol bounds on representative Android screen sizes.
