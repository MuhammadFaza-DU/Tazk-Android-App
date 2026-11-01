import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

void main() {
  late AppDatabase db;
  late GamificationRepository gamification;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final notifications = NotificationService.instance;
    final settings = SettingsRepository(db);
    final widgets = HomeWidgetService(db, settings);
    gamification = GamificationRepository(db, notifications, settings, widgets);
  });

  tearDown(() async {
    await db.close();
  });

  test('ensureProfile creates default profile', () async {
    final profile = await gamification.ensureProfile();

    expect(profile.name, '');
    expect(profile.avatarId, 'default');
    expect(profile.xp, 0);
    expect(profile.level, 1);
  });

  test('onTaskCompleted grants XP and starts streak', () async {
    await gamification.onTaskCompleted(TaskPriority.medium);

    final profile = await db.select(db.userProfile).getSingle();
    final streak = await db.select(db.streakState).getSingle();

    expect(profile.xp, GamificationRepository.taskXpFor(TaskPriority.medium));
    expect(profile.level, 1);
    expect(streak.currentStreak, 1);
    expect(streak.longestStreak, 1);
    expect(streak.lastActiveDate, isNotNull);
  });

  test('taskXpFor weights XP by task priority', () {
    expect(GamificationRepository.taskXpFor(TaskPriority.high), 15);
    expect(GamificationRepository.taskXpFor(TaskPriority.medium), 10);
    expect(GamificationRepository.taskXpFor(TaskPriority.low), 5);
  });

  test('sequential completions accumulate priority-weighted XP', () async {
    await gamification.onTaskCompleted(TaskPriority.high);
    final afterHigh = await db.select(db.userProfile).getSingle();
    await gamification.onTaskCompleted(TaskPriority.medium);
    final afterMedium = await db.select(db.userProfile).getSingle();
    await gamification.onTaskCompleted(TaskPriority.low);
    final afterLow = await db.select(db.userProfile).getSingle();

    expect(afterHigh.xp, 15);
    expect(afterMedium.xp, 25);
    expect(afterLow.xp, 30);
  });

  for (final priority in TaskPriority.values) {
    test('uncompleting a ${priority.name} task refunds its exact XP', () async {
      await gamification.onTaskCompleted(priority);
      final completed = await db.select(db.userProfile).getSingle();

      await gamification.onTaskUncompleted(priority);
      final refunded = await db.select(db.userProfile).getSingle();

      expect(completed.xp, GamificationRepository.taskXpFor(priority));
      expect(refunded.xp, 0);
      expect(refunded.level, completed.level);
    });
  }

  test('streak rank milestone unlocks permanent badge', () async {
    final yesterday = _dateOnly(DateTime.now()).subtract(const Duration(days: 1));
    final state = await gamification.ensureStreakState();
    await (db.update(db.streakState)..where((row) => row.id.equals(state.id)))
        .write(
      StreakStateCompanion(
        currentStreak: const Value(6),
        longestStreak: const Value(6),
        freezeProgressDays: const Value(1),
        lastActiveDate: Value(yesterday),
      ),
    );

    await gamification.onHabitCompleted();

    final badges = await db.select(db.badgeUnlocks).get();
    final streak = await db.select(db.streakState).getSingle();

    expect(streak.currentStreak, 7);
    expect(badges.map((badge) => badge.rank), contains(StreakRank.petarung));
  });

  test('third consecutive active day awards a freeze', () async {
    final yesterday = _dateOnly(DateTime.now()).subtract(const Duration(days: 1));
    final state = await gamification.ensureStreakState();
    await (db.update(db.streakState)..where((row) => row.id.equals(state.id)))
        .write(
      StreakStateCompanion(
        currentStreak: const Value(2),
        longestStreak: const Value(2),
        freezeProgressDays: const Value(2),
        lastActiveDate: Value(yesterday),
      ),
    );

    await gamification.onTaskCompleted(TaskPriority.low);

    final streak = await db.select(db.streakState).getSingle();

    expect(streak.currentStreak, 3);
    expect(streak.freezeCount, 1);
    expect(streak.freezeProgressDays, 0);
  });

  test('evaluateMissedDay consumes freeze before resetting streak', () async {
    final twoDaysAgo = _dateOnly(DateTime.now()).subtract(const Duration(days: 2));
    final state = await gamification.ensureStreakState();
    await (db.update(db.streakState)..where((row) => row.id.equals(state.id)))
        .write(
      StreakStateCompanion(
        currentStreak: const Value(8),
        longestStreak: const Value(8),
        freezeCount: const Value(1),
        lastActiveDate: Value(twoDaysAgo),
      ),
    );

    await gamification.evaluateMissedDay();

    final streak = await db.select(db.streakState).getSingle();

    expect(streak.currentStreak, 8);
    expect(streak.freezeCount, 0);
    expect(
      _dateOnly(streak.lastActiveDate!),
      _dateOnly(DateTime.now()).subtract(const Duration(days: 1)),
    );
  });

  test('level 10 unlocks cosmetic milestone', () async {
    final profile = await gamification.ensureProfile();
    await (db.update(db.userProfile)..where((row) => row.id.equals(profile.id)))
        .write(
      const UserProfileCompanion(
        level: Value(9),
        xp: Value(899),
      ),
    );

    await gamification.onTaskCompleted(TaskPriority.medium);

    final updatedProfile = await db.select(db.userProfile).getSingle();
    final cosmetics = await db.select(db.cosmeticUnlocks).get();

    expect(updatedProfile.level, 10);
    expect(cosmetics.map((cosmetic) => cosmetic.levelMilestone), contains(10));
  });
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
