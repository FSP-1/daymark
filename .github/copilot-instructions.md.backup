
# Daymark — GitHub Copilot Instructions

## Project purpose

Daymark is an Android-first personal organizer built with Flutter and Dart. It manages sticky notes, tasks, important dates, and local reminders.

## Architecture

- Use MVVM with Provider and ChangeNotifier.
- Keep Views focused on presentation and user interaction.
- Keep ViewModels responsible for presentation state and actions.
- Use repositories to abstract data access.
- Keep business rules independent of Flutter widgets and Firebase.
- Use Drift and SQLite for local persistence.
- Use Firebase Authentication for email/password and Google sign-in.
- Use Cloud Firestore for remote synchronization.
- Follow an offline-first approach: local operations must not require network access.

## SDD and TDD

- Define or update the feature specification before implementation.
- Review requirements, edge cases, acceptance criteria, and security implications.
- Produce an implementation plan and ordered tasks before coding.
- Write a failing automated test before implementing each behavior.
- Implement the minimum code needed to pass the test.
- Refactor without breaking existing tests.
- Never claim a test passed unless it was actually executed and passed.
- If requirements are ambiguous, ask for clarification rather than inventing behavior.

## Quality

- Run `dart format` on changed Dart files.
- Run `flutter analyze`.
- Run `flutter test`.
- Add regression tests for bug fixes.
- Cover loading, empty, success, and error states where applicable.
- Keep dependencies minimal and justify new packages.

## Security and privacy

- Never commit passwords, private keys, service-account credentials, or secrets.
- Never trust client-side checks as a replacement for Firebase Security Rules.
- Isolate user data by authenticated user ID.
- Do not log sensitive note content or authentication credentials.
- Define logout and unsynchronized-data behavior explicitly.

## Documentation and Git

- Keep README and technical documentation aligned with the implementation.
- Record significant architectural decisions.
- Use small, descriptive commits.
- Do not commit generated files, local databases, or secrets.
- Do not change unrelated files without justification.

## Working agreement

Implement only the approved scope of the current feature. Explain significant changes, report commands executed and their results, and identify any remaining limitations before considering a task complete.
