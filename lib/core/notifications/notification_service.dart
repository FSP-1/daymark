import 'notification_models.dart';

abstract interface class NotificationService {
  Future<NotificationCapability> capability();

  Future<NotificationCapability> requestPermission();

  Future<NotificationResult> schedule(NotificationRequest request);

  Future<NotificationResult> cancel(int id);
}
