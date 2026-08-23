import '../../data/database/database.dart';
import '../../data/models/enums.dart';

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Shared due-date logic for habits — used by both the in-app repository
/// and the homescreen widget service so they never drift.
bool isHabitDueOnDate(Habit habit, DateTime date) {
  final checkDate = _dateOnly(date);
  switch (habit.frequency) {
    case HabitFrequency.daily:
      return true;
    case HabitFrequency.weekly:
      return checkDate.weekday == habit.createdAt.weekday;
    case HabitFrequency.monthly:
      return checkDate.day == habit.createdAt.day;
    case HabitFrequency.custom:
      return _isCustomDueOnDate(habit, checkDate);
  }
}

bool _isCustomDueOnDate(Habit habit, DateTime date) {
  final customType = habit.customFrequencyType ?? 0;
  switch (customType) {
    case 0:
      final daysOfWeek = habit.customDaysOfWeek ?? 0;
      if (daysOfWeek == 0) return false;
      final weekdayBit = 1 << (date.weekday - 1);
      return (daysOfWeek & weekdayBit) != 0;
    case 1:
      final interval = habit.customInterval ?? 1;
      if (interval <= 0) return false;
      final diffDays = date.difference(_dateOnly(habit.createdAt)).inDays;
      return diffDays % interval == 0;
    case 2:
      final dayOfMonth = habit.customDayOfMonth ?? 1;
      if (dayOfMonth < 1 || dayOfMonth > 31) return false;
      return date.day == dayOfMonth;
    default:
      return false;
  }
}
