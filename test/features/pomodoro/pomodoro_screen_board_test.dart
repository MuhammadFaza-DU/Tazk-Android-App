import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/pomodoro/pomodoro_controller.dart';
import 'package:tazk/features/pomodoro/pomodoro_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/habit_providers.dart';

/// Uji fidelity board `design-export/05 Pomodoro (dari CTA Home).png`.
///
/// Board 780×1320 px = frame 390×660 dp (2×) menunjukkan, dari atas:
/// - segmented pill mode: track `surface-alt` 350×41, segmen aktif `surface`,
/// - kartu pemilih habit: `surface` + border, radius 14, tinggi 57, tile ikon
///   32 `primary-container`, judul + progress menit, chevron kanan,
/// - cakram timer 261 `surface` + cincin `honey` 8 dp, digit Fredoka 44,
/// - empat chip durasi 69×52 (15/25/45/60), chip aktif `primary`,
/// - tombol aksi: `primary` selebar sisa + tombol hentikan persegi 57×48.
void main() {
  late AppDatabase db;
  late Habit habit;
  late PomodoroController controller;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final id = await db
        .into(db.habits)
        .insert(
          HabitsCompanion.insert(
            name: 'Baca buku',
            frequency: HabitFrequency.daily,
            hasProgress: const Value(true),
            targetMinutes: const Value(30),
          ),
        );
    habit = await (db.select(
      db.habits,
    )..where((h) => h.id.equals(id))).getSingle();

    controller = PomodoroController(
      scheduleCompletionNotification: (_, _, _) async {},
      cancelCompletionNotification: () async {},
      completeHabitToday: (_) async {},
      logHabitProgress: (_, _) async {},
      logFocusSession: (_, _) async {},
    );
  });

  tearDown(() async {
    // `PomodoroController` dimiliki oleh `pomodoroControllerProvider`
    // (ChangeNotifierProvider) → di-dispose oleh ProviderScope, bukan di sini.
    await db.close();
  });

  HabitLog todayLog() {
    final now = DateTime.now();
    return HabitLog(
      id: 1,
      habitId: habit.id,
      date: DateTime(now.year, now.month, now.day),
      isCompleted: false,
      progressMinutes: 10,
    );
  }

  /// Pump layar dengan DB memori + locale `id` (copy board).
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(780, 2000);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeHabitsProvider.overrideWith((ref) => Stream.value([habit])),
          habitTodayLogProvider(
            habit.id,
          ).overrideWith((ref) => Stream.value(todayLog())),
          pomodoroControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          locale: const Locale('id'),
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PomodoroScreen(),
        ),
      ),
    );
    await tester.pump(); // stream provider selesai
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Lepas tree supaya ticker & timer midnight dibatalkan sebelum test selesai.
  Future<void> disposeScreen(WidgetTester tester) async {
    await controller.cancel();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  group('PomodoroScreen — struktur board 05 Pomodoro', () {
    testWidgets('pemilih mode: track surface-alt 41dp + segmen aktif surface', (
      tester,
    ) async {
      await pumpScreen(tester);

      final track = find.byKey(const Key('pomodoro_mode_selector'));
      expect(track, findsOneWidget);
      expect(tester.getSize(track).height, 41); // board 82px @2x

      final trackDecoration =
          tester.widget<DecoratedBox>(track).decoration as BoxDecoration;
      expect(trackDecoration.color, AppColors.light.surfaceAlt);
      expect(
        (trackDecoration.borderRadius! as BorderRadius).topLeft.x,
        999, // rounded.pill
      );

      final pill = find.byKey(const Key('pomodoro_mode_pill'));
      final pillDecoration =
          tester.widget<DecoratedBox>(pill).decoration as BoxDecoration;
      expect(pillDecoration.color, AppColors.light.surface);

      // Copy board: dua mode, label memakai token l10n.
      expect(find.text('Terkait Habit'), findsOneWidget);
      expect(find.text('Bebas Mandiri'), findsOneWidget);

      // Default = mode bebas → pill di paruh kanan track.
      final trackRect = tester.getRect(track);
      final pillRect = tester.getRect(pill);
      expect(pillRect.center.dx, greaterThan(trackRect.center.dx));

      // Pindah ke mode habit → pill geser ke paruh kiri + kartu habit muncul.
      await tester.tap(find.byKey(const Key('pomodoro_mode_habit')));
      await tester.pumpAndSettle();
      expect(controller.isHabitMode, isTrue);
      expect(find.byKey(const Key('pomodoro_habit_card')), findsOneWidget);
      expect(tester.getRect(pill).center.dx, lessThan(trackRect.center.dx));

      await disposeScreen(tester);
    });

    testWidgets('kartu habit: surface + border, tinggi 57, tile ikon 32', (
      tester,
    ) async {
      controller.setHabitMode(true);
      controller.selectHabit(habit);
      await pumpScreen(tester);

      final card = find.byKey(const Key('pomodoro_habit_card'));
      expect(tester.getSize(card).height, 57); // board 114px @2x
      final material = tester.widget<Material>(card);
      expect(material.color, AppColors.light.surface);
      final shape = material.shape! as RoundedRectangleBorder;
      expect((shape.borderRadius as BorderRadius).topLeft.x, 14); // md

      final tile = find.byKey(const Key('pomodoro_habit_icon'));
      expect(tester.getSize(tile), const Size(32, 32)); // board 64px @2x
      final tileDecoration =
          tester.widget<Container>(tile).decoration! as BoxDecoration;
      expect(tileDecoration.color, AppColors.light.primaryContainer);

      // Judul habit + progress menit nyata (board: baris kedua di bawah judul).
      expect(find.text('Baca buku'), findsOneWidget);
      expect(find.text('10/30 menit'), findsOneWidget);

      await disposeScreen(tester);
    });

    testWidgets('cakram timer 261dp + cincin honey 8dp + digit Fredoka 44', (
      tester,
    ) async {
      await pumpScreen(tester);

      final timer = find.byKey(const Key('pomodoro_timer'));
      expect(tester.getSize(timer).width, 261); // board 522px @2x
      expect(tester.getSize(timer).height, 261);
      final disc = tester.widget<Container>(timer).decoration! as BoxDecoration;
      expect(disc.color, AppColors.light.surface);
      expect(disc.shape, BoxShape.circle);
      expect((disc.border! as Border).top.color, AppColors.light.border);

      // Cincin: busur honey, tebal 8, penuh saat idle (board: lingkaran utuh).
      final ring = find.byKey(const Key('pomodoro_timer_ring'));
      expect(tester.getSize(ring).width, 218); // 261 - 2×21,5
      final painter = tester.widget<CustomPaint>(ring).painter!;
      expect(painter, isA<PomodoroRingPainter>());
      final ringPainter = painter as PomodoroRingPainter;
      expect(ringPainter.color, AppColors.light.honey);
      expect(ringPainter.strokeWidth, 8); // board 16px @2x
      expect(ringPainter.progress, 1.0);

      // Digit: Fredoka 600 44dp dengan tabular figures.
      final digits = find.descendant(
        of: find.byKey(const Key('pomodoro_timer_text')),
        matching: find.byType(Text),
      );
      expect(digits, findsNWidgets(5)); // 2 5 : 0 0
      final style = tester.widget<Text>(digits.first).style!;
      expect(style.fontFamily, 'Fredoka');
      expect(style.fontSize, 44); // board 196×64px @2x
      expect(style.fontWeight, FontWeight.w600);
      expect(
        style.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('25:00'), findsOneWidget);
      handle.dispose();

      await disposeScreen(tester);
    });

    testWidgets(
      'label timer tetap lewat ValueListenableBuilder(remainingNotifier)',
      (tester) async {
        await controller.start(
          completionTitle: 'Selesai',
          completionBody: 'Selesai',
        );
        await pumpScreen(tester);

        final builder = tester.widget<ValueListenableBuilder<Duration>>(
          find.byType(ValueListenableBuilder<Duration>),
        );
        expect(builder.valueListenable, controller.remainingNotifier);

        final handle = tester.ensureSemantics();
        expect(find.bySemanticsLabel('25:00'), findsOneWidget);

        // Tick hanya lewat notifier: tidak ada notifyListeners/rebuild penuh.
        controller.remainingNotifier.value = const Duration(
          minutes: 3,
          seconds: 7,
        );
        await tester.pump();
        expect(find.bySemanticsLabel('03:07'), findsOneWidget);
        expect(find.bySemanticsLabel('25:00'), findsNothing);
        handle.dispose();

        await disposeScreen(tester);
      },
    );

    testWidgets('chip durasi: 69×52, aktif primary, tap mengubah durasi', (
      tester,
    ) async {
      await pumpScreen(tester);

      final presets = find.byKey(const Key('pomodoro_duration_presets'));
      expect(presets, findsOneWidget);
      for (final minutes in [15, 25, 45, 60]) {
        final chip = find.byKey(Key('pomodoro_duration_chip_$minutes'));
        expect(chip, findsOneWidget);
        expect(tester.getSize(chip), const Size(69, 52)); // 138×104px @2x
      }

      // Board: 25 menit aktif = `primary` + angka `onPrimary`.
      final selected = tester.widget<Material>(
        find
            .ancestor(
              of: find.byKey(const Key('pomodoro_duration_chip_25')),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(selected.color, AppColors.light.primary);
      final numberStyle = tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('pomodoro_duration_chip_25')),
              matching: find.byType(Text),
            ),
          )
          .style!;
      expect(numberStyle.color, AppColors.light.onPrimary);

      // Chip belum aktif: `surface` + border.
      final unselected = tester.widget<Material>(
        find
            .ancestor(
              of: find.byKey(const Key('pomodoro_duration_chip_45')),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(unselected.color, AppColors.light.surface);

      await tester.tap(find.byKey(const Key('pomodoro_duration_chip_45')));
      await tester.pump();
      expect(controller.durationMinutes, 45);

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('45:00'), findsOneWidget);
      handle.dispose();

      await disposeScreen(tester);
    });

    testWidgets('idle: satu tombol "Mulai" selebar isi layar', (tester) async {
      await pumpScreen(tester);

      final start = find.byKey(const Key('pomodoro_start_button'));
      expect(start, findsOneWidget);
      expect(tester.widget<AppButton>(start).label, 'Mulai');
      expect(find.byKey(const Key('pomodoro_stop_button')), findsNothing);

      final contentWidth = tester
          .getSize(find.byKey(const Key('pomodoro_mode_selector')))
          .width;
      // Board: tombol aksi mengisi lebar konten (tanpa tombol hentikan).
      expect(tester.getSize(start).width, contentWidth);

      await disposeScreen(tester);
    });

    testWidgets('berjalan: "Pause" + tombol hentikan persegi 57×48', (
      tester,
    ) async {
      await controller.start(
        completionTitle: 'Selesai',
        completionBody: 'Selesai',
      );
      await pumpScreen(tester);

      final primary = find.byKey(const Key('pomodoro_primary_action'));
      expect(tester.widget<AppButton>(primary).label, 'Pause');
      final start = find.byKey(const Key('pomodoro_start_button'));
      expect(start, findsNothing);

      final stop = find.byKey(const Key('pomodoro_stop_button'));
      expect(stop, findsOneWidget);
      expect(tester.getSize(stop), const Size(57, 48)); // board 114×102px @2x
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

      // Board: tombol utama + gap 10 + tombol persegi = lebar konten.
      final contentWidth = tester
          .getSize(find.byKey(const Key('pomodoro_mode_selector')))
          .width;
      expect(
        tester.getSize(primary).width + 10 + tester.getSize(stop).width,
        contentWidth,
      );

      // Selama sesi berjalan, mode + chip durasi tidak bisa diubah (0.45).
      final presetsOpacity = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byKey(const Key('pomodoro_duration_presets')),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(presetsOpacity.opacity, 0.45);

      await disposeScreen(tester);
    });
  });
}