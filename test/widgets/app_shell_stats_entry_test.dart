import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_shell.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/features/stats/stats_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Uji entri "Statistik" di sheet "Lainnya" (board `15`): Statistik ada dan
/// berada paling atas, lalu menavigasi ke `StatsScreen`.
void main() {
  Future<void> pumpShell(WidgetTester tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.byKey(shellTabMoreKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> disposeShell(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('sheet "Lainnya": Statistik ada dan di atas Profil',
      (tester) async {
    await pumpShell(tester);
    await openSheet(tester);

    expect(find.text('Statistik'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    final statsTop = tester.getTopLeft(find.text('Statistik')).dy;
    final profileTop = tester.getTopLeft(find.text('Profil')).dy;
    expect(statsTop, lessThan(profileTop));

    await disposeShell(tester);
  });

  testWidgets('tap baris Statistik menavigasi ke StatsScreen', (tester) async {
    await pumpShell(tester);
    await openSheet(tester);

    expect(find.byType(StatsScreen), findsNothing);

    await tester.tap(find.text('Statistik'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StatsScreen), findsOneWidget);

    await disposeShell(tester);
  });
}