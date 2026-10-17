# Feature Specification: Sticky Notes

**Feature Branch**: `001-sticky-notes`  
**Created**: 2026-10-15  
**Status**: Amended
**Input**: `prompts/first/sticky-notes.txt`

## Scope and Boundaries

- **In scope**:
  - Creating a sticky note from user-provided text.
  - Viewing existing sticky notes.
  - Keeping notes available after the application is closed and reopened.
  - Supporting creation and viewing without Internet access.
  - Communicating clearly when no notes exist.
  - Rejecting empty or whitespace-only note content.
  - Communicating persistence failures without falsely reporting success.
  - Recording the creation date for each note.
  - Optionally capturing a title and subtitle while keeping content mandatory.
  - Filtering notes by text and/or creation date through a reusable filtering capability.
  - Limiting date filtering to today and earlier dates.
  - Drawing freehand content on a note with local persistence and erase/clear controls.
  - Presenting notes as creative post-it-style cards and providing a Home entry point.
- **Out of scope**:
  - Editing, deleting, pinning, reminders, and task management.
  - Authentication and user accounts.
  - Firebase Authentication, Cloud Firestore, remote databases, and synchronization.
  - Unrelated changes to the existing application.
- **Dependencies requiring approval**:
  - No remote service or authentication dependency is approved for this feature.
  - Any new package or persistence dependency requires justification in the technical plan.
  - The reusable filter MUST remain independent of Sticky Notes so other features can use
    or extend it later.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a valid note (Priority: P1)

As a Daymark user, I want to enter note text and save it so that I can capture a
thought for later.

**Why this priority**: Creating a note is the primary value of the first usable
feature and provides the data that the remaining scenarios display.

**Independent Test**: Start with an empty note collection, enter non-whitespace text,
save it, and verify that the note appears in the collection without Internet access.

**Acceptance Scenarios**:

1. **Given** no notes exist, **When** the user enters valid text and confirms creation,
   **Then** the note is persisted and appears in the notes list.
2. **Given** the device has no Internet connection, **When** the user enters valid text
   and confirms creation, **Then** the note is created successfully without requiring
   network access.

---

### User Story 2 - View notes and empty state (Priority: P1)

As a Daymark user, I want to see my existing notes and a clear empty state so that I
understand whether I have saved content.

**Why this priority**: Viewing notes completes the basic capture-and-recall loop, while
the empty state prevents an empty collection from appearing broken.

**Independent Test**: Verify the notes list with both an empty collection and a collection
containing saved notes, without requiring an Internet connection.

**Acceptance Scenarios**:

1. **Given** no notes exist, **When** the user opens the notes view, **Then** the
   interface clearly communicates that no notes are available and does not show an error.
2. **Given** one or more notes exist, **When** the user opens the notes view, **Then**
   each saved note is displayed in the list.
3. **Given** the device has no Internet connection, **When** the user opens the notes view,
   **Then** locally saved notes remain viewable.

---

### User Story 3 - Preserve notes across restart (Priority: P1)

As a Daymark user, I want my notes to remain after closing and reopening the application
so that captured information is not lost.

**Why this priority**: Persistence is essential for a personal organizer; without it,
the feature would only work for a single application session.

**Independent Test**: Create a valid note, close the application, reopen it, and verify
that the same note is available without Internet access.

**Acceptance Scenarios**:

1. **Given** a valid note was saved successfully, **When** the user closes and reopens
   the application, **Then** the note appears in the notes list.
2. **Given** notes were saved locally and the device is offline, **When** the user
   reopens the application, **Then** the notes remain available.

---

### User Story 4 - Handle invalid input and save failures (Priority: P1)

As a Daymark user, I want invalid input and saving problems to be explained clearly
so that I know whether my note was created and what action I can take.

**Why this priority**: Preventing empty notes and false success protects data quality
and user trust in the first feature.

**Independent Test**: Attempt to save empty and whitespace-only content, then simulate
or induce a persistence failure and verify the resulting feedback and note list.

**Acceptance Scenarios**:

1. **Given** the note content is empty, **When** the user attempts to create the note,
   **Then** the note is not saved and understandable validation feedback is shown.
2. **Given** the note content contains only whitespace, **When** the user attempts to
   create the note, **Then** the note is not saved and understandable validation feedback
   is shown.
3. **Given** saving the note fails, **When** the user attempts to create it, **Then**
   understandable error feedback is shown, the note is not presented as successfully
   created, and existing notes remain available.

---

### User Story 5 - Add note metadata and filter notes (Priority: P1)

As a Daymark user, I want to optionally add a title and subtitle, know when a note was
created, and filter notes by text or creation date so that I can find relevant notes later.

**Why this priority**: Metadata and retrieval are necessary for a usable notes collection
as soon as more than one note exists.

**Independent Test**: Create notes with and without optional metadata, verify creation dates,
then apply text, date, and combined filters and verify only matching notes are displayed.

**Acceptance Scenarios**:

1. **Given** a note has valid content and optional title or subtitle, **When** the user
   saves it, **Then** the note is persisted with those metadata values and its creation
   timestamp.
2. **Given** a note has valid content but no title or subtitle, **When** the user saves it,
   **Then** the note is saved successfully and content remains the required field.
3. **Given** saved notes have different creation dates, **When** the user filters by a date
   or date range, **Then** only notes created in that selection are displayed.
4. **Given** saved notes contain different titles, subtitles, or content, **When** the user
   enters text in the filter, **Then** notes matching any of those text fields are displayed.
5. **Given** both text and date criteria are active, **When** the user filters the collection,
   **Then** only notes matching both criteria are displayed.
6. **Given** no filter criteria are active, **When** the user views the collection, **Then**
   all locally saved notes are displayed.

### Edge Cases

- A note containing leading or trailing whitespace MUST be handled consistently; validation
  MUST not treat whitespace-only content as valid.
- A note containing valid text surrounded by whitespace MUST NOT be silently reported as
  failed solely because of the surrounding whitespace.
- Opening the notes view before any note has been saved MUST produce the empty state, not
  an exception or an empty-looking failure state.
- A persistence failure MUST leave the user able to retry or continue viewing existing notes.
- A missing title or subtitle MUST NOT prevent saving a note when content is valid.
- A date filter MUST use the note creation date and MUST behave consistently at date
  boundaries in the device's local timezone.
- Clearing filter criteria MUST restore the complete local collection.
- Reopening after a successful save MUST not lose the saved note because the device is offline.
- The feature MUST NOT create duplicate visible notes merely because the notes view is opened
  or refreshed.

## Requirements *(mandatory)*

### Functional Requirements

- **REQ-001**: The application MUST allow a user to enter text for a new sticky note.
- **REQ-002**: The application MUST reject note content that is empty or contains only
  whitespace.
- **REQ-003**: When note content is rejected, the application MUST show understandable
  validation feedback and MUST NOT persist the note.
- **REQ-004**: The application MUST allow a user to confirm creation of a note containing
  at least one non-whitespace character.
- **REQ-005**: A successfully created note MUST appear in the notes list after creation.
- **REQ-006**: The application MUST persist successfully created notes locally so they remain
  available after the application is closed and reopened.
- **REQ-007**: The application MUST allow users to create and view notes without Internet
  access.
- **REQ-008**: The notes view MUST display every locally saved note available to the feature.
- **REQ-009**: When no notes exist, the application MUST display a clear empty-state message
  and MUST NOT treat the empty collection as an error.
- **REQ-010**: If local saving fails, the application MUST show understandable error feedback,
  MUST NOT report success, and MUST preserve access to existing notes.
- **REQ-011**: The feature MUST remain limited to creating and viewing notes and MUST NOT
  introduce editing, deletion, searching, pinning, colors, reminders, tasks, authentication,
  remote synchronization, or unrelated behavior.
- **REQ-012**: The feature MUST NOT log note content, credentials, or other sensitive data.
- **REQ-013**: The implementation MUST preserve the approved project architecture and MUST
  keep note business rules independent of presentation and external services.
- **REQ-014**: The application MUST assign and persist a creation timestamp when a note is
  created.
- **REQ-015**: The application MUST allow title and subtitle to be omitted while requiring
  non-whitespace content.
- **REQ-016**: The notes view MUST display the localized creation date for each note.
- **REQ-017**: The application MUST provide a reusable filtering function independent of
  Sticky Notes that can filter items by text and/or creation date.
- **REQ-018**: The notes view MUST allow filtering by text across title, subtitle, and content.
- **REQ-019**: The notes view MUST allow filtering by a creation date or date range.
- **REQ-020**: When text and date filters are both active, the application MUST display only
  notes matching both criteria.
- **REQ-021**: Clearing all filter criteria MUST restore every locally saved note.
- **REQ-022**: Date filtering MUST NOT allow dates later than the current local calendar date.
- **REQ-023**: A note editor MUST provide a freehand drawing canvas with local stroke persistence.
- **REQ-024**: The drawing canvas MUST provide an erase mode and a clear-drawing action.
- **REQ-025**: Note presentation MUST use post-it-style cards with visual hierarchy beyond plain
  list rows while preserving readable content and localized dates.
- **REQ-026**: The application MUST provide a Home entry point with navigation to Sticky Notes
  and clearly marked placeholders for future features.
- **REQ-027**: Home navigation MUST use a bottom navigation structure and keep feature state
  behind the existing Provider/MVVM boundaries.

### Security & Privacy Considerations

- **SP-001**: Authentication and account isolation are out of scope because this feature
  does not introduce user accounts.
- **SP-002**: The feature MUST NOT introduce Firebase Authentication, Firestore, a remote
  database, or synchronization.
- **SP-003**: Note content MUST NOT be written to logs, diagnostics, analytics, or error
  messages beyond what is necessary to identify a failure without exposing the content.
- **SP-004**: Secrets, credentials, private keys, and generated local databases MUST NOT be
  committed to the repository.
- **SP-005**: The reusable filtering capability MUST not log or transmit note content.
- **SP-006**: Drawing data MUST remain local and MUST NOT be logged or transmitted.

### Key Entities

- **Sticky Note**: A locally saved piece of user-entered text that can be displayed after
  creation and after an application restart. Its content MUST contain at least one
  non-whitespace character.
- **Notes Collection**: The locally available set of sticky notes displayed by the notes view.
  It can be empty and MUST have an explicit empty-state presentation.
- **Search Filter**: A reusable text/date criteria object and filtering operation that can be
  applied to different feature entities through field and date selectors.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In acceptance testing, 100% of valid-note attempts create a note that appears
  in the list without requiring Internet access.
- **SC-002**: In acceptance testing, 100% of empty and whitespace-only attempts are rejected,
  show validation feedback, and create no note.
- **SC-003**: In acceptance testing, 100% of successfully saved notes remain available after
  closing and reopening the application while offline.
- **SC-004**: In acceptance testing, 100% of simulated save failures show an error state,
  do not show success, and leave previously saved notes viewable.
- **SC-005**: Users can determine whether notes exist from the notes view in one interaction
  or less, including when the collection is empty.
- **SC-006**: The feature introduces zero remote-service, authentication, or synchronization
  dependencies.
- **SC-007**: Users can find a matching note using text and/or creation date filters in one
  interaction after entering criteria.
- **SC-008**: 100% of saved notes display a localized creation date and retain it after restart.
- **SC-009**: Future dates are never offered by the date filter.
- **SC-010**: A saved drawing reappears after reopening the local store.
- **SC-011**: Home reaches Sticky Notes in one bottom-navigation interaction.

## Assumptions

- The feature has a single local notes collection because authentication and multiple-user
  separation are explicitly out of scope.
- Local persistence is available to the application through a mechanism selected during
  planning; this specification does not prescribe its technical implementation.
- The application can be closed and reopened in the acceptance environment to verify
  persistence.
- The user can retry after a save failure, while previously saved notes remain readable.
- Ordering of notes is not a product requirement for this feature and will be defined during
  planning only if the existing application requires a deterministic order.
