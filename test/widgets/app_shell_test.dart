import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_shell.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Pumps [AppShell] with an in-memory database and the Indonesian locale so the
/// nav labels match the design copy (Lainnya / Profil / Pengaturan / Tentang).
Future<void> _pumpShell(WidgetTester tester) async {
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

void main() {
  testWidgets('AppShell shows a 5-destination NavigationBar and no drawer',
      (tester) async {
    await _pumpShell(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    // Home is the initial tab and its label is visible.
    expect(find.text('Home'), findsOneWidget);
    // v2 navigation has no hamburger/drawer at all.
    expect(find.byType(Drawer), findsNothing);

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
}