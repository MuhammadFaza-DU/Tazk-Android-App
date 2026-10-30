import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/celebration_overlay.dart';

Widget _harness({bool disableAnimations = false}) {
  final app = MaterialApp(
    theme: AppTheme.light,
    home: Builder(
      builder: (ctx) => Scaffold(
        body: TextButton(
          onPressed: () => showRankCelebration(ctx, rankLabel: 'Perintis'),
          child: const Text('go'),
        ),
      ),
    ),
  );
  if (!disableAnimations) return app;
  // Ambil ukuran view nyata (800x600) supaya layout tetap valid, hanya
  // `disableAnimations` yang diubah — sama dengan perilaku sistem.
  final binding = TestWidgetsFlutterBinding.instance;
  return MediaQuery(
    data: MediaQueryData.fromView(binding.platformDispatcher.views.first)
        .copyWith(disableAnimations: true),
    child: app,
  );
}

void main() {
  testWidgets('opens celebration and stops the ticker after one shot', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(find.text('Rank Baru!'), findsOneWidget);
    expect(find.text('Perintis'), findsOneWidget);

    // Satu putaran penuh + jeda: kalau controller masih `repeat()`, ticker
    // tetap hidup dan framework gagal di teardown ("A Timer is still pending"
    // / "A Ticker was still active"). Dialog sengaja DIBIARKAN terbuka —
    // menutupnya men-trigger dispose yang mematikan ticker meski `repeat()`.
    await tester.pump(AppMotion.celebration);
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion shows the card instantly without confetti', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(disableAnimations: true));

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(find.text('Rank Baru!'), findsOneWidget);
    expect(find.byKey(const Key('celebration_confetti')), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    expect(find.text('Rank Baru!'), findsNothing);
  });
}