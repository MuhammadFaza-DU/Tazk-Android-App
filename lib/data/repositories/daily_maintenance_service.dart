import 'gamification_repository.dart';
import 'habit_repository.dart';
import 'task_repository.dart';
import '../../widgets/home_widget_service.dart';

/// Coordinates the once-per-day rollover work: evaluating a missed streak day,
/// re-arming all reminders, refreshing tonight's streak warning, and pushing a
/// fresh snapshot to the home-screen widgets.
///
/// Deliberately Riverpod-free so the midnight background isolate (which has no
/// [ProviderScope]) can build it directly from the same repository graph. Every
/// step is idempotent, so it is safe to run on cold start, on app resume, and
/// from the midnight alarm.
class DailyMaintenanceService {
  DailyMaintenanceService(
    this._tasks,
    this._habits,
    this._gamification,
    this._widget,
  );

  final TaskRepository _tasks;
  final HabitRepository _habits;
  final GamificationRepository _gamification;
  final HomeWidgetService _widget;

  Future<void> rescheduleAllReminders() async {
    await _tasks.rescheduleAllReminders();
    await _habits.rescheduleAllReminders();
  }

  Future<void> runDailyRollover() async {
    await _gamification.evaluateMissedDay();
    await rescheduleAllReminders();
    await _gamification.refreshStreakWarningNotification();
    await _widget.refreshAll();
  }
}
