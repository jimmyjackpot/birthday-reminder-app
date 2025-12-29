import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/birthday.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'birthday_reminders',
      'Birthday Reminders',
      description: 'Notifications for upcoming birthdays',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> scheduleBirthdayReminder(Birthday birthday) async {
    if (!birthday.reminderEnabled) {
      await cancelReminder(birthday.id);
      return;
    }

    final now = DateTime.now();
    final nextBirthday = DateTime(
      now.year,
      birthday.birthdate.month,
      birthday.birthdate.day,
    );

    // If birthday already passed this year, schedule for next year
    final targetDate = nextBirthday.isBefore(now)
        ? DateTime(now.year + 1, birthday.birthdate.month, birthday.birthdate.day)
        : nextBirthday;

    // Calculate reminder date (at 9 AM)
    final reminderDate = targetDate.subtract(Duration(days: birthday.reminderDays));
    final scheduledTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9, // 9 AM
    );

    // Only schedule if reminder date is in the future
    if (scheduledTime.isBefore(now)) return;

    const androidDetails = AndroidNotificationDetails(
      'birthday_reminders',
      'Birthday Reminders',
      channelDescription: 'Notifications for upcoming birthdays',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        birthday.id.hashCode,
        'Birthday Reminder 🎉',
        '${birthday.name}\'s birthday is in ${birthday.reminderDays} day${birthday.reminderDays > 1 ? 's' : ''}!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // If exact alarms are not permitted, fall back to inexact alarms
      if (e.toString().contains('exact_alarms_not_permitted')) {
        try {
          await _notifications.zonedSchedule(
            birthday.id.hashCode,
            'Birthday Reminder 🎉',
            '${birthday.name}\'s birthday is in ${birthday.reminderDays} day${birthday.reminderDays > 1 ? 's' : ''}!',
            tz.TZDateTime.from(scheduledTime, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (e2) {
          // If that also fails, use default scheduling
          await _notifications.zonedSchedule(
            birthday.id.hashCode,
            'Birthday Reminder 🎉',
            '${birthday.name}\'s birthday is in ${birthday.reminderDays} day${birthday.reminderDays > 1 ? 's' : ''}!',
            tz.TZDateTime.from(scheduledTime, tz.local),
            notificationDetails,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      } else {
        rethrow;
      }
    }
  }

  static Future<void> cancelReminder(String birthdayId) async {
    await _notifications.cancel(birthdayId.hashCode);
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  static Future<void> rescheduleAllReminders(List<Birthday> birthdays) async {
    await cancelAllReminders();
    for (var birthday in birthdays) {
      await scheduleBirthdayReminder(birthday);
    }
  }
}

