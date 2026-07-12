import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/habit_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

void main() {
  late AppDatabase db;
  late HabitRepository habits;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final notifications = NotificationService.instance;
    final settings = SettingsRepository(db);
    final widgets = HomeWidgetService(db, settings);
    final gamification =
        GamificationRepository(db, notifications, settings, widgets);
    habits = HabitRepository(db, gamification, notifications, settings, widgets);
  });

  tearDown(() async {
    await db.close();
  });

  test('createHabit stores active habit metadata', () async {
    final time = DateTime(2026, 7, 11, 6, 30);

    final id = await habits.createHabit(
      name: 'Olahraga pagi',
      frequency: HabitFrequency.daily,
      scheduledTime: time,
      hasProgress: true,
      targetMinutes: 30,
    );

    final habit =
        await (db.select(db.habits)..where((row) => row.id.equals(id)))
            .getSingle();

    expect(habit.name, 'Olahraga pagi');
    expect(habit.frequency, HabitFrequency.daily);
    expect(habit.scheduledTime, time);
    expect(habit.hasProgress, isTrue);
    expect(habit.targetMinutes, 30);
    expect(habit.isActive, isTrue);
  });

  test('logProgress creates and increments today progress', () async {
    final habitId = await habits.createHabit(
      name: 'Baca buku',
      frequency: HabitFrequency.daily,
      hasProgress: true,
      targetMinutes: 45,
    );

    await habits.logProgress(habitId, 15);
    await habits.logProgress(habitId, 20);

    final logs = await (db.select(db.habitLogs)
          ..where((row) => row.habitId.equals(habitId)))
        .get();

    expect(logs, hasLength(1));
    expect(logs.single.progressMinutes, 35);
    expect(logs.single.isCompleted, isFalse);
  });

  test('completeHabitToday marks today complete only once', () async {
    final habitId = await habits.createHabit(
      name: 'Meditasi',
      frequency: HabitFrequency.daily,
    );

    await habits.completeHabitToday(habitId);
    await habits.completeHabitToday(habitId);

    final logs = await (db.select(db.habitLogs)
          ..where((row) => row.habitId.equals(habitId)))
        .get();
    final profile = await db.select(db.userProfile).getSingle();

    expect(logs, hasLength(1));
    expect(logs.single.isCompleted, isTrue);
    expect(profile.xp, 15);
  });

  test('deactivateHabit keeps history and marks habit inactive', () async {
    final habitId = await habits.createHabit(
      name: 'Minum air',
      frequency: HabitFrequency.daily,
    );
    await habits.completeHabitToday(habitId);

    await habits.deactivateHabit(habitId);

    final habit =
        await (db.select(db.habits)..where((row) => row.id.equals(habitId)))
            .getSingle();
    final logs = await (db.select(db.habitLogs)
          ..where((row) => row.habitId.equals(habitId)))
        .get();

    expect(habit.isActive, isFalse);
    expect(logs, hasLength(1));
    expect(logs.single.isCompleted, isTrue);
  });
}
