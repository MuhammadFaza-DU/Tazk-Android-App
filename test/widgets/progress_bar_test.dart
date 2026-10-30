import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/progress_bar.dart';

/// Skala horizontal fill. `Transform.scale(scaleX:)` membangun
/// `Matrix4.diagonal3Values(scaleX, 1, 1)`, sehingga `getMaxScaleOnAxis()`
/// selalu 1.0 saat scaleX < 1 — jadi entry m00 dibaca langsung.
double fillScaleX(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.byKey(const Key('progress_fill')),
  );
  return transform.transform.storage[0];
}

Widget harness(double value, {bool disableAnimations = false}) {
  final bar = ProgressBar(value: value);
  return MaterialApp(
    theme: AppTheme.light,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: Scaffold(body: Center(child: bar)),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the fill at the given value without animating on first '
      'mount', (tester) async {
    await tester.pumpWidget(harness(0.35));
    await tester.pump();

    expect(fillScaleX(tester), closeTo(0.35, 0.001));
  });

  testWidgets('animates smoothly when the value changes', (tester) async {
    await tester.pumpWidget(harness(0.2));
    await tester.pump();

    await tester.pumpWidget(harness(0.8));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final mid = fillScaleX(tester);
    expect(mid, greaterThan(0.2));
    expect(mid, lessThan(0.8));

    await tester.pumpAndSettle();
    expect(fillScaleX(tester), closeTo(0.8, 0.001));
  });

  testWidgets('reduced motion jumps instantly', (tester) async {
    await tester.pumpWidget(harness(0.2, disableAnimations: true));
    await tester.pump();

    await tester.pumpWidget(harness(0.8, disableAnimations: true));
    await tester.pump();

    expect(fillScaleX(tester), closeTo(0.8, 0.001));
  });
}