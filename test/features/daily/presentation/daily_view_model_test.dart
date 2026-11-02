import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/notifications/notification_models.dart';
import 'package:daymark/core/notifications/notification_service.dart';
import 'package:daymark/features/daily/data/daily_notification_coordinator.dart';
import 'package:daymark/features/daily/domain/daily_activity.dart';
import 'package:daymark/features/daily/domain/daily_repository.dart';
import 'package:daymark/features/daily/domain/daily_schedule.dart';
import 'package:daymark/features/daily/presentation/daily_view_model.dart';

class _FakeNotifications implements NotificationService {
  final scheduled = <int>[];
  final cancelled = <int>[];
  bool throwOnSchedule = false;

  @override
  Future<NotificationCapability> capability() async =>
      const NotificationCapability(
        availability: NotificationAvailability.available,
      );

  @override
  Future<NotificationCapability> requestPermission() async => capability();

  @override
  Future<NotificationResult> schedule(NotificationRequest request) async {
    if (throwOnSchedule) {
      throw StateError('notification unavailable');
    }
    scheduled.add(request.id);
    return const NotificationResult(operation: NotificationOperation.scheduled);
  }

  @override
  Future<NotificationResult> cancel(int id) async {
    cancelled.add(id);
    return const NotificationResult(operation: NotificationOperation.cancelled);
  }
}

class _FakeRepository implements DailyRepository {
  final activities = <DailyActivity>[];
  final completions = <String>{};

  @override
  Future<List<DailyActivity>> listActivities() async =>
      List.unmodifiable(activities);

  @override
  Future<DailyActivity> saveActivity(DailyActivity activity) async {
    final saved = activity.copyWith(id: activity.id ?? activities.length + 1);
    activities.removeWhere((value) => value.id == saved.id);
    activities.add(saved);
    return saved;
  }

  @override
  Future<void> deleteActivity(int id) async =>
      activities.removeWhere((value) => value.id == id);

  @override
  Future<Set<int>> completedActivityIds(String localDate) async => activities
      .where((activity) => completions.contains('$localDate:${activity.id}'))
      .map((activity) => activity.id!)
      .toSet();

  @override
  Future<void> setCompleted({
    required int activityId,
    required String localDate,
    required bool completed,
  }) async {
    final key = '$localDate:$activityId';
    if (completed) {
      completions.add(key);
    } else {
      completions.remove(key);
    }
  }
}

void main() {
  test('keeps completion scoped to the injected local date', () async {
    final repository = _FakeRepository();
    final notifications = _FakeNotifications();
    final model = DailyViewModel(
      repository: repository,
      notifications: DailyNotificationCoordinator(notifications),
      now: () => DateTime(2026, 11, 1, 23, 59),
    );
    await model.save(
      name: 'Study',
      schedule: const DailySchedule.anytime(),
      notificationsEnabled: false,
    );
    final activity = model.activities.single;

    await model.toggleCompleted(activity);
    expect(model.isCompleted(activity), isTrue);
    expect(model.todayKey, '2026-11-01');
  });

  test('schedules specific-time notifications but not Anytime', () async {
    final repository = _FakeRepository();
    final notifications = _FakeNotifications();
    final model = DailyViewModel(
      repository: repository,
      notifications: DailyNotificationCoordinator(notifications),
    );
    expect(
      await model.save(
        name: 'Read',
        schedule: const DailySchedule.specific(hour: 8, minute: 30),
        notificationsEnabled: true,
      ),
      isTrue,
    );
    expect(notifications.scheduled, hasLength(1));
    await model.save(
      id: model.activities.single.id,
      name: 'Read',
      schedule: const DailySchedule.anytime(),
      notificationsEnabled: true,
    );
    expect(notifications.cancelled, hasLength(1));
  });

  test('keeps the activity when notification scheduling throws', () async {
    final repository = _FakeRepository();
    final notifications = _FakeNotifications()..throwOnSchedule = true;
    final model = DailyViewModel(
      repository: repository,
      notifications: DailyNotificationCoordinator(notifications),
    );

    expect(
      await model.save(
        name: 'Exercise',
        schedule: const DailySchedule.specific(hour: 7, minute: 0),
        notificationsEnabled: true,
      ),
      isTrue,
    );
    expect(model.activities.single.name, 'Exercise');
    expect(model.activities.single.notificationsEnabled, isFalse);
    expect(model.errorMessage, 'notificationUnavailable');
  });

  test('refreshes completion state when the local date changes', () async {
    final repository = _FakeRepository();
    final notifications = _FakeNotifications();
    var now = DateTime(2026, 11, 1, 23, 59);
    final model = DailyViewModel(
      repository: repository,
      notifications: DailyNotificationCoordinator(notifications),
      now: () => now,
    );
    await model.save(
      name: 'Walk',
      schedule: const DailySchedule.anytime(),
      notificationsEnabled: false,
    );
    final activity = model.activities.single;
    await model.toggleCompleted(activity);
    expect(model.isCompleted(activity), isTrue);

    now = DateTime(2026, 11, 2);
    await model.refreshForDateIfNeeded();

    expect(model.isCompleted(activity), isFalse);
  });
}
