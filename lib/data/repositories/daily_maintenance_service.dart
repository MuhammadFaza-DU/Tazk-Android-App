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
    this._widget, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final TaskRepository _tasks;
  final HabitRepository _habits;
  final GamificationRepository _gamification;
  final HomeWidgetService _widget;
  final DateTime Function() _now;

  /// The last day (as a date-only value) this instance already ran the rollover
  /// for. Lets the service skip redundant work while the app is alive across
  /// many `resumed` lifecycle events within the same day.
  DateTime? _lastRolloverDate;

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> rescheduleAllReminders() async {
    await _tasks.rescheduleAllReminders();
    await _habits.rescheduleAllReminders();
  }

  Future<void> runDailyRollover() async {
    final today = _dateOnly(_now());
    if (_lastRolloverDate == today) return;
    _lastRolloverDate = today;
    await _gamification.evaluateMissedDay();
    // Self-heal a stored streak that drifted below the real history (the user
    // saw "1" for days of real work). Monotonic, so freezes stay meaningful.
    await _gamification.repairStreakFromHistory();
    await rescheduleAllReminders();
    await _gamification.refreshStreakWarningNotification();
    await _widget.refreshAll();
  }
}
