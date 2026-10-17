# Daymark

Daymark is an Android-first personal organizer built with Flutter and Dart.

## Current functionality

The first feature provides local sticky notes:

- Create notes containing at least one non-whitespace character.
- Optionally add a title and subtitle; every note records its localized creation date.
- View saved notes and an explicit empty state.
- Filter notes by text across title, subtitle, and content, or by a creation-date range.
- Date filtering is limited to today and earlier.
- Create a freehand drawing with erase and clear controls; drawing data is persisted locally.
- Use the Home screen and bottom navigation to reach Sticky Notes and future feature areas.
- Keep notes available after closing and reopening the app.
- Create and view notes without an Internet connection.
- Show validation and persistence error feedback without reporting false success.

Notes are currently stored locally on the device. Authentication, Firebase, Firestore,
remote databases, synchronization, editing, deleting, pinning, colors,
reminders, and task management are not part of the current feature.

## Development checks

Run these commands before submitting changes:

```text
dart format lib test
flutter analyze
flutter test
```
