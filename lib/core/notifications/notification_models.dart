enum NotificationAvailability { available, denied, unavailable, failed }

enum NotificationOperation { scheduled, cancelled, failed }

class NotificationCapability {
  const NotificationCapability({required this.availability, this.message});

  final NotificationAvailability availability;
  final String? message;

  bool get canSchedule => availability == NotificationAvailability.available;
}

class NotificationResult {
  const NotificationResult({required this.operation, this.message});

  final NotificationOperation operation;
  final String? message;

  bool get isSuccess => operation != NotificationOperation.failed;
}

class NotificationRequest {
  const NotificationRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
  });

  final int id;
  final String title;
  final String body;
  final int hour;
  final int minute;
}

int notificationId(String namespace, int activityId) {
  var hash = 17;
  for (final codeUnit in namespace.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return (hash * 31 + activityId) & 0x7fffffff;
}
