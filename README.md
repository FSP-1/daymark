# Daymark

Daymark is an Android-first personal organizer built with Flutter and Dart.

## Current functionality

The first feature provides local sticky notes:

- Create notes containing at least one non-whitespace character.
- View saved notes and an explicit empty state.
- Keep notes available after closing and reopening the app.
- Create and view notes without an Internet connection.
- Show validation and persistence error feedback without reporting false success.

Notes are currently stored locally on the device. Authentication, Firebase, Firestore,
remote databases, synchronization, editing, deleting, searching, pinning, colors,
reminders, and task management are not part of the current feature.

## Development checks

Run these commands before submitting changes:

```text
dart format lib test
flutter analyze
flutter test
```

