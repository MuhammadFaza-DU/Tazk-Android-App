import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/features/dev/component_preview_screen.dart';

void main() {
  testWidgets('component preview renders in light theme without exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ComponentPreviewScreen(),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('component preview renders in dark theme without exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const ComponentPreviewScreen(),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('theme toggle switches preview to dark without exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ComponentPreviewScreen(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('preview_theme_toggle')));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}