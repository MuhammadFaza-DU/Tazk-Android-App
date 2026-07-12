import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/data/repositories/task_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

void main() {
  late AppDatabase db;
  late TaskRepository tasks;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final notifications = NotificationService.instance;
    final settings = SettingsRepository(db);
    final widgets = HomeWidgetService(db, settings);
    final gamification =
        GamificationRepository(db, notifications, settings, widgets);
    tasks = TaskRepository(db, gamification, notifications, settings, widgets);
  });

  tearDown(() async {
    await db.close();
  });

  test('createTask stores task details', () async {
    final date = DateTime(2026, 7, 11);
    final time = DateTime(2026, 7, 11, 8, 30);

    final id = await tasks.createTask(
      title: 'Tugas Kuliah',
      date: date,
      time: time,
      priority: TaskPriority.high,
      location: 'Kampus',
    );

    final task =
        await (db.select(db.tasks)..where((row) => row.id.equals(id)))
            .getSingle();

    expect(task.title, 'Tugas Kuliah');
    expect(task.date, date);
    expect(task.time, time);
    expect(task.priority, TaskPriority.high);
    expect(task.location, 'Kampus');
    expect(task.isCompleted, isFalse);
  });

  test('completeTask completes task and all subtasks', () async {
    final taskId = await tasks.createTask(
      title: 'Submit laporan',
      date: DateTime(2026, 7, 11),
      priority: TaskPriority.medium,
    );
    final firstSubtaskId = await tasks.addSubtask(taskId, 'Draft');
    final secondSubtaskId = await tasks.addSubtask(taskId, 'Review');

    await tasks.completeTask(taskId);

    final task =
        await (db.select(db.tasks)..where((row) => row.id.equals(taskId)))
            .getSingle();
    final subtasks = await (db.select(db.subtasks)
          ..where((row) => row.id.isIn([firstSubtaskId, secondSubtaskId])))
        .get();

    expect(task.isCompleted, isTrue);
    expect(subtasks, hasLength(2));
    expect(subtasks.every((subtask) => subtask.isCompleted), isTrue);
  });

  test('duplicateTask copies details and subtask titles', () async {
    final taskId = await tasks.createTask(
      title: 'Belanja bulanan',
      date: DateTime(2026, 7, 11),
      time: DateTime(2026, 7, 11, 18),
      priority: TaskPriority.low,
      location: 'Market',
    );
    await tasks.addSubtask(taskId, 'Beras');
    await tasks.addSubtask(taskId, 'Sabun');
    final original =
        await (db.select(db.tasks)..where((row) => row.id.equals(taskId)))
            .getSingle();

    final duplicate = await tasks.duplicateTask(original);
    final duplicateSubtasks = await (db.select(db.subtasks)
          ..where((row) => row.taskId.equals(duplicate.id)))
        .get();

    expect(duplicate.id, isNot(taskId));
    expect(duplicate.title, original.title);
    expect(duplicate.date, original.date);
    expect(duplicate.time, original.time);
    expect(duplicate.priority, original.priority);
    expect(duplicate.location, original.location);
    expect(duplicateSubtasks.map((subtask) => subtask.title), [
      'Beras',
      'Sabun',
    ]);
    expect(duplicateSubtasks.every((subtask) => !subtask.isCompleted), isTrue);
  });
}
