import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/database/database.dart';
import '../data/models/enums.dart';
import '../data/repositories/habit_repository.dart';

/// Wraps [FlutterLocalNotificationsPlugin] for Tazk's reminder system.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _exactAlarmsAllowed = false;

  static const _taskIdBase = 100000;
  static const _habitIdBase = 200000;
  static const _idRangeSize = 100000;

  static const streakWarningNotificationId = 900001;
  static const freezeUsedNotificationId = 900002;
  static const focusSessionNotificationId = 900003;

  static const _taskChannelId = 'task_reminders';
  static const _habitChannelId = 'habit_reminders';
  static const _streakChannelId = 'streak_warning';
  static const _freezeChannelId = 'freeze_used';
  static const _focusChannelId = 'focus_session';

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

    // Sync current exact-alarm capability without prompting. Lets background
    // isolates (which never call requestPermission) still pick exact mode when
    // the user has already granted it.
    try {
      final canExact = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.canScheduleExactNotifications();
      _exactAlarmsAllowed = canExact ?? true;
    } catch (error) {
      debugPrint('NotificationService: canScheduleExactNotifications failed: $error');
    }
  }

  /// Whether the OS currently allows exact alarms. Queried live (not cached)
  /// since the user can revoke "Alarms & reminders" at any time. Returns true on
  /// pre-31 devices where exact alarms need no permission. Used by the midnight
  /// scheduler to decide exact vs inexact — the alarm plugin silently no-ops an
  /// exact request when the permission is revoked, so we must never ask for one
  /// we can't get.
  Future<bool> canScheduleExactAlarms() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final can = await android?.canScheduleExactNotifications();
      return can ?? true;
    } catch (error) {
      debugPrint('NotificationService: canScheduleExactAlarms failed: $error');
      return false;
    }
  }

  Future<void> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      // Opens the system "Alarms & reminders" page on Android 12+ (API 31+).
      // Returns null on older versions, where exact alarms are always allowed.
      final granted = await android?.requestExactAlarmsPermission();
      _exactAlarmsAllowed = granted ?? true;
    } catch (error) {
      debugPrint('NotificationService: requestPermission failed: $error');
    }
  }

  DateTime resolveReminderTime(DateTime date, DateTime? time) {
    if (time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
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

  Future<void> cancelTaskReminder(int taskId) =>
      _cancel(taskNotificationId(taskId));

  Future<void> cancelAllTaskReminders() => _cancelIdRange(_taskIdBase);

  Future<void> scheduleHabitReminder({
    required int habitId,
    required String title,
    required String body,
    DateTime? scheduledTime,
    required HabitRepository habitRepository,
    required Habit habit,
  }) async {
    await cancelHabitReminder(habitId);
    final now = DateTime.now();

    if (habit.frequency == HabitFrequency.daily) {
      var scheduled =
          resolveReminderTime(DateTime(now.year, now.month, now.day), scheduledTime);
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
      return;
    }

    final dueDates = _getNextDueDates(habit, habitRepository, now, 7);
    for (var i = 0; i < dueDates.length; i++) {
      final scheduled = resolveReminderTime(dueDates[i], scheduledTime);
      if (!scheduled.isAfter(now)) continue;

      await _zonedSchedule(
        id: habitNotificationId(habitId) + i,
        title: title,
        body: body,
        scheduledDate: scheduled,
        channelId: _habitChannelId,
        channelName: 'Habit Reminders',
      );
    }
  }

  List<DateTime> _getNextDueDates(
    Habit habit,
    HabitRepository repo,
    DateTime fromDate,
    int count,
  ) {
    final dates = <DateTime>[];
    var current = _dateOnly(fromDate);
    final endSearch = current.add(const Duration(days: 60));

    while (dates.length < count && current.isBefore(endSearch)) {
      if (repo.isDueOnDate(habit, current)) {
        dates.add(current);
      }
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  Future<void> cancelHabitReminder(int habitId) async {
    for (var i = 0; i < 7; i++) {
      await _cancel(habitNotificationId(habitId) + i);
    }
  }

  Future<void> cancelAllHabitReminders() => _cancelIdRange(_habitIdBase);

  Future<void> scheduleTonightsStreakWarning({
    required String title,
    required String body,
  }) async {
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

  Future<void> showFreezeUsedNotification({
    required String title,
    required String body,
  }) async {
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

  Future<void> scheduleFocusSessionComplete({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await cancelFocusSessionComplete();
    if (!scheduledDate.isAfter(DateTime.now())) return;

    await _zonedSchedule(
      id: focusSessionNotificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      channelId: _focusChannelId,
      channelName: 'Focus Session',
    );
  }

  Future<void> cancelFocusSessionComplete() =>
      _cancel(focusSessionNotificationId);

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
        androidScheduleMode: _exactAlarmsAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
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

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
