import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';

/// Key tetap yang dipasang `AppButton` pada `AnimatedScale` pembungkus tombol.
const _scaleKey = Key('app_button_scale');

void main() {
  AnimatedScale scaleOf(WidgetTester tester) =>
      tester.widget<AnimatedScale>(find.byKey(_scaleKey));

  testWidgets('press scales button to 0.97 and releases back to 1.0', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: AppButton.primary(
              label: 'OK',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(scaleOf(tester).scale, 1.0);
    expect(scaleOf(tester).duration, AppMotion.fast);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AppButton)),
    );
    // Lewati `kPressTimeout` supaya `onTapDown` pasti sudah terkirim.
    await tester.pump(const Duration(milliseconds: 100));
    expect(scaleOf(tester).scale, 0.97);

    await gesture.up();
    await tester.pump();
    expect(scaleOf(tester).scale, 1.0);
    expect(tapped, isTrue);
  });

  testWidgets('reduced motion keeps scale at 1.0 while pressed', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: AppButton.primary(label: 'OK', onPressed: () {}),
            ),
          ),
        ),
      ),
    );

    expect(scaleOf(tester).duration, Duration.zero);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AppButton)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(scaleOf(tester).scale, 1.0);

    await gesture.up();
    await tester.pump();
    expect(scaleOf(tester).scale, 1.0);
  });

  testWidgets('disabled button does not scale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: AppButton.primary(label: 'OK', onPressed: null)),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AppButton)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(scaleOf(tester).scale, 1.0);

    await gesture.up();
    await tester.pump();
    expect(scaleOf(tester).scale, 1.0);
  });
}