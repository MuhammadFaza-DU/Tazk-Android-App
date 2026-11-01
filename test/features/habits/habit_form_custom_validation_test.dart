import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import 'package:tazk/data/database/database.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/features/habits/habit_form_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

Future<void> _pumpForm(WidgetTester tester) async {
  // Tall surface so the whole form fits on screen and every control is
  // directly tappable without scroll gymnastics.
  await tester.binding.setSurfaceSize(const Size(600, 2200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  // Form kategori membaca stream dari database, jadi DB harus benar-benar
  // ditutup setelah tree dilepas (lihat `_disposeForm`).
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  // Mock the home_widget platform channel: without a native side the real
  // channel never answers inside the test binding, which would leave
  // HomeWidgetService.refreshAll() (and therefore save) hanging forever.
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('home_widget');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
  addTearDown(() => TestDefaultBinaryMessengerBinding.instance
      .defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HabitFormScreen()),
                ),
                child: const Text('BUKA FORM'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  // Push the real form so its save flow can Navigator.pop() back out.
  await tester.tap(find.text('BUKA FORM'));
  await tester.pumpAndSettle();
}

/// Lepas tree di dalam body test supaya langganan stream Drift berhenti dan
/// timer nol-detaknya ter-flush oleh `pump` berikutnya (bukan menggantung di
/// fake clock sampai pemeriksaan invariant binding).
Future<void> _disposeForm(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('custom weekly habit with no day selected blocks save',
      (tester) async {
    await _pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Olahraga');
    await tester.tap(find.text('Custom'));
    await tester.pump();
    await tester.tap(find.text('Hari tertentu tiap minggu'));
    await tester.pump();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // PRD: validation must BLOCK saving — form stays open with the inline
    // error plus the SnackBar echo of it.
    expect(find.byType(HabitFormScreen), findsOneWidget);
    expect(find.text('Pilih minimal satu hari'), findsNWidgets(2));

    await _disposeForm(tester);
  });

  testWidgets('custom weekly habit saves once a day is selected',
      (tester) async {
    await _pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).first, 'Olahraga');
    await tester.tap(find.text('Custom'));
    await tester.pump();
    await tester.tap(find.text('Hari tertentu tiap minggu'));
    await tester.pump();

    await tester.tap(find.text('Sen'));
    await tester.pump();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.byType(HabitFormScreen), findsNothing);

    await _disposeForm(tester);
  });
}
