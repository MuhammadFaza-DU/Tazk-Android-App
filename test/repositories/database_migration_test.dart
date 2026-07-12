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
}
