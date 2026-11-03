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

Daymark currently provides local sticky notes, Daily recurring activities, and a
private Personal Journal.

### Sticky Notes

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
- Use Home as the feature launcher with a responsive two-column grid for Sticky
  Notes, Daily, Important Dates, and future features.
- Change the application language between Spanish and English from Settings.
- Store Spanish and English interface strings in local JSON assets.
- Choose one of three appearance styles (Soft, Playful, or Minimal).
- Choose one of six color palettes (Vanilla, Sage, Rose, Sky, Lavender, or Peach).
- Apply appearance changes immediately across the application.
- Restore appearance preferences after restarting the app while offline.
- Show a branded Flutter loading screen during startup and use the Daymark symbol
  for the in-app loading composition; the Android launcher uses the separate icon
  asset and adaptive background resources.
- Keep notes available after closing and reopening the app.
- Create and view notes without an Internet connection.
- Show validation and persistence error feedback without reporting false success.

### Daily activities

- Create, edit, and delete recurring activities stored locally with Drift/SQLite.
- Choose `Anytime` or a specific local wall-clock time.
- Select and persist an activity icon from the built-in Daily icon catalog.
- Mark activities complete or incomplete for the current local calendar date.
- Preserve completion history across dates without duplicating recurring activities.
- Enable optional local notifications for specific-time activities.
- Request notification permission only when the user enables reminders; notification
  failures do not block local activity CRUD or completion tracking.
- Use responsive activity cards and a scrollable, localized create/edit dialog with
  icon selection, schedule controls, reminder settings, and delete confirmation.
- Support Daily UI strings in Spanish and English across the existing theme styles and
  color palettes.

Daily remains offline-first. Authentication, Firebase, Firestore, remote databases,
cloud synchronization, weekly/custom recurrence, snoozing, and remote notifications
are not part of the current scope. Operating-system alarm restrictions may delay or
prevent local notifications; Android build and emulator verification is performed by
the implementation owner.

### Personal Journal

- Open Journal from the Home launcher or bottom navigation.
- Browse entries in reverse chronological order with localized month grouping.
- Keep multiple entries on the same date.
- Create entries with optional titles, text, dates, and drawings.
- Reuse the shared `core/drawing` canvas, preview, and serialization.
- Read entries in a dedicated view and edit them without losing the updated
  content when returning to reading mode.
- Remove drawings explicitly while editing an entry.
- Delete entries after confirmation; associated drawing data is removed locally.
- Protect unsaved editor changes with a discard confirmation.
- Show localized loading, validation, save, load, and delete feedback.
- Persist journal entries and drawings in the local Drift/SQLite database.
- Support English and Spanish and the existing appearance styles and palettes.

Personal Journal remains entirely offline. Cloud synchronization, accounts,
sharing, exporting, rich text, audio, and AI assistance are outside the current
scope. The complete feature specification is documented in
[specs/005-personal-journal/spec.md](specs/005-personal-journal/spec.md).

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

Feature specifications and implementation artifacts are tracked under
[`specs/`](specs/), including the implemented Daily feature in
[`specs/004-daily/`](specs/004-daily/) and the implemented Personal Journal in
[`specs/005-personal-journal/`](specs/005-personal-journal/).

Implementation follows TDD: **Red -> Green -> Refactor**. A regression or new
behavior should have an automated test before its implementation, and test
results are reported only after the command has actually been executed.
