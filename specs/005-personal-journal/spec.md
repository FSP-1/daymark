# Feature Specification: Personal Journal

**Feature**: Personal Journal  
**Project**: Daymark  
**Status**: Implemented

## Objective

Provide a private, book-like journal for writing and preserving personal entries
completely offline. Entries may contain an optional title, text, date, and a
freehand drawing using the existing `core/drawing` implementation.

## Scope and boundaries

### In scope

- Journal access from Home and bottom navigation.
- Reverse-chronological entry index grouped by month.
- Multiple entries on the same date.
- Optional title and text body.
- User-selectable entry date, defaulting to today.
- Drawing creation, preview, editing, and removal.
- Dedicated reading view with edit and delete actions.
- Delete confirmation and local cleanup of drawing data.
- Drift/SQLite persistence and schema migration.
- English and Spanish localization.
- Existing themes, palettes, MVVM, Provider, and repository boundaries.

### Out of scope

- Cloud synchronization, Firebase, Firestore, or authentication.
- Sharing, exporting, collaboration, audio, AI features, or rich text.
- Remote persistence or any operation requiring an Internet connection.

## User stories and acceptance scenarios

### User Story 1 - Browse journal entries (P1)

As a user, I want a calm journal index so that I can find previous entries
quickly.

1. **Given** no entries exist, **when** the user opens Journal, **then** a
   localized empty state and create action are shown.
2. **Given** entries exist, **when** the user opens Journal, **then** entries
   appear newest first and are grouped by localized month and year.
3. **Given** multiple entries share a date, **when** the index is opened,
   **then** every entry is displayed separately.
4. **Given** an entry contains only a drawing, **when** it appears in the
   index, **then** a localized drawing-entry preview is shown.

### User Story 2 - Write and edit entries (P1)

As a user, I want to write without being forced to provide a title.

1. **Given** the editor is opened, **then** the date defaults to today and
   title and content are editable.
2. **Given** text or a drawing is present, **when** the user saves, **then**
   the entry is persisted locally.
3. **Given** an entry has neither text nor a drawing, **when** the user saves,
   **then** localized validation feedback is shown and the editor remains open.
4. **Given** an existing entry is edited, **when** it is saved, **then** its
   title, text, date, drawing, and modification timestamp are updated.
5. **Given** unsaved editor changes exist, **when** the user leaves, **then**
   the application requests confirmation before discarding them.
6. **Given** saving is in progress, **then** repeated save actions are
   disabled and progress feedback is visible.

### User Story 3 - Draw and read entries (P1)

As a user, I want drawings to feel part of the journal page.

1. **Given** the editor is open, **when** the user draws, **then** the
   existing `DrawingCanvas` tools are used.
2. **Given** an entry has a drawing, **when** it is listed or read, **then**
   `DrawingPreview` renders the serialized strokes.
3. **Given** an existing drawing is cleared and saved, **then** its persisted
   drawing data becomes null.
4. **Given** an entry is opened, **then** a dedicated reading view shows its
   date, title, complete body, and drawing when present.
5. **Given** an entry is edited from reading view, **then** the reading view
   displays the updated entry after returning.

### User Story 4 - Delete entries privately (P1)

1. **Given** an entry is open, **when** the user requests deletion, **then**
   a localized confirmation is required.
2. **Given** deletion is confirmed, **then** the entry and associated drawing
   data are removed from local storage.
3. **Given** deletion fails, **then** localized error feedback is shown and
   the application does not report false success.

## Functional requirements

- **REQ-001**: Journal MUST provide local create, read, update, and delete
  operations for entries.
- **REQ-002**: Each entry MUST support an optional title, text content, entry
  date, drawing data, creation timestamp, and update timestamp.
- **REQ-003**: The entry date MUST default to the current local date and be
  editable.
- **REQ-004**: An entry MUST be valid when it contains non-whitespace text or
  at least one drawing; a title MUST remain optional.
- **REQ-005**: Journal MUST reuse `DrawingCanvas`, `DrawingPreview`,
  `DrawingStroke`, `encodeDrawing`, and `decodeDrawing`.
- **REQ-006**: Clearing a drawing during edit MUST persist a null drawing value.
- **REQ-007**: Entries MUST be ordered newest-first and grouped by month while
  supporting multiple entries on the same date.
- **REQ-008**: Delete confirmation MUST precede deletion, and deletion MUST
  remove the associated drawing data with the entry.
- **REQ-009**: Save, load, validation, and delete failures MUST have explicit
  localized UI feedback.
- **REQ-010**: Saving MUST update `updatedAt` at the persistence boundary.
- **REQ-011**: All user-facing strings MUST be available in English and Spanish.
- **REQ-012**: Journal MUST use existing MVVM, Provider/ChangeNotifier,
  repository, Drift, SQLite, theme, and localization patterns.
- **REQ-013**: Existing features and database migrations MUST continue working.
- **REQ-014**: Journal MUST work without network access and preserve entries
  across application restarts.

## Data model

The existing Drift database contains a versioned `JournalEntries` table:

| Field | Type | Constraints |
|---|---|---|
| `id` | integer | Auto-increment primary key |
| `title` | text | Nullable |
| `content` | text | Required |
| `entryDate` | datetime | Required, local calendar date |
| `drawingData` | text | Nullable serialized strokes |
| `createdAt` | datetime | Required |
| `updatedAt` | datetime | Required |

The schema migration creates this table without modifying existing Sticky
Notes data.

## Non-functional requirements

- **NFR-001 Privacy**: Journal content and drawings remain in local SQLite
  storage and must not be logged or sent remotely.
- **NFR-002 Offline**: Reading and writing entries must not require network
  access.
- **NFR-003 Accessibility**: The editor and reading view must remain scrollable,
  support text scaling, and avoid horizontal overflow.
- **NFR-004 Reliability**: Persistence failures must remain visible and must
  not produce success-shaped UI.
- **NFR-005 Maintainability**: Drawing serialization must have one shared
  implementation; the journal must not create a second drawing engine.

## Localization and visual design

Journal strings are defined in `assets/i18n/en.json` and `assets/i18n/es.json`.
The interface uses the existing `ThemeData`, semantic color scheme, typography,
and responsive layout. The index emphasizes month grouping, dates, title
hierarchy, excerpts, and drawing previews while keeping the writing experience
minimal.

## Validation

Required checks:

```text
dart format lib test
flutter analyze
flutter test
flutter test test/features/journal
```

Android debug build and emulator verification remain owned by the implementation
operator.
