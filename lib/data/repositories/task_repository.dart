import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/enums.dart';
import 'gamification_repository.dart';

class TaskRepository {
  TaskRepository(this._db, this._gamification);

  final AppDatabase _db;
  final GamificationRepository _gamification;

  Stream<List<Task>> watchTasksForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.tasks)
          ..where(
            (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.time, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Stream<List<Subtask>> watchSubtasks(int taskId) {
    return (_db.select(_db.subtasks)..where((s) => s.taskId.equals(taskId)))
        .watch();
  }

  Future<int> createTask({
    required String title,
    required DateTime date,
    DateTime? time,
    required TaskPriority priority,
    String? location,
  }) {
    return _db.into(_db.tasks).insert(TasksCompanion.insert(
          title: title,
          date: date,
          time: Value(time),
          priority: priority,
          location: Value(location),
        ));
  }

  Future<void> updateTask(Task task) => _db.update(_db.tasks).replace(task);

  Future<void> deleteTask(int id) =>
      (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();

  Future<int> addSubtask(int taskId, String title) {
    return _db.into(_db.subtasks).insert(
          SubtasksCompanion.insert(taskId: taskId, title: title),
        );
  }

  Future<void> setSubtaskCompleted(int subtaskId, bool completed) {
    return (_db.update(_db.subtasks)..where((s) => s.id.equals(subtaskId)))
        .write(SubtasksCompanion(isCompleted: Value(completed)));
  }

  Future<Task> duplicateTask(Task task) async {
    final newId = await createTask(
      title: task.title,
      date: task.date,
      time: task.time,
      priority: task.priority,
      location: task.location,
    );
    final subtasks =
        await (_db.select(_db.subtasks)..where((s) => s.taskId.equals(task.id)))
            .get();
    for (final subtask in subtasks) {
      await addSubtask(newId, subtask.title);
    }
    return (_db.select(_db.tasks)..where((t) => t.id.equals(newId))).getSingle();
  }

  Future<void> completeTask(int taskId) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId)))
          .write(const TasksCompanion(isCompleted: Value(true)));
      await (_db.update(_db.subtasks)..where((s) => s.taskId.equals(taskId)))
          .write(const SubtasksCompanion(isCompleted: Value(true)));
      await _gamification.onTaskCompleted();
    });
  }
}
