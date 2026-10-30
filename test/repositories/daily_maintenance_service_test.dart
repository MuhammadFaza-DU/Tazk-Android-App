import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/daily_maintenance_service.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/habit_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/data/repositories/task_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

class _CountingTaskRepository extends Fake implements TaskRepository {
  int rescheduleCount = 0;

  @override
  Future<void> rescheduleAllReminders() async {
    rescheduleCount++;
  }
}

class _CountingHabitRepository extends Fake implements HabitRepository {
  int rescheduleCount = 0;

  @override
  Future<void> rescheduleAllReminders() async {
    rescheduleCount++;
  }
}

class _CountingGamificationRepository extends Fake
    implements GamificationRepository {
  int evaluateCount = 0;
  int refreshWarningCount = 0;

  @override
  Future<void> evaluateMissedDay() async {
    evaluateCount++;
  }

  @override
  Future<void> refreshStreakWarningNotification() async {
    refreshWarningCount++;
  }
}

class _CountingHomeWidgetService extends Fake implements HomeWidgetService {
  int refreshAllCount = 0;

  @override
  Future<void> refreshAll() async {
    refreshAllCount++;
  }
}

void main() {
  late AppDatabase db;
  late TaskRepository tasks;
  late HabitRepository habits;
  late DailyMaintenanceService maintenance;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final notifications = NotificationService.instance;
    final settings = SettingsRepository(db);
    final widgets = HomeWidgetService(db, settings);
    final gamification =
        GamificationRepository(db, notifications, settings, widgets);
    tasks = TaskRepository(db, gamification, notifications, settings, widgets);
    habits = HabitRepository(db, gamification, notifications, settings, widgets);
    maintenance =
        DailyMaintenanceService(tasks, habits, gamification, widgets);
  });

  tearDown(() async {
    await db.close();
  });

  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  test('rescheduleAllReminders completes over seeded tasks and habits',
      () async {
    await tasks.createTask(
      title: 'Tugas hari ini',
      date: today(),
      priority: TaskPriority.medium,
    );
    await tasks.createTask(
      title: 'Tugas besok',
      date: today().add(const Duration(days: 1)),
      priority: TaskPriority.high,
    );
    await habits.createHabit(
      name: 'Olahraga',
      frequency: HabitFrequency.daily,
    );

    // Should not throw regardless of the notification plugin being unbound
    // under `flutter test`.
    await maintenance.rescheduleAllReminders();
  });

  test('runDailyRollover is idempotent across repeated runs', () async {
    await tasks.createTask(
      title: 'Tugas',
      date: today(),
      priority: TaskPriority.low,
    );
    await habits.createHabit(
      name: 'Baca buku',
      frequency: HabitFrequency.daily,
    );

    await maintenance.runDailyRollover();
    await maintenance.runDailyRollover();

    // Rollover must not mutate task/habit rows (idempotent side effects only).
    final taskRows = await db.select(db.tasks).get();
    final habitRows = await db.select(db.habits).get();
    expect(taskRows, hasLength(1));
    expect(habitRows, hasLength(1));
    expect(taskRows.single.isCompleted, isFalse);
    expect(habitRows.single.isActive, isTrue);
  });

  test('rescheduleAllReminders skips completed tasks without error', () async {
    final id = await tasks.createTask(
      title: 'Selesai',
      date: today(),
      priority: TaskPriority.medium,
    );
    await tasks.completeTask(id);

    await maintenance.rescheduleAllReminders();

    final row =
        await (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
    expect(row.isCompleted, isTrue);
  });

  test('runDailyRollover runs its work once per day (guard)', () async {
    var clock = DateTime(2026, 1, 15, 8);
    final tasks = _CountingTaskRepository();
    final habits = _CountingHabitRepository();
    final gamification = _CountingGamificationRepository();
    final widgets = _CountingHomeWidgetService();
    final service = DailyMaintenanceService(
      tasks,
      habits,
      gamification,
      widgets,
      now: () => clock,
    );

    await service.runDailyRollover();
    // Same day — the instance-level guard must skip the work entirely.
    await service.runDailyRollover();

    expect(tasks.rescheduleCount, 1);
    expect(habits.rescheduleCount, 1);
    expect(gamification.evaluateCount, 1);
    expect(gamification.refreshWarningCount, 1);
    expect(widgets.refreshAllCount, 1);

    // A fresh calendar day on the same live instance — the rollover runs again.
    clock = DateTime(2026, 1, 16, 8);
    await service.runDailyRollover();

    expect(tasks.rescheduleCount, 2);
    expect(habits.rescheduleCount, 2);
    expect(gamification.evaluateCount, 2);
    expect(gamification.refreshWarningCount, 2);
    expect(widgets.refreshAllCount, 2);
  });
}
