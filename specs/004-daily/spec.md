# Feature Specification: Daily Activities

**Feature Branch**: `004-daily`  
**Created**: 2026-11-01  
**Status**: Implemented
**Input**: Daymark Daily feature request

## Scope and Boundaries

### In scope

- Creating, viewing, editing, and deleting recurring daily activities.
- Marking an activity complete or incomplete for the current calendar date.
- Persisting completion history without duplicating the recurring activity for each day.
- Two scheduling modes: Anytime and Specific time.
- Optional local notifications only for Specific time activities.
- User-selectable activity icons persisted with each activity.
- A responsive Daily activity list and rounded create/edit dialog with accessible
  icon, schedule, reminder, completion, and delete controls.
- A reusable, feature-independent notification service and observer/event mechanism.
- English and Spanish localization for every user-facing Daily and notification string.
- Integration with the existing MVVM, Provider/ChangeNotifier, Drift/SQLite,
  offline-first, theme, navigation, and localization conventions.
- Explicit handling of notification permission denial and unavailable platform support.

### Out of scope

- Firebase, authentication, accounts, cloud synchronization, or remote notifications.
- Weekly/custom recurrence, one-off tasks, reminders unrelated to Daily, snoozing,
  notification actions, or notification history.
- Replacing or changing the existing Sticky Notes schema or behavior.
- A background server or a guarantee that notifications fire when the OS restricts
  background alarms.
- Automatic migration of arbitrary external task data.

### Dependencies and prerequisites

- Existing local Drift database and migration strategy in
  [`lib/features/sticky_notes/data/local/app_database.dart`](../../lib/features/sticky_notes/data/local/app_database.dart).
- Existing `HomeShell`, theme tokens, Provider/ChangeNotifier patterns, and JSON
  localization.
- A notification plugin must be selected and approved during implementation planning;
  this specification recommends `flutter_local_notifications` with `timezone` for
  timezone-aware scheduled local notifications.
- Android notification permission and exact-alarm policy must be handled explicitly;
  a denied or unavailable notification capability must never prevent activity CRUD or
  completion tracking.

## User Stories and Acceptance Scenarios

### User Story 1 - Create and view daily activities (Priority: P1)

As a Daymark user, I want to create activities I intend to do every day and see them
in one list.

**Independent Test**: Start with an empty local Daily collection, create Anytime and
Specific time activities, reopen the Daily view, and verify both entries and their
schedule labels.

**Acceptance Scenarios**

1. **Given** no Daily activities exist, **when** the user opens Daily, **then** a
   localized empty state and Add Activity action are shown.
2. **Given** a valid activity name, **when** the user saves it as Anytime, **then**
   it is persisted and displayed without a scheduled time or notification control.
3. **Given** a valid activity name and time, **when** the user saves it as Specific
   time, **then** the configured time and compact reminder state are displayed.
4. **Given** an activity icon is selected, **when** the user saves or reopens the
   activity, **then** the selected icon is preserved.
5. **Given** the device is offline, **when** the user creates or views activities,
   **then** all local CRUD behavior remains available.

### User Story 2 - Edit and delete activities (Priority: P1)

As a Daymark user, I want to maintain my recurring activity list as my routine changes.

**Independent Test**: Create an activity, edit its name/schedule/notification choice,
delete it, and verify the resulting local collection and notification operations.

**Acceptance Scenarios**

1. **Given** an existing activity, **when** the user edits its name or schedule,
   **then** the updated values are persisted and displayed.
2. **Given** an activity with a pending notification, **when** its time changes,
   **then** the old notification is cancelled before the new schedule is applied.
3. **Given** an activity with a pending notification, **when** the activity is
   deleted, **then** its notification is cancelled and the activity disappears.
4. **Given** an Anytime activity, **when** it is edited, **then** notification
   controls remain unavailable until Specific time is selected.
5. **Given** an existing activity, **when** the user changes its icon and saves,
   **then** the new icon is persisted and displayed.

### User Story 3 - Track completion by calendar date (Priority: P1)

As a Daymark user, I want completion to describe today without erasing previous days.

**Independent Test**: Complete an activity on one local date, change the injected
calendar date, verify it is incomplete for the new date, then return to the original
date and verify the original completion remains.

**Acceptance Scenarios**

1. **Given** an incomplete activity today, **when** the user marks it complete, **then**
   a completion record for today's local calendar date is persisted.
2. **Given** an activity completed today, **when** the user unmarks it, **then** only
   today's completion record is removed or marked incomplete.
3. **Given** a completion from a previous date, **when** a new local date begins,
   **then** the activity appears incomplete until completed on that date.
4. **Given** an activity has completion history, **when** the user views it, **then**
   the recurring activity remains one activity and history is not copied into activity
   rows.
5. **Given** a device crosses daylight-saving or timezone boundaries, **when** today's
   state is evaluated, **then** the injected/local calendar date determines the key,
   not a fixed 24-hour duration calculation.

### User Story 4 - Configure optional notifications (Priority: P1)

As a Daymark user, I want a local notification at a chosen activity time without
being forced to use notifications.

**Independent Test**: Exercise permission granted, denied, unavailable, enabled,
disabled, changed-time, deleted, and Anytime paths using a fake notification service.

**Acceptance Scenarios**

1. **Given** a Specific time activity and notification permission is available,
   **when** the user enables notifications, **then** one uniquely identified local
   notification schedule is created.
2. **Given** a Specific time activity, **when** the user disables notifications,
   **then** its pending notification is cancelled and the activity remains scheduled.
3. **Given** a Specific time activity with notifications enabled, **when** its time
   changes, **then** the existing schedule is replaced with the new time.
4. **Given** an Anytime activity, **when** the user views or edits it, **then**
   notification enablement is unavailable and no notification is scheduled.
5. **Given** permission is denied or notifications are unavailable, **when** the user
   enables notifications, **then** the app explains the limitation, stores no false
   enabled state, and keeps CRUD/completion usable.
6. **Given** a notification is scheduled for a time that has passed today, **when**
   scheduling occurs, **then** the service applies the documented next-occurrence
   policy rather than silently creating an immediately stale alarm.

### User Story 5 - Use a consistent Daily experience (Priority: P1)

As a Daymark user, I want Daily to look and behave like the rest of the app in either
supported language and across all configured appearances.

**Independent Test**: Render Daily under all 18 style/palette combinations and both
locales, then inspect labels, contrast, semantics, and touch targets.

**Acceptance Scenarios**

1. **Given** any supported style and palette, **when** Daily renders, **then** it uses
   centralized theme data without a Daily-specific color map.
2. **Given** English or Spanish is active, **when** Daily renders, **then** every
   user-facing string is localized.
3. **Given** an activity is completed, **when** it is displayed, **then** completion
   is conveyed by more than color alone and the toggle has an accessible state label.
4. **Given** a narrow or large display, **when** the list and editor render, **then**
   controls remain usable without clipping or inaccessible overflow.
5. **Given** the activity editor is open with limited vertical space or the keyboard
   visible, **when** the user scrolls the form, **then** all fields and actions remain
   reachable without a layout overflow.
6. **Given** a selected activity icon, **when** the icon grid renders, **then** the
   selected icon has a subtle theme-based surface and clear selection border while
   unselected icons avoid strong filled backgrounds.

## Functional Requirements

- **REQ-001**: The system MUST provide Daily CRUD for recurring activities with a
  non-empty, non-whitespace name.
- **REQ-002**: Each activity MUST have exactly one scheduling mode: Anytime or Specific
  time; Specific time MUST store local wall-clock hour and minute.
- **REQ-003**: Anytime activities MUST NOT expose or schedule notifications.
- **REQ-004**: Specific time activities MUST display their configured time and MAY have
  notifications enabled or disabled independently.
- **REQ-004a**: Each activity MUST preserve a user-selected `iconKey` from the
  `DailyActivityIcons` catalog; unknown keys MUST fall back safely to the default icon.
- **REQ-005**: Editing a scheduled activity MUST update its persisted values and
  notification schedule consistently.
- **REQ-006**: Deleting an activity MUST remove it and cancel its notification, if any.
- **REQ-007**: Completion MUST be keyed by the activity identifier and a local calendar
  date, and MUST support complete/uncomplete for today.
- **REQ-008**: Completion history MUST remain available across dates without duplicating
  recurring activity records.
- **REQ-009**: Date comparisons MUST use calendar components in the chosen local
  timezone, not elapsed 24-hour durations.
- **REQ-010**: Daily persistence MUST use the existing Drift/SQLite boundary and remain
  usable offline.
- **REQ-011**: Notification platform access MUST be isolated behind a reusable global
  service interface independent of Daily and Flutter widgets.
- **REQ-012**: The notification architecture MUST provide scheduling, replacement,
  cancellation, stable per-notification identifiers, and availability/permission
  results.
- **REQ-013**: Features MUST communicate notification changes through a small reusable
  observer/event mechanism and MUST NOT depend directly on plugin APIs.
- **REQ-014**: Notification permission denial, unsupported platform, initialization
  failure, and scheduling failure MUST be explicit recoverable states, never false
  success.
- **REQ-015**: Notification state MUST never block activity CRUD or completion tracking.
- **REQ-016**: Every new user-facing string MUST exist in English and Spanish resources.
- **REQ-017**: Daily MUST use existing MVVM, Provider/ChangeNotifier, repositories,
  centralized theme tokens, and accessible Material controls.
- **REQ-017a**: Daily activity cards MUST use a consistent responsive layout with the
  selected icon, prominent title, compact schedule/reminder metadata, edit control,
  and completion control aligned in one row.
- **REQ-017b**: The create/edit form MUST use a scrollable rounded dialog, responsive
  icon grid, segmented schedule selector, conditional reminder section, and separate
  primary, secondary, and destructive actions without hardcoded colors.
- **REQ-018**: Daily MUST preserve existing Sticky Notes behavior and MUST NOT alter
  existing Notes columns or semantics.
- **REQ-019**: The implementation MUST include tests for domain rules, persistence,
  completion dates, notification orchestration, localization, themes, accessibility,
  and existing-feature regression.

## Non-Functional Requirements

- **NFR-001 Reliability**: CRUD and completion operations must be deterministic and
  recoverable after local database or notification failures.
- **NFR-002 Privacy**: Activity names, schedules, and completion data stay local; logs
  must not include activity content or notification payloads.
- **NFR-003 Accessibility**: Completion state must have semantic labels, controls must
  meet platform touch-target guidance, and color must not be the only state signal.
- **NFR-004 Performance**: Daily list rendering and today's completion lookup must be
  local and bounded by indexed activity/completion queries.
- **NFR-005 Reproducibility**: Notification identifiers and scheduling rules must be
  deterministic from the activity identifier.
- **NFR-006 Compatibility**: Unsupported notification capabilities degrade to a clear
  in-app state without reducing offline Daily functionality.

## Data Model Considerations

Use two new tables in a later implementation migration; do not modify `Notes`.

### `DailyActivities`

- `id`: integer primary key.
- `name`: required text.
- `scheduleMode`: enum serialized as a stable string (`anytime` or `specificTime`).
- `scheduledHour`: nullable integer 0–23; required only for Specific time.
- `scheduledMinute`: nullable integer 0–59; required only for Specific time.
- `notificationsEnabled`: boolean; always false for Anytime.
- `iconKey`: required stable key from `DailyActivityIcons`; defaults to `repeat` for
  records created before icon selection was introduced.
- `createdAt`, `updatedAt`: local timestamps for deterministic ordering/auditing.

### `DailyCompletions`

- `activityId`: foreign key to `DailyActivities`.
- `localDate`: canonical `YYYY-MM-DD` string produced by a local calendar service.
- `completedAt`: optional local timestamp for audit/display if needed.
- Unique key `(activityId, localDate)`.

The ViewModel should query today's completion set using an injected clock/calendar
service. A date-only key avoids DST errors caused by subtracting fixed 24-hour
durations. Deleting an activity must cascade or explicitly delete its completions.
Notification records are not a source of truth; persisted activity notification state
and deterministic IDs are.

## Notification Architecture

### Responsibilities

- `NotificationService`: global platform-facing interface for permission status/request,
  availability, schedule/replace, and cancel. It returns typed outcomes.
- `PlatformNotificationService`: adapter around the selected Flutter plugin. Only this
  adapter imports plugin APIs.
- `NotificationEventBus`: small synchronous/asynchronous observer mechanism carrying
  typed events such as `NotificationScheduleRequested`,
  `NotificationCancellationRequested`, and result events.
- `DailyNotificationCoordinator`: feature adapter that translates Daily activity
  changes into notification events and updates Daily presentation state. It knows
  Daily rules but not platform/plugin types.
- `NotificationId`: stable identifier derived from a namespace and activity ID, so
  Daily operations cannot cancel another feature's notification.

The observer mechanism is intentionally narrow: typed event subscription and disposal,
not a general application event bus. Event delivery must not hide failures; scheduling
results are returned to the coordinator and surfaced to the user when needed. Daily
must schedule at most one notification per activity. Future features reuse the same
service/event contracts with their own namespace and coordinator.

### Permission and availability policy

1. Initialize the service during the approved local startup seam, without blocking the
   first usable Daily screen indefinitely.
2. Check platform availability before showing notification controls as enabled.
3. Request permission in context when the user explicitly enables a notification.
4. If denied, leave `notificationsEnabled` false, explain how to retry/settings-enable
   permission where supported, and preserve the activity's Specific time.
5. If unavailable, show an unavailable state and preserve all non-notification behavior.
6. If a replacement or cancellation fails, surface an error and retain a retryable
   notification state; do not claim the schedule changed.

## Edge Cases

- Blank or whitespace-only names are rejected without a database write.
- A Specific time must have both hour and minute; Anytime must have neither.
- Switching Specific time to Anytime disables notifications and cancels any pending ID.
- Switching Anytime to Specific time starts with notifications disabled.
- Changing the time while notifications are disabled must not schedule a notification.
- Changing the time while enabled must cancel/replace atomically from the user's
  perspective and recover if either platform call fails.
- Deleting an activity with no notification must still delete its completions.
- Repeated complete/uncomplete actions must be idempotent.
- A completion record for yesterday must not make today's activity appear complete.
- A local date change at midnight, DST transition, or timezone change must use the
  current injected calendar policy.
- Permission denial, plugin initialization failure, unsupported platform, and OS-level
  alarm restrictions must not prevent local activity use.
- Notification IDs must not collide across activities or future feature namespaces.
- App reinstall/OS data clearing may remove local state; this is outside persistence
  guarantees and must not be represented as successful synchronization.
- Very long names must remain readable and not break list layout.

## Testing Strategy

- Domain tests: validation, schedule invariants, notification eligibility, stable IDs.
- Repository tests: CRUD, migration, completion uniqueness, date isolation, delete
  cleanup, reopened local database, and offline behavior.
- ViewModel tests: idle/loading/success/error/retry transitions, completion toggles,
  notification result handling, and no false success.
- Notification tests: fake service/event bus for permission granted/denied/unavailable,
  schedule/replace/cancel ordering, ID isolation, and disposal.
- Widget tests: empty/list/editor states, schedule controls, notification affordances,
  completion semantics, localized strings, all 18 theme combinations, narrow layouts,
  and interaction/error feedback.
- Regression tests: existing Sticky Notes, settings, navigation, and localization suite.
- Validation commands for implementation: `dart format`, `flutter analyze`, focused
  `flutter test`, and full `flutter test`. Android build/emulator work is explicitly
  manual and outside this planning task; no Android debug build is to be run by the
  assistant.

## Technical Questions Resolved

- **Where should recurring completion live?** A separate completion table keyed by
  activity and date; duplicating activities per day was rejected.
- **How should dates be represented?** A canonical local date key plus injected clock/
  calendar, not UTC midnight or elapsed-duration arithmetic.
- **Where should platform notifications live?** A global service adapter and narrow
  observer events under `lib/core/notifications/`; Daily owns only translation and
  policy.
- **What happens when notifications fail?** The activity remains usable and scheduled
  time is retained; notification state reports a recoverable error.
- **Which package is recommended?** Research supports evaluating
  [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)
  with [`timezone`](https://pub.dev/packages/timezone); package addition is deferred
  to implementation approval and compatibility verification.

## Measurable Success Criteria

- **SC-001**: A user can create, edit, delete, and reopen Anytime and Specific time
  activities locally.
- **SC-002**: Completion toggles persist independently for at least two injected dates.
- **SC-003**: Anytime never schedules a notification; Specific time can schedule,
  replace, and cancel one notification by stable ID.
- **SC-004**: Permission denied/unavailable paths preserve CRUD and show recoverable,
  localized feedback without false enabled state.
- **SC-005**: All Daily user-facing strings render in English and Spanish.
- **SC-006**: Daily passes all 18 style/palette combinations and accessibility checks.
- **SC-007**: Sticky Notes and existing migrations remain green with no Notes changes.
- **SC-008**: No Firebase, remote backend, cloud sync, or assistant-run Android debug
  build is introduced or performed.
