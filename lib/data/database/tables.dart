import 'package:drift/drift.dart';

import '../models/enums.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get time => dateTime().nullable()();
  IntColumn get priority => intEnum<TaskPriority>()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get location => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get frequency => intEnum<HabitFrequency>()();
  DateTimeColumn get scheduledTime => dateTime().nullable()();
  BoolColumn get hasProgress => boolean().withDefault(const Constant(false))();
  IntColumn get targetMinutes => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get progressMinutes => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, date},
      ];
}

class StreakState extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  IntColumn get freezeCount => integer().withDefault(const Constant(0))();
  IntColumn get freezeProgressDays =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDate => dateTime().nullable()();
}

class BadgeUnlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rank => intEnum<StreakRank>()();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {rank},
      ];
}

class UserProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get avatarId => text().withDefault(const Constant('default'))();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
}

class CosmeticUnlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get levelMilestone => integer()();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {levelMilestone},
      ];
}

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get themeMode =>
      intEnum<AppThemeMode>().withDefault(const Constant(0))();
  IntColumn get language =>
      intEnum<AppLanguage>().withDefault(const Constant(0))();
  BoolColumn get notifyTasks => boolean().withDefault(const Constant(true))();
  BoolColumn get notifyHabits => boolean().withDefault(const Constant(true))();
  BoolColumn get notifyStreakWarning =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get notifyFreezeUsed =>
      boolean().withDefault(const Constant(true))();
}
