import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class NotificationScheduler {
  static const String taskName = "hourlyNotificationTask";

  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings settings = InitializationSettings(android: android);
      
      // Fixed initialization syntax
      await flip.initialize(settings: settings);

      await _showNotification(flip);
      return Future.value(true);
    });
  }

  static Future<void> _showNotification(FlutterLocalNotificationsPlugin flip) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hourly_channel',
      'Hourly Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platDetails = NotificationDetails(android: androidDetails);

    // FIXED: Removed named labels (id:, title:, etc.) to use positional arguments.
    // Order: id, title, body, notificationDetails, {payload}
    await flip.show(
      id:0,                          // id
      title:"EduHub Reminder",          // title
      body:"It's time to check your progress!", // body
      notificationDetails: platDetails,                // notificationDetails (NOT payload)
    );
  }

  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static void scheduleHourlyNotification() {
    Workmanager().registerPeriodicTask(
      "1",
      taskName,
      frequency: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }
}