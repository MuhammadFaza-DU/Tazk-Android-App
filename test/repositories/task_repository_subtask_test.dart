import 'package:drift/drift.dart';
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

Future<int> _newTask(
  TaskRepository tasks,
  String title, {
  bool autoCompleteSubtasks = true,
}) {
  return tasks.createTask(
    title: title,
    date: DateTime(2026, 11, 1),
    priority: TaskPriority.medium,
    autoCompleteSubtasks: autoCompleteSubtasks,
  );
}

Future<Map<int, int>> _positions(AppDatabase db, int taskId) async {
  final rows = await (db.select(db.subtasks)
        ..where((s) => s.taskId.equals(taskId)))
      .get();
  return {for (final row in rows) row.id: row.position};
}

Future<Task> _readTask(AppDatabase db, int taskId) {
  return (db.select(db.tasks)..where((t) => t.id.equals(taskId))).getSingle();
}

/// 0 until the profile row exists, which is exactly the "no XP yet" state.
Future<int> _xp(AppDatabase db) async {
  final profile = await db.select(db.userProfile).getSingleOrNull();
  return profile?.xp ?? 0;
}

void main() {
  test('addSubtask assigns 1-based positions and watchSubtasks keeps that order',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Urutan subtask');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    final third = await tasks.addSubtask(taskId, 'Tiga');

    expect(await _positions(db, taskId), {first: 1, second: 2, third: 3});

    final watched = await tasks.watchSubtasks(taskId).first;
    expect(watched.map((s) => s.id), [first, second, third]);
    expect(watched.map((s) => s.position), [1, 2, 3]);
  });

  test('addSubtask appends after the highest existing position', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Bekas backfill');
    final backfilledLow = await db.into(db.subtasks).insert(
          SubtasksCompanion.insert(
            taskId: taskId,
            title: 'Lama satu',
            position: const Value(5),
          ),
        );
    final backfilledHigh = await db.into(db.subtasks).insert(
          SubtasksCompanion.insert(
            taskId: taskId,
            title: 'Lama dua',
            position: const Value(9),
          ),
        );

    final appended = await tasks.addSubtask(taskId, 'Baru');

    expect(
      await _positions(db, taskId),
      {backfilledLow: 5, backfilledHigh: 9, appended: 10},
    );
    final watched = await tasks.watchSubtasks(taskId).first;
    expect(watched.map((s) => s.id), [backfilledLow, backfilledHigh, appended]);
  });

  test('reorderSubtasks persists the new order with 1-based positions',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Reorder');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    final third = await tasks.addSubtask(taskId, 'Tiga');

    await tasks.reorderSubtasks(taskId, [third, first, second]);

    expect(await _positions(db, taskId), {third: 1, first: 2, second: 3});
    final watched = await tasks.watchSubtasks(taskId).first;
    expect(watched.map((s) => s.id), [third, first, second]);
    expect(watched.map((s) => s.position), [1, 2, 3]);
  });

  test('reorderSubtasks never touches another task\'s rows', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskA = await _newTask(tasks, 'Tugas A');
    final taskB = await _newTask(tasks, 'Tugas B');
    final aFirst = await tasks.addSubtask(taskA, 'A satu');
    final aSecond = await tasks.addSubtask(taskA, 'A dua');
    final bFirst = await tasks.addSubtask(taskB, 'B satu');
    final bSecond = await tasks.addSubtask(taskB, 'B dua');

    await tasks.reorderSubtasks(taskA, [aSecond, aFirst]);

    expect(await _positions(db, taskA), {aSecond: 1, aFirst: 2});
    expect(await _positions(db, taskB), {bFirst: 1, bSecond: 2});
  });

  test('reorderSubtasks rejects a partial list and writes nothing', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Sebagian');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    final third = await tasks.addSubtask(taskId, 'Tiga');

    await expectLater(
      tasks.reorderSubtasks(taskId, [third, first]),
      throwsArgumentError,
    );

    expect(await _positions(db, taskId), {first: 1, second: 2, third: 3});
    final watched = await tasks.watchSubtasks(taskId).first;
    expect(watched.map((s) => s.id), [first, second, third]);
  });

  test('reorderSubtasks rejects a foreign id and leaves both tasks untouched',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskA = await _newTask(tasks, 'Tugas A');
    final taskB = await _newTask(tasks, 'Tugas B');
    final aFirst = await tasks.addSubtask(taskA, 'A satu');
    final aSecond = await tasks.addSubtask(taskA, 'A dua');
    final aThird = await tasks.addSubtask(taskA, 'A tiga');
    final bFirst = await tasks.addSubtask(taskB, 'B satu');
    final bSecond = await tasks.addSubtask(taskB, 'B dua');

    await expectLater(
      tasks.reorderSubtasks(taskA, [aThird, bFirst, aFirst, aSecond]),
      throwsArgumentError,
    );

    expect(await _positions(db, taskA), {aFirst: 1, aSecond: 2, aThird: 3});
    expect(await _positions(db, taskB), {bFirst: 1, bSecond: 2});
  });

  test('reorderSubtasks rejects duplicate ids and writes nothing', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Duplikat');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    final third = await tasks.addSubtask(taskId, 'Tiga');

    await expectLater(
      tasks.reorderSubtasks(taskId, [second, second, first]),
      throwsArgumentError,
    );

    expect(await _positions(db, taskId), {first: 1, second: 2, third: 3});
  });

  test('duplicateTask copies subtasks in position order when positions are gapped',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Bekas backfill');
    const seeded = [(7, 'Tujuh'), (3, 'Tiga'), (9, 'Sembilan')];
    for (final (position, title) in seeded) {
      await db.into(db.subtasks).insert(
            SubtasksCompanion.insert(
              taskId: taskId,
              title: title,
              position: Value(position),
            ),
          );
    }

    final duplicate = await tasks.duplicateTask(await _readTask(db, taskId));

    final copied = await tasks.watchSubtasks(duplicate.id).first;
    expect(copied.map((s) => s.title), ['Tiga', 'Tujuh', 'Sembilan']);
    expect(copied.map((s) => s.position), [1, 2, 3]);
  });

  test('createTask stores autoCompleteSubtasks with true as the default',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final defaulted = await _newTask(tasks, 'Default');
    final custom = await _newTask(
      tasks,
      'Custom',
      autoCompleteSubtasks: false,
    );

    expect((await _readTask(db, defaulted)).autoCompleteSubtasks, isTrue);
    expect((await _readTask(db, custom)).autoCompleteSubtasks, isFalse);
  });

  test('duplicateTask preserves autoCompleteSubtasks and copies subtask order',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Belanja', autoCompleteSubtasks: false);
    final beras = await tasks.addSubtask(taskId, 'Beras');
    final sabun = await tasks.addSubtask(taskId, 'Sabun');
    final gula = await tasks.addSubtask(taskId, 'Gula');
    await tasks.reorderSubtasks(taskId, [gula, beras, sabun]);

    final duplicate = await tasks.duplicateTask(await _readTask(db, taskId));

    expect(duplicate.id, isNot(taskId));
    expect(duplicate.autoCompleteSubtasks, isFalse);
    final copied = await tasks.watchSubtasks(duplicate.id).first;
    expect(copied.map((s) => s.title), ['Gula', 'Beras', 'Sabun']);
    expect(copied.map((s) => s.position), [1, 2, 3]);
  });

  test('toggleSubtask leaves the task incomplete when autoCompleteSubtasks is off',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Manual', autoCompleteSubtasks: false);
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');

    await tasks.toggleSubtask(first, true);
    await tasks.toggleSubtask(second, true);

    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);
    final subtasks = await tasks.watchSubtasks(taskId).first;
    expect(subtasks.every((s) => s.isCompleted), isTrue);
  });

  test('toggleSubtask completes the task on the last subtask and awards XP once',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Dua langkah');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');

    await tasks.toggleSubtask(first, true);
    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);

    await tasks.toggleSubtask(second, true);

    expect((await _readTask(db, taskId)).isCompleted, isTrue);
    expect(await _xp(db), GamificationRepository.taskXpFor(TaskPriority.medium));
    expect(await db.select(db.xpEvents).get(), hasLength(1));
  });

  test('toggleSubtask off on a completed task uncompletes it and refunds once',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Dua langkah');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    await tasks.toggleSubtask(first, true);
    await tasks.toggleSubtask(second, true);
    expect((await _readTask(db, taskId)).isCompleted, isTrue);
    expect(await _xp(db), GamificationRepository.taskXpFor(TaskPriority.medium));

    await tasks.toggleSubtask(first, false);

    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);
    final subtasks = await tasks.watchSubtasks(taskId).first;
    expect(subtasks.firstWhere((s) => s.id == first).isCompleted, isFalse);
    expect(subtasks.firstWhere((s) => s.id == second).isCompleted, isTrue,
        reason: 'siblings are not flipped');
  });

  test('toggleSubtask off uncompletes the task even when autoCompleteSubtasks is off',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Manual', autoCompleteSubtasks: false);
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    await tasks.completeTask(taskId);
    expect(await _xp(db), GamificationRepository.taskXpFor(TaskPriority.medium));

    await tasks.toggleSubtask(first, false);

    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);
    final subtasks = await tasks.watchSubtasks(taskId).first;
    expect(subtasks.firstWhere((s) => s.id == second).isCompleted, isTrue,
        reason: 'completeTask had completed it; unchecking one box keeps it');
  });

  test('a single subtask completes the task only when autoCompleteSubtasks is on',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final manualId = await _newTask(tasks, 'Manual', autoCompleteSubtasks: false);
    final manualOnly = await tasks.addSubtask(manualId, 'Satu-satunya');
    await tasks.toggleSubtask(manualOnly, true);
    expect((await _readTask(db, manualId)).isCompleted, isFalse);
    expect(await _xp(db), 0);

    final autoId = await _newTask(tasks, 'Otomatis');
    final autoOnly = await tasks.addSubtask(autoId, 'Satu-satunya');
    await tasks.toggleSubtask(autoOnly, true);
    expect((await _readTask(db, autoId)).isCompleted, isTrue);
    expect(await _xp(db), GamificationRepository.taskXpFor(TaskPriority.medium));
  });

  test('repeated toggles neither double-award nor double-refund XP', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Idempoten');
    final only = await tasks.addSubtask(taskId, 'Satu');

    await tasks.toggleSubtask(only, true);
    await tasks.toggleSubtask(only, true);
    expect((await _readTask(db, taskId)).isCompleted, isTrue);
    expect(await _xp(db), GamificationRepository.taskXpFor(TaskPriority.medium));

    await tasks.toggleSubtask(only, false);
    await tasks.toggleSubtask(only, false);
    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);
  });

  test('toggleSubtask on a missing subtask id changes nothing', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Hilang');
    final real = await tasks.addSubtask(taskId, 'Satu');

    await tasks.toggleSubtask(9999, true);

    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);
    expect(await db.select(db.xpEvents).get(), isEmpty);
    final subtasks = await tasks.watchSubtasks(taskId).first;
    expect(subtasks.single.id, real);
    expect(subtasks.single.isCompleted, isFalse);
  });

  test('re-checking after an uncheck completes again and awards exactly once',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Batal lalu ulang');
    final first = await tasks.addSubtask(taskId, 'Satu');
    await tasks.addSubtask(taskId, 'Dua');
    final xp = GamificationRepository.taskXpFor(TaskPriority.medium);
    await tasks.completeTask(taskId);
    expect(await _xp(db), xp);

    await tasks.toggleSubtask(first, false);
    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);

    await tasks.toggleSubtask(first, true);

    expect((await _readTask(db, taskId)).isCompleted, isTrue);
    expect(await _xp(db), xp);
    final events = await db.select(db.xpEvents).get();
    expect(events.fold<int>(0, (sum, e) => sum + e.amount), xp,
        reason: 'award, refund and award net to a single task XP');
    expect(events.where((e) => e.amount > 0), hasLength(2));
    expect(events.where((e) => e.amount < 0), hasLength(1));
  });

  test('unchecking two siblings of one completed task refunds only once',
      () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Dua sibling');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    await tasks.completeTask(taskId);
    expect(await _xp(db), GamificationRepository.taskXpFor(TaskPriority.medium));

    await tasks.toggleSubtask(first, false);
    expect(await _xp(db), 0);

    await tasks.toggleSubtask(second, false);

    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);
    final refunds = (await db.select(db.xpEvents).get())
        .where((e) => e.amount < 0)
        .toList();
    expect(refunds, hasLength(1));
  });

  test('toggling the same value twice writes nothing extra', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Nilai sama');
    final only = await tasks.addSubtask(taskId, 'Satu');
    await tasks.toggleSubtask(only, true);
    final xp = GamificationRepository.taskXpFor(TaskPriority.medium);
    expect(await _xp(db), xp);
    final eventsAfterComplete = await db.select(db.xpEvents).get();

    await tasks.toggleSubtask(only, true);

    expect(await _xp(db), xp);
    expect(await db.select(db.xpEvents).get(), hasLength(eventsAfterComplete.length));
    expect((await _readTask(db, taskId)).isCompleted, isTrue);
    final subtasks = await tasks.watchSubtasks(taskId).first;
    expect(subtasks.single.isCompleted, isTrue);
  });

  test('interleaved unchecks on two siblings refund only once', () async {
    final (db, tasks) = await _setup();
    addTearDown(() => db.close());

    final taskId = await _newTask(tasks, 'Tap cepat');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    await tasks.completeTask(taskId);

    await Future.wait([
      tasks.toggleSubtask(first, false),
      tasks.toggleSubtask(second, false),
    ]);

    final refunds = (await db.select(db.xpEvents).get())
        .where((e) => e.amount < 0)
        .toList();
    expect(refunds, hasLength(1),
        reason: 'the second toggle must see the task already incomplete');
    expect(await _xp(db), 0);
  });

  test('a failing XP award rolls back the subtask tick with it', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());
    final notifications = NotificationService.instance;
    final settings = SettingsRepository(db);
    final widgets = HomeWidgetService(db, settings);
    final gamification =
        _ThrowingGamification(db, notifications, settings, widgets);
    final tasks =
        TaskRepository(db, gamification, notifications, settings, widgets);

    final taskId = await _newTask(tasks, 'XP gagal');
    final first = await tasks.addSubtask(taskId, 'Satu');
    final second = await tasks.addSubtask(taskId, 'Dua');
    await tasks.toggleSubtask(first, true);

    await expectLater(tasks.toggleSubtask(second, true), throwsStateError);

    final subtasks = await tasks.watchSubtasks(taskId).first;
    expect(subtasks.firstWhere((s) => s.id == second).isCompleted, isFalse,
        reason: 'the tick must not survive a rolled-back award');
    expect((await _readTask(db, taskId)).isCompleted, isFalse);
    expect(await _xp(db), 0);
  });
}

class _ThrowingGamification extends GamificationRepository {
  _ThrowingGamification(super.db, super.notifications, super.settings, super.widgets);

  @override
  Future<void> onTaskCompleted(TaskPriority priority) async {
    throw StateError('award failed');
  }
}