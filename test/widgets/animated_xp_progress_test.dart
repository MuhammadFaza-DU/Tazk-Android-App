import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/animated_xp_progress.dart';

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Center(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  ),
);

/// Reads the effective horizontal scale out of the bounce wrapper.
double _scaleOf(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.byKey(const Key('xp_scale')),
  );
  return transform.transform.storage[0];
}

double _progressValue(WidgetTester tester) {
  final bar = tester.widget<LinearProgressIndicator>(
    find.byType(LinearProgressIndicator),
  );
  return bar.value ?? 0;
}

void main() {
  testWidgets('level up triggers a bounce animation', (tester) async {
    await tester.pumpWidget(
      _app(const AnimatedXpProgress(value: 0.5, level: 1)),
    );
    expect(_scaleOf(tester), 1.0);

    // Same value, higher level → rebuild must kick off the bounce.
    await tester.pumpWidget(
      _app(const AnimatedXpProgress(value: 0.5, level: 2)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Mid-flight the bar is scaled away from identity (pop past 1.0).
    expect(_scaleOf(tester), isNot(closeTo(1.0, 0.001)));

    // Let the 600ms controller finish so the test ends cleanly.
    await tester.pump(const Duration(milliseconds: 700));
    expect(_scaleOf(tester), closeTo(1.0, 0.001));
  });

  testWidgets('reduced motion skips bounce and glow', (tester) async {
    Widget wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: Scaffold(
            body: Center(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(wrap(const AnimatedXpProgress(value: 0.5, level: 1)));
    await tester.pumpWidget(wrap(const AnimatedXpProgress(value: 0.5, level: 2)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // No bounce: the scale stays at identity.
    expect(_scaleOf(tester), 1.0);

    // No glow: the fade layer never leaves zero opacity.
    final glow = tester.widget<FadeTransition>(
      find.byKey(const Key('xp_glow')),
    );
    expect(glow.opacity.value, 0.0);
  });

  testWidgets('fill animates to target value', (tester) async {
    await tester.pumpWidget(
      _app(const AnimatedXpProgress(value: 0.2, level: 1)),
    );
    await tester.pumpAndSettle();
    expect(_progressValue(tester), closeTo(0.2, 0.001));

    await tester.pumpWidget(
      _app(const AnimatedXpProgress(value: 0.85, level: 1)),
    );
    // Still mid-flight right after the target changes.
    await tester.pump(const Duration(milliseconds: 60));
    expect(_progressValue(tester), lessThan(0.85));

    await tester.pumpAndSettle();
    expect(_progressValue(tester), closeTo(0.85, 0.001));
  });
}