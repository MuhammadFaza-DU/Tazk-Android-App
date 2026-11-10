import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/data/repositories/task_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

Future<(AppDatabase, TaskRepository)> _setup() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final notifications = NotificationService.instance;
  final settings = SettingsRepository(db);
  final widgets = HomeWidgetService(db, settings);
  final gamification =
      GamificationRepository(db, notifications, settings, widgets);
  return (db, TaskRepository(db, gamification, notifications, settings, widgets));
}

Future<int> _newTask(TaskRepository tasks, String title) {
  return tasks.createTask(
    title: title,
    date: DateTime(2026, 11, 1),
    priority: TaskPriority.high,
  );
}

Future<List<int>> _taskIds(AppDatabase db, int id) async {
  final rows =
      await (db.select(db.tasks)..where((t) => t.id.equals(id))).get();
  return rows.map((r) => r.id).toList();
}

Future<int> _subtaskCount(AppDatabase db, int taskId) async {
  final rows = await (db.select(db.subtasks)
        ..where((s) => s.taskId.equals(taskId)))
      .get();
  return rows.length;
}

Future<int> _xp(AppDatabase db) async {
  final profile = await db.select(db.userProfile).getSingleOrNull();
  return profile?.xp ?? 0;
}

void main() {
  test('deleteTask refunds XP and removes subtasks for a completed task',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Bersih-bersih');
    await tasks.addSubtask(taskId, 'Sapu');
    await tasks.addSubtask(taskId, 'Pel');
    await tasks.completeTask(taskId);
    expect(await _xp(db), GamificationRepository.taskXpFor(TaskPriority.high));

    await tasks.deleteTask(taskId);

    expect(await _taskIds(db, taskId), isEmpty);
    expect(await _subtaskCount(db, taskId), 0);
    expect(await _xp(db), 0);
    final refunds = (await db.select(db.xpEvents).get())
        .where((e) => e.amount < 0)
        .toList();
    expect(refunds, hasLength(1));
    expect(
      refunds.single.amount,
      -GamificationRepository.taskXpFor(TaskPriority.high),
    );
  });

  test('deleteTask on an uncompleted task does not refund', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Belum selesai');
    await tasks.addSubtask(taskId, 'Satu');

    await tasks.deleteTask(taskId);

    expect(await _taskIds(db, taskId), isEmpty);
    expect(await _subtaskCount(db, taskId), 0);
    expect(await _xp(db), 0);
    expect(await db.select(db.xpEvents).get(), isEmpty);
  });
}