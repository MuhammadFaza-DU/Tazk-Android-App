import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_motion.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_sheet.dart';
import 'package:tazk/core/widgets/app_shell.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Uji fidelity board untuk shell navigasi (AGENTS.md §11).
///
/// Sumber kebenaran: `design-export/01 Home.png` (tab bar mengambang),
/// `design-export/01b Home - Sheet Lainnya.png` (isi sheet), dan
/// `design-export/15 Navigation Map.png` (aturan navigasi).
Future<void> _pumpShell(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        home: const AppShell(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _disposeShell(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

BoxDecoration _barDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(find.byKey(shellTabBarKey));
  return container.decoration! as BoxDecoration;
}

AnimatedContainer _indicator(WidgetTester tester, Finder item) {
  return tester.widget<AnimatedContainer>(
    find.descendant(of: item, matching: find.byType(AnimatedContainer)),
  );
}

void main() {
  group('tab bar floating pill vs board 01 Home', () {
    testWidgets('tinggi 62, radius pill 999, bg surface, border 1px',
        (tester) async {
      await _pumpShell(tester);

      final container = tester.widget<Container>(find.byKey(shellTabBarKey));
      expect(container.constraints?.maxHeight, AppShell.tabBarHeight);
      expect(AppShell.tabBarHeight, 62);

      final decoration = _barDecoration(tester);
      expect(decoration.color, AppColors.light.surface);
      expect(decoration.borderRadius, BorderRadius.circular(999));
      expect(decoration.borderRadius, BorderRadius.circular(AppShell.tabBarRadius));

      final border = decoration.border! as Border;
      expect(border.top.width, 1);
      expect(border.top.color, AppColors.light.border);

      await _disposeShell(tester);
    });

    testWidgets('margin 16 kiri/kanan/bawah + padding horizontal 8',
        (tester) async {
      await _pumpShell(tester);

      final padding = tester.widget<Padding>(find.byKey(shellTabBarInsetKey));
      expect(
        padding.padding,
        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      );
      expect(AppShell.tabBarInset, 16);

      final container = tester.widget<Container>(find.byKey(shellTabBarKey));
      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 8),
      );
      expect(AppShell.tabBarPadding, 8);

      await _disposeShell(tester);
    });

    testWidgets('bar mengambang: tidak selebar layar', (tester) async {
      await _pumpShell(tester);

      final screenWidth = tester.getSize(find.byType(MaterialApp)).width;
      final barWidth = tester.getSize(find.byKey(shellTabBarKey)).width;
      expect(barWidth, screenWidth - 2 * AppShell.tabBarInset);

      await _disposeShell(tester);
    });

    testWidgets('item aktif pakai primaryContainer, item lain transparan',
        (tester) async {
      await _pumpShell(tester);

      expect(
        _indicator(tester, find.byKey(shellTabItemKey(0))).decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          AppColors.light.primaryContainer,
        ),
      );
      for (final index in [1, 2, 3]) {
        final decoration =
            _indicator(tester, find.byKey(shellTabItemKey(index))).decoration!
                as BoxDecoration;
        expect(decoration.color, Colors.transparent);
        expect(decoration.borderRadius, BorderRadius.circular(999));
      }

      await _disposeShell(tester);
    });

    testWidgets('ikon 22 dan label bodySmall 12 seperti board', (tester) async {
      await _pumpShell(tester);

      final item = find.byKey(shellTabItemKey(0));
      final icon = tester.widget<Icon>(
        find.descendant(of: item, matching: find.byType(Icon)),
      );
      expect(icon.size, 22);
      // Item aktif memakai `primary`, bukan `inkMuted`.
      expect(icon.color, AppColors.light.primary);

      final label = tester.widget<Text>(
        find.descendant(of: item, matching: find.byType(Text)),
      );
      expect(label.style?.fontSize, 12);
      expect(label.style?.color, AppColors.light.primary);

      final inactiveIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(shellTabItemKey(1)),
          matching: find.byType(Icon),
        ),
      );
      expect(inactiveIcon.color, AppColors.light.inkMuted);

      await _disposeShell(tester);
    });

    testWidgets('tap target tiap item minimal 48dp', (tester) async {
      await _pumpShell(tester);

      for (var i = 0; i < AppShell.tabCount; i++) {
        final size = tester.getSize(
          find.descendant(
            of: find.byKey(shellTabItemKey(i)),
            matching: find.byType(InkWell),
          ),
        );
        expect(size.height, greaterThanOrEqualTo(48));
        expect(size.width, greaterThanOrEqualTo(48));
      }

      await _disposeShell(tester);
    });

    testWidgets('reduce motion: transisi indikator jadi nol', (tester) async {
      await _pumpShell(tester, disableAnimations: true);

      expect(
        _indicator(tester, find.byKey(shellTabItemKey(0))).duration,
        Duration.zero,
      );

      await _disposeShell(tester);
    });

    testWidgets('tanpa reduce motion: transisi indikator 150ms easeStandard',
        (tester) async {
      await _pumpShell(tester);

      final indicator = _indicator(tester, find.byKey(shellTabItemKey(0)));
      expect(indicator.duration, AppMotion.fast);
      expect(indicator.curve, AppMotion.easeStandard);

      await _disposeShell(tester);
    });
  });

  group('sheet "Lainnya" vs board 01b', () {
    testWidgets('tab "Lainnya" membuka sheet dan tidak mengubah tab aktif',
        (tester) async {
      await _pumpShell(tester);

      await tester.tap(find.byKey(shellTabMoreKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Sheet memakai handle tema (bukan drag bar bawaan M3).
      expect(find.byType(AppSheetHandle), findsOneWidget);

      expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
      expect(
        _indicator(tester, find.byKey(shellTabItemKey(0))).decoration,
        isA<BoxDecoration>().having(
          (d) => d.color,
          'color',
          AppColors.light.primaryContainer,
        ),
      );
      expect(
        (_indicator(tester, find.byKey(shellTabMoreKey)).decoration!
                as BoxDecoration)
            .color,
        Colors.transparent,
      );

      await _disposeShell(tester);
    });

    testWidgets('isi sheet 3 tujuan; Statistik belum ada (deviasi T5)',
        (tester) async {
      await _pumpShell(tester);

      await tester.tap(find.byKey(shellTabMoreKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Tentang'), findsOneWidget);
      // Board 15 menyebut 4 item, tapi layar Statistik baru dibuat di T5:
      // tidak boleh ada baris yang menunjuk layar yang tidak ada.
      expect(find.text('Statistik'), findsNothing);

      await _disposeShell(tester);
    });
  });
}