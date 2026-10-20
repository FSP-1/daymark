# Daymark

Daymark is an Android-first personal organizer built with Flutter and Dart.

## Stack and architecture

- Flutter and Dart, optimized for Android-first use.
- MVVM with `Provider` and `ChangeNotifier`.
- Views handle presentation and interaction; ViewModels handle presentation
  state and actions.
- Repositories isolate local persistence from the domain and UI.
- Drift over SQLite provides durable, offline-first local storage.
- Business rules remain independent of Flutter widgets and remote services.

Firebase, Firestore, authentication, synchronization, and remote databases are
explicitly outside the approved scope at this stage.

## Current functionality

The first feature provides local sticky notes:

- Create notes containing at least one non-whitespace character.
- Optionally add a title and subtitle; every note records its localized creation date.
- View saved notes and an explicit empty state.
- Filter notes by text across title, subtitle, and content, or by a creation-date range.
- Date filtering is limited to today and earlier.
- The search and date-filter controls appear below the note editor; matching notes
  are rendered directly below those controls.
- Create a freehand drawing with erase and clear controls; drawing data is persisted locally.
- Use the Home screen and bottom navigation to reach Sticky Notes, future feature
  areas, and Settings.
- Change the application language between Spanish and English from Settings.
- Store Spanish and English interface strings in local JSON assets.
- Choose one of three appearance styles (Soft, Playful, or Minimal).
- Choose one of six color palettes (Vanilla, Sage, Rose, Sky, Lavender, or Peach).
- Apply appearance changes immediately across the application.
- Restore appearance preferences after restarting the app while offline.
- Keep notes available after closing and reopening the app.
- Create and view notes without an Internet connection.
- Show validation and persistence error feedback without reporting false success.

Notes are currently stored locally on the device. Authentication, Firebase, Firestore,
remote databases, synchronization, editing, deleting, pinning, colors,
reminders, and task management are not part of the current feature.

## Localization and settings

The current language selector is intentionally limited to Spanish and English.
Translations live in [assets/i18n/es.json](assets/i18n/es.json) and
[assets/i18n/en.json](assets/i18n/en.json), and are loaded locally through
`AppLocalizations`. Flutter's Material, Widgets, and Cupertino localization
delegates are also configured so date pickers and platform controls follow the
selected locale.

The selected language currently applies for the active application session. A
future approved feature may persist this preference locally; no remote service is
used for language selection.

## Appearance customization

Feature 002 centralizes visual customization under [lib/core/theme/](lib/core/theme/):

- `app_styles.dart` defines the three component-treatment styles.
- `theme_presets.dart` defines the six semantic color palettes.
- `app_theme.dart` composes any style/palette combination into `ThemeData`.

Appearance preferences are managed by `ThemeViewModel` and stored in a separate
Drift `AppPreferences` table. The existing `Notes` table and note serialization
are unchanged. Preferences load before the main shell is rendered, so the app
does not show the default theme while saved values are being restored. Missing
or invalid values fall back to Soft + Vanilla.

Settings provides one compact UI Style dropdown, a localized description of the
selected style, selected-state indicators, a reset action, and responsive palette
swatches. Typography is centralized in the style
tokens: Soft uses warm serif headings, Playful uses the Android generic `cursive`
family with a sans-serif fallback, and Minimal uses a neutral sans-serif
hierarchy. No font dependency or unverified font asset is included; Comic Sans MS
is not assumed to be installed on Android.

## Development checks

Run these commands before submitting changes:

```text
dart format lib test
flutter analyze
flutter test
```

## SDD and TDD workflow

Feature work follows the approved Spec-Driven Development flow:

1. Define the feature in `specs/<feature>/spec.md`.
2. Create the technical plan and requirement mapping in `plan.md`.
3. Generate executable tasks in `tasks.md`.
4. Implement only the approved scope.
5. Validate requirements, tests, analysis, formatting, and documentation.

Implementation follows TDD: **Red -> Green -> Refactor**. A regression or new
behavior should have an automated test before its implementation, and test
results are reported only after the command has actually been executed.
