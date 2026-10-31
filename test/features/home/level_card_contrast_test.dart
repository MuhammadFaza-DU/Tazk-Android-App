import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/features/home/home_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/gamification_providers.dart';
import 'package:tazk/providers/habit_providers.dart';
import 'package:tazk/providers/task_providers.dart';

/// Kartu Level = "hero" card. Di light ia berlatarkan `primary` gelap dengan
/// teks terang; di dark latar itu menyilaukan sehingga tokennya dibalik jadi
/// panel hijau dalam. Test ini menjaga agar:
/// 1. light TIDAK berubah (masih memakai nilai board 01),
/// 2. dark memakai panel gelap (opsi owner 2026-10-31),
/// 3. semua pasangan teks/aksen lolos ambang WCAG di KEDUA tema.
void main() {
  double lin(int c) {
    final v = c / 255.0;
    return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
  }

  double lum(Color c) =>
      0.2126 * lin((c.r * 255).round()) +
      0.7152 * lin((c.g * 255).round()) +
      0.0722 * lin((c.b * 255).round());

  double contrast(Color a, Color b) {
    final la = lum(a);
    final lb = lum(b);
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  group('token kartu Level', () {
    test('light identik dengan board 01 (primary / on-primary / honey)', () {
      const c = AppColors.light;
      expect(c.levelCard, c.primary);
      expect(c.levelCardOn, c.onPrimary);
      expect(c.levelCardOnMuted, c.onPrimaryMuted);
      expect(c.levelCardTrack, c.primarySoft);
      expect(c.levelCardAccent, c.honey);
      expect(c.levelCardOnAccent, c.ink);
    });

    test('dark memakai panel gelap, bukan primary terang', () {
      const c = AppColors.dark;
      expect(c.levelCard, const Color(0xFF21402F));
      expect(c.levelCardAccent, const Color(0xFFC99B3F));
      expect(c.levelCard, isNot(c.primary));
    });

    for (final entry in {'light': AppColors.light, 'dark': AppColors.dark}.entries) {
      final name = entry.key;
      final c = entry.value;

      test('$name: teks kartu Level lolos AA 4.5:1', () {
        expect(contrast(c.levelCardOn, c.levelCard), greaterThanOrEqualTo(4.5),
            reason: '$name judul');
        expect(contrast(c.levelCardOnMuted, c.levelCard), greaterThanOrEqualTo(4.5),
            reason: '$name baris sekunder');
      });

      test('$name: pil streak lolos AA 4.5:1 (bug dark: 1.37:1)', () {
        expect(
          contrast(c.levelCardOnAccent, c.levelCardAccent),
          greaterThanOrEqualTo(4.5),
          reason: '$name label pil streak',
        );
      });

      test('$name: isi XP terbedakan dari track', () {
        final value = contrast(c.levelCardAccent, c.levelCardTrack);
        if (name == 'dark') {
          // Token baru (opsi owner 2026-10-31) memang dirancang lolos 3:1.
          expect(value, greaterThanOrEqualTo(3.0),
              reason: 'dark isi vs track');
        } else {
          // LIGHT SENGAJA TIDAK DIUBAH: masih nilai board 01 (`honey` di atas
          // `primary-soft`) = 1,77:1, di bawah ambang non-teks 3:1. Ini isu
          // terbuka yang menunggu keputusan owner (lihat docs/STATUS.md isu
          // kontras grafis). Di-assert sebagai angka tetap supaya perubahan
          // track/isi light memaksa keputusan itu, bukan lewat diam-diam.
          expect(value, closeTo(1.772, 0.02),
              reason: 'light isi vs track = nilai board, isu terbuka');
        }
      });
    }
  });

  testWidgets('kartu Level memakai token tema aktif (light vs dark)',
      (tester) async {
    final profile = UserProfileData(
      id: 1,
      name: 'Faza',
      avatarId: 'default',
      xp: 235,
      level: 4,
    );
    const streak = StreakStateData(
      id: 1,
      currentStreak: 1,
      longestStreak: 1,
      freezeCount: 0,
      freezeProgressDays: 0,
    );

    Future<void> pump(ThemeData theme) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
            streakStateProvider.overrideWith((ref) => Stream.value(streak)),
            todayTasksProvider.overrideWith((ref) => Stream.value(<Task>[])),
            activeHabitsProvider.overrideWith((ref) => Stream.value(<Habit>[])),
            todayHabitLogCompletionProvider
                .overrideWith((ref) => Stream.value(<int, bool>{})),
            habitHistoryProvider.overrideWith(
                (ref, habitId) => Stream.value(const <HabitLog>[])),
          ],
          child: MaterialApp(
            locale: const Locale('id'),
            theme: theme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    Color? cardColor() {
      final container = tester.widget<Container>(
        find.byKey(const Key('home_level_card')),
      );
      return (container.decoration as BoxDecoration).color;
    }

    await pump(AppTheme.light);
    final lightCard = cardColor();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));

    await pump(AppTheme.dark);
    final darkCard = cardColor();

    expect(lightCard, AppColors.light.levelCard);
    expect(darkCard, AppColors.dark.levelCard);
    expect(darkCard, isNot(lightCard));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}