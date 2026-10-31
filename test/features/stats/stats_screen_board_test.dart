import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/bar_chart.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/stats_repository.dart';
import 'package:tazk/features/stats/stats_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/stats_providers.dart';

/// Uji fidelity board `design-export/07 Statistik.png` untuk [StatsScreen].

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Future<int> _insertTask(
  AppDatabase db, {
  bool isCompleted = false,
}) {
  return db.into(db.tasks).insert(
        TasksCompanion.insert(
          title: 'task',
          date: _today(),
          priority: TaskPriority.medium,
          isCompleted: Value(isCompleted),
        ),
      );
}

Future<int> _insertFocus(AppDatabase db, int minutes) {
  return db.into(db.focusSessions).insert(
        FocusSessionsCompanion.insert(
          startedAt: _today(),
          minutes: minutes,
        ),
      );
}

Future<int> _insertXp(AppDatabase db, int amount) {
  return db.into(db.xpEvents).insert(
        XpEventsCompanion(
          createdAt: Value(_today()),
          amount: Value(amount),
          source: const Value(XpSource.task),
        ),
      );
}

Future<int> _insertHabitWithLog(AppDatabase db, String name) async {
  final id = await db.into(db.habits).insert(
        HabitsCompanion.insert(
          name: name,
          frequency: HabitFrequency.daily,
          isActive: const Value(true),
        ),
      );
  await db.into(db.habitLogs).insert(
        HabitLogsCompanion.insert(
          habitId: id,
          date: _today(),
          isCompleted: const Value(true),
        ),
      );
  return id;
}

Future<void> _pumpScreen(
  WidgetTester tester,
  AppDatabase db, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        home: const StatsScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('StatsScreen — struktur board 07 Statistik', () {
    testWidgets('struktur: segmented + 2 kartu stat + XP + heatmap + insight',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);
      await _insertFocus(db, 25);

      await _pumpScreen(tester, db);

      expect(find.byKey(statsSegmentedKey), findsOneWidget);
      expect(find.byKey(statsSegmentKey(StatsPeriod.week)), findsOneWidget);
      expect(find.byKey(statsSegmentKey(StatsPeriod.month)), findsOneWidget);
      expect(find.byKey(statsSegmentKey(StatsPeriod.year)), findsOneWidget);

      final statRow = find.byKey(statsStatRowKey);
      expect(statRow, findsOneWidget);
      expect(
        find.descendant(of: statRow, matching: find.byType(AppCard)),
        findsNWidgets(2),
      );

      expect(find.byKey(statsXpCardKey), findsOneWidget);
      expect(find.byKey(statsHeatmapCardKey), findsOneWidget);
      expect(find.byKey(statsInsightCardKey), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('geometri 390dp: gutter 20, kartu stat 171, XP 350, '
        'kartu stat sama tinggi', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);
      await _insertTask(db, isCompleted: true);
      await _insertTask(db);
      await _insertFocus(db, 25);
      await _insertFocus(db, 30);
      await _insertXp(db, 7);

      await _pumpScreen(tester, db);

      final leftCard = tester.getRect(find.byKey(statsCompletionCardKey));
      final rightCard = tester.getRect(find.byKey(statsFocusCardKey));
      expect(leftCard.left, 20); // gutter
      expect(leftCard.width, closeTo(171, 0.6));
      expect(rightCard.width, closeTo(171, 0.6));
      expect(rightCard.left - leftCard.right, closeTo(8, 0.6));

      expect(
        tester.getRect(find.byKey(statsXpCardKey)).width,
        closeTo(350, 0.6),
      );
      // F3: tinggi kartu stat bergantung isi (delta 1/2 baris); assertion angka
      // 103 tidak jujur lagi. Pastikan keduanya sama tinggi (IntrinsicHeight) dan
      // berada di rentang wajar (board 102.5 tercapai saat delta muat 1 baris).
      expect(leftCard.height, closeTo(rightCard.height, 0.01));
      expect(leftCard.height, inInclusiveRange(100, 140));

      await _disposeScreen(tester);
    });

    testWidgets('DB kosong: EmptyState tanpa angka palsu', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      expect(find.byKey(statsEmptyKey), findsOneWidget);
      expect(find.text('0%'), findsNothing);
      expect(find.text('0 XP'), findsNothing);
      expect(find.textContaining('NaN'), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('hanya data habit (0 task, 0 fokus): kartu heatmap tetap tampil, '
        'dua kartu stat berisi dash (bukan EmptyState)', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // Kasus nyata yang tertangkap di HP: pengguna hanya mencatat habit.
      await _insertHabitWithLog(db, 'Strecing + Joging');

      await _pumpScreen(tester, db);

      expect(find.byKey(statsEmptyKey), findsNothing);
      expect(find.byKey(statsHeatmapCardKey), findsOneWidget);
      expect(find.byKey(statsHeatmapKey), findsOneWidget);
      expect(find.byKey(statsCompletionCardKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(statsCompletionCardKey),
          matching: find.text('–'),
        ),
        findsOneWidget,
      );
      expect(find.text('0%'), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('kartu XP tanpa event: judul tetap, tanpa angka "0 XP"', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // Ada task (jadi bukan EmptyState) tapi belum ada event XP sama sekali.
      await _insertTask(db, isCompleted: true);

      await _pumpScreen(tester, db);

      final card = find.byKey(statsXpCardKey);
      expect(card, findsOneWidget);
      expect(find.descendant(of: card, matching: find.text('0 XP')), findsNothing);
      expect(
        find.descendant(of: card, matching: find.text('Belum ada XP')),
        findsOneWidget,
      );

      await _disposeScreen(tester);
    });

    testWidgets('data nyata: 2/3 task -> 67%, 25+30 -> 55m', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);
      await _insertTask(db, isCompleted: true);
      await _insertTask(db);
      await _insertFocus(db, 25);
      await _insertFocus(db, 30);

      await _pumpScreen(tester, db);

      expect(find.text('67%'), findsOneWidget);
      expect(find.text('55m'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('chart: week 7, bulan 30, tahun 12', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertXp(db, 7);
      // Perlu task supaya kartu statistik tidak masuk EmptyState (hasData).
      await _insertTask(db, isCompleted: true);

      await _pumpScreen(tester, db);

      BarChart chart() =>
          tester.widget<BarChart>(find.byKey(statsBarChartKey));
      expect(chart().data.length, 7);

      await tester.tap(find.byKey(statsSegmentKey(StatsPeriod.month)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(chart().data.length, 30);

      await tester.tap(find.byKey(statsSegmentKey(StatsPeriod.year)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(chart().data.length, 12);

      await _disposeScreen(tester);
    });

    testWidgets('segmented mengubah periode: judul XP jadi "XP bulanan"',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);

      await _pumpScreen(tester, db);

      expect(find.text('XP mingguan'), findsOneWidget);

      await tester.tap(find.byKey(statsSegmentKey(StatsPeriod.month)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('XP bulanan'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('reduce motion: tanpa ticker idle, tap tetap mengubah tampilan',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db, disableAnimations: true);

      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);

      expect(find.text('Belum ada data minggu ini'), findsOneWidget);

      await tester.tap(find.byKey(statsSegmentKey(StatsPeriod.month)));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada data bulan ini'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('insight: task selesai + habit -> "paling produktif"', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);
      await _insertHabitWithLog(db, 'Minum air');

      await _pumpScreen(tester, db);

      expect(find.textContaining('paling produktif'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('insight: DB kosong -> insight kosong', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      expect(find.textContaining('Insight muncul'), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('320dp + teks 1.6x: tanpa overflow', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(
        tester.view.platformDispatcher.clearTextScaleFactorTestValue,
      );

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);
      await _insertTask(db);
      await _insertFocus(db, 25);
      await _insertXp(db, 7);

      await _pumpScreen(tester, db);

      expect(tester.takeException(), isNull);

      await _disposeScreen(tester);
    });

    testWidgets('F1: hanya sesi fokus (0 task) -> task dash, fokus durasi',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertFocus(db, 25);

      await _pumpScreen(tester, db);

      // Kartu task: `–` (bukan `0%`) karena belum ada task sama sekali.
      final taskCard = find.byKey(statsCompletionCardKey);
      expect(
        find.descendant(of: taskCard, matching: find.text('\u2013')),
        findsOneWidget,
      );
      expect(find.text('0%'), findsNothing);

      // Kartu fokus: 25 menit nyata.
      final focusCard = find.byKey(statsFocusCardKey);
      expect(
        find.descendant(of: focusCard, matching: find.text('25m')),
        findsOneWidget,
      );
      expect(find.text('0m'), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('F2: pil segmented memakai transform (composite-only), '
        'bukan margin', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);

      await _pumpScreen(tester, db);

      final pill = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(statsSegmentedKey),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(pill.transform, isNotNull);
      expect(pill.margin, isNull);

      await _disposeScreen(tester);
    });

    testWidgets('F3: insight masih loading -> placeholder kosong, bukan klaim',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, isCompleted: true);

      // insightProvider tak pernah selesai → layar harus render placeholder.
      final completer = Completer<StatsInsight?>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            insightProvider.overrideWith((_) => completer.future),
          ],
          child: MaterialApp(
            locale: const Locale('id'),
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const StatsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.byKey(const ValueKey('stats-insight-loading')),
        findsOneWidget,
      );
      expect(find.textContaining('Insight muncul'), findsNothing);

      await _disposeScreen(tester);
    });
  });
}