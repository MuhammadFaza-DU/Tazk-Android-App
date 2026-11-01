import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/enums.dart';
import 'database_recovery.dart';
import 'tables.dart';

part 'database.g.dart';

/// Set to true once per app run when the database file was found corrupt and
/// had to be moved aside so a fresh one could start. The UI reads this to
/// explain the reset to the user (PRD "Error States").
final databaseRecoveredFromCorruption = ValueNotifier<bool>(false);

@DriftDatabase(tables: [
  Tasks,
  Subtasks,
  Habits,
  HabitLogs,
  StreakState,
  BadgeUnlocks,
  UserProfile,
  CosmeticUnlocks,
  AppSettings,
  FocusSessions,
  XpEvents,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createAll();
            await _addHabitColumnIfMissing(m, habits.customDaysOfWeek);
            await _addHabitColumnIfMissing(m, habits.customInterval);
            await _addHabitColumnIfMissing(m, habits.customDayOfMonth);
            await _addHabitColumnIfMissing(m, habits.customFrequencyType);
          }
          if (from < 3) {
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_tasks_date ON tasks(date);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_tasks_is_completed ON tasks(is_completed);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_habits_is_active ON habits(is_active);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_subtasks_task_id ON subtasks(task_id);');
          }
          if (from < 4) {
            await m.createTable(focusSessions);
            await m.createTable(xpEvents);
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_xp_events_created_at ON xp_events(created_at);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_focus_sessions_started_at ON focus_sessions(started_at);');
          }
          if (from < 5) {
            await _addColumnIfMissing(m, subtasks, subtasks.position);
            await _addColumnIfMissing(m, tasks, tasks.autoCompleteSubtasks);
            // v4 had no position column, so every row defaults to 0. Seed it from
            // id to preserve insertion order for existing tasks.
            await customStatement(
                'UPDATE subtasks SET position = id WHERE position = 0;');
          }
        },
      );

  Future<void> _addColumnIfMissing(
    Migrator migrator,
    TableInfo<Table, dynamic> table,
    GeneratedColumn<Object> column,
  ) async {
    final existingColumns = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final columnExists = existingColumns.any(
      (row) => row.read<String>('name') == column.name,
    );
    if (!columnExists) {
      await migrator.addColumn(table, column);
    }
  }

  Future<void> _addHabitColumnIfMissing(
    Migrator migrator,
    GeneratedColumn<Object> column,
  ) async {
    final existingColumns = await customSelect('PRAGMA table_info(habits)').get();
    final columnExists = existingColumns.any(
      (row) => row.read<String>('name') == column.name,
    );
    if (!columnExists) {
      await migrator.addColumn(habits, column);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tazk.sqlite'));
    final recovery = await ensureHealthyDatabaseFile(file.path);
    if (recovery.quarantined) {
      debugPrint(
        'AppDatabase: corrupt database quarantined, starting fresh '
        '(backup at ${p.basename(file.path)}.corrupt-*)',
      );
      databaseRecoveredFromCorruption.value = true;
    }
    return NativeDatabase.createInBackground(file);
  });
}
