import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/celebration_overlay.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/features/home/home_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/gamification_providers.dart';
import 'package:tazk/providers/habit_providers.dart';
import 'package:tazk/providers/task_providers.dart';

UserProfileData _profile({required int level}) => UserProfileData(
  id: 1,
  name: 'Faza',
  avatarId: 'default',
  xp: 100 * level,
  level: level,
  createdAt: DateTime(2026, 1, 1),
);

const _streak = StreakStateData(
  id: 1,
  currentStreak: 0,
  longestStreak: 0,
  freezeCount: 0,
  freezeProgressDays: 0,
);

/// Pump [HomeScreen] dengan [profileStream] yang bisa dikendalikan dari luar.
/// `disableAnimations` mematikan confetti lewat `builder` (MediaQuery di dalam
/// MaterialApp, supaya override tidak ditimpa — pola sama dengan
/// `celebration_board_test`).
Widget _harness(
  Stream<UserProfileData> profileStream, {
  bool disableAnimations = false,
}) {
  return ProviderScope(
    overrides: [
      userProfileProvider.overrideWith((ref) => profileStream),
      streakStateProvider.overrideWith((ref) => Stream.value(_streak)),
      todayTasksProvider.overrideWith((ref) => Stream.value(const <Task>[])),
      activeHabitsProvider.overrideWith((ref) => Stream.value(const <Habit>[])),
      todayHabitLogCompletionProvider.overrideWith(
        (ref) => Stream.value(const <int, bool>{}),
      ),
      habitHistoryProvider.overrideWith(
        (ref, habitId) => Stream.value(const <HabitLog>[]),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('id'),
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
        ),
        child: child!,
      ),
      home: const HomeScreen(),
    ),
  );
}

/// Pump beberapa frame supaya alur stream → listener → `addPostFrameCallback`
/// → `showGeneralDialog` → route selesai dibangun. Satu pump tidak cukup karena
/// dialog didorong di *post-frame* callback (satu frame lebih lambat dari alur
/// button-tap di test lain).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('naik level 9→10 membuka dialog level-up tepat sekali', (
    tester,
  ) async {
    final controller = StreamController<UserProfileData>();
    addTearDown(controller.close);

    await tester.pumpWidget(_harness(controller.stream));
    await tester.pump();

    // Emisi pertama = level saat ini (bukan level-up).
    controller.add(_profile(level: 9));
    await _settle(tester);
    expect(find.text('Naik ke level 9!'), findsNothing);
    expect(find.byKey(celebrationCardKey), findsNothing);

    controller.add(_profile(level: 10));
    await _settle(tester);

    expect(find.text('Naik ke level 10!'), findsOneWidget);
    expect(find.byKey(celebrationCardKey), findsOneWidget);

    await tester.tap(find.text('Lanjutkan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Naik ke level 10!'), findsNothing);
  });

  testWidgets('level tetap / turun tidak memicu dialog level-up', (tester) async {
    final controller = StreamController<UserProfileData>();
    addTearDown(controller.close);

    await tester.pumpWidget(_harness(controller.stream));
    await tester.pump();

    controller.add(_profile(level: 10));
    await _settle(tester);
    expect(find.byKey(celebrationCardKey), findsNothing);

    // Tidak berubah.
    controller.add(_profile(level: 10));
    await _settle(tester);
    expect(find.byKey(celebrationCardKey), findsNothing);

    // Turun.
    controller.add(_profile(level: 8));
    await _settle(tester);
    expect(find.byKey(celebrationCardKey), findsNothing);
  });

  testWidgets('reduced-motion: level-up tampil tanpa confetti', (tester) async {
    final controller = StreamController<UserProfileData>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      _harness(controller.stream, disableAnimations: true),
    );
    await tester.pump();

    controller.add(_profile(level: 9));
    await _settle(tester);
    controller.add(_profile(level: 10));
    await _settle(tester);

    expect(find.text('Naik ke level 10!'), findsOneWidget);
    expect(find.byKey(const Key('celebration_confetti')), findsNothing);

    await tester.tap(find.text('Lanjutkan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Naik ke level 10!'), findsNothing);
  });
}