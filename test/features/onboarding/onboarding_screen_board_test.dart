import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/core/widgets/app_shell.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/onboarding/onboarding_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Uji fidelity board `design-export/09 Onboarding.png` untuk
/// [OnboardingScreen] (AGENTS.md §11).
///
/// Board diukur langsung dari PNG 780×1688 px (= frame 390×844dp @2x):
/// - lingkaran maskot Ø168dp (336px), isi `#F4EDE1`, otter mengisi penuh Ø;
/// - judul Fredoka cap 20dp → 26dp, sub-judul em 13dp `ink-muted` 2 baris;
/// - label "Nama kamu" di atas field (bukan floating label) + helper caption;
/// - field 342×48,5dp radius 14, CTA "Mulai" 342×51dp radius 14;
/// - page dots: pill aktif 20×5 `primary` + 2 dot 5×5 `border`, jarak 6;
/// - gutter board 24dp, kode memakai 16 (gutter app-wide) → deviasi tercatat.
///
/// Board hanya menggambar langkah 1; langkah tema & bahasa memakai
/// `segmented-control` DESIGN.md (board 08 Pengaturan).
Future<AppDatabase> _pumpScreen(
  WidgetTester tester, {
  double width = 390,
  double height = 844,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        home: const OnboardingScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return db;
}

/// Lepas tree supaya stream Drift berhenti sebelum pemeriksaan pending-timer.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

final Finder _mascot = find.byKey(const Key('onboarding_mascot'));
final Finder _dots = find.byType(AnimatedContainer);

void main() {
  group('OnboardingScreen — maskot board 09', () {
    testWidgets('maskot otter-waving dipotong ClipOval Ø168, bukan gambar kotak', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(_mascot, findsOneWidget);
      expect(tester.getSize(_mascot), const Size(168, 168));

      final clip = find.descendant(of: _mascot, matching: find.byType(ClipOval));
      expect(clip, findsOneWidget, reason: 'maskot wajib dipotong ClipOval');

      final image = tester.widget<Image>(
        find.descendant(of: _mascot, matching: find.byType(Image)),
      );
      expect(
        (image.image as AssetImage).assetName,
        'assets/mascot/otter-waving.png',
      );

      // Isi lingkaran = board `#F4EDE1` (honey-container 22% di atas canvas).
      final tint = tester.widget<ColoredBox>(
        find.descendant(of: _mascot, matching: find.byType(ColoredBox)),
      );
      expect(
        tint.color,
        AppColors.light.honeyContainer.withValues(alpha: 0.22),
      );

      await _disposeScreen(tester);
    });
  });

  group('OnboardingScreen — urutan & ukuran mengikuti board 09', () {
    testWidgets('urutan maskot → judul → sub-judul → label → field → helper '
        '→ CTA → dots', (tester) async {
      await _pumpScreen(tester);

      final order = <String, double>{
        'maskot': tester.getRect(_mascot).top,
        'judul': tester.getRect(find.text('Halo! Aku Tazk')).top,
        'sub-judul': tester.getRect(
          find.text(
            'Aku akan bantu kamu menyelesaikan hal kecil setiap hari. '
            'Siapa namamu?',
          ),
        ).top,
        'label': tester.getRect(find.text('Nama kamu')).top,
        'field': tester.getRect(find.byType(TextFormField)).top,
        'helper': tester.getRect(
          find.text('Bisa diubah kapan saja di Profil'),
        ).top,
        'CTA': tester.getRect(find.byType(AppButton)).top,
        'dots': tester.getRect(_dots.first).top,
      };

      final keys = order.keys.toList();
      for (var i = 1; i < keys.length; i++) {
        expect(
          order[keys[i]]!,
          greaterThan(order[keys[i - 1]]!),
          reason: '${keys[i]} harus di bawah ${keys[i - 1]}',
        );
      }

      // Jarak kotak maskot → kotak judul 22dp; board 29,5dp diukur antar-ink,
      // dan leading Fredoka 26dp menambah ~7,5dp di atas cap.
      expect(order['judul']! - (order['maskot']! + 168), closeTo(22, 0.5));

      // Judul 26dp (board cap 20dp), sub-judul 13dp `ink-muted`.
      final title = tester.widget<Text>(find.text('Halo! Aku Tazk'));
      expect(title.style?.fontSize, 26);
      final subtitle = tester.widget<Text>(
        find.text(
          'Aku akan bantu kamu menyelesaikan hal kecil setiap hari. '
          'Siapa namamu?',
        ),
      );
      expect(subtitle.style?.fontSize, 13);
      expect(subtitle.style?.color, AppColors.light.inkMuted);

      await _disposeScreen(tester);
    });

    testWidgets('gutter 16 + CTA full width + 3 page dots', (tester) async {
      await _pumpScreen(tester);

      final field = tester.getRect(find.byType(TextFormField));
      expect(field.left, closeTo(16, 0.5)); // board 24 → kode 16
      expect(field.width, closeTo(390 - 32, 0.5)); // board 342

      final cta = tester.getRect(find.byType(AppButton));
      expect(cta.left, closeTo(16, 0.5));
      expect(cta.width, closeTo(390 - 32, 0.5));
      expect(cta.height, greaterThanOrEqualTo(48)); // tap target

      // Board: dot aktif 20×5 `primary`, sisanya 5×5 `border`, jarak 6.
      expect(_dots, findsNWidgets(3));
      final active = tester.widget<AnimatedContainer>(_dots.at(0));
      expect(active.constraints?.maxWidth, 20);
      expect(active.constraints?.maxHeight, 5);
      final inactive = tester.widget<AnimatedContainer>(_dots.at(1));
      expect(inactive.constraints?.maxWidth, 5);

      final first = tester.getRect(_dots.at(0));
      final second = tester.getRect(_dots.at(1));
      expect(second.left - first.right, closeTo(6, 0.5));

      await _disposeScreen(tester);
    });
  });

  group('OnboardingScreen — CTA', () {
    testWidgets('nama kosong ditolak, nama terisi lanjut ke langkah tema', (
      tester,
    ) async {
      await _pumpScreen(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Mulai'));
      await tester.pump();
      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Halo! Aku Tazk'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Fazal');
      await tester.tap(find.widgetWithText(AppButton, 'Mulai'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih tema'), findsOneWidget);
      expect(find.text('Halo! Aku Tazk'), findsNothing);

      await _disposeScreen(tester);
    });

    testWidgets('langkah terakhir menyimpan profil lalu masuk app shell', (
      tester,
    ) async {
      await _pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'Fazal');
      await tester.tap(find.widgetWithText(AppButton, 'Mulai'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih bahasa'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Selesai'));
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);

      await _disposeScreen(tester);
    });

    testWidgets('tema & bahasa memakai segmented control bertema', (
      tester,
    ) async {
      await _pumpScreen(tester);

      await tester.enterText(find.byType(TextFormField), 'Fazal');
      await tester.tap(find.widgetWithText(AppButton, 'Mulai'));
      await tester.pumpAndSettle();

      final segmented = tester.widget<SegmentedButton<AppThemeMode>>(
        find.byType(SegmentedButton<AppThemeMode>),
      );
      expect(segmented.showSelectedIcon, isFalse);
      expect(segmented.selected, {AppThemeMode.light});
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Lanjut'));
      await tester.pumpAndSettle();

      // Langkah 3 = bahasa, memakai kontrol yang sama.
      final language = tester.widget<SegmentedButton<AppLanguage>>(
        find.byType(SegmentedButton<AppLanguage>),
      );
      expect(language.selected, {AppLanguage.indonesian});
      expect(find.text('Indonesia'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      await _disposeScreen(tester);
    });
  });
}