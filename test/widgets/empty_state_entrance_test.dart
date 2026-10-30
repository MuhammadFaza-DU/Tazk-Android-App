import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/empty_state.dart';

const _entranceKey = Key('empty_state_entrance');

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

/// Opacity yang dibangun oleh entrance wrapper (`Opacity` di dalam
/// `TweenAnimationBuilder` ber-key `empty_state_entrance`).
double _opacityOf(WidgetTester tester) {
  final opacity = tester.widget<Opacity>(
    find.descendant(
      of: find.byKey(_entranceKey),
      matching: find.byType(Opacity),
    ),
  );
  return opacity.opacity;
}

void main() {
  testWidgets('empty state fades in on mount', (tester) async {
    await tester.pumpWidget(_app(const EmptyState(message: 'Kosong')));
    await tester.pump();

    // Frame awal: belum terlihat (entrance masih di titik awal).
    expect(find.byKey(_entranceKey), findsOneWidget);
    expect(_opacityOf(tester), lessThan(1.0));

    await tester.pump(AppMotion.base);

    expect(_opacityOf(tester), closeTo(1.0, 0.001));
    expect(find.text('Kosong'), findsOneWidget);
  });

  testWidgets('reduced motion renders instantly at full opacity', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Center(child: EmptyState(message: 'Kosong')),
          ),
        ),
      ),
    );

    // Tanpa gerak: sudah penuh di frame pertama, tanpa perlu pump tambahan.
    expect(_opacityOf(tester), closeTo(1.0, 0.001));
    expect(find.text('Kosong'), findsOneWidget);
  });
}