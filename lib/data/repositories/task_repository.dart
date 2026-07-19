import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import '../../widgets/home_widget_service.dart';
import '../database/database.dart';
import '../models/enums.dart';
import 'gamification_repository.dart';
import 'settings_repository.dart';

class TaskRepository {
  TaskRepository(
    this._db,
    this._gamification,
    this._notifications,
    this._settings,
    this._widget,
  );

  final AppDatabase _db;
  final GamificationRepository _gamification;
  final NotificationService _notifications;
  final SettingsRepository _settings;
  final HomeWidgetService _widget;

  Future<void> _scheduleReminder(Task task) async {
    final settings = await _settings.ensureSettings();
    if (!settings.notifyTasks) {
      await _notifications.cancelTaskReminder(task.id);
      return;
    }
    final l10n = lookupAppLocalizations(
      Locale(settings.language == AppLanguage.english ? 'en' : 'id'),
    );
    await _notifications.scheduleTaskReminder(
      taskId: task.id,
      title: l10n.notifTaskReminderTitle(task.title),
      body: l10n.notifTaskReminderBody,
      date: task.date,
      time: task.time,
    );
  }

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
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Stream<List<Task>> watchTasksInMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return (_db.select(_db.tasks)
          ..where(
            (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
          ))
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
  }) async {
    final id = await _db.into(_db.tasks).insert(TasksCompanion.insert(
          title: title,
          date: date,
          time: Value(time),
          priority: priority,
          location: Value(location),
        ));
    final task = await (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingle();
    if (!task.isCompleted) await _scheduleReminder(task);
    await _widget.refreshAll();
    return id;
  }

  Future<void> updateTask(Task task) async {
    await _db.update(_db.tasks).replace(task);
    if (task.isCompleted) {
      await _notifications.cancelTaskReminder(task.id);
    } else {
      await _scheduleReminder(task);
    }
    await _widget.refreshAll();
  }

  Future<void> deleteTask(int id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    await _notifications.cancelTaskReminder(id);
    await _widget.refreshAll();
  }

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
    await _notifications.cancelTaskReminder(taskId);
    await _gamification.refreshStreakWarningNotification();
    await _widget.refreshAll();
  }

  /// Re-arms reminders for every incomplete task from today onward. Idempotent:
  /// [_scheduleReminder]/[NotificationService.scheduleTaskReminder] cancel before
  /// scheduling. Used by daily maintenance so reminders don't run dry when the
  /// app stays alive across midnight.
  Future<void> rescheduleAllReminders() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final tasks = await (_db.select(_db.tasks)
          ..where((t) =>
              t.isCompleted.equals(false) &
              t.date.isBiggerOrEqualValue(startOfToday)))
        .get();
    for (final task in tasks) {
      await _scheduleReminder(task);
    }
  }
}
