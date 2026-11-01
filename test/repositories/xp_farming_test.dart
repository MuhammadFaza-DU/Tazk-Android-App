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
  test('task toggle must not farm XP: complete-uncomplete-recomplete nets the priority amount', () async {
    final (db, tasks, _, gamification) = await _setup();
    addTearDown(() => db.close());

    var profile = await gamification.ensureProfile();
    expect(profile.xp, 0);
    expect(profile.level, 1);

    final lowXp = GamificationRepository.taskXpFor(TaskPriority.low);
    final id = await tasks.createTask(
      title: 'Farm',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.low,
    );

    await tasks.completeTask(id);
    profile = await gamification.ensureProfile();
    expect(profile.xp, lowXp, reason: 'first complete awards low priority XP');

    await tasks.uncompleteTask(id);
    profile = await gamification.ensureProfile();
    // After uncheck XP should be reverted so re-check does not double.
    expect(profile.xp, 0, reason: 'uncomplete reverts XP');

    await tasks.completeTask(id);
    profile = await gamification.ensureProfile();
    expect(profile.xp, lowXp,
        reason: 're-complete awards the same amount again, no farming');
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
    expect(profile.xp, GamificationRepository.taskXpFor(TaskPriority.medium));
  });

  test('completing a high priority task awards 15 XP end-to-end', () async {
    final (db, tasks, _, gamification) = await _setup();
    addTearDown(() => db.close());

    final id = await tasks.createTask(
      title: 'Penting',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.high,
    );

    await tasks.completeTask(id);

    final profile = await gamification.ensureProfile();
    final events = await db.select(db.xpEvents).get();
    expect(profile.xp, 15);
    expect(events.single.amount, 15);
    expect(events.single.source, XpSource.task);
  });

  test('lowering priority of a completed task rebalances XP to the new amount', () async {
    final (db, tasks, _, gamification) = await _setup();
    addTearDown(() => db.close());

    final id = await tasks.createTask(
      title: 'Turun prioritas',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.high,
    );
    await tasks.completeTask(id);
    expect((await gamification.ensureProfile()).xp, 15);

    final completed = await _taskById(db, id);
    await tasks.updateTask(completed.copyWith(priority: TaskPriority.low));

    expect((await gamification.ensureProfile()).xp, 5,
        reason: 'the 10 XP difference is taken back when priority drops');
    expect(
      (await db.select(db.xpEvents).get()).map((e) => e.amount).toList(),
      [15, -10],
      reason: 'the rebalance is a real event, not a silent profile edit',
    );

    await tasks.uncompleteTask(id);
    expect((await gamification.ensureProfile()).xp, 0,
        reason: 'uncheck refunds the rebalanced amount, no farmed XP left');
  });

  test('raising priority of a completed task awards the difference', () async {
    final (db, tasks, _, gamification) = await _setup();
    addTearDown(() => db.close());

    final id = await tasks.createTask(
      title: 'Naik prioritas',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.low,
    );
    await tasks.completeTask(id);
    expect((await gamification.ensureProfile()).xp, 5);

    final completed = await _taskById(db, id);
    await tasks.updateTask(completed.copyWith(priority: TaskPriority.high));

    expect((await gamification.ensureProfile()).xp, 15,
        reason: 'the user keeps the XP the new priority promises');
    expect(
      (await db.select(db.xpEvents).get()).map((e) => e.amount).toList(),
      [5, 10],
      reason: 'the top-up is a real event, not a silent profile edit',
    );

    await tasks.uncompleteTask(id);
    expect((await gamification.ensureProfile()).xp, 0,
        reason: 'uncheck must not silently destroy XP the user earned');
  });

  test('editing priority of an incomplete task does not touch XP', () async {
    final (db, tasks, _, gamification) = await _setup();
    addTearDown(() => db.close());

    final id = await tasks.createTask(
      title: 'Belum selesai',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.low,
    );

    final pending = await _taskById(db, id);
    await tasks.updateTask(pending.copyWith(priority: TaskPriority.high));

    final profile = await gamification.ensureProfile();
    final events = await db.select(db.xpEvents).get();
    expect(profile.xp, 0);
    expect(events, isEmpty);
  });
}

Future<Task> _taskById(AppDatabase db, int id) =>
    (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
