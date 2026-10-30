import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/shine_sweep.dart';

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

/// Translasi horizontal pita shine (entri m12 matriks `Transform`).
double _bandX(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byKey(const Key('shine_overlay')),
      matching: find.byType(Transform),
    ),
  );
  return transform.transform.storage[12];
}

void main() {
  testWidgets('shine overlay plays once and then stops', (tester) async {
    const childKey = Key('shine_child');
    await tester.pumpWidget(
      _app(
        const ShineSweep(
          child: SizedBox(key: childKey, width: 100, height: 40),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('shine_overlay')), findsOneWidget);

    final start = _bandX(tester);
    await tester.pump(AppMotion.slow ~/ 2);
    final mid = _bandX(tester);
    expect(mid, greaterThan(start)); // pita benar-benar bergerak

    // Selesaikan sapuan sekali jalan; tidak boleh mulai lagi (bukan repeat).
    await tester.pump(AppMotion.slow);
    await tester.pump(const Duration(milliseconds: 100));

    // Ticker berhenti sendiri: 0 transient callback = tidak ada ticker aktif.
    expect(tester.binding.transientCallbackCount, 0);

    final settled = _bandX(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_bandX(tester), settled); // diam di posisi akhir

    // Overlay tetap terpasang (tidak perlu rebuild), hanya tidak bergerak.
    expect(find.byKey(const Key('shine_overlay')), findsOneWidget);
    expect(find.byKey(childKey), findsOneWidget);
  });

  testWidgets('reduced motion renders no shine overlay', (tester) async {
    const childKey = Key('shine_child');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => MediaQuery(
            // Pola yang sama dengan progress_bar_test: MediaQuery di dalam
            // MaterialApp supaya override disableAnimations tidak ditimpa.
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const Scaffold(
              body: Center(
                child: ShineSweep(
                  child: SizedBox(key: childKey, width: 100, height: 40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('shine_overlay')), findsNothing);
    expect(find.byKey(childKey), findsOneWidget);
    expect(tester.getSize(find.byKey(childKey)), const Size(100, 40));
    expect(tester.binding.transientCallbackCount, 0); // ticker tidak jalan
  });
}