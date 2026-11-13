import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/gamification_repository.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/notifications/notification_service.dart';
import 'package:tazk/widgets/home_widget_service.dart';

/// Riwayat hari aktif + perbaikan streak.
///
/// Sumber kebenaran "hari itu ada penyelesaian" adalah `xp_events` dengan
/// jumlah positif: log habit yang diisi mundur lewat kalender dan tanggal jatuh
/// tempo task tidak pernah menaikkan streak, jadi keduanya tidak boleh dihitung.
void main() {
  late AppDatabase db;
  late GamificationRepository gamification;
  late DateTime now;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final settings = SettingsRepository(db);
    gamification = GamificationRepository(
      db,
      NotificationService.instance,
      settings,
      HomeWidgetService(db, settings),
      now: () => now,
    );
  });

  tearDown(() async {
    await db.close();
  });

  DateTime day(int daysAgo) {
    final base = DateTime(now.year, now.month, now.day);
    return base.subtract(Duration(days: daysAgo));
  }

  Future<void> addXp(DateTime at, {int amount = 15}) async {
    await db.into(db.xpEvents).insert(
          XpEventsCompanion.insert(
            amount: amount,
            source: XpSource.task,
            createdAt: Value(at.add(const Duration(hours: 9))),
          ),
        );
  }

  Future<void> seedStreak({
    int current = 0,
    int longest = 0,
    int freezeCount = 0,
    DateTime? lastActive,
  }) async {
    final state = await gamification.ensureStreakState();
    await (db.update(db.streakState)..where((s) => s.id.equals(state.id)))
        .write(
      StreakStateCompanion(
        currentStreak: Value(current),
        longestStreak: Value(longest),
        freezeCount: Value(freezeCount),
        lastActiveDate: Value(lastActive),
      ),
    );
  }

  group('activeDays', () {
    test('hanya mengembalikan hari yang punya XP bersih positif', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(3));
      await addXp(day(1));
      // Refund saja di hari yang sama tidak membuat hari itu dianggap aktif.
      await addXp(day(2), amount: -15);

      final days = await gamification.activeDays(lookbackDays: 10);

      expect(days, [day(3), day(1)]);
    });

    test('penyelesaian yang dibatalkan tidak meninggalkan hari aktif', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(0));
      await addXp(day(0), amount: -15);

      final days = await gamification.activeDays(lookbackDays: 10);

      expect(days, isEmpty);
    });

    test('menaikkan prioritas task tidak membuat hari ini aktif', () async {
      now = DateTime(2026, 11, 14, 10);
      // Task diselesaikan kemarin; hari ini hanya prioritasnya dinaikkan.
      await addXp(day(1));
      await gamification.onTaskPriorityChanged(
        TaskPriority.low,
        TaskPriority.high,
      );

      final days = await gamification.activeDays(lookbackDays: 10);

      expect(days, [day(1)], reason: 'XP penyesuaian bukan penyelesaian');
    });

    test('mengabaikan hari di luar jendela lookback', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(30));
      await addXp(day(1));

      final days = await gamification.activeDays(lookbackDays: 7);

      expect(days, [day(1)]);
    });
  });

  group('streakFromHistory', () {
    test('menghitung hari berurutan yang berakhir hari ini', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(2));
      await addXp(day(1));
      await addXp(day(0));

      expect(await gamification.streakFromHistory(), 3);
    });

    test('hari ini yang belum selesai tidak memutus streak', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(2));
      await addXp(day(1));

      expect(await gamification.streakFromHistory(), 2);
    });

    test('hari bolong menghentikan hitungan', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(4));
      await addXp(day(3));
      // day(2) sengaja kosong.
      await addXp(day(1));

      expect(await gamification.streakFromHistory(), 1);
    });

    test('nol saat kemarin dan hari ini sama-sama kosong', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(5));

      expect(await gamification.streakFromHistory(), 0);
    });
  });

  group('repairStreakFromHistory', () {
    test('menaikkan streak basi ke nilai riwayat yang sebenarnya', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(2));
      await addXp(day(1));
      await addXp(day(0));
      await seedStreak(current: 1, longest: 1, lastActive: day(1));

      final changed = await gamification.repairStreakFromHistory();

      final state = await db.select(db.streakState).getSingle();
      expect(changed, isTrue);
      expect(state.currentStreak, 3);
      expect(state.longestStreak, 3);
      expect(state.lastActiveDate, day(0));
    });

    test('tidak menurunkan streak tersimpan (freeze tetap bermakna)', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(1));
      // Streak 8 dipertahankan oleh freeze walau riwayat hanya 1 hari.
      await seedStreak(current: 8, longest: 8, lastActive: day(1));

      final changed = await gamification.repairStreakFromHistory();

      final state = await db.select(db.streakState).getSingle();
      expect(changed, isFalse);
      expect(state.currentStreak, 8);
      expect(state.longestStreak, 8);
    });

    test('idempoten: pemanggilan kedua tidak mengubah apa pun', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(1));
      await seedStreak(current: 1, longest: 1, lastActive: day(1));

      await gamification.repairStreakFromHistory();
      final changed = await gamification.repairStreakFromHistory();

      expect(changed, isFalse);
    });

    test('tidak memundurkan lastActiveDate saat hari ini netral', () async {
      now = DateTime(2026, 11, 14, 10);
      await addXp(day(1));
      // Hari ini ada penyelesaian lalu dibatalkan → net 0.
      await addXp(day(0));
      await addXp(day(0), amount: -15);
      await seedStreak(current: 1, longest: 1, lastActive: day(0));

      await gamification.repairStreakFromHistory();

      final state = await db.select(db.streakState).getSingle();
      // Tanggal aktif tidak boleh mundur ke kemarin hanya karena hari ini netral.
      expect(state.lastActiveDate, day(0));
    });
  });

  group('evaluateMissedDay', () {
    test('streak putus hanya diberitahukan sekali, bukan tiap hari', () async {
      now = DateTime(2026, 11, 14, 10);
      await seedStreak(current: 5, longest: 5, lastActive: day(5));

      await gamification.evaluateMissedDay();
      final afterFirst = await db.select(db.streakState).getSingle();
      expect(afterFirst.currentStreak, 0);

      // Rollover berikutnya: streak sudah 0, tidak boleh memicu notifikasi lagi.
      final notifications = <String>[];
      final service = _RecordingNotifications(notifications);
      final repo = GamificationRepository(
        db,
        service,
        SettingsRepository(db),
        HomeWidgetService(db, SettingsRepository(db)),
        now: () => now,
      );
      await repo.evaluateMissedDay();
      await repo.evaluateMissedDay();

      expect(notifications, isEmpty, reason: 'streak sudah 0, tidak ada reset');
    });
  });
}

/// Merekam notifikasi supaya pengulangan bisa dibuktikan.
class _RecordingNotifications extends Fake implements NotificationService {
  _RecordingNotifications(this.calls);

  final List<String> calls;

  @override
  Future<void> showStreakBrokenNotification({
    required String title,
    required String body,
  }) async {
    calls.add('streakBroken');
  }

  @override
  Future<void> showFreezeUsedNotification({
    required String title,
    required String body,
  }) async {
    calls.add('freezeUsed');
  }

  @override
  Future<void> cancelStreakWarning() async {}
}
