import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';

import '../notifications/notification_service.dart';
import 'midnight_task.dart';

/// Schedules a background alarm that fires shortly after each local midnight to
/// run [midnightRolloverCallback], keeping the home-screen widgets and reminders
/// in sync with the new day even while the app is closed.
class MidnightScheduler {
  MidnightScheduler._();

  /// Fixed id so re-arming replaces the pending alarm instead of stacking
  /// duplicates.
  static const alarmId = 424242;

  static Future<void> initialize() async {
    try {
      await AndroidAlarmManager.initialize();
    } catch (error) {
      debugPrint('MidnightScheduler: initialize failed: $error');
    }
  }

  static Future<void> armNextMidnight() async {
    final now = DateTime.now();
    // A few seconds past midnight so DateTime.now() inside the callback lands on
    // the new day. Recomputed from now() each time, so it stays correct across
    // DST transitions.
    final next = DateTime(now.year, now.month, now.day + 1)
        .add(const Duration(seconds: 5));

    // The alarm plugin silently no-ops an `exact` request when the OS has revoked
    // "Alarms & reminders" (the Android 12+ default), scheduling nothing. So we
    // must decide exact-vs-inexact up front: an inexact alarm always schedules
    // and still fires within Doze's maintenance window, which is fine for a
    // once-daily rollover. NotificationService.initialize() is idempotent.
    var exact = false;
    try {
      await NotificationService.instance.initialize();
      exact = await NotificationService.instance.canScheduleExactAlarms();
    } catch (error) {
      debugPrint('MidnightScheduler: exact-alarm capability check failed: $error');
    }

    try {
      await AndroidAlarmManager.oneShotAt(
        next,
        alarmId,
        midnightRolloverCallback,
        exact: exact,
        wakeup: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
      );
    } catch (error) {
      debugPrint('MidnightScheduler: arm failed (exact=$exact): $error');
    }
  }
}
