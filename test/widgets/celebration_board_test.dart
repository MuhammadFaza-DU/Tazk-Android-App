import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/core/widgets/celebration_overlay.dart';
import 'package:tazk/l10n/app_localizations.dart';

/// Uji fidelity board `design-export/27 Celebration.png` (kolom MILESTONE).
///
/// Board (2240×1408, dibagi 2 → kartu 357dp) menunjukkan, dari atas:
/// - maskot `otter-waving` di dalam lingkaran 100dp (disc krem 200px @2x),
/// - judul Fredoka: 26px cap @2x → `headline` 18,
/// - pill label: cap 15px @2x → `label` 13, radius `pill`,
/// - CTA `primary` berlabel aksi lanjut.
///
/// Jarak antar-elemen dari board: lingkaran → judul 24, judul → pill 12,
/// pill → CTA 12. Kartu: `surface` + border, radius `xl` (24).

Future<void> _pumpDialog(
  WidgetTester tester, {
  bool disableAnimations = false,
  String rank = 'Penakluk',
  double width = 390,
  double height = 844,
}) async {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
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
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showRankCelebration(ctx, rankLabel: rank),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('go'));
  await tester.pump(); // dorong route
  await tester.pump(AppMotion.base); // transisi masuk selesai
}

BoxDecoration _decorationOf(WidgetTester tester, Key key) {
  final container = tester.widget<Container>(find.byKey(key));
  return container.decoration! as BoxDecoration;
}

void main() {
  group('showRankCelebration — komposisi board 27 Celebration', () {
    testWidgets('maskot otter-waving dalam lingkaran 100dp', (tester) async {
      await _pumpDialog(tester);

      expect(find.byKey(celebrationMascotKey), findsOneWidget);
      expect(
        tester.getSize(find.byKey(celebrationMascotKey)),
        const Size(100, 100),
      );

      final mascot = find.byKey(celebrationMascotKey);
      expect(
        find.descendant(of: mascot, matching: find.byType(ClipOval)),
        findsOneWidget,
        reason: 'maskot harus dipotong lingkaran, bukan kotak',
      );

      final image = tester.widget<Image>(
        find.descendant(of: mascot, matching: find.byType(Image)),
      );
      expect(
        (image.image as AssetImage).assetName,
        'assets/mascot/otter-waving.png',
      );

      final decoration = _decorationOf(tester, celebrationMascotKey);
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, AppColors.light.surfaceAlt);
    });

    testWidgets('judul Fredoka headline di atas pill rank label', (
      tester,
    ) async {
      await _pumpDialog(tester);

      final title = tester.widget<Text>(find.text('Rank Baru!'));
      expect(title.style?.fontFamily, 'Fredoka');
      expect(title.style?.fontSize, 18); // headline
      expect(title.style?.color, AppColors.light.ink);
      expect(title.textAlign, TextAlign.center);

      final pill = _decorationOf(tester, celebrationRankPillKey);
      expect(pill.color, AppColors.light.honeyContainer); // chip-priority
      expect(pill.borderRadius, BorderRadius.circular(999));

      final label = tester.widget<Text>(find.text('Penakluk'));
      expect(label.style?.fontSize, 13); // label
      expect(label.style?.color, AppColors.light.warningStrong);
      expect(label.maxLines, 1);

      expect(
        find.descendant(
          of: find.byKey(celebrationRankPillKey),
          matching: find.byIcon(Icons.workspace_premium_rounded),
        ),
        findsOneWidget,
      );
    });

    testWidgets('CTA primary label aksi lanjut, tap target 48', (tester) async {
      await _pumpDialog(tester);

      expect(find.byType(AppButton), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.text('Lanjutkan'),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(AppButton)).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('urutan atas→bawah: maskot, judul, pill, CTA', (tester) async {
      await _pumpDialog(tester);

      final mascot = tester.getRect(find.byKey(celebrationMascotKey));
      final title = tester.getRect(find.text('Rank Baru!'));
      final pill = tester.getRect(find.byKey(celebrationRankPillKey));
      final cta = tester.getRect(find.byType(AppButton));

      expect(title.top, greaterThan(mascot.bottom));
      expect(pill.top, greaterThan(title.bottom));
      expect(cta.top, greaterThan(pill.bottom));
    });

    testWidgets('kartu: surface + border, radius 24, maksimum 360', (
      tester,
    ) async {
      await _pumpDialog(tester);

      final card = _decorationOf(tester, celebrationCardKey);
      expect(card.color, AppColors.light.surface);
      expect(card.borderRadius, BorderRadius.circular(24));
      expect((card.border! as Border).top.color, AppColors.light.border);

      // Frame 390: gutter 28 kiri/kanan → 334 (board: kartu 357).
      expect(
        tester.getSize(find.byKey(celebrationCardKey)).width,
        390 - 2 * 28,
      );
    });

    testWidgets('kartu dibatasi 360 di layar lebar', (tester) async {
      await _pumpDialog(tester, width: 800, height: 900);

      expect(tester.getSize(find.byKey(celebrationCardKey)).width, 360);
    });
  });

  group('showRankCelebration — motion', () {
    testWidgets('one-shot: tidak ada ticker tersisa setelah satu putaran', (
      tester,
    ) async {
      await _pumpDialog(tester);

      // Confetti hanya ada saat motion aktif.
      expect(find.byKey(const Key('celebration_confetti')), findsOneWidget);

      await tester.pump(AppMotion.celebration);
      await tester.pump(const Duration(milliseconds: 300));

      // `repeat()` akan menyisakan satu ticker aktif di sini.
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion: tanpa confetti, kartu instan', (tester) async {
      await _pumpDialog(tester, disableAnimations: true);

      expect(find.byKey(const Key('celebration_confetti')), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.getSize(find.byKey(celebrationCardKey)).width, greaterThan(0));

      await tester.tap(find.text('Lanjutkan'));
      await tester.pumpAndSettle();
      expect(find.text('Rank Baru!'), findsNothing);
    });
  });

  group('showRankCelebration — stress data', () {
    testWidgets('label rank panjang dipotong ellipsis, tanpa overflow', (
      tester,
    ) async {
      await _pumpDialog(tester, rank: 'Sang Master Tertinggi Sekali');

      expect(tester.takeException(), isNull);
      expect(find.text('Sang Master Tertinggi Sekali'), findsOneWidget);
      expect(tester.getSize(find.byKey(celebrationRankPillKey)).width,
          lessThanOrEqualTo(390 - 2 * 28 - 2 * 24));
    });

    testWidgets('label pendek tetap satu baris', (tester) async {
      await _pumpDialog(tester, rank: 'A');

      expect(tester.takeException(), isNull);
      expect(find.text('A'), findsOneWidget);
    });
  });
}