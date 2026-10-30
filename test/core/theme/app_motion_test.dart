import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/widgets/app_page_route.dart';

void main() {
  group('AppMotion token', () {
    test('durasi persis DESIGN.md section Motion', () {
      expect(AppMotion.fast, const Duration(milliseconds: 150));
      expect(AppMotion.base, const Duration(milliseconds: 220));
      expect(AppMotion.slow, const Duration(milliseconds: 320));
      expect(AppMotion.celebration, const Duration(milliseconds: 750));
    });

    test('kurva persis DESIGN.md section Motion', () {
      expect(AppMotion.easeStandard, const Cubic(0.2, 0.0, 0.0, 1.0));
      expect(AppMotion.easeGentle, const Cubic(0.4, 0.0, 0.2, 1.0));
    });
  });

  group('AppMotionContext', () {
    testWidgets('reduceMotion false saat animasi normal', (tester) async {
      bool? value;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              value = context.reduceMotion;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(value, isFalse);
    });

    testWidgets('reduceMotion true saat disableAnimations aktif', (
      tester,
    ) async {
      bool? value;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                value = context.reduceMotion;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(value, isTrue);
    });

    testWidgets('motion() menjaga durasi normal', (tester) async {
      late Duration value;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              value = context.motion(AppMotion.base);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(value, AppMotion.base);
    });

    testWidgets('motion() jadi Duration.zero saat reduced-motion', (
      tester,
    ) async {
      late Duration value;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                value = context.motion(AppMotion.celebration);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(value, Duration.zero);
    });
  });

  group('AppPageRoute', () {
    testWidgets('push menampilkan halaman tujuan', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  AppPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Tujuan')),
                  ),
                ),
                child: const Text('Buka'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();

      expect(find.text('Tujuan'), findsOneWidget);
      // Dalam mode normal, transisi membungkus layar tujuan.
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);
    });

    testWidgets('reduced-motion: tujuan muncul instan, tanpa gerak', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    AppPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('Tujuan')),
                    ),
                  ),
                  child: const Text('Buka'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();

      expect(find.text('Tujuan'), findsOneWidget);
      // Tanpa gerak: transitionsBuilder mengembalikan child apa adanya,
      // jadi tidak ada pembungkus fade/slide di layar tujuan.
      expect(find.byType(FadeTransition), findsNothing);
      expect(find.byType(SlideTransition), findsNothing);
    });

    testWidgets('durasi transisi memakai token base', (tester) async {
      final route = AppPageRoute<void>(
        builder: (_) => const SizedBox.shrink(),
      );

      expect(route.transitionDuration, AppMotion.base);
      expect(route.reverseTransitionDuration, AppMotion.base);
    });
  });
}