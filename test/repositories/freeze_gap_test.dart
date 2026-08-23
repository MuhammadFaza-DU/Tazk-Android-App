import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

Future<GamificationRepository> _setupWithStreak(
  AppDatabase db, {
  required DateTime lastActive,
  int currentStreak = 5,
  int freezeCount = 1,
}) async {
  final notifications = NotificationService.instance;
  final settings = SettingsRepository(db);
  final widgets = HomeWidgetService(db, settings);
  final gamification = GamificationRepository(db, notifications, settings, widgets);
  // Ensure row exists then overwrite with test values.
  await gamification.ensureStreakState();
  final existing = await db.select(db.streakState).getSingle();
  await (db.update(db.streakState)..where((s) => s.id.equals(existing.id))).write(
    StreakStateCompanion(
      currentStreak: Value(currentStreak),
      lastActiveDate: Value(lastActive),
      freezeCount: Value(freezeCount),
      freezeProgressDays: Value(0),
    ),
  );
  return gamification;
}

void main() {
  test('evaluateMissedDay with 2-day gap and 1 freeze should reset streak (not forgive all)', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    final today = DateTime.now();
    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    final lastActive = dateOnly(today).subtract(const Duration(days: 3));

    final gamification = await _setupWithStreak(db, lastActive: lastActive, currentStreak: 5, freezeCount: 1);

    await gamification.evaluateMissedDay();

    final state = await db.select(db.streakState).getSingle();
    // Gap is 2 missed days (today-2 and today-1). 1 freeze insufficient -> streak must reset.
    expect(state.currentStreak, 0, reason: 'insufficient freezes -> streak reset');
    expect(state.freezeCount, 0, reason: 'the single freeze was consumed');
  });

  test('evaluateMissedDay with 2-day gap and 2 freezes should preserve streak', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    final today = DateTime.now();
    DateTime dateOnly2(DateTime d) => DateTime(d.year, d.month, d.day);
    final lastActive = dateOnly2(today).subtract(const Duration(days: 3));

    final gamification = await _setupWithStreak(db, lastActive: lastActive, currentStreak: 5, freezeCount: 2);

    await gamification.evaluateMissedDay();

    final state = await db.select(db.streakState).getSingle();
    expect(state.currentStreak, 5, reason: '2 freezes cover 2 missed days');
    expect(state.freezeCount, 0);
  });
}
