import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps [FlutterLocalNotificationsPlugin] for Tazk's reminder system.
///
/// Notification id ranges (to allow bulk cancel/lookup by category without a
/// native tagging API): task reminders `100000..199999`, habit reminders
/// `200000..299999`, plus two fixed singleton ids for streak warning and
/// freeze-used.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _taskIdBase = 100000;
  static const _habitIdBase = 200000;
  static const _idRangeSize = 100000;

  static const streakWarningNotificationId = 900001;
  static const freezeUsedNotificationId = 900002;

  static const _taskChannelId = 'task_reminders';
  static const _habitChannelId = 'habit_reminders';
  static const _streakChannelId = 'streak_warning';
  static const _freezeChannelId = 'freeze_used';

  int taskNotificationId(int taskId) => _taskIdBase + taskId;
  int habitNotificationId(int habitId) => _habitIdBase + habitId;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (error) {
      debugPrint('NotificationService: failed to resolve local timezone: $error');
    }

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (error) {
      debugPrint('NotificationService: initialize failed: $error');
    }
  }

  Future<void> requestPermission() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (error) {
      debugPrint('NotificationService: requestPermission failed: $error');
    }
  }

  DateTime resolveReminderTime(DateTime date, DateTime? time) {
    if (time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    // PRD 3.1/3.2: default 2 hours before midnight when no time is set.
    return DateTime(date.year, date.month, date.day, 22);
  }

  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required String body,
    required DateTime date,
    DateTime? time,
  }) async {
    await cancelTaskReminder(taskId);
    final scheduled = resolveReminderTime(date, time);
    if (!scheduled.isAfter(DateTime.now())) return;

    await _zonedSchedule(
      id: taskNotificationId(taskId),
      title: title,
      body: body,
      scheduledDate: scheduled,
      channelId: _taskChannelId,
      channelName: 'Task Reminders',
    );
  }

  Future<void> cancelTaskReminder(int taskId) => _cancel(taskNotificationId(taskId));

  Future<void> cancelAllTaskReminders() => _cancelIdRange(_taskIdBase);

  Future<void> scheduleHabitReminder({
    required int habitId,
    required String title,
    required String body,
    DateTime? scheduledTime,
  }) async {
    await cancelHabitReminder(habitId);
    final now = DateTime.now();
    var scheduled = resolveReminderTime(DateTime(now.year, now.month, now.day), scheduledTime);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _zonedSchedule(
      id: habitNotificationId(habitId),
      title: title,
      body: body,
      scheduledDate: scheduled,
      channelId: _habitChannelId,
      channelName: 'Habit Reminders',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelHabitReminder(int habitId) => _cancel(habitNotificationId(habitId));

  Future<void> cancelAllHabitReminders() => _cancelIdRange(_habitIdBase);

  Future<void> scheduleTonightsStreakWarning({required String title, required String body}) async {
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, 21);
    if (!scheduled.isAfter(now)) return;

    await _zonedSchedule(
      id: streakWarningNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduled,
      channelId: _streakChannelId,
      channelName: 'Streak Warning',
    );
  }

  Future<void> cancelStreakWarning() => _cancel(streakWarningNotificationId);

  Future<void> showFreezeUsedNotification({required String title, required String body}) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _freezeChannelId,
        'Freeze Used',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      await _plugin.show(
        freezeUsedNotificationId,
        title,
        body,
        const NotificationDetails(android: androidDetails),
      );
    } catch (error) {
      debugPrint('NotificationService: showFreezeUsedNotification failed: $error');
    }
  }

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (error) {
      debugPrint('NotificationService: zonedSchedule($id) failed: $error');
    }
  }

  Future<void> _cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (error) {
      debugPrint('NotificationService: cancel($id) failed: $error');
    }
  }

  Future<void> _cancelIdRange(int base) async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final request in pending) {
        if (request.id >= base && request.id < base + _idRangeSize) {
          await _plugin.cancel(request.id);
        }
      }
    } catch (error) {
      debugPrint('NotificationService: cancelIdRange($base) failed: $error');
    }
  }
}
