import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/habits/habit_detail_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Uji fidelity board `design-export/25 Habit Detail.png` untuk
/// [HabitDetailScreen].
///
/// Board (780×1142 px @2x → frame 390dp) menunjukkan:
/// - header dengan dua lingkaran aksi (edit + hapus) di kanan,
/// - tiga kartu statistik (streak aktif / total selesai / konsistensi),
/// - kartu ringkasan tiga baris (Frekuensi, Pengingat, Target),
/// - "Histori 4 minggu" + "18 dari 28" + grid 7×4 sel + legenda,
/// - CTA "Mulai sesi fokus" di bawah.
///
/// Aturan yang diuji khusus: hari yang **belum terjadi** dan **hari ini yang
/// belum ditutup** tidak boleh ditandai gagal (board `25` hanya memakai warna
/// `primary-container` untuk hari yang belum selesai, bukan tanda silang).

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
  DateTime? scheduledTime,
  int createdDaysAgo = 60,
}) async {
  final id = await db
      .into(db.habits)
      .insert(
        HabitsCompanion.insert(
          name: name,
          frequency: frequency,
          scheduledTime: Value(scheduledTime),
          hasProgress: Value(hasProgress),
          targetMinutes: Value(targetMinutes),
          createdAt: Value(_daysAgo(createdDaysAgo)),
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

Future<void> _pumpScreen(
  WidgetTester tester,
  Habit habit, {
  Size size = const Size(390 * 3, 844 * 3),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(_db!)],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HabitDetailScreen(habit: habit),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

AppDatabase? _db;

/// Lepas tree supaya query stream Drift & timer `currentDateProvider` berhenti
/// sebelum pemeriksaan pending-timer milik binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

Color? _cellColor(WidgetTester tester, int index) {
  final cell = tester.widget<Container>(find.byKey(habitHistoryCellKey(index)));
  return (cell.decoration! as BoxDecoration).color;
}

Color? _cellBorder(WidgetTester tester, int index) {
  final cell = tester.widget<Container>(find.byKey(habitHistoryCellKey(index)));
  return (cell.decoration! as BoxDecoration).border?.top.color;
}

void main() {
  group('habitDayStateFor — hari yang belum terjadi tidak dinilai gagal', () {
    test('hari masa depan = notYet, bukan missed', () {
      expect(
        habitDayStateFor(
          date: _daysAgo(-3), // tiga hari ke depan
          today: _today(),
          isDue: true,
        ),
        HabitDayState.notYet,
      );
    });

    test('hari ini yang belum dicentang = notYet, bukan missed', () {
      expect(
        habitDayStateFor(date: _today(), today: _today(), isDue: true),
        HabitDayState.notYet,
      );
    });

    test('hari yang sudah lewat & tidak dikerjakan = missed', () {
      expect(
        habitDayStateFor(date: _daysAgo(1), today: _today(), isDue: true),
        HabitDayState.missed,
      );
    });

    test('selesai menang atas status lain (termasuk di luar jadwal)', () {
      expect(
        habitDayStateFor(
          date: _daysAgo(2),
          today: _today(),
          isDue: false,
          log: _logAt(_daysAgo(2)),
        ),
        HabitDayState.completed,
      );
    });

    test('progres menit tanpa selesai = partial, bukan missed', () {
      expect(
        habitDayStateFor(
          date: _daysAgo(2),
          today: _today(),
          isDue: true,
          log: _logAt(_daysAgo(2), progressMinutes: 10),
        ),
        HabitDayState.partial,
      );
    });

    test('hari yang tidak dijadwalkan = notDue, bukan missed', () {
      expect(
        habitDayStateFor(date: _daysAgo(1), today: _today(), isDue: false),
        HabitDayState.notDue,
      );
    });
  });

  group('buildHabitHistory', () {
    test('28 hari, urut lama → hari ini, indeks terakhir = hari ini', () async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(_db!, name: 'Baca buku');

      final days = buildHabitHistory(
        habit: habit,
        logs: const [],
        today: _today(),
      );

      expect(days.length, 28);
      expect(days.first.date, _daysAgo(27));
      expect(days.last.date, _today());
      // Habit dibuat 60 hari lalu & tanpa log: semua hari lampau terlewat,
      // hari ini tetap belum selesai.
      expect(days.last.state, HabitDayState.notYet);
      expect(days[days.length - 2].state, HabitDayState.missed);
    });

    test('hari sebelum habit dibuat = notDue, bukan missed', () async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(_db!, name: 'Baru', createdDaysAgo: 2);

      final days = buildHabitHistory(
        habit: habit,
        logs: const [],
        today: _today(),
      );

      // Dua hari terakhir sejak habit dibuat (indeks 25 = lusa, 26 = kemarin).
      expect(days[27].state, HabitDayState.notYet); // hari ini
      expect(days[26].state, HabitDayState.missed); // kemarin
      expect(days[25].state, HabitDayState.missed); // hari pertama habit ada
      // Sisanya sebelum habit ada.
      expect(days.take(25).every((d) => d.state == HabitDayState.notDue), isTrue);
    });

    test('habit mingguan: hari di luar jadwal = notDue', () async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      // `weekly` jatuh pada hari yang sama dengan `createdAt`.
      final habit = await _insertHabit(
        _db!,
        name: 'Kelas',
        frequency: HabitFrequency.weekly,
        createdDaysAgo: 56,
      );

      final days = buildHabitHistory(
        habit: habit,
        logs: const [],
        today: _today(),
      );

      final dueDays = days.where((d) => d.state != HabitDayState.notDue);
      // 28 hari = tepat 4 kemunculan hari yang sama.
      expect(dueDays.length, 4);
    });
  });

  group('habitDetailStats', () {
    test('streak, total, hitungan jendela, dan konsistensi', () async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(_db!, name: 'Jurnal');

      // Selesai 18 hari berurutan sampai kemarin (hari ini belum).
      for (var back = 1; back <= 18; back++) {
        await _insertLog(_db!, habitId: habit.id, date: _daysAgo(back));
      }
      final logs = await (_db!.select(
        _db!.habitLogs,
      )..where((l) => l.habitId.equals(habit.id))).get();

      final stats = habitDetailStats(
        habit: habit,
        logs: logs,
        today: _today(),
      );

      expect(stats.streakDays, 18);
      expect(stats.completedDays, 18);
      expect(stats.completedInWindow, 18);
      // Penyebut = 27 hari lampau (hari ini belum dinilai).
      expect(stats.consistencyPercent, (18 / 27 * 100).round());
    });

    test('tanpa log sama sekali: 0 semua, tanpa pembagian nol', () async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(_db!, name: 'Baru', createdDaysAgo: 0);

      final stats = habitDetailStats(
        habit: habit,
        logs: const [],
        today: _today(),
      );

      expect(stats.streakDays, 0);
      expect(stats.completedDays, 0);
      expect(stats.completedInWindow, 0);
      expect(stats.consistencyPercent, 0);
    });
  });

  group('HabitDetailScreen — struktur board 25 Habit Detail', () {
    testWidgets('header, 3 kartu statistik, kartu ringkasan, histori, CTA', (
      tester,
    ) async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(
        _db!,
        name: 'Baca buku',
        hasProgress: true,
        targetMinutes: 30,
        scheduledTime: DateTime(2000, 1, 1, 20),
      );
      for (var back = 1; back <= 18; back++) {
        await _insertLog(_db!, habitId: habit.id, date: _daysAgo(back));
      }

      await _pumpScreen(tester, habit);

      // Header: dua aksi bulat (edit + hapus).
      expect(find.byKey(habitDetailEditKey), findsOneWidget);
      expect(find.byKey(habitDetailDeleteKey), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

      // Tiga kartu statistik (bukan dua, bukan empat).
      expect(find.byKey(habitDetailStreakTileKey), findsOneWidget);
      expect(find.byKey(habitDetailTotalTileKey), findsOneWidget);
      expect(find.byKey(habitDetailConsistencyTileKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(habitDetailStreakTileKey),
          matching: find.text('18'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(habitDetailTotalTileKey),
          matching: find.text('18'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(habitDetailConsistencyTileKey),
          matching: find.text('67%'),
        ),
        findsOneWidget,
      );
      // Label streak memakai key l10n yang sudah ada.
      expect(find.text('Streak aktif'), findsOneWidget);
      expect(find.text('Total selesai'), findsOneWidget);
      expect(find.text('Konsistensi'), findsOneWidget);

      // Kartu ringkasan: tiga baris label + nilai.
      expect(find.byKey(habitDetailSummaryKey), findsOneWidget);
      expect(find.text('Frekuensi'), findsOneWidget);
      expect(find.text('Harian'), findsOneWidget);
      expect(find.text('Pengingat'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('30 menit / hari'), findsOneWidget);

      // Judul histori + hitungan jendela 28 hari.
      expect(find.byKey(habitDetailHistoryHeaderKey), findsOneWidget);
      expect(find.text('Histori 4 minggu'), findsOneWidget);
      expect(find.text('18 dari 28'), findsOneWidget);

      // Grid 7×4 = 28 sel + legenda empat langkah.
      for (var index = 0; index < 28; index++) {
        expect(find.byKey(habitHistoryCellKey(index)), findsOneWidget);
      }
      expect(find.byKey(habitHistoryCellKey(28)), findsNothing);
      expect(find.byKey(habitDetailLegendKey), findsOneWidget);
      expect(find.text('lewat'), findsOneWidget);
      expect(find.text('selesai'), findsOneWidget);

      // CTA board.
      expect(find.byKey(habitDetailStartFocusKey), findsOneWidget);
      expect(find.text('Mulai sesi fokus'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('hari ini & masa depan tidak ditandai gagal (tanpa tanda '
        'silang)', (tester) async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      // Tanpa log: hari lampau terlewat, hari ini belum selesai.
      final habit = await _insertHabit(_db!, name: 'Meditasi');
      // Satu hari selesai (2 hari lalu) untuk menguji penanda centang.
      await _insertLog(_db!, habitId: habit.id, date: _daysAgo(2));

      await _pumpScreen(tester, habit);

      final colors = AppColors.light;
      // Sel terakhir = hari ini: warna `belum`, bukan warna `lewat`.
      expect(_cellColor(tester, 27), colors.primaryContainer);
      expect(_cellColor(tester, 27), isNot(colors.surfaceAlt));
      // Kemarin: benar-benar terlewat.
      expect(_cellColor(tester, 26), colors.surfaceAlt);
      // Ikon silang lama (cancel) tidak boleh muncul lagi di mana pun.
      expect(find.byIcon(Icons.cancel_outlined), findsNothing);
      expect(find.byIcon(Icons.cancel_rounded), findsNothing);
      // Hari selesai memakai centang di dalam selnya (bukan hanya warna).
      expect(
        find.descendant(
          of: find.byKey(habitHistoryCellKey(25)),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(habitHistoryCellKey(26)),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsNothing,
      );

      await _disposeScreen(tester);
    });

    testWidgets('sel selesai, sebagian, dan tidak dijadwalkan dibedakan', (
      tester,
    ) async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(
        _db!,
        name: 'Lari',
        hasProgress: true,
        targetMinutes: 30,
      );
      await _insertLog(_db!, habitId: habit.id, date: _daysAgo(1));
      await _insertLog(
        _db!,
        habitId: habit.id,
        date: _daysAgo(2),
        isCompleted: false,
        progressMinutes: 15,
      );

      await _pumpScreen(tester, habit);

      final colors = AppColors.light;
      expect(_cellColor(tester, 27), colors.primaryContainer); // hari ini
      expect(_cellColor(tester, 26), colors.primary); // kemarin selesai
      expect(_cellColor(tester, 25), colors.primarySoft); // 2 hari lalu sebagian
      expect(_cellColor(tester, 24), colors.surfaceAlt); // 3 hari lalu terlewat

      await _disposeScreen(tester);
    });

    testWidgets('habit mingguan: hari di luar jadwal bergaris, bukan terlewat', (
      tester,
    ) async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(
        _db!,
        name: 'Kelas',
        frequency: HabitFrequency.weekly,
        // 55 hari (bukan 56) supaya hari ini BUKAN hari jadwalnya.
        createdDaysAgo: 55,
      );

      await _pumpScreen(tester, habit);

      final colors = AppColors.light;
      // Hari ini bukan jadwalnya → tidak dijadwalkan (garis, tanpa isian).
      expect(_cellColor(tester, 27), isNull);
      expect(_cellBorder(tester, 27), colors.border);

      await _disposeScreen(tester);
    });

    testWidgets('geometri board: gutter 20, sel 26dp, jarak 4dp', (
      tester,
    ) async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(_db!, name: 'Baca buku');

      await _pumpScreen(tester, habit);

      final summary = tester.getRect(find.byKey(habitDetailSummaryKey));
      expect(summary.left, 20); // gutter
      expect(summary.width, 390 - 40);

      final streakTile = tester.getRect(find.byKey(habitDetailStreakTileKey));
      final totalTile = tester.getRect(find.byKey(habitDetailTotalTileKey));
      final consistencyTile = tester.getRect(
        find.byKey(habitDetailConsistencyTileKey),
      );
      expect(streakTile.left, 20);
      expect(totalTile.left - streakTile.right, closeTo(8, 0.01)); // jarak kartu
      expect(consistencyTile.right, closeTo(390 - 20, 0.01));
      // Ketiga kartu sama tinggi (IntrinsicHeight).
      expect(totalTile.height, streakTile.height);
      expect(consistencyTile.height, streakTile.height);
      // Kartu statistik 16dp di atas kartu ringkasan (board).
      expect(summary.top - streakTile.bottom, closeTo(16, 0.01));

      final first = tester.getRect(find.byKey(habitHistoryCellKey(0)));
      final second = tester.getRect(find.byKey(habitHistoryCellKey(1)));
      final eighth = tester.getRect(find.byKey(habitHistoryCellKey(7)));
      expect(first.left, 20);
      expect(first.height, 26);
      expect(second.left - first.right, closeTo(4, 0.01)); // jarak sel horizontal
      expect(eighth.top - first.bottom, closeTo(4, 0.01)); // jarak baris
      // 7 kolom mengisi lebar konten penuh.
      expect(
        tester.getRect(find.byKey(habitHistoryCellKey(6))).right,
        closeTo(390 - 20, 0.01),
      );

      // Legenda rata kanan.
      expect(
        tester.getRect(find.byKey(habitDetailLegendKey)).right,
        closeTo(390 - 20, 0.01),
      );

      await _disposeScreen(tester);
    });

    testWidgets('nama & label panjang tidak overflow di layar 320dp', (
      tester,
    ) async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(
        _db!,
        name:
            'Membaca buku pengembangan diri selama tiga puluh menit setiap '
            'malam sebelum tidur',
        hasProgress: true,
        targetMinutes: 999,
        scheduledTime: DateTime(2000, 1, 1, 23, 59),
      );

      await _pumpScreen(tester, habit, size: const Size(320 * 3, 800 * 3));

      expect(tester.takeException(), isNull);
      expect(find.text('999 menit / hari'), findsOneWidget);
      expect(find.text('23:59'), findsOneWidget);
      expect(find.byType(AppCard), findsNWidgets(4)); // 3 statistik + ringkasan
      expect(find.byType(AppButton), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('habit tanpa jam & target memakai tanda "-"', (tester) async {
      _db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(_db!.close);
      final habit = await _insertHabit(_db!, name: 'Minum air');

      await _pumpScreen(tester, habit);

      expect(find.text('-'), findsNWidgets(2)); // pengingat + target

      await _disposeScreen(tester);
    });
  });
}

HabitLog _logAt(DateTime date, {int progressMinutes = 0}) => HabitLog(
  id: 1,
  habitId: 1,
  date: DateTime(date.year, date.month, date.day),
  isCompleted: progressMinutes == 0,
  progressMinutes: progressMinutes,
);
