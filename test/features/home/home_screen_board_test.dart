import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/core/widgets/app_chip.dart';
import 'package:tazk/core/widgets/completion_checkbox.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/home/home_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/gamification_providers.dart';
import 'package:tazk/providers/habit_providers.dart';
import 'package:tazk/providers/task_providers.dart';

/// Board `01 Home` (390×872dp): greeting + tanggal + avatar, kartu level
/// `primary`, item task/habit sebagai kartu per item, dan CTA selebar isinya.
void main() {
  final today = DateTime.now();

  // Muat font sungguhan (Fredoka + Plus Jakarta Sans) supaya pengukuran lebar
  // CTA realistis. Font default `flutter test` (Ahem) melebar tiap glif 1em,
  // sehingga lebar label terukur ~2× ukuran aslinya.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Future<ByteData> bytes(String path) =>
        Future.value(ByteData.sublistView(File(path).readAsBytesSync()));
    await (FontLoader('Fredoka')
          ..addFont(bytes('assets/fonts/Fredoka-Variable.ttf')))
        .load();
    await (FontLoader('PlusJakartaSans')
          ..addFont(bytes('assets/fonts/PlusJakartaSans-Regular.ttf'))
          ..addFont(bytes('assets/fonts/PlusJakartaSans-SemiBold.ttf')))
        .load();
  });

  final profile = UserProfileData(
    id: 1,
    name: 'Faza',
    avatarId: 'default',
    xp: 620,
    level: 12,
    createdAt: DateTime(2026, 1, 1),
  );

  const streakState = StreakStateData(
    id: 1,
    currentStreak: 15,
    longestStreak: 15,
    freezeCount: 0,
    freezeProgressDays: 0,
  );

  final tasks = <Task>[
    Task(
      id: 1,
      title: 'Tugas Kuliah A',
      date: today,
      time: DateTime(2026, 1, 1, 8),
      priority: TaskPriority.high,
      isCompleted: true,
      autoCompleteSubtasks: true,
      createdAt: today,
    ),
    Task(
      id: 2,
      title: 'Rapat Organisasi',
      date: today,
      time: DateTime(2026, 1, 1, 13),
      priority: TaskPriority.medium,
      isCompleted: false,
      autoCompleteSubtasks: true,
      createdAt: today,
    ),
    Task(
      id: 3,
      title: 'Belanja bulanan',
      date: today,
      priority: TaskPriority.low,
      isCompleted: false,
      autoCompleteSubtasks: true,
      createdAt: today,
    ),
  ];

  final habits = <Habit>[
    Habit(
      id: 1,
      name: 'Olahraga pagi',
      frequency: HabitFrequency.daily,
      hasProgress: false,
      isActive: true,
      createdAt: today,
    ),
    Habit(
      id: 2,
      name: 'Baca buku',
      frequency: HabitFrequency.daily,
      hasProgress: true,
      targetMinutes: 30,
      isActive: true,
      createdAt: today,
    ),
  ];

  var logId = 0;
  HabitLog log(int habitId, DateTime day, {bool done = true, int minutes = 0}) {
    logId++;
    return HabitLog(
      id: logId,
      habitId: habitId,
      date: DateTime(day.year, day.month, day.day),
      isCompleted: done,
      progressMinutes: minutes,
    );
  }

  /// Board: Olahraga pagi 23 hari (selesai hari ini), Baca buku 12 hari
  /// (belum selesai hari ini) + 15/30 menit.
  final history = <int, List<HabitLog>>{
    1: [
      for (var i = 0; i < 23; i++)
        log(1, DateTime(today.year, today.month, today.day - i)),
    ],
    2: [
      log(2, today, done: false, minutes: 15),
      for (var i = 1; i <= 12; i++)
        log(2, DateTime(today.year, today.month, today.day - i)),
    ],
  };

  Future<void> pumpHome(WidgetTester tester) async {
    // Board `01 Home` = 390dp lebar; tinggi dinaikkan supaya seluruh isi
    // (termasuk CTA di bawah) ikut ter-layout tanpa perlu scroll.
    tester.view.physicalSize = const Size(780, 2000);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith((ref) => Stream.value(profile)),
          streakStateProvider.overrideWith((ref) => Stream.value(streakState)),
          todayTasksProvider.overrideWith((ref) => Stream.value(tasks)),
          activeHabitsProvider.overrideWith((ref) => Stream.value(habits)),
          todayHabitLogCompletionProvider.overrideWith(
            (ref) => Stream.value(const {1: true, 2: false}),
          ),
          habitHistoryProvider.overrideWith(
            (ref, habitId) => Stream.value(history[habitId] ?? const <HabitLog>[]),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('id'),
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    // Frame pertama: skeleton. Pump singkat supaya stream provider selesai.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('header board: sapaan, tanggal hari ini, avatar inisial 48dp',
      (tester) async {
    await pumpHome(tester);

    // "Halo, Faza" tanpa tanda seru (board), Fredoka 28sp.
    final greeting = tester.widget<Text>(find.text('Halo, Faza'));
    expect(greeting.style?.fontSize, 28);
    expect(greeting.style?.color, AppColors.light.ink);

    // Tanggal hari ini mengikuti locale aktif ("Rabu, 29 Oktober").
    final expectedDate =
        DateFormat('EEEE, d MMMM', 'id').format(DateTime.now());
    expect(find.text(expectedDate), findsOneWidget);

    // Avatar kanan: lingkaran 48dp `honeyContainer` berisi inisial nama.
    final avatar = find.byKey(const Key('home_avatar'));
    expect(avatar, findsOneWidget);
    expect(tester.widget<Material>(avatar).color, AppColors.light.honeyContainer);
    expect(tester.getSize(avatar).width, 48);
    expect(tester.getSize(avatar).height, 48);
    expect(find.descendant(of: avatar, matching: find.text('F')),
        findsOneWidget);
  });

  testWidgets('kartu gamifikasi berlatar primary dengan XP bar honey',
      (tester) async {
    await pumpHome(tester);

    final card = tester.widget<Container>(
      find.byKey(const Key('home_level_card')),
    );
    final decoration = card.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.primary);
    expect(
      (decoration.borderRadius! as BorderRadius).topLeft.x,
      24, // rounded.xl
    );

    expect(find.text('Level 12'), findsOneWidget);
    expect(find.text('15 hari'), findsOneWidget);
    // "620 / 1200 XP · Petarung"
    expect(find.text('620 / 1200 XP · Petarung'), findsOneWidget);

    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.minHeight, 8);
    expect(bar.backgroundColor, AppColors.light.primarySoft);
    expect(bar.valueColor?.value, AppColors.light.honey);
  });

  testWidgets('section header menampilkan hitungan di kanan', (tester) async {
    await pumpHome(tester);

    expect(find.text('Tugas Hari Ini'), findsOneWidget);
    expect(find.text('2 sisa'), findsOneWidget);
    expect(find.text('Habits Hari Ini'), findsOneWidget);
    expect(find.text('1 dari 2'), findsOneWidget);
  });

  testWidgets('item task = kartu per item dengan chip prioritas + jam',
      (tester) async {
    await pumpHome(tester);

    // Satu kartu per task (bukan satu kartu berdivider).
    expect(find.byKey(const Key('home_task_card_1')), findsOneWidget);
    expect(find.byKey(const Key('home_task_card_2')), findsOneWidget);
    expect(find.byKey(const Key('home_task_card_3')), findsOneWidget);
    expect(find.byType(CompletionCheckbox), findsNWidgets(5));

    // Chip prioritas untuk tiap item + jam / "Tanpa jam".
    expect(find.byType(AppChip), findsNWidgets(3));
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Med'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('13:00'), findsOneWidget);
    expect(find.text('Tanpa jam'), findsOneWidget);
  });

  testWidgets('item habit menampilkan streak dan progress menit',
      (tester) async {
    await pumpHome(tester);

    expect(find.byKey(const Key('home_habit_card_1')), findsOneWidget);
    expect(find.byKey(const Key('home_habit_card_2')), findsOneWidget);
    expect(find.text('23 hari'), findsOneWidget);
    expect(find.text('12 hari'), findsOneWidget);
    expect(find.text('15 / 30 mnt'), findsOneWidget);
  });

  testWidgets('CTA "Mulai sesi fokus" selebar isinya dan rata kiri',
      (tester) async {
    await pumpHome(tester);

    final cta = find.widgetWithText(AppButton, 'Mulai sesi fokus');
    expect(cta, findsOneWidget);

    final size = tester.getSize(cta);
    final pageWidth = tester.getSize(find.byType(CustomScrollView)).width;
    // Bukan full-width: menyisakan padding halaman di kedua sisi.
    expect(size.width, lessThan(pageWidth - 40));
    expect(size.width, greaterThan(80));

    expect(tester.getTopLeft(cta).dx, 20); // padding halaman board
  });

  testWidgets('CTA "Mulai sesi fokus" tinggi 59 dan lebar ~144 di 390dp',
      (tester) async {
    await pumpHome(tester);

    final cta = find.widgetWithText(AppButton, 'Mulai sesi fokus');
    expect(cta, findsOneWidget);

    final size = tester.getSize(cta);
    // Board `01 Home` mengukur 144×59 dp; lebar auto mengikuti label sehingga
    // dipakai rentang (bukan angka mati).
    expect(size.height, closeTo(59, 0.6));
    expect(size.width, greaterThanOrEqualTo(140));
    expect(size.width, lessThanOrEqualTo(160));

    expect(tester.takeException(), isNull);
  });
}