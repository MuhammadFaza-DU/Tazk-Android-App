import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/enums.dart';
import 'gamification_repository.dart';

class HabitRepository {
  HabitRepository(this._db, this._gamification);

  final AppDatabase _db;
  final GamificationRepository _gamification;

  Stream<List<Habit>> watchActiveHabits() {
    return (_db.select(_db.habits)..where((h) => h.isActive.equals(true)))
        .watch();
  }

  Stream<HabitLog?> watchTodayLog(int habitId) {
    final today = _dateOnly(DateTime.now());
    return (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(today)))
        .watchSingleOrNull();
  }

  Stream<List<HabitLog>> watchHistory(int habitId) {
    return (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId))
          ..orderBy(
            [(l) => OrderingTerm(expression: l.date, mode: OrderingMode.desc)],
          ))
        .watch();
  }

  Future<int> createHabit({
    required String name,
    required HabitFrequency frequency,
    DateTime? scheduledTime,
    bool hasProgress = false,
    int? targetMinutes,
  }) {
    return _db.into(_db.habits).insert(HabitsCompanion.insert(
          name: name,
          frequency: frequency,
          scheduledTime: Value(scheduledTime),
          hasProgress: Value(hasProgress),
          targetMinutes: Value(targetMinutes),
        ));
  }

  Future<void> updateHabit(Habit habit) => _db.update(_db.habits).replace(habit);

  Future<void> deactivateHabit(int id) async {
    await (_db.update(_db.habits)..where((h) => h.id.equals(id)))
        .write(const HabitsCompanion(isActive: Value(false)));
  }

  Future<void> logProgress(int habitId, int minutes) async {
    final today = _dateOnly(DateTime.now());
    final existing = await (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(today)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.habitLogs).insert(HabitLogsCompanion.insert(
            habitId: habitId,
            date: today,
            progressMinutes: Value(minutes),
          ));
      return;
    }
    await (_db.update(_db.habitLogs)..where((l) => l.id.equals(existing.id)))
        .write(
      HabitLogsCompanion(
        progressMinutes: Value(existing.progressMinutes + minutes),
      ),
    );
  }

  Future<void> completeHabitToday(int habitId) async {
    final today = _dateOnly(DateTime.now());
    await _db.transaction(() async {
      final existing = await (_db.select(_db.habitLogs)
            ..where((l) => l.habitId.equals(habitId) & l.date.equals(today)))
          .getSingleOrNull();

      if (existing == null) {
        await _db.into(_db.habitLogs).insert(HabitLogsCompanion.insert(
              habitId: habitId,
              date: today,
              isCompleted: const Value(true),
            ));
      } else {
        if (existing.isCompleted) return;
        await (_db.update(_db.habitLogs)..where((l) => l.id.equals(existing.id)))
            .write(const HabitLogsCompanion(isCompleted: Value(true)));
      }
      await _gamification.onHabitCompleted();
    });
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
