import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/enums.dart';
import 'tables.dart';

part 'database.g.dart';

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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

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
        },
      );

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
    return NativeDatabase.createInBackground(file);
  });
}
