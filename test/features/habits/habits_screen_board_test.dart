import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/core/widgets/empty_state.dart';
import 'package:tazk/core/widgets/error_state.dart';
import 'package:tazk/core/widgets/skeleton_list.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/habits/habits_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/habit_providers.dart';

/// Uji fidelity board `design-export/03 Habits.png` untuk [HabitsScreen].
///
/// Board (780×1232 px, dibagi 2 → frame 390dp) menunjukkan:
/// - header "Habits" + tombol bulat tambah di kanan (BUKAN FAB),
/// - kartu ringkasan `primary-container`: lingkaran persen + "1 dari 2 habit
///   hari ini" + "Jaga ritme, kamu sedang on-track",
/// - satu kartu berbingkai per habit: checkbox, judul, sub-judul
///   `frekuensi · 🔥 streak · progress menit`, chevron.

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _daysAgo(int days) {
  final today = _today();
  return DateTime(today.year, today.month, today.day - days);
}

Future<Habit> _insertHabit(
  AppDatabase db, {
  required String name,
  HabitFrequency frequency = HabitFrequency.daily,
  bool hasProgress = false,
  int? targetMinutes,
}) async {
  final id = await db
      .into(db.habits)
      .insert(
        HabitsCompanion.insert(
          name: name,
          frequency: frequency,
          hasProgress: Value(hasProgress),
          targetMinutes: Value(targetMinutes),
        ),
      );
  return (db.select(db.habits)..where((h) => h.id.equals(id))).getSingle();
}

Future<void> _insertLog(
  AppDatabase db, {
  required int habitId,
  required DateTime date,
  bool isCompleted = true,
  int progressMinutes = 0,
}) async {
  await db
      .into(db.habitLogs)
      .insert(
        HabitLogsCompanion.insert(
          habitId: habitId,
          date: DateTime(date.year, date.month, date.day),
          isCompleted: Value(isCompleted),
          progressMinutes: Value(progressMinutes),
        ),
      );
}

/// Pump [HabitsScreen] dengan DB memori + locale `id` (copy board).
Future<void> _pumpScreen(
  WidgetTester tester,
  AppDatabase db, {
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db), ...extraOverrides],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HabitsScreen(),
      ),
    ),
  );
  // Frame pertama membangun layar; pump pendek membiarkan stream Drift
  // menyelesaikan query sehingga tidak ada skeleton yang tertinggal.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Lepas tree supaya query stream Drift & ticker skeleton berhenti sebelum
/// pemeriksaan pending-timer milik binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('HabitsScreen — struktur board 03 Habits', () {
    testWidgets('kartu ringkasan + satu kartu per habit (bukan satu kartu '
        'berdivider), tanpa FAB', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final done = await _insertHabit(db, name: 'Olahraga pagi');
      await _insertLog(db, habitId: done.id, date: _today());
      final progressHabit = await _insertHabit(
        db,
        name: 'Baca buku',
        hasProgress: true,
        targetMinutes: 30,
      );
      await _insertLog(
        db,
        habitId: progressHabit.id,
        date: _today(),
        isCompleted: false,
        progressMinutes: 15,
      );

      await _pumpScreen(tester, db);

      // Board: tombol tambah di header, TIDAK ada FAB.
      expect(find.byKey(habitsAddButtonKey), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);

      // Kartu ringkasan: persen, jumlah habit hari ini, kalimat pendukung.
      expect(find.byKey(habitsSummaryKey), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('1 dari 2 habit hari ini'), findsOneWidget);
      expect(find.text('Jaga ritme, kamu sedang on-track'), findsOneWidget);

      // Satu `AppCard` per habit (ringkasan bukan AppCard).
      expect(find.byType(AppCard), findsNWidgets(2));
      expect(find.byKey(habitCardKey(done.id)), findsOneWidget);
      expect(find.byKey(habitCardKey(progressHabit.id)), findsOneWidget);

      // Sub-judul: frekuensi untuk keduanya, streak hanya saat > 0,
      // progress menit hanya untuk habit bertarget.
      expect(find.text('Harian'), findsNWidgets(2));
      expect(find.text('1 hari'), findsOneWidget);
      expect(find.text('15 / 30 mnt'), findsOneWidget);

      // Streak memakai ikon api (bukan emoji) sesuai board.
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      // Chevron kanan ada di setiap kartu.
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));

      await _disposeScreen(tester);
    });

    testWidgets('streak berhari-hari muncul sebagai "N hari" dan ringkasan '
        'jadi 100% saat semua selesai', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final habit = await _insertHabit(db, name: 'Jurnal malam');
      for (final days in [0, 1, 2]) {
        await _insertLog(db, habitId: habit.id, date: _daysAgo(days));
      }

      await _pumpScreen(tester, db);

      expect(find.text('3 hari'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Semua habit hari ini selesai'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('habit bertahap tanpa progres hari ini memakai teks 0/target', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertHabit(
        db,
        name: 'Meditasi',
        hasProgress: true,
        targetMinutes: 20,
      );

      await _pumpScreen(tester, db);

      expect(find.text('0 / 20 mnt'), findsOneWidget);
      // Tidak ada streak sama sekali -> tidak ada ikon api.
      expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('geometri board pada layar 390dp: gutter 20, jarak 12, '
        'badge persen 54dp', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final first = await _insertHabit(db, name: 'Olahraga pagi');
      final second = await _insertHabit(db, name: 'Baca buku');

      await _pumpScreen(tester, db);

      // Tinggi kartu tidak diuji di sini: `flutter test` memakai font kotak,
      // jadi tinggi yang mengikuti teks tidak mewakili render sebenarnya.
      final summary = tester.getRect(find.byKey(habitsSummaryKey));
      expect(summary.left, 20); // gutter kiri
      expect(summary.width, 390 - 40);

      final badge = tester.getSize(find.byKey(habitsSummaryBadgeKey));
      expect(badge.width, 54);
      expect(badge.height, 54);

      final firstCard = tester.getRect(find.byKey(habitCardKey(first.id)));
      final secondCard = tester.getRect(find.byKey(habitCardKey(second.id)));
      expect(firstCard.left, 20);
      expect(secondCard.top - firstCard.bottom, 12); // jarak antar kartu
      // Ringkasan berhenti 12dp sebelum kartu habit pertama.
      expect(firstCard.top - summary.bottom, 12);

      await _disposeScreen(tester);
    });

    testWidgets('data ekstrem tidak overflow di layar sempit 320dp', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertHabit(
        db,
        name:
            'Membaca buku pengembangan diri selama tiga puluh menit '
            'setiap malam sebelum tidur',
      );
      final huge = await _insertHabit(
        db,
        name: 'Lari',
        hasProgress: true,
        targetMinutes: 999,
      );
      await _insertLog(
        db,
        habitId: huge.id,
        date: _today(),
        isCompleted: false,
        progressMinutes: 999,
      );

      await _pumpScreen(tester, db);

      expect(tester.takeException(), isNull);
      expect(find.text('999 / 999 mnt'), findsOneWidget);
      expect(find.byType(AppCard), findsNWidgets(2));

      await _disposeScreen(tester);
    });
  });

  group('HabitsScreen — state', () {
    testWidgets('kosong: EmptyState berjudul + aksi tambah habit', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Belum ada habit aktif'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Tambah Habit'), findsOneWidget);
      expect(find.byKey(habitsSummaryKey), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('memuat: SkeletonList, bukan spinner', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final pending = StreamController<List<Habit>>();
      addTearDown(pending.close);

      await _pumpScreen(
        tester,
        db,
        extraOverrides: [
          activeHabitsProvider.overrideWith((ref) => pending.stream),
        ],
      );

      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('gagal: ErrorState dengan tombol coba lagi', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(
        tester,
        db,
        extraOverrides: [
          activeHabitsProvider.overrideWith(
            (ref) => Stream<List<Habit>>.error(Exception('db rusak')),
          ),
        ],
      );

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);

      await _disposeScreen(tester);
    });
  });

  group('habitStreakDays', () {
    test('menghitung hari berurutan yang selesai', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final habit = await _insertHabit(db, name: 'Harian');

      expect(
        habitStreakDays(
          habit: habit,
          completedDates: [_daysAgo(0), _daysAgo(1), _daysAgo(2)],
          today: _today(),
        ),
        3,
      );
    });

    test('hari ini belum dicentang tidak memutus streak', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final habit = await _insertHabit(db, name: 'Harian');

      expect(
        habitStreakDays(
          habit: habit,
          completedDates: [_daysAgo(1), _daysAgo(2), _daysAgo(3)],
          today: _today(),
        ),
        3,
      );
    });

    test('hari yang bolong memutus hitungan', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final habit = await _insertHabit(db, name: 'Harian');

      expect(
        habitStreakDays(
          habit: habit,
          completedDates: [_daysAgo(1), _daysAgo(3), _daysAgo(4)],
          today: _today(),
        ),
        1,
      );
    });

    test('habit bukan harian melewati hari yang tidak dijadwalkan', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      // Senin + Kamis saja.
      const monday = 1 << 0;
      const thursday = 1 << 3;
      final habit = await _insertHabit(
        db,
        name: 'Kelas',
        frequency: HabitFrequency.custom,
      );
      await (db.update(db.habits)..where((h) => h.id.equals(habit.id))).write(
        HabitsCompanion(
          customFrequencyType: const Value(0),
          customDaysOfWeek: const Value(monday | thursday),
        ),
      );
      final custom = await (db.select(
        db.habits,
      )..where((h) => h.id.equals(habit.id))).getSingle();

      // Ambil dua hari terakhir yang jatuh pada Senin atau Kamis.
      final dueDates = <DateTime>[];
      for (var back = 0; back < 21 && dueDates.length < 2; back++) {
        final day = _daysAgo(back);
        if (day.weekday == DateTime.monday ||
            day.weekday == DateTime.thursday) {
          dueDates.add(day);
        }
      }

      expect(
        habitStreakDays(
          habit: custom,
          completedDates: dueDates,
          today: _today(),
        ),
        2,
      );
    });

    test('tanpa log sama sekali = 0', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final habit = await _insertHabit(db, name: 'Baru');

      expect(
        habitStreakDays(
          habit: habit,
          completedDates: const [],
          today: _today(),
        ),
        0,
      );
    });
  });
}
