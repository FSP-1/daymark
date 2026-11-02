import 'package:flutter/foundation.dart';

import '../../../core/notifications/notification_models.dart';
import '../data/daily_notification_coordinator.dart';
import '../domain/daily_activity.dart';
import '../domain/daily_repository.dart';
import '../domain/daily_schedule.dart';

enum DailyStatus { idle, loading, ready, error }

class DailyViewModel extends ChangeNotifier {
  DailyViewModel({
    required this.repository,
    required this.notifications,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DailyRepository repository;
  final DailyNotificationCoordinator notifications;
  final DateTime Function() _now;

  DailyStatus status = DailyStatus.idle;
  List<DailyActivity> activities = const [];
  Set<int> completedIds = const {};
  String? errorMessage;
  String? _loadedDateKey;

  String get todayKey {
    final date = _now();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  bool isCompleted(DailyActivity activity) =>
      activity.id != null && completedIds.contains(activity.id);

  Future<void> load() async {
    status = DailyStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      activities = await repository.listActivities();
      final dateKey = todayKey;
      completedIds = await repository.completedActivityIds(dateKey);
      _loadedDateKey = dateKey;
      status = DailyStatus.ready;
    } catch (_) {
      status = DailyStatus.error;
      errorMessage = 'loadDaily';
    }
    notifyListeners();
  }

  Future<void> refreshForDateIfNeeded() async {
    if (_loadedDateKey != null && _loadedDateKey != todayKey) {
      await load();
    }
  }

  Future<bool> setNotificationsEnabled(
    DailyActivity activity,
    bool enabled,
  ) async {
    if (activity.id == null || !activity.schedule.hasSpecificTime) {
      return false;
    }
    if (enabled) {
      try {
        final allowed = await notifications.requestPermission();
        if (!allowed) {
          errorMessage = 'notificationUnavailable';
          notifyListeners();
          return false;
        }
      } catch (_) {
        errorMessage = 'notificationUnavailable';
        notifyListeners();
        return false;
      }
    }
    return save(
      id: activity.id,
      name: activity.name,
      schedule: activity.schedule,
      notificationsEnabled: enabled,
    );
  }

  Future<bool> save({
    int? id,
    required String name,
    required DailySchedule schedule,
    required bool notificationsEnabled,
  }) async {
    final existing = id == null
        ? null
        : activities.firstWhere((activity) => activity.id == id);
    final activity = DailyActivity(
      id: id,
      name: name,
      schedule: schedule,
      notificationsEnabled: schedule.hasSpecificTime && notificationsEnabled,
      createdAt: existing?.createdAt ?? _now(),
      updatedAt: _now(),
    );
    if (!activity.isValid) {
      errorMessage = 'invalidDaily';
      notifyListeners();
      return false;
    }
    try {
      final saved = await repository.saveActivity(activity);
      await load();

      NotificationResult result;
      try {
        result = await notifications.sync(saved);
      } catch (error) {
        result = NotificationResult(
          operation: NotificationOperation.failed,
          message: error.toString(),
        );
      }

      final notificationFailed =
          !result.isSuccess && saved.notificationsEnabled;
      if (notificationFailed) {
        try {
          await repository.saveActivity(
            saved.copyWith(notificationsEnabled: false),
          );
          await load();
        } catch (_) {
          // The activity remains saved even if the notification flag cannot
          // be updated after a platform notification failure.
        }
      }
      if (notificationFailed) {
        errorMessage = 'notificationUnavailable';
        notifyListeners();
      }
      return true;
    } catch (_) {
      status = DailyStatus.error;
      errorMessage = 'saveDaily';
      notifyListeners();
      return false;
    }
  }

  Future<void> delete(DailyActivity activity) async {
    if (activity.id == null) return;
    try {
      await notifications.cancel(activity);
      await repository.deleteActivity(activity.id!);
      await load();
    } catch (_) {
      status = DailyStatus.error;
      errorMessage = 'deleteDaily';
      notifyListeners();
    }
  }

  Future<void> toggleCompleted(DailyActivity activity) async {
    if (activity.id == null) return;
    final completed = !isCompleted(activity);
    try {
      await repository.setCompleted(
        activityId: activity.id!,
        localDate: todayKey,
        completed: completed,
      );
      completedIds = {
        ...completedIds,
        if (completed) activity.id! else ...const <int>{},
      };
      if (!completed) {
        completedIds = {...completedIds}..remove(activity.id);
      }
      notifyListeners();
    } catch (_) {
      errorMessage = 'completionDaily';
      notifyListeners();
    }
  }
}
