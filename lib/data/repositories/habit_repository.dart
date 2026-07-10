import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import '../database/database.dart';
import '../models/enums.dart';
import 'gamification_repository.dart';
import 'settings_repository.dart';

class HabitRepository {
  HabitRepository(this._db, this._gamification, this._notifications, this._settings);

  final AppDatabase _db;
  final GamificationRepository _gamification;
  final NotificationService _notifications;
  final SettingsRepository _settings;

  Future<void> _scheduleReminder(Habit habit) async {
    final settings = await _settings.ensureSettings();
    if (!settings.notifyHabits) {
      await _notifications.cancelHabitReminder(habit.id);
      return;
    }
    final l10n = lookupAppLocalizations(
      Locale(settings.language == AppLanguage.english ? 'en' : 'id'),
    );
    await _notifications.scheduleHabitReminder(
      habitId: habit.id,
      title: l10n.notifHabitReminderTitle(habit.name),
      body: l10n.notifHabitReminderBody,
      scheduledTime: habit.scheduledTime,
    );
  }

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
  }) async {
    final id = await _db.into(_db.habits).insert(HabitsCompanion.insert(
          name: name,
          frequency: frequency,
          scheduledTime: Value(scheduledTime),
          hasProgress: Value(hasProgress),
          targetMinutes: Value(targetMinutes),
        ));
    final habit = await (_db.select(_db.habits)..where((h) => h.id.equals(id))).getSingle();
    await _scheduleReminder(habit);
    return id;
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.update(_db.habits).replace(habit);
    if (habit.isActive) {
      await _scheduleReminder(habit);
    } else {
      await _notifications.cancelHabitReminder(habit.id);
    }
  }

  Future<void> deactivateHabit(int id) async {
    await (_db.update(_db.habits)..where((h) => h.id.equals(id)))
        .write(const HabitsCompanion(isActive: Value(false)));
    await _notifications.cancelHabitReminder(id);
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
    await _gamification.refreshStreakWarningNotification();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
