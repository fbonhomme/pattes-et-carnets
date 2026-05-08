import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'pattes_reminders';
  static const _channelName = 'Rappels de soins';
  static const _channelDesc = 'Rappels pour les soins et rendez-vous de vos chats';

  /// Call once from main() before runApp.
  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Fallback to UTC if timezone detection fails (e.g. on Linux desktop)
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Ouvrir',
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      ),
    );

    // Request Android 13+ POST_NOTIFICATIONS permission
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Schedule (or immediately show if overdue) a notification for [reminder].
  /// [catName] is used in the notification body.
  static Future<void> scheduleReminder(Reminder reminder, String catName) async {
    if (reminder.isDone) return;

    final due = reminder.dueDate;
    // Fire at 9:00 AM on the due date
    final scheduled = DateTime(due.year, due.month, due.day, 9, 0);
    final now = DateTime.now();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(),
    );

    final title = reminder.title;
    final body = _buildBody(reminder.type, catName, reminder.description);

    if (scheduled.isBefore(now)) {
      // Already past — show immediately as a simple notification
      await _plugin.show(reminder.id, title, body, details);
    } else {
      final tzScheduled = tz.TZDateTime.from(scheduled, tz.local);
      await _plugin.zonedSchedule(
        reminder.id,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Cancel the notification for a single reminder.
  static Future<void> cancelReminder(int reminderId) async {
    await _plugin.cancel(reminderId);
  }

  /// Cancel all scheduled notifications (call on full DB reset).
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Reschedule every pending reminder on startup (handles app restarts).
  static Future<void> rescheduleAll(
    List<Reminder> reminders,
    Map<int, String> catNames,
  ) async {
    await _plugin.cancelAll();
    for (final r in reminders) {
      await scheduleReminder(r, catNames[r.catId] ?? '');
    }
  }

  static String _buildBody(
    ReminderType type,
    String catName,
    String? description,
  ) {
    final base = '${type.label} pour $catName';
    if (description != null && description.isNotEmpty) {
      return '$base — $description';
    }
    return base;
  }
}
