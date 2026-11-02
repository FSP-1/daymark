import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_service.dart';
import '../domain/daily_activity.dart';

class DailyNotificationCoordinator {
  DailyNotificationCoordinator(this.service);

  final NotificationService service;

  Future<bool> requestPermission() async {
    final result = await service.requestPermission();
    return result.canSchedule;
  }

  Future<NotificationResult> sync(DailyActivity activity) async {
    final id = notificationId('daily', activity.id!);
    if (!activity.schedule.hasSpecificTime || !activity.notificationsEnabled) {
      return service.cancel(id);
    }
    final capability = await service.capability();
    final resolvedCapability =
        capability.availability == NotificationAvailability.denied
        ? await service.requestPermission()
        : capability;
    if (!resolvedCapability.canSchedule) {
      return NotificationResult(
        operation: NotificationOperation.failed,
        message:
            resolvedCapability.message ?? resolvedCapability.availability.name,
      );
    }
    return service.schedule(
      NotificationRequest(
        id: id,
        title: activity.name,
        body: activity.name,
        hour: activity.schedule.hour!,
        minute: activity.schedule.minute!,
      ),
    );
  }

  Future<NotificationResult> cancel(DailyActivity activity) =>
      service.cancel(notificationId('daily', activity.id!));
}
