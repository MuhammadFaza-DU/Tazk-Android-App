import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_shell.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Pumps [AppShell] with an in-memory database and the Indonesian locale so the
/// nav labels match the design copy (Lainnya / Profil / Pengaturan / Tentang).
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
  // First frame builds the shell; a short pump lets the Drift-backed stream
  // providers resolve so no loading spinner is left mid-animation.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Unmounts the tree (disposing the ProviderScope and its Drift stream queries)
/// then pumps once more so the zero-duration cleanup timer they schedule fires
/// before the binding's pending-timer invariant check runs.
Future<void> _disposeShell(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Latar indikator pill milik satu item bar.
Color? _indicatorColor(WidgetTester tester, Finder item) {
  final indicator = tester.widget<AnimatedContainer>(
    find.descendant(of: item, matching: find.byType(AnimatedContainer)),
  );
  return (indicator.decoration as BoxDecoration?)?.color;
}

void main() {
  testWidgets('AppShell shows a 5-item pill tab bar and no drawer',
      (tester) async {
    await _pumpShell(tester);

    // v2 navigation is a hand-built floating bar, never the M3 NavigationBar.
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byKey(shellTabBarKey), findsOneWidget);

    // 4 tab layar + aksi "Lainnya" = 5 item.
    for (var i = 0; i < AppShell.tabCount; i++) {
      expect(find.byKey(shellTabItemKey(i)), findsOneWidget);
    }
    expect(find.byKey(shellTabMoreKey), findsOneWidget);

    // Home is the initial tab and every label is visible.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Habits'), findsWidgets);
    expect(find.text('Kalender'), findsWidgets);
    expect(find.text('Lainnya'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);

    await _disposeShell(tester);
  });

  testWidgets('tapping a tab moves the IndexedStack and the active indicator',
      (tester) async {
    await _pumpShell(tester);

    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);

    await tester.tap(find.byKey(shellTabItemKey(1)));
    await tester.pumpAndSettle();

    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
    expect(
      _indicatorColor(tester, find.byKey(shellTabItemKey(1))),
      AppColors.light.primaryContainer,
    );
    expect(
      _indicatorColor(tester, find.byKey(shellTabItemKey(0))),
      Colors.transparent,
    );

    await _disposeShell(tester);
  });

  testWidgets('tapping "Lainnya" opens the more sheet', (tester) async {
    await _pumpShell(tester);

    await tester.tap(find.text('Lainnya'));
    await tester.pump(); // sheet begins entering
    await tester.pump(const Duration(milliseconds: 300)); // enter animation

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('Tentang'), findsOneWidget);

    await _disposeShell(tester);
  });

  testWidgets('"Lainnya" is an action: the active tab does not move',
      (tester) async {
    await _pumpShell(tester);

    await tester.tap(find.byKey(shellTabMoreKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Sheet terbuka, tapi tab yang aktif tetap Home.
    expect(find.text('Profil'), findsOneWidget);
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    expect(
      _indicatorColor(tester, find.byKey(shellTabItemKey(0))),
      AppColors.light.primaryContainer,
    );
    // "Lainnya" tidak pernah tampil sebagai tab aktif.
    expect(
      _indicatorColor(tester, find.byKey(shellTabMoreKey)),
      Colors.transparent,
    );

    await _disposeShell(tester);
  });
}