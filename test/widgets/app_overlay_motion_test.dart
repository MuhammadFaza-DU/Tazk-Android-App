import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_dialog.dart';
import 'package:tazk/core/widgets/app_sheet.dart';

/// Key entrance dialog (`TweenAnimationBuilder` di `showAppDialog`).
const _dialogEntranceKey = Key('app_dialog_entrance');

/// Scale dari `Transform` pembungkus dialog. `Transform.scale` membangun
/// `Matrix4.diagonal3Values(scale, scale, 1)`, jadi entry `m00` = scale.
double _dialogScale(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find
        .descendant(
          of: find.byKey(_dialogEntranceKey),
          matching: find.byType(Transform),
        )
        .first,
  );
  return transform.transform.storage[0];
}

/// Harness: satu tombol "Open". `onPressed` menerima context di dalam
/// `MaterialApp` agar bisa memanggil `showAppSheet`/`showAppDialog`.
/// `disableAnimations` membungkus `MediaQuery` di luar `MaterialApp` (pola
/// yang sama dengan test reduced-motion lain di project).
Widget _harness({
  required void Function(BuildContext context) onPressed,
  bool disableAnimations = false,
}) {
  final app = MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  if (!disableAnimations) {
    return app;
  }
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: app,
  );
}

void main() {
  testWidgets('sheet opens and settles with motion tokens', (tester) async {
    await tester.pumpWidget(
      _harness(
        onPressed: (context) {
          showAppSheet<void>(context, child: const Text('Isi Sheet'));
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Isi Sheet'), findsOneWidget);

    // Tutup sheet agar tidak ada animation controller yang menggantung.
    Navigator.of(tester.element(find.text('Isi Sheet'))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('dialog entrance scales from 0.96 to 1.0', (tester) async {
    await tester.pumpWidget(
      _harness(
        onPressed: (context) {
          showAppDialog<void>(
            context,
            title: 'Judul',
            content: const Text('Isi'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    // Frame awal: 0.96 — bukan 0; tidak pernah muncul dari ketiadaan.
    expect(_dialogScale(tester), closeTo(0.96, 0.02));

    await tester.pump(AppMotion.base);

    // Selesai: 1.0, dan isi dialog tampil.
    expect(_dialogScale(tester), closeTo(1.0, 0.001));
    expect(find.text('Isi'), findsOneWidget);

    Navigator.of(tester.element(find.byKey(_dialogEntranceKey))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion shows dialog instantly at scale 1.0', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        disableAnimations: true,
        onPressed: (context) {
          showAppDialog<void>(context, content: const Text('Isi'));
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    expect(_dialogScale(tester), closeTo(1.0, 0.001));

    Navigator.of(tester.element(find.byKey(_dialogEntranceKey))).pop();
    await tester.pumpAndSettle();
  });
}