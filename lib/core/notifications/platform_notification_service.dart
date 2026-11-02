import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notification_models.dart';
import 'notification_service.dart';

class PlatformNotificationService implements NotificationService {
  PlatformNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    final initialized = await _plugin.initialize(settings: settings);
    if (initialized != true) {
      throw StateError('Notification platform initialization failed');
    }
    _initialized = true;
  }

  @override
  Future<NotificationCapability> capability() async {
    try {
      await _initialize();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final enabled = await android?.areNotificationsEnabled();
      if (enabled == false) {
        return const NotificationCapability(
          availability: NotificationAvailability.denied,
        );
      }
      return const NotificationCapability(
        availability: NotificationAvailability.available,
      );
    } catch (error) {
      return NotificationCapability(
        availability: NotificationAvailability.failed,
        message: error.toString(),
      );
    }
  }

  @override
  Future<NotificationCapability> requestPermission() async {
    try {
      await _initialize();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission() ?? false;
      return NotificationCapability(
        availability: granted
            ? NotificationAvailability.available
            : NotificationAvailability.denied,
      );
    } catch (error) {
      return NotificationCapability(
        availability: NotificationAvailability.failed,
        message: error.toString(),
      );
    }
  }

  @override
  Future<NotificationResult> schedule(NotificationRequest request) async {
    try {
      await _initialize();
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        request.hour,
        request.minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: request.id,
        title: request.title,
        body: request.body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily',
            'Daily activities',
            channelDescription: 'Daily activity reminders',
            importance: Importance.defaultImportance,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return const NotificationResult(
        operation: NotificationOperation.scheduled,
      );
    } catch (error) {
      return NotificationResult(
        operation: NotificationOperation.failed,
        message: error.toString(),
      );
    }
  }

  @override
  Future<NotificationResult> cancel(int id) async {
    try {
      await _initialize();
      await _plugin.cancel(id: id);
      return const NotificationResult(
        operation: NotificationOperation.cancelled,
      );
    } catch (error) {
      return NotificationResult(
        operation: NotificationOperation.failed,
        message: error.toString(),
      );
    }
  }
}
