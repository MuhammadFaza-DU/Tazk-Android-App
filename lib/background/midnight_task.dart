import 'package:flutter/widgets.dart';

import '../data/database/database.dart';
import '../data/repositories/daily_maintenance_service.dart';
import '../data/repositories/gamification_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/task_repository.dart';
import '../notifications/notification_service.dart';
import '../widgets/home_widget_service.dart';
import 'midnight_scheduler.dart';

/// Runs in a background isolate at (just after) local midnight via
/// android_alarm_manager_plus. Mirrors [homeWidgetBackgroundCallback]: it wires
/// up a throwaway repository graph against the same on-disk database, runs the
/// idempotent daily rollover, re-arms the next midnight alarm, then tears the
/// database down.
@pragma('vm:entry-point')
Future<void> midnightRolloverCallback() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  try {
    final notifications = NotificationService.instance;
    await notifications.initialize();
    final settings = SettingsRepository(db);
    final widgetService = HomeWidgetService(db, settings);
    final gamification =
        GamificationRepository(db, notifications, settings, widgetService);
    final taskRepository =
        TaskRepository(db, gamification, notifications, settings, widgetService);
    final habitRepository =
        HabitRepository(db, gamification, notifications, settings, widgetService);
    final maintenance = DailyMaintenanceService(
      taskRepository,
      habitRepository,
      gamification,
      widgetService,
    );

    await maintenance.runDailyRollover();
  } catch (error) {
    debugPrint('midnightRolloverCallback failed: $error');
  } finally {
    await MidnightScheduler.armNextMidnight();
    await db.close();
  }
}
