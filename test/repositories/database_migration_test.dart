import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';

void main() {
  test('opens a version 1 database and adds custom habit columns', () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE IF NOT EXISTS habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('PRAGMA user_version = 1;');
        },
      ),
    );
    try {
      final habitId = await db.into(db.habits).insert(
            HabitsCompanion.insert(
              name: 'Baca buku',
              frequency: HabitFrequency.custom,
            ),
          );
      final habit = await (db.select(db.habits)
            ..where((row) => row.id.equals(habitId)))
          .getSingle();

      expect(habit.customDaysOfWeek, isNull);
      expect(habit.customInterval, isNull);
      expect(habit.customDayOfMonth, isNull);
      expect(habit.customFrequencyType, isNull);
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('opens a version 2 database and adds performance indexes', () async {
    final tempDir = await Directory.systemTemp.createTemp('tazk_db_migration_');
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}tazk.sqlite');
    final db = AppDatabase.forTesting(
      NativeDatabase(
        dbFile,
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE tasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              date INTEGER NOT NULL,
              time INTEGER,
              priority INTEGER NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1)),
              location TEXT,
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
            );
          ''');
          rawDb.execute('''
            CREATE TABLE subtasks (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              task_id INTEGER NOT NULL REFERENCES tasks (id) ON DELETE CASCADE,
              title TEXT NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0 CHECK (is_completed IN (0, 1))
            );
          ''');
          rawDb.execute('''
            CREATE TABLE habits (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              frequency INTEGER NOT NULL,
              scheduled_time INTEGER,
              has_progress INTEGER NOT NULL DEFAULT 0 CHECK (has_progress IN (0, 1)),
              target_minutes INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
              created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
              custom_days_of_week INTEGER,
              custom_interval INTEGER,
              custom_day_of_month INTEGER,
              custom_frequency_type INTEGER
            );
          ''');
          rawDb.execute(
            "INSERT INTO tasks (id, title, date, priority) "
            "VALUES (1, 'Belanja bulanan', strftime('%s', 'now'), 1);",
          );
          rawDb.execute(
            "INSERT INTO habits (id, name, frequency) "
            "VALUES (1, 'Minum air', 0);",
          );
          rawDb.execute(
            "INSERT INTO subtasks (id, task_id, title) "
            "VALUES (1, 1, 'Beli susu');",
          );
          rawDb.execute('PRAGMA user_version = 2;');
        },
      ),
    );
    try {
      final task = await (db.select(db.tasks)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(task.title, 'Belanja bulanan');
      expect(task.priority, TaskPriority.medium);

      final habit = await (db.select(db.habits)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(habit.name, 'Minum air');
      expect(habit.frequency, HabitFrequency.daily);

      final subtask = await (db.select(db.subtasks)
            ..where((row) => row.id.equals(1)))
          .getSingle();
      expect(subtask.title, 'Beli susu');
      expect(subtask.taskId, task.id);

      Future<Set<String>> indexNames(String table) async {
        final rows = await db.customSelect("PRAGMA index_list('$table')").get();
        return rows.map((row) => row.read<String>('name')).toSet();
      }

      final taskIndexes = await indexNames('tasks');
      expect(
        taskIndexes,
        containsAll(['idx_tasks_date', 'idx_tasks_is_completed']),
      );

      final habitIndexes = await indexNames('habits');
      expect(habitIndexes, contains('idx_habits_is_active'));

      final subtaskIndexes = await indexNames('subtasks');
      expect(subtaskIndexes, contains('idx_subtasks_task_id'));
    } finally {
      await db.close();
      await tempDir.delete(recursive: true);
    }
  });
}
