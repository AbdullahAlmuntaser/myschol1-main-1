import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../event_model.dart'; // Import Event model

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo')); // Set your local timezone, e.g., 'America/Detroit' or 'Europe/London'

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'your_channel_id', // id
          'your_channel_name', // name
          channelDescription: 'your_channel_description', // description
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id, // notification id
      title, // title
      body, // body
      platformChannelSpecifics,
      payload: payload, // payload
    );
  }

  // New method to schedule an event notification
  Future<void> scheduleEventNotification(Event event) async {
    if (event.id == null) return; // Event must have an ID to schedule a notification

    // Parse date and time from event strings
    final DateTime eventDate = DateTime.parse(event.date);
    final List<String> startTimeParts = event.startTime.split(':');
    final int startHour = int.parse(startTimeParts[0]);
    final int startMinute = int.parse(startTimeParts[1]);

    // Combine date and time to get the exact event start time
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      eventDate.year,
      eventDate.month,
      eventDate.day,
      startHour,
      startMinute,
    );

    // Schedule notification 30 minutes before the event
    scheduledDate = scheduledDate.subtract(const Duration(minutes: 30));

    // Ensure the scheduled date is in the future
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      // If the event is already in the past, or less than 30 minutes away, don't schedule
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'event_channel_id',
          'Event Reminders',
          channelDescription: 'Reminders for school events',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Event Reminder',
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      event.id!,
      'تذكير بالفعالية: ${event.title}',
      'تبدأ فعاليتك في ${event.location} الساعة ${event.startTime}',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'event_${event.id}',
    );
  }

  // New method to cancel an event notification
  Future<void> cancelEventNotification(int eventId) async {
    await flutterLocalNotificationsPlugin.cancel(eventId);
  }

  // New method to cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
