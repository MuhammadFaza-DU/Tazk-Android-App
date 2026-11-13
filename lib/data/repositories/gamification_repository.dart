import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../notifications/notification_service.dart';
import '../../widgets/home_widget_service.dart';
import '../database/database.dart';
import '../models/enums.dart';
import 'settings_repository.dart';

class GamificationRepository {
  GamificationRepository(
    this._db,
    this._notifications,
    this._settings,
    this._widget, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final NotificationService _notifications;
  final SettingsRepository _settings;
  // Widget refreshes are now owned by the calling repositories/services, but
  // the service is retained on the public constructor for call-site stability.
  // ignore: unused_field
  final HomeWidgetService _widget;
  final DateTime Function() _now;

  Future<AppLocalizations> _l10n() async {
    final settings = await _settings.ensureSettings();
    return lookupAppLocalizations(
      Locale(settings.language == AppLanguage.english ? 'en' : 'id'),
    );
  }

  static const habitXp = 15;

  static int taskXpFor(TaskPriority priority) => switch (priority) {
        TaskPriority.high => 15,
        TaskPriority.medium => 10,
        TaskPriority.low => 5,
      };

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
              UserProfileData(
                id: 0,
                name: '',
                avatarId: 'default',
                xp: 0,
                level: 1,
                createdAt: DateTime.now(),
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

  Future<void> updateAvatar(String avatarId) async {
    final profile = await ensureProfile();
    await (_db.update(_db.userProfile)..where((u) => u.id.equals(profile.id)))
        .write(UserProfileCompanion(avatarId: Value(avatarId)));
  }

  Stream<List<BadgeUnlock>> watchBadges() => _db.select(_db.badgeUnlocks).watch();

  Stream<List<CosmeticUnlock>> watchCosmetics() =>
      _db.select(_db.cosmeticUnlocks).watch();

  Future<void> onTaskCompleted(TaskPriority priority) async {
    await _awardXp(taskXpFor(priority), XpSource.task);
    await _registerActiveDay();
  }

  Future<void> onTaskUncompleted(TaskPriority priority) async {
    await _deductXp(taskXpFor(priority), XpSource.task);
  }

  /// Re-settles XP when a completed task's priority is edited, so a later
  /// uncheck refunds exactly what the task is already holding.
  Future<void> onTaskPriorityChanged(TaskPriority from, TaskPriority to) async {
    final delta = taskXpFor(to) - taskXpFor(from);
    if (delta > 0) {
      await _awardXp(delta, XpSource.task);
    } else if (delta < 0) {
      await _deductXp(-delta, XpSource.task);
    }
  }

  Future<void> onHabitCompleted() async {
    await _awardXp(habitXp, XpSource.habit);
    await _registerActiveDay();
  }

  Future<void> onHabitUncompleted() async {
    await _deductXp(habitXp, XpSource.habit);
  }

  Future<void> _awardXp(int amount, XpSource source) async {
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
    await _db.into(_db.xpEvents).insert(
          XpEventsCompanion.insert(amount: amount, source: source),
        );
  }

  Future<void> _deductXp(int amount, XpSource source) async {
    final profile = await ensureProfile();
    var xp = profile.xp - amount;
    var level = profile.level;
    while (xp < 0 && level > 1) {
      level -= 1;
      final needed = 100 * level;
      xp += needed;
    }
    if (xp < 0) xp = 0;
    await (_db.update(_db.userProfile)..where((u) => u.id.equals(profile.id)))
        .write(UserProfileCompanion(xp: Value(xp), level: Value(level)));
    await _db.into(_db.xpEvents).insert(
          XpEventsCompanion.insert(amount: -amount, source: source),
        );
  }

  Future<void> _registerActiveDay() async {
    final today = _dateOnly(_now());
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

    // Today now has an activity, so tonight's "you haven't done anything
    // yet" warning is no longer applicable.
    await _notifications.cancelStreakWarning();

    await _unlockBadgeIfNeeded(newStreak);
  }

  /// Schedules or cancels tonight's streak-warning notification depending on
  /// whether the user has already completed a task/habit today. Call once
  /// when the app opens (after [evaluateMissedDay]).
  Future<void> refreshStreakWarningNotification() async {
    final settings = await _settings.ensureSettings();
    if (!settings.notifyStreakWarning) {
      await _notifications.cancelStreakWarning();
      return;
    }

    final state = await ensureStreakState();
    final today = _dateOnly(_now());
    final alreadyActiveToday =
        state.lastActiveDate != null && _dateOnly(state.lastActiveDate!) == today;

    if (alreadyActiveToday) {
      await _notifications.cancelStreakWarning();
      return;
    }

    final l10n = await _l10n();
    await _notifications.scheduleTonightsStreakWarning(
      title: l10n.notifStreakWarningTitle,
      body: l10n.notifStreakWarningBody,
    );
  }

  Future<void> _unlockBadgeIfNeeded(int streakDays) async {
    final rank = streakRankForDays(streakDays);
    await _db.into(_db.badgeUnlocks).insert(
          BadgeUnlocksCompanion.insert(rank: rank),
          onConflict: DoNothing(target: [_db.badgeUnlocks.rank]),
        );
  }

  /// Breaks the streak (or consumes freezes) when full days have passed
  /// with no task/habit completion. Call once when the app opens. Each missed
  /// day needs its own freeze; one freeze cannot forgive a multi-day gap.
  Future<void> evaluateMissedDay() async {
    final today = _dateOnly(_now());
    final state = await ensureStreakState();
    if (state.lastActiveDate == null) return;
    final lastActive = _dateOnly(state.lastActiveDate!);
    final daysSinceActive = today.difference(lastActive).inDays;
    if (daysSinceActive <= 1) return;

    final missedDays = daysSinceActive - 1;
    final freezesToUse = missedDays < state.freezeCount ? missedDays : state.freezeCount;
    final remainingMissed = missedDays - freezesToUse;
    final newFreezeCount = state.freezeCount - freezesToUse;

    if (remainingMissed > 0) {
      // Not enough freezes to cover the gap — streak breaks.
      await (_db.update(_db.streakState)..where((s) => s.id.equals(state.id)))
          .write(
        StreakStateCompanion(
          currentStreak: const Value(0),
          freezeProgressDays: const Value(0),
          freezeCount: Value(newFreezeCount),
        ),
      );
      // A reset used to happen silently: the user saw the number drop with no
      // explanation and reasonably assumed the streak was broken code.
      final settings = await _settings.ensureSettings();
      if (settings.notifyStreakWarning) {
        final l10n = await _l10n();
        await _notifications.showStreakBrokenNotification(
          title: l10n.streakBrokenTitle,
          body: l10n.streakBrokenBody,
        );
      }
    } else {
      // All missed days covered by freezes — streak survives.
      await (_db.update(_db.streakState)..where((s) => s.id.equals(state.id)))
          .write(
        StreakStateCompanion(
          freezeCount: Value(newFreezeCount),
          lastActiveDate: Value(today.subtract(const Duration(days: 1))),
        ),
      );
      if (freezesToUse > 0) {
        final settings = await _settings.ensureSettings();
        if (settings.notifyFreezeUsed) {
          final l10n = await _l10n();
          await _notifications.showFreezeUsedNotification(
            title: l10n.notifFreezeUsedTitle,
            body: l10n.notifFreezeUsedBody,
          );
        }
      }
    }
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Days (date-only, oldest first) on which at least one completion stuck.
  ///
  /// Positive `xp_events` are the only trustworthy marker: habit logs back-
  /// filled through the calendar and a task's due date both leave rows without
  /// ever advancing the streak, so counting them would invent history. Amounts
  /// are summed per day so a completion that was later undone nets back to zero
  /// instead of leaving the day marked active forever.
  Future<List<DateTime>> activeDays({int lookbackDays = 60}) async {
    final start = _dateOnly(_now()).subtract(Duration(days: lookbackDays));
    final rows = await (_db.select(_db.xpEvents)
          ..where((e) => e.createdAt.isBiggerOrEqualValue(start)))
        .get();
    return _netActiveDays(rows);
  }

  /// Reactive version of [activeDays] for the profile history strip.
  Stream<List<DateTime>> watchActiveDays({int lookbackDays = 6}) {
    final start = _dateOnly(_now()).subtract(Duration(days: lookbackDays));
    return (_db.select(_db.xpEvents)
          ..where((e) => e.createdAt.isBiggerOrEqualValue(start)))
        .watch()
        .map(_netActiveDays);
  }

  List<DateTime> _netActiveDays(Iterable<XpEvent> events) {
    final net = <DateTime, int>{};
    for (final event in events) {
      final day = _dateOnly(event.createdAt);
      net[day] = (net[day] ?? 0) + event.amount;
    }
    final days = net.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();
    return days;
  }

  /// Consecutive active days ending today, or ending yesterday when today has
  /// no completion yet. An unfinished today must not read as a broken streak.
  Future<int> streakFromHistory({int lookbackDays = 400}) async {
    final active = (await activeDays(lookbackDays: lookbackDays)).toSet();
    final today = _dateOnly(_now());
    var cursor = active.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    var streak = 0;
    while (active.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Raises a stored streak that drifted below the real history.
  ///
  /// Monotonic on purpose: it never lowers a value, so a streak kept alive by a
  /// freeze stays intact, and running it on every app open is idempotent.
  /// Returns whether anything was written.
  Future<bool> repairStreakFromHistory({int lookbackDays = 400}) async {
    final computed = await streakFromHistory(lookbackDays: lookbackDays);
    final state = await ensureStreakState();
    final newCurrent =
        computed > state.currentStreak ? computed : state.currentStreak;
    final newLongest =
        computed > state.longestStreak ? computed : state.longestStreak;
    if (newCurrent == state.currentStreak &&
        newLongest == state.longestStreak) {
      return false;
    }

    final active = await activeDays(lookbackDays: lookbackDays);
    final today = _dateOnly(_now());
    final lastActive = active.isEmpty
        ? state.lastActiveDate
        : (active.contains(today)
            ? today
            : today.subtract(const Duration(days: 1)));

    await (_db.update(_db.streakState)..where((s) => s.id.equals(state.id)))
        .write(
      StreakStateCompanion(
        currentStreak: Value(newCurrent),
        longestStreak: Value(newLongest),
        lastActiveDate: Value(lastActive),
      ),
    );
    await _unlockBadgeIfNeeded(newCurrent);
    return true;
  }
}
