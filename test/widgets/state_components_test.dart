import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/empty_state.dart';
import 'package:tazk/core/widgets/error_state.dart';
import 'package:tazk/core/widgets/skeleton_list.dart';

/// Pump dengan `AppTheme.light`; `disableAnimations` dipakai untuk memeriksa
/// jalur reduced-motion (ticker wajib diam).
Widget _app(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  group('EmptyState', () {
    testWidgets('menampilkan maskot ter-clip, judul, sub-judul, dan aksi', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          EmptyState(
            title: 'Judul',
            message: 'Pesan',
            action: AppButton.primary(label: 'Aksi', onPressed: () {}),
          ),
        ),
      );
      await tester.pump(AppMotion.base);

      expect(find.byType(AppCard), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.text('Judul'), findsOneWidget);
      expect(find.text('Pesan'), findsOneWidget);
      expect(find.text('Aksi'), findsOneWidget);
    });

    testWidgets('title null tetap kompatibel: maskot + message', (tester) async {
      await tester.pumpWidget(_app(const EmptyState(message: 'Pesan lama')));
      await tester.pump(AppMotion.base);

      expect(find.text('Pesan lama'), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
    });
  });

  group('SkeletonList', () {
    testWidgets('merender 3 kartu skeleton tanpa spinner', (tester) async {
      await tester.pumpWidget(_app(const SkeletonList(rows: 3)));
      await tester.pump();

      expect(find.byType(AppCard), findsNWidgets(3));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Lepas tree supaya ticker shimmer berhenti sebelum test berakhir.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('reduced motion: skeleton statis, tanpa ticker pending', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const SkeletonList(rows: 3), disableAnimations: true),
      );
      await tester.pump();

      expect(find.byType(AppCard), findsNWidgets(3));
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group('ErrorState', () {
    testWidgets('tombol retry memanggil onRetry', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        _app(
          ErrorState(
            title: 'Gagal',
            message: 'Coba lagi',
            onRetry: () => retried++,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Gagal'), findsOneWidget);
      expect(find.byIcon(Icons.priority_high_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Coba lagi'));
      await tester.pump();

      expect(retried, 1);
    });
  });
}