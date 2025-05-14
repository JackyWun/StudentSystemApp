import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize the local notifications plugin (call this in main)
  static Future<void> initialize() async {
    tzData.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(initSettings);
  }

  // Schedule a notification (e.g., for an assignment due date reminder)
  static Future<void> scheduleAssignmentNotification({
    required int id,
    required String title,
    required DateTime scheduledTime,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      '📚 Assignment Reminder',
      'Your assignment "$title" is due tomorrow!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'assignment_channel',
          'Assignment Notifications',
          channelDescription: 'Reminders for assignment due dates',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      // Use the new Android scheduling mode (exact timing, allowing idle).
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Optionally, match time components for recurring daily alerts (if needed)
      matchDateTimeComponents: DateTimeComponents.time,
      // (Removed the deprecated uiLocalNotificationDateInterpretation parameter :contentReference[oaicite:0]{index=0})
    );
  }

  // Show an immediate notification
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Instant Notifications',
          channelDescription: 'Immediate alerts and updates',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
