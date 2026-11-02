import 'notification_models.dart';

sealed class NotificationEvent {
  const NotificationEvent();
}

class NotificationScheduleRequested extends NotificationEvent {
  const NotificationScheduleRequested(this.request);

  final NotificationRequest request;
}

class NotificationCancellationRequested extends NotificationEvent {
  const NotificationCancellationRequested(this.id);

  final int id;
}

class NotificationEventBus {
  final _listeners = <void Function(NotificationEvent)>[];

  void subscribe(void Function(NotificationEvent) listener) {
    _listeners.add(listener);
  }

  void unsubscribe(void Function(NotificationEvent) listener) {
    _listeners.remove(listener);
  }

  void publish(NotificationEvent event) {
    for (final listener in List.of(_listeners)) {
      listener(event);
    }
  }

  void dispose() => _listeners.clear();
}
