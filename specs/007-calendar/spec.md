# Feature 007 — Calendar

## Objective

Implement a calendar feature in Daymark that provides a centralized chronological view of the user's content, integrating Sticky Notes and Journal entries through their associated dates.

The calendar must allow users to navigate through the year, select individual dates, inspect existing content, open existing entries, and create new content associated with a selected date.

The implementation must respect the existing project constitution, MVVM architecture, SDD and TDD workflows, localization system, visual styles and color palettes.

## User Story 1 — Calendar navigation (P1)

As a user, I want to navigate through a calendar so that I can explore my content chronologically.

Acceptance scenarios:

- When opening Calendar, the current month and current year are displayed.
- Today's date is highlighted.
- Today is selected by default on initial access.
- The user can navigate to previous and subsequent months.
- The user can navigate to previous and subsequent years.
- The user can switch between monthly and annual views.
- Selecting a month in the annual view opens that month.
- A Today action returns the calendar to the current date.
- Month lengths, leap years and year transitions are handled correctly.
- Weekday names and date formats respect the active application locale.

## User Story 2 — Consult daily content (P1)

As a user, I want to select a day and see all content associated with it.

Acceptance scenarios:

- Selecting a day updates the daily content section.
- Notes associated with the selected date are displayed.
- Journal entries associated with the selected date are displayed.
- Each content item displays its type, title and a short preview.
- Days containing content display small visual indicators.
- Notes and Journal entries use distinguishable indicators.
- Multiple entries on the same date are supported.
- Empty dates display a localized empty state.
- Content changes are reflected immediately after creation, editing or deletion.

## User Story 3 — Create notes from Calendar (P1)

As a user, I want to create a note for any selected date.

Acceptance scenarios:

- The user can create notes for past, present and future dates.
- Selecting Add Note opens the existing Sticky Notes editor.
- The selected calendar date is automatically assigned to the new note.
- Saving the note updates both Calendar and Sticky Notes.
- Cancelling the editor does not create a note.
- Existing notes can optionally be assigned a calendar date.
- Users can modify or remove the associated date.
- Notes without an associated date remain accessible from Sticky Notes.

## User Story 4 — Create Journal entries from Calendar (P1)

As a user, I want to write Journal entries associated with today or previous dates.

Acceptance scenarios:

- Selecting Write Journal opens the existing Journal editor.
- The selected calendar date is automatically assigned to entryDate.
- Today and past dates are valid.
- Future dates are invalid.
- The Write Journal action is disabled when a future date is selected.
- A localized explanation describes why the action is unavailable.
- The Journal date picker does not allow future dates.
- Journal validation rejects future dates even when the editor is opened outside Calendar.
- Saving an entry refreshes Calendar and Journal.
- Existing drawing functionality remains available.

## User Story 5 — Open existing content (P1)

As a user, I want to open content directly from Calendar without searching for it in another feature.

Acceptance scenarios:

- Selecting a note opens its existing editor or detail view.
- Selecting a Journal entry opens its existing reading page.
- Existing editing and deletion functionality is preserved.
- Returning from a content screen preserves the selected calendar date and displayed month.
- Moving an item's associated date removes it from the previous day and displays it on the new day.
- Deleted items disappear from Calendar.

## User Story 6 — Annual overview (P2)

As a user, I want to see the twelve months of a year to navigate quickly between them.

Acceptance scenarios:

- The annual view displays twelve month cards.
- Each card contains a compact representation of its month.
- The current month is visually distinguishable.
- Months containing content display subtle indicators.
- Selecting a month opens the monthly view.
- Annual navigation supports previous and subsequent years.
- The layout adapts to mobile, tablet and desktop widths.

## Functional Requirements

- FR-001: Provide a dedicated Calendar feature.
- FR-002: Support monthly and annual calendar views.
- FR-003: Support navigation between months and years.
- FR-004: Maintain the currently selected date.
- FR-005: Highlight today's date independently of the selected date.
- FR-006: Retrieve Sticky Notes associated with calendar dates.
- FR-007: Retrieve Journal entries using entryDate.
- FR-008: Display distinct content indicators for each supported content type.
- FR-009: Allow multiple content items per date.
- FR-010: Allow note creation on any supported date.
- FR-011: Allow Journal creation only on today or previous dates.
- FR-012: Enforce Journal date validation at the domain and persistence workflow levels.
- FR-013: Reuse existing Note and Journal editors.
- FR-014: Reuse existing Journal reading and drawing functionality.
- FR-015: Refresh calendar content after CRUD operations.
- FR-016: Preserve calendar navigation state when opening and closing content.
- FR-017: Support optional associated dates for Sticky Notes.
- FR-018: Preserve all existing user data during database migrations.
- FR-019: Support Spanish and English localization.
- FR-020: Respect all existing visual styles and color palettes.
- FR-021: Support responsive layouts without RenderFlex overflow.
- FR-022: Store all content locally using the existing Drift database.
- FR-023: Provide loading, empty and error states.
- FR-024: Integrate Calendar into HomeShell and the home feature grid.
- FR-025: Provide a Today navigation action.
- FR-026: Keep Calendar extensible for future content types.
- FR-027: Refresh date-dependent restrictions when the local day changes or the application resumes.

## Data requirements

Calendar must aggregate existing content instead of duplicating it.

Sticky Notes:

- Add an optional associated calendar date if an equivalent field does not already exist.
- Preserve existing notes through a non-destructive Drift migration.
- Do not automatically assign creation dates as associated calendar dates.
- Allow the associated date to be changed or removed.

Journal:

- Reuse the existing entryDate field.
- Reject new or modified future entry dates.
- Preserve existing entries and drawings.

Calendar dates represent local calendar days rather than UTC instants.

The implementation must distinguish associated dates from creation and modification timestamps.

## UI requirements

The Calendar interface must be simple, recognizable and visually consistent with Daymark.

Monthly view:

- Calendar header with title and description.
- Month/year navigation.
- Monthly and annual view selector.
- Seven-column weekday grid.
- Compact day cells with content indicators.
- Selected-day content section.
- Add Note and Write Journal actions.

Annual view:

- Twelve compact month cards.
- Responsive month grid.
- Current month highlight.
- Content indicators.
- Year navigation.

Daily content cards:

- Content type icon.
- Title.
- Short text preview.
- Optional drawing indicator.
- Navigation affordance.
- Consistent spacing and sizing.

Avoid large filled icon backgrounds, oversized cards, excessive vertical spacing and decorative elements that reduce usability.

Use theme-aware colors rather than hardcoded palette values.

## Architecture constraints

- Preserve MVVM architecture.
- Separate presentation, domain and data responsibilities.
- Keep Calendar widgets modular and reusable.
- Use Provider and ChangeNotifier consistently with existing features.
- Do not place repository or database queries inside UI widgets.
- Reuse existing repositories and editors.
- Refactor private editor widgets into reusable public components when necessary.
- Do not duplicate Note or Journal CRUD logic.
- Do not introduce Firebase, cloud synchronization or authentication.
- Do not add unnecessary third-party dependencies.

## Testing requirements

Create unit and widget tests covering:

- Calendar month generation.
- Leap years.
- Month and year transitions.
- Local date normalization.
- Today selection.
- Daily content filtering.
- Multiple content types on the same date.
- Note creation on future dates.
- Journal creation on past dates and today.
- Rejection of future Journal dates.
- Optional note date assignment and removal.
- Database migration preserving existing notes.
- Calendar refresh after editing and deleting content.
- Preservation of selected dates during navigation.
- Empty, loading and error states.
- Responsive layouts and long localized text.
- Compatibility with existing visual styles.

## Success criteria

- SC-001: Users can navigate between months and years without errors.
- SC-002: Selecting a date displays all associated supported content.
- SC-003: Notes can be created for past, present and future dates.
- SC-004: Future Journal entries cannot be created through any application entry point.
- SC-005: Existing content opens directly from Calendar.
- SC-006: No existing data is lost during database migration.
- SC-007: No duplicated Note or Journal business logic is introduced.
- SC-008: Calendar works with all existing visual styles and palettes.
- SC-009: No layout overflow occurs on supported screen sizes.
- SC-010: Flutter analysis and automated tests pass.

## Out of scope

- External calendar synchronization.
- Google Calendar integration.
- Cloud storage.
- Recurring calendar events.
- Drag-and-drop scheduling.
- New notification scheduling mechanisms.
