import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/enums.dart';

class GamificationRepository {
  GamificationRepository(this._db);

  final AppDatabase _db;

  static const taskXp = 10;
  static const habitXp = 15;

  Future<UserProfileData> ensureProfile() async {
    final existing = await _db.select(_db.userProfile).getSingleOrNull();
    if (existing != null) return existing;
    final id =
        await _db.into(_db.userProfile).insert(const UserProfileCompanion());
    return (_db.select(_db.userProfile)..where((u) => u.id.equals(id)))
        .getSingle();
  }

  Stream<UserProfileData> watchProfile() {
    return _db.select(_db.userProfile).watchSingleOrNull().map(
          (profile) =>
              profile ??
              const UserProfileData(
                id: 0,
                name: '',
                avatarId: 'default',
                xp: 0,
                level: 1,
              ),
        );
  }

  Future<StreakStateData> ensureStreakState() async {
    final existing = await _db.select(_db.streakState).getSingleOrNull();
    if (existing != null) return existing;
    final id =
        await _db.into(_db.streakState).insert(const StreakStateCompanion());
    return (_db.select(_db.streakState)..where((s) => s.id.equals(id)))
        .getSingle();
  }

  Stream<StreakStateData> watchStreakState() {
    return _db.select(_db.streakState).watchSingleOrNull().map(
          (state) =>
              state ??
              const StreakStateData(
                id: 0,
                currentStreak: 0,
                longestStreak: 0,
                freezeCount: 0,
                freezeProgressDays: 0,
              ),
        );
  }

  Future<void> updateName(String name) async {
    final profile = await ensureProfile();
    await (_db.update(_db.userProfile)..where((u) => u.id.equals(profile.id)))
        .write(UserProfileCompanion(name: Value(name)));
  }

  Stream<List<BadgeUnlock>> watchBadges() => _db.select(_db.badgeUnlocks).watch();

  Stream<List<CosmeticUnlock>> watchCosmetics() =>
      _db.select(_db.cosmeticUnlocks).watch();

  Future<void> onTaskCompleted() async {
    await _awardXp(taskXp);
    await _registerActiveDay();
  }

  Future<void> onHabitCompleted() async {
    await _awardXp(habitXp);
    await _registerActiveDay();
  }

  Future<void> _awardXp(int amount) async {
    final profile = await ensureProfile();
    var xp = profile.xp + amount;
    var level = profile.level;
    var needed = 100 * level;
    while (xp >= needed) {
      xp -= needed;
      level += 1;
      needed = 100 * level;
      if (level % 10 == 0) {
        await _db.into(_db.cosmeticUnlocks).insertOnConflictUpdate(
              CosmeticUnlocksCompanion.insert(levelMilestone: level),
            );
      }
    }
    await (_db.update(_db.userProfile)..where((u) => u.id.equals(profile.id)))
        .write(UserProfileCompanion(xp: Value(xp), level: Value(level)));
  }

  Future<void> _registerActiveDay() async {
    final today = _dateOnly(DateTime.now());
    final state = await ensureStreakState();
    if (state.lastActiveDate != null &&
        _dateOnly(state.lastActiveDate!) == today) {
      return;
    }

    final yesterday = today.subtract(const Duration(days: 1));
    final continuesStreak = state.lastActiveDate != null &&
        _dateOnly(state.lastActiveDate!) == yesterday;

    final newStreak = continuesStreak ? state.currentStreak + 1 : 1;
    var freezeProgressDays =
        continuesStreak ? state.freezeProgressDays + 1 : 0;
    var freezeCount = state.freezeCount;
    if (freezeProgressDays >= 3) {
      freezeCount += 1;
      freezeProgressDays = 0;
    }

    await (_db.update(_db.streakState)..where((s) => s.id.equals(state.id)))
        .write(
      StreakStateCompanion(
        currentStreak: Value(newStreak),
        longestStreak: Value(
          newStreak > state.longestStreak ? newStreak : state.longestStreak,
        ),
        freezeCount: Value(freezeCount),
        freezeProgressDays: Value(freezeProgressDays),
        lastActiveDate: Value(today),
      ),
    );

    await _unlockBadgeIfNeeded(newStreak);
  }

  Future<void> _unlockBadgeIfNeeded(int streakDays) async {
    final rank = streakRankForDays(streakDays);
    await _db.into(_db.badgeUnlocks).insertOnConflictUpdate(
          BadgeUnlocksCompanion.insert(rank: rank),
        );
  }

  /// Breaks the streak (or consumes a freeze) when a full day has passed
  /// with no task/habit completion. Call once when the app opens.
  Future<void> evaluateMissedDay() async {
    final today = _dateOnly(DateTime.now());
    final state = await ensureStreakState();
    if (state.lastActiveDate == null) return;
    final lastActive = _dateOnly(state.lastActiveDate!);
    final daysSinceActive = today.difference(lastActive).inDays;
    if (daysSinceActive <= 1) return;

    if (state.freezeCount > 0) {
      await (_db.update(_db.streakState)..where((s) => s.id.equals(state.id)))
          .write(
        StreakStateCompanion(
          freezeCount: Value(state.freezeCount - 1),
          lastActiveDate: Value(today.subtract(const Duration(days: 1))),
        ),
      );
    } else {
      await (_db.update(_db.streakState)..where((s) => s.id.equals(state.id)))
          .write(
        const StreakStateCompanion(
          currentStreak: Value(0),
          freezeProgressDays: Value(0),
        ),
      );
    }
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
