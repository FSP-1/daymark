# Feature 008 — Goals and Customizable Navigation

## Objective

Implement a personal goal management feature in Daymark that allows users to define objectives, track their progress, complete milestones and associate deadlines with the existing Calendar feature.

Additionally, introduce a customizable bottom navigation system that allows users to choose which features appear as shortcuts while keeping all available features accessible from Home.

Respect the existing project constitution, MVVM architecture, SDD and TDD workflows, local persistence, localization system, visual styles and color palettes.

## User Story 1 — Manage personal goals (P1)

As a user, I want to create personal goals so that I can organize and track the things I want to achieve.

Acceptance scenarios:

- Users can create, open, edit and delete goals.
- Each goal requires a non-empty title.
- Goals support an optional description, category, icon and color.
- Goals support a start date and an optional target date.
- The target date cannot precede the start date.
- Users can create goals without deadlines.
- Goals are persisted locally.
- Deleting a goal requires confirmation.
- Cancelling creation or editing does not persist unsaved changes.

## User Story 2 — Track goal progress (P1)

As a user, I want different progress tracking methods depending on the type of goal.

Supported tracking methods:

1. Checklist: progress calculated from completed milestones.
2. Counter: progress calculated from a current numeric value and target value.
3. Manual: progress controlled directly through a percentage.

Acceptance scenarios:

- Users select a tracking method when creating a goal.
- Checklist goals support creating, editing, deleting, reordering and completing milestones.
- Counter goals support incrementing, decrementing and directly editing their current value.
- Counter goals require a positive target value.
- Counter goals support an optional unit, such as books, kilometers or hours.
- Manual goals support values between 0 and 100 percent.
- Progress is calculated automatically for checklist and counter goals.
- Progress is constrained between 0 and 100 percent.
- Empty checklists display zero percent progress.
- Reaching 100 percent marks the goal as completed.
- Reducing progress below 100 percent reopens the goal.
- Switching tracking methods requires confirmation if existing progress data would be lost.

## User Story 3 — Consult goals (P1)

As a user, I want to see my goals and understand my overall progress.

Acceptance scenarios:

- The Goals page displays total, active and completed goal counts.
- Users can filter goals by All, Active and Completed.
- Goal cards display the title, icon, category, progress bar and percentage.
- Goal cards display deadlines when available.
- Overdue active goals display a subtle localized indicator.
- Completed goals remain accessible.
- Selecting a goal opens its detail screen.
- Progress updates are immediately reflected in the list.
- Loading, empty and error states are provided.

## User Story 4 — Goal details (P1)

As a user, I want to open a goal and manage its individual progress.

Acceptance scenarios:

- The detail screen displays the goal title, description, category and dates.
- The detail screen displays the current progress.
- Checklist goals display interactive milestones.
- Counter goals display the current value, target value and increment/decrement actions.
- Manual goals display a percentage slider.
- Users can edit goal metadata.
- Users can delete the goal.
- Returning to the Goals page preserves the selected filter.

## User Story 5 — Calendar integration (P1)

As a user, I want to see goal deadlines in Calendar so that I can organize my time.

Acceptance scenarios:

- Goals with target dates appear on their associated calendar dates.
- Calendar displays a distinct indicator for Goals.
- Selecting a goal from Calendar opens its detail screen.
- Changing a goal deadline updates its associated calendar date.
- Removing a deadline removes the goal from Calendar.
- Deleting a goal removes its calendar representation.
- Completed goals remain visible on their associated dates.
- Goals without deadlines do not appear in Calendar.
- Goals can have future target dates.
- Calendar does not duplicate goal data.

## User Story 6 — Centralized Home feature grid (P1)

As a user, I want to access every available feature from Home.

Acceptance scenarios:

- Home displays all registered Daymark features.
- Sticky Notes, Daily, Journal, Calendar and Goals are accessible from Home.
- Home cards remain visible regardless of bottom navigation preferences.
- Every feature card opens its corresponding screen.
- Settings is accessible through a dedicated icon in the Home header.
- Existing compact feature card styling is preserved.
- Adding a new feature requires registering it in a centralized feature registry.
- Home and bottom navigation consume the same feature registry.

## User Story 7 — Customize bottom navigation (P1)

As a user, I want to choose which features appear in the bottom navigation bar.

Acceptance scenarios:

- Settings contains a Navigation section.
- Home is permanently visible as the first destination.
- Users can select up to four additional feature destinations.
- Users can deselect optional destinations.
- Users can reorder selected destinations.
- The navigation preview updates immediately.
- The actual bottom navigation updates immediately.
- Navigation preferences persist across application restarts.
- Users can restore the default navigation configuration.
- Hiding a destination does not delete its data or disable its functionality.
- Hidden destinations remain accessible from Home.
- Unknown or removed feature identifiers are ignored safely.
- Existing users receive a valid default navigation configuration.
- Navigation remains functional when only Home is selected.

## User Story 8 — Open hidden features (P1)

As a user, I want to access a feature even if it is not pinned to the bottom navigation bar.

Acceptance scenarios:

- Selecting a pinned feature from Home activates its corresponding navigation destination.
- Selecting an unpinned feature from Home opens its screen through the Navigator.
- Unpinned features provide normal back navigation.
- Returning from an unpinned feature restores the Home screen.
- Existing feature providers and repositories are reused.
- Opening an unpinned feature does not modify navigation preferences.
- Navigation uses stable feature identifiers rather than hardcoded indexes.
- Removing the currently selected navigation destination safely returns the user to Home.

## Functional requirements

- FR-001: Provide a dedicated Goals feature.
- FR-002: Support goal CRUD operations.
- FR-003: Support checklist, counter and manual tracking methods.
- FR-004: Support goal milestones.
- FR-005: Calculate progress according to the selected tracking method.
- FR-006: Automatically derive completion status from progress.
- FR-007: Support optional goal deadlines.
- FR-008: Support goal icons, colors and categories.
- FR-009: Provide goal filters and summary statistics.
- FR-010: Display overdue active goals.
- FR-011: Integrate goal deadlines with Calendar.
- FR-012: Provide a reusable goal detail screen.
- FR-013: Display all available features on Home.
- FR-014: Introduce a centralized feature registry.
- FR-015: Replace hardcoded navigation indexes with stable feature identifiers.
- FR-016: Keep Home permanently available.
- FR-017: Support up to four optional bottom navigation destinations.
- FR-018: Allow destination visibility customization.
- FR-019: Allow destination reordering.
- FR-020: Persist navigation preferences locally.
- FR-021: Provide a navigation preview.
- FR-022: Provide default navigation restoration.
- FR-023: Support opening features that are not pinned.
- FR-024: Preserve existing user data and feature functionality.
- FR-025: Support Spanish and English localization.
- FR-026: Respect existing visual styles and color palettes.
- FR-027: Provide responsive layouts without overflow.
- FR-028: Preserve navigation and feature state when possible.
- FR-029: Use the existing local database and settings persistence mechanisms.

## Data requirements

Goal entity:

- id
- title
- description
- category
- iconId
- color
- trackingType
- startDate
- targetDate
- targetValue
- currentValue
- unit
- manualProgress
- createdAt
- updatedAt
- completedAt

Goal milestone entity:

- id
- goalId
- title
- isCompleted
- sortOrder
- createdAt
- completedAt

Navigation preferences:

- Ordered list of visible optional feature identifiers.

Home must not be stored as an optional destination.

Use stable string identifiers for features, icons and tracking types.

Goal progress must be derived from the tracking method rather than maintaining conflicting progress values.

Persist goals and milestones using Drift with non-destructive migrations.

Reuse the existing settings persistence mechanism for navigation preferences.

Deleting a goal must also remove its associated milestones.

## UI requirements

Goals overview:

- Editorial header with title and subtitle.
- Compact summary of total, active and completed goals.
- Segmented filter control.
- Compact goal cards.
- Progress bars and percentages.
- New Goal action.

Goal detail:

- Title and goal metadata.
- Prominent progress indicator.
- Tracking-method-specific controls.
- Milestone list when applicable.
- Edit and delete actions.

Goal editor:

- Title and description.
- Category selection.
- Icon and color selection.
- Start date and optional deadline.
- Tracking method selector.
- Conditional fields based on the tracking method.

Navigation settings:

- Permanent Home destination.
- List of available optional destinations.
- Visibility controls.
- Reordering controls.
- Maximum selection indicator.
- Live bottom navigation preview.
- Restore defaults action.

All screens must use theme-aware design tokens and support the existing visual style system, including Retro and other alternative styles.

Avoid oversized cards, excessive vertical spacing, hardcoded palette colors and fixed-width layouts.

## Architecture constraints

- Preserve MVVM architecture.
- Use Provider and ChangeNotifier consistently.
- Separate domain, data and presentation responsibilities.
- Keep widgets modular.
- Do not duplicate feature repositories or CRUD logic.
- Reuse existing providers when opening pinned or unpinned features.
- Introduce a centralized feature registry.
- Use stable feature identifiers instead of numeric navigation indexes.
- Avoid unnecessary dependencies.
- Do not introduce authentication, Firebase or cloud synchronization.
- Preserve all existing application features.

## Testing requirements

Unit tests:

- Goal validation.
- Checklist progress calculation.
- Empty checklist progress.
- Counter progress calculation.
- Manual progress validation.
- Completion and reopening behavior.
- Deadline validation.
- Overdue status calculation.
- Navigation preference validation.
- Maximum destination count.
- Destination reordering.
- Unknown feature identifiers.
- Default navigation restoration.

Repository tests:

- Goal CRUD.
- Milestone CRUD.
- Cascading milestone deletion.
- Database migration.
- Calendar integration.
- Navigation preference persistence.

Widget tests:

- Goals list and filters.
- Goal creation and editing.
- Milestone completion.
- Counter controls.
- Manual progress slider.
- Navigation settings.
- Live navigation updates.
- Opening hidden features from Home.
- Removing the active destination.
- Navigation with only Home.
- Responsive layouts.
- Localization and visual style compatibility.

## Success criteria

- Users can create and manage goals using all three tracking methods.
- Progress and completion states remain consistent.
- Goal deadlines appear in Calendar.
- All registered features remain accessible from Home.
- Users can customize and reorder bottom navigation destinations.
- Navigation preferences survive application restarts.
- Hiding a feature does not affect its stored data.
- Existing features continue to work without regressions.
- No layout overflow occurs on supported screen sizes.
- Flutter analysis and automated tests pass.

## Out of scope

- Social goal sharing.
- Collaborative goals.
- Cloud synchronization.
- AI-generated goals.
- Goal-specific notification scheduling.
- Automatic progress synchronization with Daily activities.
- Financial goal tracking integrations.
