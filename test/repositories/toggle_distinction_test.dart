import 'package:drift/drift.dart';
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

Future<(AppDatabase, TaskRepository, HabitRepository)> _setup() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final notifications = NotificationService.instance;
  final settings = SettingsRepository(db);
  final widgets = HomeWidgetService(db, settings);
  final gamification = GamificationRepository(db, notifications, settings, widgets);
  final tasks = TaskRepository(db, gamification, notifications, settings, widgets);
  final habits = HabitRepository(db, gamification, notifications, settings, widgets);
  return (db, tasks, habits);
}

void main() {
  test('task toggle: complete -> uncomplete -> re-complete', () async {
    final (db, tasks, _) = await _setup();
    addTearDown(() => db.close());

    final id = await tasks.createTask(
      title: 'Kerjain laporan',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.medium,
    );

    await tasks.completeTask(id);
    var task = await (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
    expect(task.isCompleted, isTrue);

    await tasks.uncompleteTask(id);
    task = await (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
    expect(task.isCompleted, isFalse);

    await tasks.completeTask(id);
    task = await (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
    expect(task.isCompleted, isTrue);
  });

  test('tasks with same title on different dates stay distinct', () async {
    final (db, tasks, _) = await _setup();
    addTearDown(() => db.close());

    final idA = await tasks.createTask(
      title: 'Same title',
      date: DateTime(2026, 7, 10),
      priority: TaskPriority.low,
    );
    final idB = await tasks.createTask(
      title: 'Same title',
      date: DateTime(2026, 7, 11),
      priority: TaskPriority.low,
    );

    await tasks.completeTask(idA);

    final taskA = await (db.select(db.tasks)..where((t) => t.id.equals(idA))).getSingle();
    final taskB = await (db.select(db.tasks)..where((t) => t.id.equals(idB))).getSingle();
    expect(taskA.isCompleted, isTrue);
    expect(taskB.isCompleted, isFalse);
  });

  test('habit per-date distinction: completing today does not affect other dates', () async {
    final (db, _, habits) = await _setup();
    addTearDown(() => db.close());

    final habitId = await habits.createHabit(
      name: 'Olahraga',
      frequency: HabitFrequency.daily,
    );

    final dateA = DateTime(2026, 7, 10);
    final dateB = DateTime(2026, 7, 11);

    await habits.completeHabitOnDate(habitId, dateA);
    final logA = await (db.select(db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(DateTime(dateA.year, dateA.month, dateA.day))))
        .getSingleOrNull();
    final logB = await (db.select(db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(DateTime(dateB.year, dateB.month, dateB.day))))
        .getSingleOrNull();

    expect(logA?.isCompleted, isTrue);
    expect(logB == null, isTrue);

    await habits.uncompleteHabitOnDate(habitId, dateA);
    final logAAfter = await (db.select(db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(DateTime(dateA.year, dateA.month, dateA.day))))
        .getSingleOrNull();
    expect(logAAfter?.isCompleted, isFalse);
  });
}
