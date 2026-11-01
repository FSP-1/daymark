# Research: Daily Activities

**Date**: 2026-11-01  
**Scope**: Specification and planning only; no package installation or source changes.

## Existing project findings

- The app uses Flutter/Dart, Provider/ChangeNotifier, repository boundaries, and
  Drift/SQLite. The current database is
  [`lib/features/sticky_notes/data/local/app_database.dart`](../../lib/features/sticky_notes/data/local/app_database.dart)
  with explicit schema migrations.
- `HomeShell` currently exposes a placeholder Tasks destination. Daily should replace
  that destination through a focused feature page rather than creating a second shell.
- Existing theme composition is centralized in
  [`lib/core/theme/app_theme.dart`](../../lib/core/theme/app_theme.dart), with three
  styles and six palettes. Daily must consume `Theme.of(context)` and existing tokens.
- Localization is loaded from `assets/i18n/en.json` and `assets/i18n/es.json` through
  [`lib/core/localization/app_localizations.dart`](../../lib/core/localization/app_localizations.dart).
- Existing tests inject `AppDatabase.test()` and fake repositories. Daily should expose
  equivalent seams for clocks, calendars, notification services, and event delivery.
- No notification package, notification service, notification event bus, Daily tables,
  or Daily ViewModel currently exist.

## Completion data model

A recurring activity and a daily fact are different aggregates. Store one activity row
and one completion row per `(activityId, localDate)`. A unique composite key makes
repeated completion idempotent and preserves history. The UI can obtain today's state
with a single date-keyed query, while historical reporting remains possible later.

Do not store “last completed at” on the activity as the source of truth: it loses
history and makes timezone/date changes ambiguous. Do not derive dates by
`DateTime.difference(...).inDays`; Dart documents that elapsed durations across DST
may not equal calendar-day differences. Use local calendar components and a stable
date-only key.

Reference: [Dart `DateTime` documentation](https://api.flutter.dev/flutter/dart-core/DateTime-class.html).

## Local time and timezone policy

The product concept is a local calendar day and local wall-clock schedule. An injected
`DailyClock`/`LocalCalendar` should provide:

- `nowLocal()`;
- `dateKey(DateTime)` as `YYYY-MM-DD`;
- `todayKey()`;
- validation and formatting of hour/minute;
- conversion of a scheduled local wall-clock time to the next schedulable instant.

For platform scheduling, use an IANA timezone-aware representation rather than assuming
UTC. The `timezone` package provides an embedded IANA database and `TZDateTime`; its
documentation states that local location must be initialized/set explicitly. The
implementation must define how the device timezone is obtained and what happens if it
cannot be resolved. The first implementation can use the platform's local timezone
when the chosen notification adapter supports it, but must test DST and midnight
boundaries with a fake calendar.

Reference: [timezone package](https://pub.dev/packages/timezone).

## Notification package research

`flutter_local_notifications` is the recommended candidate because its documented API
supports platform initialization, permission requests, scheduled notifications,
cancellation by integer ID, and platform-specific implementations. It also documents
Android setup requirements, notification channels, icon configuration, and scheduling
limitations. It should remain behind `PlatformNotificationService`; no Daily widget
or ViewModel should import it.

The package's exact version, Android compatibility, permission API, and scheduling API
must be verified during implementation against the repository's Flutter/Dart toolchain.
Do not add it during this documentation task.

Reference: [flutter_local_notifications package](https://pub.dev/packages/flutter_local_notifications).

## Android permission and availability findings

Android 13/API 33 introduced the runtime `POST_NOTIFICATIONS` permission for non-exempt
notifications. The app must request it in context when a user enables a notification,
not assume it is granted at installation. Denial must be represented as a recoverable
notification capability state. Android's notification permission documentation also
describes differences for apps targeting older API levels and upgrade/install paths;
implementation must verify the project's target SDK before choosing exact setup.

Reference: [Android notification runtime permission](https://developer.android.com/develop/ui/views/notifications/notification-permission).

Exact alarms, battery restrictions, OEM policies, and device notification settings can
also prevent a notification from firing. The service must distinguish “requested and
accepted by platform” from “guaranteed delivery,” and must never block local Daily use.

## Observer/event design

The smallest useful abstraction is:

1. `NotificationService` exposes typed methods and capability results.
2. `NotificationEventBus` allows feature coordinators to publish/observe typed
   schedule/cancel requests and result events.
3. `DailyNotificationCoordinator` owns Daily-specific eligibility and event mapping.
4. `PlatformNotificationService` is the only plugin adapter.

This is preferable to a general-purpose event bus or a global mutable loading-style
controller. Events should be scoped, typed, disposable, and include a feature
namespace plus stable notification ID. A service call may be used directly by a
coordinator when request/response semantics are clearer; the observer mechanism is
for decoupled change propagation, not an obligation to route every method through a
bus.

## Alternatives rejected

- **One activity row per day**: duplicates recurring data and complicates edits/history.
- **A `lastCompletedDate` column only**: loses history and is unsafe across timezone
  changes.
- **UTC date keys**: can switch the user's day at a local time other than midnight.
- **A Daily-owned plugin wrapper**: prevents future features from reusing notifications.
- **A broad event bus**: hides dependencies and makes failure ownership unclear.
- **Remote push notifications**: violates offline-first scope and is unnecessary for
  local scheduled reminders.
- **Scheduling Anytime notifications**: contradicts the product rule and creates
  unwanted alerts.

## Implementation risks and mitigations

| Risk | Mitigation |
|---|---|
| Permission denied | Typed capability result, localized explanation, retry/settings path |
| Plugin unavailable | No-op/unavailable adapter preserving CRUD and completion |
| DST or timezone boundary | Injected calendar tests and timezone-aware adapter |
| Duplicate alarms | Deterministic namespace + activity ID and cancel-before-replace |
| Partial replace failure | Persist intended state only after service outcome; retryable error |
| OS alarm restrictions | Document best-effort delivery; never claim guaranteed delivery |
| Migration regression | Drift migration tests and existing Sticky Notes regression suite |
| Localization drift | Resource-key checklist and English/Spanish widget tests |

## Research decision

Proceed with a local-only Daily feature, separate activity/completion tables, an
injected local calendar, and a reusable notification service/event contract. Defer
package installation, platform configuration, database migration, and implementation
until the plan and task list are approved.
