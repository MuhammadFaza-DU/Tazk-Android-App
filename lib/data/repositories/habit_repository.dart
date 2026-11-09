import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import '../../core/utils/habit_due.dart' as habit_due;
import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import '../../widgets/home_widget_service.dart';
import '../database/database.dart';
import '../models/enums.dart';
import 'gamification_repository.dart';
import 'settings_repository.dart';

class HabitRepository {
  HabitRepository(
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
      habitRepository: this,
      habit: habit,
    );
  }

  Stream<List<Habit>> watchActiveHabits() {
    return (_db.select(_db.habits)..where((h) => h.isActive.equals(true)))
        .watch();
  }

  Stream<HabitLog?> watchLogForDate(int habitId, DateTime date) {
    final day = _dateOnly(date);
    return (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(day)))
        .watchSingleOrNull();
  }

  Stream<HabitLog?> watchTodayLog(int habitId) =>
      watchLogForDate(habitId, DateTime.now());

  Stream<List<HabitLog>> watchHistory(int habitId) {
    return (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId))
          ..orderBy(
            [(l) => OrderingTerm(expression: l.date, mode: OrderingMode.desc)],
          ))
        .watch();
  }

  Stream<List<HabitLog>> watchLogsForDate(DateTime date) {
    final day = _dateOnly(date);
    return (_db.select(_db.habitLogs)..where((l) => l.date.equals(day))).watch();
  }

  Future<int> createHabit({
    required String name,
    required HabitFrequency frequency,
    DateTime? scheduledTime,
    bool hasProgress = false,
    int? targetMinutes,
    // Custom frequency fields
    int? customDaysOfWeek,
    int? customInterval,
    int? customDayOfMonth,
    int? customFrequencyType,
  }) async {
    final id = await _db.into(_db.habits).insert(HabitsCompanion.insert(
          name: name,
          frequency: frequency,
          scheduledTime: Value(scheduledTime),
          hasProgress: Value(hasProgress),
          targetMinutes: Value(targetMinutes),
          customDaysOfWeek: Value(customDaysOfWeek),
          customInterval: Value(customInterval),
          customDayOfMonth: Value(customDayOfMonth),
          customFrequencyType: Value(customFrequencyType),
        ));
    final habit = await (_db.select(_db.habits)..where((h) => h.id.equals(id))).getSingle();
    await _scheduleReminder(habit);
    await _widget.refreshAll();
    return id;
  }

  Future<void> updateHabit(Habit habit) async {
    await _db.update(_db.habits).replace(habit);
    if (habit.isActive) {
      await _scheduleReminder(habit);
    } else {
      await _notifications.cancelHabitReminder(habit.id);
    }
    await _widget.refreshAll();
  }

  Future<void> deactivateHabit(int id) async {
    await (_db.update(_db.habits)..where((h) => h.id.equals(id)))
        .write(const HabitsCompanion(isActive: Value(false)));
    await _notifications.cancelHabitReminder(id);
    await _widget.refreshAll();
  }

  bool isDueOnDate(Habit habit, DateTime date) => habit_due.isHabitDueOnDate(habit, date);

  /// Check if a habit is due today based on its frequency and custom settings
  bool isDueToday(Habit habit) {
    return isDueOnDate(habit, DateTime.now());
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
    } else {
      await (_db.update(_db.habitLogs)..where((l) => l.id.equals(existing.id)))
          .write(
        HabitLogsCompanion(
          progressMinutes: Value(existing.progressMinutes + minutes),
        ),
      );
    }
    await _widget.refreshAll();
  }

  Future<void> completeHabitToday(int habitId) async {
    await completeHabitOnDate(habitId, DateTime.now());
  }

  Future<void> completeHabitOnDate(int habitId, DateTime date) async {
    final targetDate = _dateOnly(date);
    final today = _dateOnly(DateTime.now());
    final shouldApplyGamification = targetDate == today;
    await _db.transaction(() async {
      final existing = await (_db.select(_db.habitLogs)
            ..where((l) => l.habitId.equals(habitId) & l.date.equals(targetDate)))
          .getSingleOrNull();

      if (existing == null) {
        await _db.into(_db.habitLogs).insert(HabitLogsCompanion.insert(
              habitId: habitId,
              date: targetDate,
              isCompleted: const Value(true),
            ));
      } else {
        if (existing.isCompleted) return;
        await (_db.update(_db.habitLogs)..where((l) => l.id.equals(existing.id)))
            .write(const HabitLogsCompanion(isCompleted: Value(true)));
      }
      if (shouldApplyGamification) {
        await _gamification.onHabitCompleted();
      }
    });
    if (shouldApplyGamification) {
      await _gamification.refreshStreakWarningNotification();
    }
    await _widget.refreshAll();
  }

  /// PRD gap F: allow toggling a completed habit back to incomplete for a
  /// specific date (calendar vs today).
  Future<void> uncompleteHabitOnDate(int habitId, DateTime date) async {
    final targetDate = _dateOnly(date);
    final existing = await (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(targetDate)))
        .getSingleOrNull();
    if (existing == null || !existing.isCompleted) return;
    await _db.transaction(() async {
      await (_db.update(_db.habitLogs)..where((l) => l.id.equals(existing.id)))
          .write(const HabitLogsCompanion(isCompleted: Value(false)));
      final today = _dateOnly(DateTime.now());
      if (targetDate == today) {
        await _gamification.onHabitUncompleted();
      }
    });
    await _widget.refreshAll();
  }

  Future<void> uncompleteHabitToday(int habitId) async {
    await uncompleteHabitOnDate(habitId, DateTime.now());
  }

  /// Toggle used by the widgets: complete today's habit or undo it.
  Future<void> toggleHabitToday(int habitId) =>
      toggleHabitOnDate(habitId, DateTime.now());

  /// Toggle used by the widgets: complete a habit for [date] or undo it.
  Future<void> toggleHabitOnDate(int habitId, DateTime date) async {
    final targetDate = _dateOnly(date);
    final log = await (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.equals(habitId) & l.date.equals(targetDate)))
        .getSingleOrNull();
    if (log != null && log.isCompleted) {
      await uncompleteHabitOnDate(habitId, date);
    } else {
      await completeHabitOnDate(habitId, date);
    }
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Re-arms reminders for every active habit, sliding the non-daily reminder
  /// window forward so it never runs out of scheduled occurrences. Idempotent:
  /// [_scheduleReminder] cancels before scheduling.
  Future<void> rescheduleAllReminders() async {
    final habits = await (_db.select(_db.habits)
          ..where((h) => h.isActive.equals(true)))
        .get();
    for (final habit in habits) {
      await _scheduleReminder(habit);
    }
  }
}
