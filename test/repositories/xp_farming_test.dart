import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/habit_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/data/repositories/task_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

Future<(AppDatabase, TaskRepository, HabitRepository, GamificationRepository)>
    _setup() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final notifications = NotificationService.instance;
  final settings = SettingsRepository(db);
  final widgets = HomeWidgetService(db, settings);
  final gamification =
      GamificationRepository(db, notifications, settings, widgets);
  final tasks = TaskRepository(db, gamification, notifications, settings, widgets);
  final habits = HabitRepository(db, gamification, notifications, settings, widgets);
  return (db, tasks, habits, gamification);
}

void main() {
  test('task toggle must not farm XP: complete-uncomplete-recomplete = +10 not +20', () async {
    final (db, tasks, _, gamification) = await _setup();
    addTearDown(() => db.close());

    var profile = await gamification.ensureProfile();
    expect(profile.xp, 0);
    expect(profile.level, 1);

    final id = await tasks.createTask(
      title: 'Farm',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.low,
    );

    await tasks.completeTask(id);
    profile = await gamification.ensureProfile();
    expect(profile.xp, 10, reason: 'first complete +10');

    await tasks.uncompleteTask(id);
    profile = await gamification.ensureProfile();
    // After uncheck XP should be reverted so re-check does not double.
    expect(profile.xp, 0, reason: 'uncomplete reverts XP');

    await tasks.completeTask(id);
    profile = await gamification.ensureProfile();
    expect(profile.xp, 10, reason: 're-complete gives +10 again, net +10 not +20');
  });

  test('habit toggle must not farm XP', () async {
    final (db, _, habits, gamification) = await _setup();
    addTearDown(() => db.close());

    final habitId = await habits.createHabit(
      name: 'Olahraga',
      frequency: HabitFrequency.daily,
    );

    await habits.completeHabitToday(habitId);
    var profile = await gamification.ensureProfile();
    expect(profile.xp, 15);

    await habits.uncompleteHabitToday(habitId);
    profile = await gamification.ensureProfile();
    expect(profile.xp, 0);

    await habits.completeHabitToday(habitId);
    profile = await gamification.ensureProfile();
    expect(profile.xp, 15);
  });

  test('double complete without uncheck stays idempotent (no extra XP)', () async {
    final (db, tasks, _, gamification) = await _setup();
    addTearDown(() => db.close());

    final id = await tasks.createTask(
      title: 'Once',
      date: DateTime.now(),
      priority: TaskPriority.medium,
    );

    await tasks.completeTask(id);
    await tasks.completeTask(id);
    final profile = await gamification.ensureProfile();
    expect(profile.xp, 10);
  });
}
