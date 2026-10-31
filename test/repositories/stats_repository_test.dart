import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/stats_repository.dart';

/// `now` deterministik: Sabtu 31 Oktober 2026 pukul 09:00 waktu lokal.
final now = DateTime(2026, 10, 31, 9);

Future<int> _insertTask(
  AppDatabase db, {
  required DateTime date,
  bool completed = false,
}) {
  return db.into(db.tasks).insert(
        TasksCompanion.insert(
          title: 'task',
          date: date,
          priority: TaskPriority.medium,
          isCompleted: Value(completed),
        ),
      );
}

Future<int> _insertFocus(AppDatabase db, DateTime startedAt, int minutes) {
  return db.into(db.focusSessions).insert(
        FocusSessionsCompanion.insert(startedAt: startedAt, minutes: minutes),
      );
}

Future<int> _insertXp(AppDatabase db, DateTime createdAt, int amount) {
  return db.into(db.xpEvents).insert(
        XpEventsCompanion(
          createdAt: Value(createdAt),
          amount: Value(amount),
          source: const Value(XpSource.task),
        ),
      );
}

Future<int> _insertHabit(AppDatabase db, String name) {
  return db.into(db.habits).insert(
        HabitsCompanion.insert(
          name: name,
          frequency: HabitFrequency.daily,
          isActive: const Value(true),
        ),
      );
}

void main() {
  late AppDatabase db;
  late StatsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = StatsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('StatsRange.of', () {
    test('week: Senin pekan ini sampai hari ini, previousStart = Senin pekan '
        'sebelumnya', () {
      final r = StatsRange.of(StatsPeriod.week, now);
      final today = DateTime(2026, 10, 31);
      // Sabtu 31 Okt → Senin pekan ini = 26 Okt, Minggu = 1 Nov.
      expect(r.start, DateTime(2026, 10, 26));
      expect(r.end, today.add(const Duration(days: 1)));
      expect(r.end.difference(r.start).inDays, 6);
      expect(r.previousStart, DateTime(2026, 10, 19));
    });

    test('month: start = today - 29 hari, end = today + 1', () {
      final r = StatsRange.of(StatsPeriod.month, now);
      final today = DateTime(2026, 10, 31);
      expect(r.start, today.subtract(const Duration(days: 29)));
      expect(r.end, today.add(const Duration(days: 1)));
      expect(r.end.difference(r.start).inDays, 30);
      expect(r.previousStart, r.start.subtract(const Duration(days: 30)));
    });

    test('year: start = 1 Januari, end = 1 Januari tahun berikutnya, '
        'previousStart = 1 Januari tahun sebelumnya', () {
      final r = StatsRange.of(StatsPeriod.year, now);
      expect(r.start, DateTime(2026, 1, 1));
      expect(r.end, DateTime(2027, 1, 1));
      expect(r.end.difference(r.start).inDays, 365);
      expect(r.previousStart, DateTime(2025, 1, 1));
    });
  });

  group('watchCompletionRate (week)', () {
    test('2 dari 3 selesai di periode, periode sebelumnya kosong', () async {
      await _insertTask(db, date: DateTime(2026, 10, 29), completed: true);
      await _insertTask(db, date: DateTime(2026, 10, 30), completed: true);
      await _insertTask(db, date: DateTime(2026, 10, 30), completed: false);

      final s = await repo.watchCompletionRate(StatsPeriod.week, now: now).first;

      expect(s.completed, 2);
      expect(s.total, 3);
      expect(s.rate, closeTo(2 / 3, 1e-9));
      expect(s.hasData, isTrue);
      expect(s.previousRate, isNull);
      expect(s.deltaPoints, isNull);
    });

    test('task di periode sebelumnya menghasilkan deltaPoints', () async {
      await _insertTask(db, date: DateTime(2026, 10, 29), completed: true);
      await _insertTask(db, date: DateTime(2026, 10, 30), completed: true);
      await _insertTask(db, date: DateTime(2026, 10, 30), completed: false);
      // Periode sebelumnya: [2026-10-18, 2026-10-25) → 1 dari 2 selesai = 50%.
      await _insertTask(db, date: DateTime(2026, 10, 20), completed: true);
      await _insertTask(db, date: DateTime(2026, 10, 21), completed: false);

      final s = await repo.watchCompletionRate(StatsPeriod.week, now: now).first;

      expect(s.previousRate, closeTo(0.5, 1e-9));
      expect(s.deltaPoints, 17);
    });

    test('tanpa task sama sekali → hasData false, rate 0, deltaPoints null',
        () async {
      final s = await repo.watchCompletionRate(StatsPeriod.week, now: now).first;
      expect(s.hasData, isFalse);
      expect(s.rate, 0);
      expect(s.completed, 0);
      expect(s.total, 0);
      expect(s.deltaPoints, isNull);
    });
  });

  group('watchFocusMinutes (week)', () {
    test('25 + 30 di periode, 40 di periode sebelumnya', () async {
      await _insertFocus(db, DateTime(2026, 10, 28, 8), 25);
      await _insertFocus(db, DateTime(2026, 10, 30, 9), 30);
      await _insertFocus(db, DateTime(2026, 10, 20, 9), 40); // sebelumnya

      final s = await repo.watchFocusMinutes(StatsPeriod.week, now: now).first;

      expect(s.minutes, 55);
      expect(s.previousMinutes, 40);
      expect(s.hasData, isTrue);
      expect(s.deltaMinutes, 15);
    });

    test('tanpa sesi focus → hasData false', () async {
      final s = await repo.watchFocusMinutes(StatsPeriod.week, now: now).first;
      expect(s.hasData, isFalse);
      expect(s.minutes, 0);
      expect(s.previousMinutes, 0);
    });
  });

  group('watchXpPerDay', () {
    test('week → 7 bucket, label hari Indonesia, net termasuk negatif, '
        'isToday di indeks Sabtu', () async {
      // Pekan kalender Senin 26 Okt .. Minggu 1 Nov 2026. Sabtu = indeks 5.
      await _insertXp(db, DateTime(2026, 10, 27, 10), 15); // Selasa (idx 1)
      await _insertXp(db, DateTime(2026, 10, 27, 11), -5); // Selasa
      await _insertXp(db, DateTime(2026, 10, 31, 9), 7); // Sabtu (idx 5)

      final buckets =
          await repo.watchXpPerDay(StatsPeriod.week, now: now).first;

      expect(buckets, hasLength(7));
      expect(buckets.map((b) => b.label).toList(), [
        'S', 'S', 'R', 'K', 'J', 'S', 'M',
      ]);
      expect(buckets.map((b) => b.value).toList(), [
        0, 10, 0, 0, 0, 7, 0,
      ]);
      final todayIdx = buckets.indexWhere((b) => b.isToday);
      expect(todayIdx, 5);
      expect(buckets.where((b) => b.isToday).length, 1);
    });

    test('month → 30 bucket harian, isToday di indeks hari ini', () async {
      await _insertXp(db, DateTime(2026, 10, 31, 9), 7);

      final buckets =
          await repo.watchXpPerDay(StatsPeriod.month, now: now).first;

      expect(buckets, hasLength(30));
      expect(buckets[29].value, 7);
      expect(buckets.indexWhere((b) => b.isToday), 29);
    });

    test('year → 12 bucket bulanan dengan label inisial bulan', () async {
      await _insertXp(db, DateTime(2026, 1, 15, 10), 12);
      await _insertXp(db, DateTime(2026, 10, 30, 10), 5);

      final buckets =
          await repo.watchXpPerDay(StatsPeriod.year, now: now).first;

      expect(buckets, hasLength(12));
      expect(buckets.map((b) => b.label).toList(), [
        'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D',
      ]);
      expect(buckets[0].value, 12); // Januari
      expect(buckets[9].value, 5); // Oktober
      expect(buckets.indexWhere((b) => b.isToday), 9);
    });

    test('year memasukkan XP Desember (regression F1)', () async {
      await _insertXp(db, DateTime(2026, 12, 20, 10), 42);

      final buckets =
          await repo.watchXpPerDay(StatsPeriod.year, now: now).first;

      expect(buckets[11].value, 42); // Desember
    });
  });

  group('watchHabitHeatmap', () {
    test('13 kolom × 7 baris, level capped 3, hari setelah hari ini = 0, '
        'jendela berakhir hari ini', () async {
      final n = DateTime(2026, 10, 31, 9); // Sabtu
      final today = DateTime(2026, 10, 31);
      // Senin 12 pekan (84 hari) sebelum pekan berjalan = 2026-08-03.
      final start = today.subtract(const Duration(days: 89));

      final hA = await _insertHabit(db, 'A');
      final hB = await _insertHabit(db, 'B');
      final hC = await _insertHabit(db, 'C');

      // Hari pertama grid (kolom 0, baris 0 = Senin 2026-08-03): 3 log selesai.
      for (final id in [hA, hB, hC]) {
        await db.into(db.habitLogs).insert(
              HabitLogsCompanion.insert(
                habitId: id,
                date: start,
                isCompleted: const Value(true),
              ),
            );
      }
      // Hari ini: 1 log selesai.
      await db.into(db.habitLogs).insert(
            HabitLogsCompanion.insert(
              habitId: hA,
              date: today,
              isCompleted: const Value(true),
            ),
          );

      final grid = await repo.watchHabitHeatmap(now: n).first;

      expect(grid.length, 13);
      expect(grid.every((col) => col.length == 7), isTrue);
      // Kolom 0 baris 0 = hari pertama → level 3 (capped).
      expect(grid[0][0], 3);
      // Hari ini = Sabtu → baris 5 kolom 12.
      expect(grid[12][5], 1);
      // Hari dalam pekan ini yang masih di masa depan (Minggu = baris 6) = 0.
      expect(grid[12][6], 0);
      // Hari lain di masa lalu tanpa log = 0.
      expect(grid[0][1], 0);
    });
  });

  group('insight', () {
    test('tanpa data → null', () async {
      expect(await repo.insight(StatsPeriod.week, now: now), isNull);
    });

    test('dengan data → productiveWeekday benar + consistentHabitName', () async {
      // Kamis (weekday 4): 1 tugas selesai. Jumat (5): 2 tugas selesai.
      await _insertTask(db, date: DateTime(2026, 10, 22), completed: true);
      await _insertTask(db, date: DateTime(2026, 10, 23), completed: true);
      await _insertTask(db, date: DateTime(2026, 10, 23), completed: true);

      final hA = await _insertHabit(db, 'Minum air');
      final hB = await _insertHabit(db, 'Baca buku');
      // hB lebih konsisten: 2 log selesai vs hA 1 log.
      await db.into(db.habitLogs).insert(
            HabitLogsCompanion.insert(
              habitId: hA,
              date: DateTime(2026, 10, 20),
              isCompleted: const Value(true),
            ),
          );
      await db.into(db.habitLogs).insert(
            HabitLogsCompanion.insert(
              habitId: hB,
              date: DateTime(2026, 10, 19),
              isCompleted: const Value(true),
            ),
          );
      await db.into(db.habitLogs).insert(
            HabitLogsCompanion.insert(
              habitId: hB,
              date: DateTime(2026, 10, 21),
              isCompleted: const Value(true),
            ),
          );

      final s = await repo.insight(StatsPeriod.week, now: now);

      expect(s, isNotNull);
      expect(s!.productiveWeekday, 5);
      expect(s.consistentHabitName, 'Baca buku');
      expect(s.isEmpty, isFalse);
    });
  });

  group('reactivitas stream', () {
    test('watchXpPerDay memancarkan nilai baru setelah insert', () async {
      // Nilai awal sebelum insert: bucket hari ini (Sabtu) = 0.
      final before = await repo.watchXpPerDay(StatsPeriod.week, now: now).first;
      expect(before[5].value, 0);

      // Dengar emisi berikutnya *sebelum* insert supaya tidak kelewatan.
      final next = repo
          .watchXpPerDay(StatsPeriod.week, now: now)
          .firstWhere((b) => b[5].value == 7);

      await _insertXp(db, DateTime(2026, 10, 31, 9), 7);

      final after = await next;
      expect(after[5].value, 7);
    });
  });
}