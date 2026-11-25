# Feature 009 — Focus and Pomodoro Timer

## Objective

Implement a Focus feature in Daymark that provides a customizable Pomodoro timer, concentration sessions, short and long breaks, activity tracking and historical statistics.

Focus must integrate with the existing Calendar, Goals, Daily, Home and customizable navigation systems.

The feature must respect the existing project constitution, MVVM architecture, SDD and TDD workflows, local persistence, localization, visual styles and color palettes.

## User Story 1 — Focus timer (P1)

As a user, I want to start a concentration timer so that I can focus on a specific activity without distractions.

Acceptance scenarios:

- The default concentration duration is 25 minutes.
- The timer displays remaining minutes and seconds.
- Users can start, pause, resume, reset and stop a session.
- Pausing freezes the remaining time.
- Resuming continues from the remaining time.
- Resetting restores the configured duration.
- Stopping an active session requires confirmation.
- Only one Focus timer can be active at a time.
- The timer remains active when navigating to other Daymark features.
- Returning to Focus restores the current timer state.
- The timer never displays negative remaining time.
- Completing a session records it exactly once.
- The screen displays the current session type and cycle progress.

## User Story 2 — Pomodoro cycles and breaks (P1)

As a user, I want to alternate concentration sessions with breaks.

Acceptance scenarios:

- Focus supports concentration, short break and long break modes.
- The default short break is five minutes.
- The default long break is fifteen minutes.
- A long break becomes available after four completed concentration sessions.
- The number of concentration sessions per cycle is configurable.
- Completing a concentration session selects the appropriate next break.
- Completing a break selects the next concentration session.
- Users can manually switch session modes when the timer is idle.
- Users can skip breaks.
- Skipped or interrupted concentration sessions do not increase the completed-session cycle counter.
- Automatic transitions are optional.
- The default behavior requires the user to start the next session manually.
- Automatic transitions must not generate unattended chains of historical sessions after application suspension.

## User Story 3 — Customize Focus settings (P1)

As a user, I want to personalize the timer according to my working preferences.

Acceptance scenarios:

- Concentration duration is configurable from 1 to 120 minutes.
- Short break duration is configurable from 1 to 30 minutes.
- Long break duration is configurable from 1 to 60 minutes.
- Sessions per cycle are configurable from 2 to 8.
- Users can enable or disable automatic break starts.
- Users can enable or disable automatic concentration starts.
- Users can enable or disable completion sounds.
- Users can enable or disable completion vibration.
- Settings persist across application restarts.
- Users can restore default settings.
- Changes to duration settings apply to subsequent sessions.
- Changing settings does not unexpectedly modify an active session.

## User Story 4 — Activities and session associations (P1)

As a user, I want to identify what I am concentrating on.

Acceptance scenarios:

- Users can start sessions without selecting an activity.
- Users can create reusable custom activities.
- Activities have a title, icon and optional color.
- Users can edit and archive custom activities.
- Users can associate a session with an existing Daily activity.
- Users can associate a session with an existing Goal.
- Associations are optional.
- Activity selection occurs before starting a session.
- Historical sessions retain their activity labels when the original activity is renamed or deleted.
- Archiving an activity does not delete historical sessions.
- Existing Daily activities are reused rather than duplicated.

## User Story 5 — Background timer and recovery (P1)

As a user, I want my timer to remain accurate when leaving the application or locking my phone.

Acceptance scenarios:

- The timer does not depend exclusively on periodic UI callbacks.
- Active session state is persisted locally.
- Running sessions store an absolute completion timestamp.
- Remaining time is recalculated when the application resumes.
- Paused sessions preserve their remaining duration.
- Active sessions can be recovered after process termination and application restart.
- A completed session is recorded exactly once after recovery.
- Background completion notifications are scheduled when supported.
- Pausing, resetting or stopping cancels pending completion notifications.
- Resuming schedules a new completion notification.
- Notification permissions are requested only when needed.
- Denying notification permissions does not prevent timer usage.
- Platform restrictions affecting notification delivery are handled gracefully.
- No permanent background execution is required solely to decrement the timer.
- Application lifecycle transitions must not create duplicate timers or sessions.

## User Story 6 — Session history (P1)

As a user, I want to consult my previous concentration sessions.

Acceptance scenarios:

- Completed concentration sessions appear in history.
- Interrupted sessions with recorded concentration time may also appear.
- Interrupted sessions are distinguishable from completed sessions.
- Break sessions are stored separately from concentration sessions.
- History displays the activity, date, duration and completion status.
- Users can filter history by date range and activity.
- Users can inspect individual session details.
- Users can delete individual sessions after confirmation.
- Resetting the timer does not delete previously saved history.
- Session duration excludes paused time.
- Historical records remain available offline.

## User Story 7 — Focus statistics (P1)

As a user, I want to understand how I spend my concentration time.

Acceptance scenarios:

- Display today's accumulated concentration time.
- Display today's completed concentration session count.
- Display today's accumulated break time.
- Display weekly and monthly concentration totals.
- Display concentration time grouped by activity.
- Display a weekly concentration bar chart.
- Users can switch between weekly and monthly statistics.
- Break time is excluded from concentration totals.
- Interrupted sessions contribute only their actual recorded concentration time.
- Sessions spanning midnight are attributed to the corresponding local calendar days.
- Statistics update after session creation or deletion.
- Empty statistics display meaningful zero states.

## User Story 8 — Calendar integration (P1)

As a user, I want to consult my concentration sessions from Calendar.

Acceptance scenarios:

- Calendar displays a Focus indicator for dates containing recorded sessions.
- Selecting a date displays its associated concentration sessions.
- Calendar displays the accumulated concentration time for the selected day.
- Selecting a session opens its detail view.
- Deleting a session updates Calendar immediately.
- Sessions spanning multiple local calendar days are handled correctly.
- Calendar retrieves existing Focus records without duplicating session data.

## User Story 9 — Goals integration (P2)

As a user, I want concentration sessions to contribute towards time-based personal goals.

Acceptance scenarios:

- Users can optionally associate a session with a Goal.
- Automatic goal progress tracking is opt-in.
- Automatic tracking is available only for counter goals with compatible time units.
- Supported time units include minutes and hours.
- Only actual recorded concentration time contributes to goal progress.
- Break sessions never contribute to goal progress.
- Paused time never contributes to goal progress.
- Each session contributes to a goal at most once.
- Deleting a linked session removes its automatic contribution.
- Manual goal progress remains independent of automatic Focus contributions.
- Deleting a goal does not delete its associated Focus history.
- Incompatible goals can be associated for reference without changing their progress.

## User Story 10 — Home and navigation integration (P1)

As a user, I want to access Focus from Home and optionally pin it to the bottom navigation.

Acceptance scenarios:

- Focus is registered in the centralized feature registry.
- Focus appears in the Home feature grid.
- Focus appears in Navigation Settings.
- Users can show, hide and reorder Focus in the bottom navigation.
- Existing navigation preferences remain unchanged after upgrading.
- The maximum number of optional navigation destinations remains unchanged.
- Hiding Focus does not stop an active timer.
- Navigating between features does not reset the timer.
- Opening Focus from Home restores its current state.
- An optional compact active-session indicator is displayed on Home while a session is running.

## Functional requirements

- FR-001: Provide a dedicated Focus feature.
- FR-002: Support concentration, short break and long break modes.
- FR-003: Support start, pause, resume, reset and stop actions.
- FR-004: Provide configurable session durations.
- FR-005: Provide configurable Pomodoro cycle lengths.
- FR-006: Support optional automatic session transitions.
- FR-007: Maintain a single active timer across application navigation.
- FR-008: Calculate remaining time using persisted timestamps.
- FR-009: Recover active and paused sessions after application restart.
- FR-010: Schedule local completion notifications where supported.
- FR-011: Support optional completion sounds and vibration.
- FR-012: Support custom Focus activities.
- FR-013: Support optional Daily and Goals associations.
- FR-014: Persist completed and interrupted sessions.
- FR-015: Prevent duplicate session records.
- FR-016: Exclude paused time from recorded duration.
- FR-017: Provide session history and filters.
- FR-018: Provide daily, weekly and monthly statistics.
- FR-019: Provide concentration statistics grouped by activity.
- FR-020: Integrate recorded sessions with Calendar.
- FR-021: Support opt-in time-based Goals contributions.
- FR-022: Register Focus in Home and customizable navigation.
- FR-023: Preserve existing navigation preferences.
- FR-024: Persist Focus settings locally.
- FR-025: Support Spanish and English localization.
- FR-026: Support all existing visual styles and color palettes.
- FR-027: Support responsive layouts without overflow.
- FR-028: Handle application lifecycle and notification permissions.
- FR-029: Preserve existing application data during migrations.
- FR-030: Operate without internet connectivity.
- FR-031: Provide loading, empty and error states.
- FR-032: Provide accessible timer controls and semantic labels.

## Data requirements

FocusSession entity:

- id
- sessionType
- status
- plannedDurationSeconds
- actualDurationSeconds
- startedAt
- endedAt
- activityId
- activityLabelSnapshot
- dailyActivityId
- goalId
- goalContributionEnabled
- createdAt

FocusActivity entity:

- id
- title
- iconId
- color
- isArchived
- createdAt
- updatedAt

ActiveFocusSession state:

- sessionId
- sessionType
- timerStatus
- plannedDurationSeconds
- accumulatedActiveSeconds
- remainingSecondsWhenPaused
- runningSegmentStartedAt
- expectedEndAt
- startedAt
- completedSessionsInCycle
- activityId
- activityLabelSnapshot
- dailyActivityId
- goalId
- goalContributionEnabled

FocusSettings:

- focusDurationMinutes
- shortBreakMinutes
- longBreakMinutes
- sessionsPerCycle
- autoStartBreaks
- autoStartFocus
- soundEnabled
- vibrationEnabled

Persist historical sessions and custom activities using the existing Drift database.

Persist active session state atomically using an appropriate existing local persistence mechanism.

Reuse the existing settings persistence mechanism for Focus preferences.

Use stable identifiers for session types, statuses and activities.

Persist active time intervals or equivalent information required to calculate accurate per-day statistics.

Use non-destructive database migrations.

Goal contributions must be derived from session records or maintained through an idempotent transactional mechanism.

## UI requirements

Focus main screen:

- Compact editorial header.
- Session mode selector.
- Large circular countdown.
- Remaining time in MM:SS format, supporting longer durations.
- Pomodoro cycle indicators.
- Activity selector.
- Start, pause, resume, reset and stop controls.
- Today's concentration summary.
- Access to history and Focus settings.

Focus history:

- Daily, weekly and monthly summary statistics.
- Date range selector.
- Concentration chart.
- Activity distribution.
- Compact session history cards.
- Session detail view.

Focus settings:

- Configurable concentration and break durations.
- Configurable cycle length.
- Automatic transition switches.
- Sound and vibration switches.
- Restore defaults action.

Active session indicator:

- Compact remaining-time display on Home.
- Opens the active Focus session.
- Must not create a second timer instance.

Use theme-aware design tokens.

The circular timer must support existing visual styles. Retro themes may use segmented or pixel-inspired progress indicators while retaining the same timer functionality.

Avoid oversized controls, excessive vertical spacing and hardcoded palette values.

## Architecture constraints

- Preserve MVVM architecture.
- Use Provider and ChangeNotifier consistently.
- Maintain a single application-scoped FocusViewModel or timer controller.
- Do not instantiate a new timer controller when opening Focus.
- Separate timer state, domain logic, persistence and UI.
- Inject a clock abstraction for deterministic testing.
- Use periodic callbacks only to refresh the displayed countdown.
- Do not use UI callback counts as the authoritative elapsed time.
- Reuse existing notification infrastructure when available.
- Reuse existing repositories and feature registry.
- Do not duplicate Daily or Goals data.
- Avoid unnecessary third-party dependencies.
- Do not introduce cloud storage, authentication or Firebase.

## Testing requirements

Unit tests:

- Timer initialization.
- Start, pause and resume.
- Remaining time calculation.
- Reset and stop behavior.
- Session completion.
- Prevention of duplicate completion.
- Short and long break transitions.
- Pomodoro cycle counting.
- Settings validation.
- Background timestamp recovery.
- Paused session recovery.
- Actual duration calculation.
- Exclusion of paused time.
- Midnight date boundaries.
- Daily, weekly and monthly statistics.
- Activity grouping.
- Goal unit conversion.
- Idempotent goal contributions.

Repository tests:

- Session persistence.
- Active session recovery.
- Custom activity CRUD and archiving.
- Historical activity label preservation.
- Database migration.
- Calendar integration.
- Goal contribution consistency.
- Session deletion.
- Settings persistence.

Widget tests:

- Timer controls.
- Session mode selector.
- Circular countdown.
- Activity selection.
- Settings screen.
- History and filters.
- Empty statistics.
- Navigation while the timer is running.
- Focus visibility preferences.
- Responsive layouts.
- Spanish and English localization.
- Compatibility with all visual styles.

Integration and manual platform tests:

- Locking the Android device during a session.
- Sending Daymark to the background.
- Returning after the expected completion time.
- Restarting the application during a running session.
- Restarting the application during a paused session.
- Notification delivery with permissions enabled.
- Timer behavior with permissions denied.
- Notification cancellation after pause or reset.
- Android battery optimization behavior.

## Success criteria

- Users can configure and complete Pomodoro sessions.
- Timer accuracy is preserved across navigation and application lifecycle changes.
- Sessions are never recorded more than once.
- History accurately reflects actual concentration time.
- Breaks and paused time are excluded from concentration statistics.
- Focus sessions are accessible from Calendar.
- Compatible Goals can receive optional time-based progress.
- Focus is accessible from Home and customizable navigation.
- Existing application features continue working.
- No existing data is lost.
- No layout overflow occurs on supported screen sizes.
- Flutter analysis and automated tests pass.

## Out of scope

- Blocking other applications or websites.
- Android accessibility service monitoring.
- Cloud synchronization.
- Social leaderboards.
- Collaborative concentration rooms.
- AI-generated productivity recommendations.
- Streaming background music.
- Automatic detection of user concentration.

## Compatibility with Daymark goals

Focus sessions are associated with activities only. Goals are managed
independently through Goals and Daily.

The timer exposes one Break control. The Pomodoro cycle selects the short or
long duration, and both durations remain configurable in Focus settings.
