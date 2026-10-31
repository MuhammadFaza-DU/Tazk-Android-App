import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/app_chip.dart';
import 'package:tazk/core/widgets/empty_state.dart';
import 'package:tazk/core/widgets/error_state.dart';
import 'package:tazk/core/widgets/skeleton_list.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/calendar/calendar_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/task_providers.dart';

/// Uji fidelity board `design-export/04 Kalender.png` untuk [CalendarScreen].
///
/// Board (780×1546 px, dibagi 2 → frame 390dp):
/// - header "Oktober 2026" + dua tombol bulat panah di kanan,
/// - kartu grid: nama hari `ink-muted`, hari luar bulan `ink-muted`, pill hari
///   terpilih `primary`/`on-primary` 44×40dp radius 10, satu titik `honey` per
///   tanggal berisi item,
/// - panel harian: "Kamis, 29 Okt" + "4 item", lalu satu kartu per item
///   (checkbox, judul, chip, jam) tanpa sub-judul kelompok "Habits (daily)".

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Tanggal lain di bulan yang sama (dipakai untuk menguji penanda "hari ini").
DateTime _otherDayInMonth(DateTime day) =>
    DateTime(day.year, day.month, day.day == 1 ? 2 : 1);

Future<Task> _insertTask(
  AppDatabase db, {
  required String title,
  required DateTime date,
  TaskPriority priority = TaskPriority.medium,
  DateTime? time,
  bool isCompleted = false,
}) async {
  final id = await db.into(db.tasks).insert(
        TasksCompanion.insert(
          title: title,
          date: date,
          time: Value(time),
          priority: priority,
          isCompleted: Value(isCompleted),
        ),
      );
  return (db.select(db.tasks)..where((t) => t.id.equals(id))).getSingle();
}

Future<Habit> _insertHabit(
  AppDatabase db, {
  required String name,
  HabitFrequency frequency = HabitFrequency.daily,
  DateTime? scheduledTime,
  bool hasProgress = false,
  int? targetMinutes,
}) async {
  final id = await db.into(db.habits).insert(
        HabitsCompanion.insert(
          name: name,
          frequency: frequency,
          scheduledTime: Value(scheduledTime),
          hasProgress: Value(hasProgress),
          targetMinutes: Value(targetMinutes),
        ),
      );
  return (db.select(db.habits)..where((h) => h.id.equals(id))).getSingle();
}

/// Pump [CalendarScreen] dengan DB memori + locale `id` (copy board).
Future<void> _pumpScreen(
  WidgetTester tester,
  AppDatabase db, {
  List<Override> extraOverrides = const [],
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db), ...extraOverrides],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    ),
  );
  if (!settle) return;
  // Pump pendek membiarkan stream Drift menyelesaikan query sehingga skeleton
  // tidak tertinggal.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Lepas tree supaya query stream Drift & ticker skeleton berhenti.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

BoxDecoration _decorationOf(WidgetTester tester, Key key) {
  final container = tester.widget<Container>(find.byKey(key));
  return container.decoration! as BoxDecoration;
}

Color? _textColorOf(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(
    find.descendant(of: find.byKey(key), matching: find.byType(Text)),
  );
  return text.style?.color;
}

/// Jam terformat bergantung locale ("08:00" vs "08.00").
final _clockPattern = RegExp(r'^\d{1,2}[:.]\d{2}$');

void main() {
  group('CalendarScreen — grid board 04 Kalender', () {
    testWidgets('hari terpilih memakai pill primary + teks on-primary 44×40',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      final today = _today();
      final key = calendarDayKey(today);

      // Board: pill `primary` radius 10, teks `on-primary`.
      final decoration = _decorationOf(tester, key);
      expect(decoration.color, AppColors.light.primary);
      expect(decoration.borderRadius, BorderRadius.circular(10));
      expect(_textColorOf(tester, key), AppColors.light.onPrimary);

      // Ukuran pill 44×40dp (board 88×80px).
      final size = tester.getSize(find.byKey(key));
      expect(size.width, 44);
      expect(size.height, 40);

      await _disposeScreen(tester);
    });

    testWidgets('hari ini ditandai border honey saat tanggal lain dipilih',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      final today = _today();
      final other = _otherDayInMonth(today);

      await tester.tap(find.byKey(calendarDayKey(other)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Hari ini: border `honey`, bukan pill penuh.
      final todayDecoration = _decorationOf(tester, calendarDayKey(today));
      expect(todayDecoration.color, isNull);
      expect(todayDecoration.border, isNotNull);
      expect(
        (todayDecoration.border! as Border).top.color,
        AppColors.light.honey,
      );
      expect(_textColorOf(tester, calendarDayKey(today)), AppColors.light.ink);

      // Tanggal yang baru dipilih memakai pill `primary`.
      expect(
        _decorationOf(tester, calendarDayKey(other)).color,
        AppColors.light.primary,
      );

      await _disposeScreen(tester);
    });

    testWidgets('hari luar bulan memakai teks ink-muted', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      final today = _today();
      // Tanggal terakhir bulan sebelumnya selalu tampil di grid bulan ini.
      final outside = DateTime(today.year, today.month, 0);
      final key = calendarDayKey(outside);

      expect(_textColorOf(tester, key), AppColors.light.inkMuted);
      expect(_decorationOf(tester, key).color, isNull);

      await _disposeScreen(tester);
    });

    testWidgets('satu titik honey per tanggal berisi item, on-primary saat '
        'tanggal itu terpilih', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final today = _today();
      final other = _otherDayInMonth(today);
      await _insertTask(db, title: 'Tugas Kuliah A', date: today);
      await _insertTask(db, title: 'Rapat Organisasi', date: other);

      await _pumpScreen(tester, db);

      // Hari terpilih: titik `on-primary` di dalam pill.
      final selectedMarker = _decorationOf(tester, calendarMarkerKey(today));
      expect(selectedMarker.shape, BoxShape.circle);
      expect(selectedMarker.color, AppColors.light.onPrimary);

      // Tanggal lain berisi item: titik `honey`.
      expect(
        _decorationOf(tester, calendarMarkerKey(other)).color,
        AppColors.light.honey,
      );

      // Tanggal tanpa item tidak punya titik sama sekali.
      final candidates = [
        DateTime(today.year, today.month, 15),
        DateTime(today.year, today.month, 16),
        DateTime(today.year, today.month, 17),
      ];
      final empty = candidates.firstWhere(
        (day) => day != today && day != other,
      );
      expect(find.byKey(calendarMarkerKey(empty)), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('kartu grid memakai surface + border radius 24', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      final decoration = _decorationOf(tester, calendarGridCardKey);
      expect(decoration.color, AppColors.light.surface);
      expect(decoration.borderRadius, BorderRadius.circular(24));
      expect((decoration.border! as Border).top.color, AppColors.light.border);

      await _disposeScreen(tester);
    });

    testWidgets('header bulan: label + dua tombol panah', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      final today = _today();
      final expectedMonth =
          DateFormat('MMMM yyyy', 'id').format(DateTime(today.year, today.month));
      expect(
        tester.widget<Text>(find.byKey(calendarMonthLabelKey)).data,
        expectedMonth,
      );
      expect(find.byKey(calendarPrevMonthKey), findsOneWidget);
      expect(find.byKey(calendarNextMonthKey), findsOneWidget);
      // Judul layar tetap di AppBar, bukan diulang di header bulan.
      expect(find.text('Kalender'), findsOneWidget);

      await _disposeScreen(tester);
    });
  });

  group('CalendarScreen — panel harian board 04 Kalender', () {
    testWidgets('satu AppCard per item + judul tanggal dan jumlah item',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final today = _today();
      await _insertTask(
        db,
        title: 'Tugas Kuliah A',
        date: today,
        priority: TaskPriority.high,
        time: DateTime(today.year, today.month, today.day, 8),
      );
      await _insertTask(
        db,
        title: 'Rapat Organisasi',
        date: today,
        time: DateTime(today.year, today.month, today.day, 13),
      );
      await _insertHabit(
        db,
        name: 'Olahraga pagi',
        scheduledTime: DateTime(today.year, today.month, today.day, 6, 30),
      );

      await _pumpScreen(tester, db);

      // Satu kartu per item (bukan satu kartu berdivider).
      expect(find.byType(AppCard), findsNWidgets(3));
      expect(find.byKey(calendarDayPanelKey), findsOneWidget);

      // Judul section = tanggal board, bukan label kelompok.
      final expectedDate = DateFormat('EEEE, d MMM', 'id').format(today);
      expect(find.text(expectedDate), findsOneWidget);
      expect(find.text('3 item'), findsOneWidget);

      // Label "Habits (daily)" tidak boleh muncul lagi.
      expect(find.textContaining('Habits ('), findsNothing);
      expect(find.text('Habits (harian)'), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('kartu task: checkbox, chip prioritas, dan jam', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final today = _today();
      await _insertTask(
        db,
        title: 'Rapat Organisasi',
        date: today,
        priority: TaskPriority.high,
        time: DateTime(today.year, today.month, today.day, 13),
      );

      await _pumpScreen(tester, db);

      expect(find.text('Rapat Organisasi'), findsWidgets);
      expect(find.widgetWithText(AppChip, 'High'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      final clockTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          .where(_clockPattern.hasMatch);
      expect(clockTexts, isNotEmpty);

      await _disposeScreen(tester);
    });

    testWidgets('kartu habit: chip "Habit" primary-container + jam jadwal',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final today = _today();
      await _insertHabit(
        db,
        name: 'Olahraga pagi',
        scheduledTime: DateTime(today.year, today.month, today.day, 6, 30),
      );

      await _pumpScreen(tester, db);

      final chip = tester.widget<AppChip>(
        find.widgetWithText(AppChip, 'Habit'),
      );
      expect(chip.backgroundColor, AppColors.light.primaryContainer);
      expect(chip.foregroundColor, AppColors.light.primary);

      await _disposeScreen(tester);
    });

    testWidgets('habit tanpa jadwal memakai frekuensi sebagai sub-judul',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertHabit(db, name: 'Baca buku');

      await _pumpScreen(tester, db);

      // Habit custom tidak boleh diberi label "daily".
      expect(find.text('Harian'), findsOneWidget);
      expect(find.textContaining('daily'), findsNothing);

      await _disposeScreen(tester);
    });
  });

  group('CalendarScreen — state board 11 States', () {
    testWidgets('loading memakai SkeletonList, bukan spinner', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // Frame pertama saja: stream belum selesai.
      await _pumpScreen(tester, db, settle: false);

      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('error memakai ErrorState dengan aksi coba lagi', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(
        tester,
        db,
        extraOverrides: [
          tasksForDateProvider.overrideWith(
            (ref, date) => Stream<List<Task>>.error(StateError('boom')),
          ),
        ],
      );

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('kosong memakai EmptyState berjudul + pesan', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _pumpScreen(tester, db);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Tidak ada task/habit di tanggal ini'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget); // kartu EmptyState
      expect(find.byType(SkeletonList), findsNothing);

      await _disposeScreen(tester);
    });
  });

  group('CalendarScreen — tahan data ekstrem (break-ui)', () {
    testWidgets('judul sangat panjang, emoji, dan banyak item tidak overflow',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      final today = _today();
      await _insertTask(
        db,
        title: 'Rapat koordinasi divisi riset dan pengembangan bersama seluruh '
            'kepala unit serta perwakilan mahasiswa tingkat akhir 🗓️',
        date: today,
        priority: TaskPriority.low,
      );
      await _insertTask(db, title: 'A', date: today);
      for (var i = 0; i < 6; i++) {
        await _insertHabit(db, name: 'Habit nomor $i dengan nama yang panjang');
      }

      // Overflow RenderFlex akan menggagalkan test ini secara otomatis.
      await _pumpScreen(tester, db);

      expect(find.byKey(calendarDayPanelKey), findsOneWidget);
      expect(find.text('8 item'), findsOneWidget);
      // Judul panjang dipotong, bukan meluber keluar kartu.
      final title = tester.widget<Text>(find.textContaining('Rapat koordinasi'));
      expect(title.maxLines, 2);
      expect(title.overflow, TextOverflow.ellipsis);

      await _disposeScreen(tester);
    });
  });

  group('CalendarScreen — interaksi lama tetap ada', () {
    testWidgets('drag-reschedule: setiap tanggal jadi DragTarget dan task bisa '
        'diseret', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertTask(db, title: 'Tugas Kuliah A', date: _today());

      await _pumpScreen(tester, db);

      // Minimal 28 sel tanggal di grid bulan ini menerima drop.
      expect(find.byType(DragTarget<Task>), findsAtLeastNWidgets(28));
      // Task di panel harian bisa diseret ke tanggal lain.
      expect(find.byType(Draggable<Task>), findsOneWidget);

      await _disposeScreen(tester);
    });
  });
}
