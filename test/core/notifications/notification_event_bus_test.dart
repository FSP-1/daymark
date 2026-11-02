import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/notifications/notification_event_bus.dart';
import 'package:daymark/core/notifications/notification_models.dart';

void main() {
  test('publishes typed events and supports disposal', () {
    final bus = NotificationEventBus();
    final received = <NotificationEvent>[];
    void listener(NotificationEvent event) => received.add(event);
    bus.subscribe(listener);
    bus.publish(const NotificationCancellationRequested(42));
    expect(received, hasLength(1));
    bus.unsubscribe(listener);
    bus.publish(const NotificationCancellationRequested(43));
    expect(received, hasLength(1));
    bus.dispose();
  });

  test('notification IDs are stable and namespaced', () {
    expect(notificationId('daily', 7), notificationId('daily', 7));
    expect(notificationId('daily', 7), isNot(notificationId('other', 7)));
  });
}
