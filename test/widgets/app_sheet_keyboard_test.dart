import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/core/widgets/app_sheet.dart';

/// Regresi dari uji HP (2026-10-31): sheet berisi field teks tertutup keyboard
/// numerik sehingga tombol aksinya tidak bisa disentuh. Sheet wajib mengangkat
/// kontennya setinggi `MediaQuery.viewInsets.bottom`.
void main() {
  testWidgets('sheet mengangkat konten di atas keyboard', (tester) async {
    // Layar 390x844 dp seperti ponsel uji; keyboard 300 dp.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );

    final context = tester.element(find.byType(Scaffold));
    showAppSheet<void>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TextField(autofocus: true),
          const SizedBox(height: 12),
          Row(
            children: [
              AppButton.ghost(label: 'Cancel', onPressed: () {}),
              AppButton.primary(
                key: const Key('sheet_save'),
                label: 'Save',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Tanpa keyboard: tombol simpan berada dekat dasar layar.
    final withoutKeyboard = tester.getRect(find.byKey(const Key('sheet_save')));

    // Munculkan keyboard 300 dp.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    await tester.pumpAndSettle();

    final withKeyboard = tester.getRect(find.byKey(const Key('sheet_save')));
    final screenBottom = tester.view.physicalSize.height / 3;

    // Tombol harus naik minimal setinggi keyboard, dan tetap di dalam layar.
    expect(withKeyboard.bottom, lessThanOrEqualTo(screenBottom - 300 + 1));
    expect(withKeyboard.top, lessThan(withoutKeyboard.top));
  });
}