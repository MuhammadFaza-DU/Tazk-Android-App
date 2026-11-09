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

  /// Single source of truth for subtask order: explicit [Subtask.position],
  /// then [Subtask.id] so rows sharing a position still order deterministically.
  List<OrderingTerm Function($SubtasksTable)> get _subtaskOrder => [
        (s) => OrderingTerm(expression: s.position),
        (s) => OrderingTerm(expression: s.id),
      ];

  Stream<List<Subtask>> watchSubtasks(int taskId) {
    return (_db.select(_db.subtasks)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy(_subtaskOrder))
        .watch();
  }

  Future<int> createTask({
    required String title,
    required DateTime date,
    DateTime? time,
    required TaskPriority priority,
    String? location,
    bool autoCompleteSubtasks = true,
  }) async {
    final id = await _db.into(_db.tasks).insert(TasksCompanion.insert(
          title: title,
          date: date,
          time: Value(time),
          priority: priority,
          location: Value(location),
          autoCompleteSubtasks: Value(autoCompleteSubtasks),
        ));
    final task = await (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingle();
    if (!task.isCompleted) await _scheduleReminder(task);
    await _widget.refreshAll();
    return id;
  }

  Future<void> updateTask(Task task) async {
    final existing =
        await (_db.select(_db.tasks)..where((t) => t.id.equals(task.id)))
            .getSingleOrNull();
    await _db.transaction(() async {
      await _db.update(_db.tasks).replace(task);
      // Only a task that stays completed holds XP; a simultaneous
      // completion change belongs to completeTask/uncompleteTask.
      if (existing != null &&
          existing.isCompleted &&
          task.isCompleted &&
          existing.priority != task.priority) {
        await _gamification.onTaskPriorityChanged(
          existing.priority,
          task.priority,
        );
      }
    });
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
    return _db.transaction(() async {
      final maxPosition = _db.subtasks.position.max();
      final row = await (_db.selectOnly(_db.subtasks)
            ..addColumns([maxPosition])
            ..where(_db.subtasks.taskId.equals(taskId)))
          .getSingle();
      final position = (row.read(maxPosition) ?? 0) + 1;
      return _db.into(_db.subtasks).insert(
            SubtasksCompanion.insert(
              taskId: taskId,
              title: title,
              position: Value(position),
            ),
          );
    });
  }

  /// Positions are 1-based, assigned per list index, scoped so a row owned by
  /// another task is never touched.
  ///
  /// Callers must pass a complete permutation of this task's subtask ids (the
  /// drag UI always does); an invalid list throws [ArgumentError] and changes
  /// nothing, so the stored order is never left half-applied.
  Future<void> reorderSubtasks(int taskId, List<int> orderedSubtaskIds) {
    return _db.transaction(() async {
      final currentIds = (await (_db.select(_db.subtasks)
                ..where((s) => s.taskId.equals(taskId)))
              .get())
          .map((s) => s.id)
          .toSet();
      final requestedIds = orderedSubtaskIds.toSet();
      final isPermutation = orderedSubtaskIds.length == currentIds.length &&
          requestedIds.length == orderedSubtaskIds.length &&
          requestedIds.containsAll(currentIds);
      if (!isPermutation) {
        throw ArgumentError.value(
          orderedSubtaskIds,
          'orderedSubtaskIds',
          'must be a complete permutation of the subtask ids of task $taskId',
        );
      }
      for (var index = 0; index < orderedSubtaskIds.length; index++) {
        await (_db.update(_db.subtasks)
              ..where((s) =>
                  s.id.equals(orderedSubtaskIds[index]) &
                  s.taskId.equals(taskId)))
            .write(SubtasksCompanion(position: Value(index + 1)));
      }
    });
  }

  Future<void> setSubtaskCompleted(int subtaskId, bool completed) {
    return (_db.update(_db.subtasks)..where((s) => s.id.equals(subtaskId)))
        .write(SubtasksCompanion(isCompleted: Value(completed)));
  }

  /// Subtask checkbox entry point: keeps task completion and XP in step.
  /// [autoCompleteSubtasks] gates auto-completion only, never un-completion.
  Future<void> toggleSubtask(int subtaskId, bool completed) async {
    int? completedTaskId;
    Task? uncompletedTask;
    // One transaction, not several: a failing award must roll the tick back with
    // it, and interleaved taps must read the task the previous tap wrote.
    await _db.transaction(() async {
      final subtask = await (_db.select(_db.subtasks)
            ..where((s) => s.id.equals(subtaskId)))
          .getSingleOrNull();
      if (subtask == null || subtask.isCompleted == completed) return;
      await (_db.update(_db.subtasks)..where((s) => s.id.equals(subtaskId)))
          .write(SubtasksCompanion(isCompleted: Value(completed)));
      // Re-read inside the transaction; a pre-transaction snapshot can be stale.
      final task = await (_db.select(_db.tasks)
            ..where((t) => t.id.equals(subtask.taskId)))
          .getSingleOrNull();
      if (task == null) return;
      if (completed) {
        if (!task.autoCompleteSubtasks || task.isCompleted) return;
        final subtasks = await (_db.select(_db.subtasks)
              ..where((s) => s.taskId.equals(task.id)))
            .get();
        if (subtasks.isEmpty || subtasks.any((s) => !s.isCompleted)) return;
        await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id)))
            .write(const TasksCompanion(isCompleted: Value(true)));
        await _gamification.onTaskCompleted(task.priority);
        completedTaskId = task.id;
      } else {
        // Siblings stay untouched: the user unchecked one box, not the list.
        if (!task.isCompleted) return;
        await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id)))
            .write(const TasksCompanion(isCompleted: Value(false)));
        await _gamification.onTaskUncompleted(task.priority);
        uncompletedTask = task;
      }
    });
    final completedId = completedTaskId;
    if (completedId != null) {
      await _notifications.cancelTaskReminder(completedId);
      await _gamification.refreshStreakWarningNotification();
      await _widget.refreshAll();
    }
    final reminderTask = uncompletedTask;
    if (reminderTask != null) {
      await _scheduleReminder(reminderTask.copyWith(isCompleted: false));
      await _widget.refreshAll();
    }
  }

  Future<Task> duplicateTask(Task task) async {
    final newId = await createTask(
      title: task.title,
      date: task.date,
      time: task.time,
      priority: task.priority,
      location: task.location,
      autoCompleteSubtasks: task.autoCompleteSubtasks,
    );
    final subtasks = await (_db.select(_db.subtasks)
          ..where((s) => s.taskId.equals(task.id))
          ..orderBy(_subtaskOrder))
        .get();
    for (final subtask in subtasks) {
      await addSubtask(newId, subtask.title);
    }
    return (_db.select(_db.tasks)..where((t) => t.id.equals(newId))).getSingle();
  }

  Future<void> completeTask(int taskId) async {
    final existing = await (_db.select(_db.tasks)..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
    if (existing == null || existing.isCompleted) return;
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId)))
          .write(const TasksCompanion(isCompleted: Value(true)));
      await (_db.update(_db.subtasks)..where((s) => s.taskId.equals(taskId)))
          .write(const SubtasksCompanion(isCompleted: Value(true)));
      await _gamification.onTaskCompleted(existing.priority);
    });
    await _notifications.cancelTaskReminder(taskId);
    await _gamification.refreshStreakWarningNotification();
    await _widget.refreshAll();
  }

  /// PRD gap F: allow unchecking a completed task (toggle).
  Future<void> uncompleteTask(int taskId) async {
    final task = await (_db.select(_db.tasks)..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
    if (task == null || !task.isCompleted) return;
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId)))
          .write(const TasksCompanion(isCompleted: Value(false)));
      await (_db.update(_db.subtasks)..where((s) => s.taskId.equals(taskId)))
          .write(const SubtasksCompanion(isCompleted: Value(false)));
      await _gamification.onTaskUncompleted(task.priority);
    });
    // Incomplete again — re-arm its reminder if the date is still upcoming.
    await _scheduleReminder(task.copyWith(isCompleted: false));
    await _widget.refreshAll();
  }

  /// Toggle used by the widgets: complete a pending task or un-complete a
  /// completed one, keeping the widget row visible with a checkmark either way.
  Future<void> toggleTaskCompletion(int taskId) async {
    final task = await (_db.select(_db.tasks)..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
    if (task == null) return;
    if (task.isCompleted) {
      await uncompleteTask(taskId);
    } else {
      await completeTask(taskId);
    }
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
