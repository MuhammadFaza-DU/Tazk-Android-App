import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

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

  /// Check if a habit is due on a specific date based on its frequency and custom settings
  bool isDueOnDate(Habit habit, DateTime date) {
    final checkDate = _dateOnly(date);
    
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        // Check if the date is the same weekday as the habit's creation day
        return checkDate.weekday == habit.createdAt.weekday;
      case HabitFrequency.monthly:
        // Check if the date is the same day of month as the habit's creation day
        return checkDate.day == habit.createdAt.day;
      case HabitFrequency.custom:
        return _isCustomDueOnDate(habit, checkDate);
    }
  }

  bool _isCustomDueOnDate(Habit habit, DateTime date) {
    final customType = habit.customFrequencyType ?? 0;
    
    switch (customType) {
      case 0: // Weekly - specific days of week
        final daysOfWeek = habit.customDaysOfWeek ?? 0;
        if (daysOfWeek == 0) return false;
        // Bitmask: 1=Mon(1), 2=Tue(2), 4=Wed(3), 8=Thu(4), 16=Fri(5), 32=Sat(6), 64=Sun(7)
        final weekdayBit = 1 << (date.weekday - 1);
        return (daysOfWeek & weekdayBit) != 0;
      
      case 1: // Interval - every N days
        final interval = habit.customInterval ?? 1;
        if (interval <= 0) return false;
        final diffDays = date.difference(_dateOnly(habit.createdAt)).inDays;
        return diffDays % interval == 0;
      
      case 2: // Monthly - specific day of month
        final dayOfMonth = habit.customDayOfMonth ?? 1;
        if (dayOfMonth < 1 || dayOfMonth > 31) return false;
        return date.day == dayOfMonth;
      
      default:
        return false;
    }
  }

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

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
