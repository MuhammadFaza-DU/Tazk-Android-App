import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/features/settings/battery_optimization_row.dart';
import 'package:tazk/l10n/app_localizations.dart';

/// Baris toggle "Jangan optimalkan baterai" di Pengaturan.
///
/// Android tidak menyediakan API untuk melepas pengecualian baterai dari dalam
/// app, jadi sakelar ON membuka dialog izin sistem dan sakelar OFF membuka
/// daftar pengaturan baterai agar user mematikannya sendiri.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.tazk.tazk/app_settings');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<String> calls;
  late bool ignoring;

  setUp(() {
    calls = <String>[];
    ignoring = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'isIgnoringBatteryOptimizations') return ignoring;
      return null;
    });
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  Future<void> pumpRow(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('id'),
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: BatteryOptimizationRow()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Switch switchOf(WidgetTester tester) =>
      tester.widget<Switch>(find.byType(Switch));

  testWidgets('sakelar mati saat Android masih mengoptimalkan baterai', (
    tester,
  ) async {
    ignoring = false;
    await pumpRow(tester);

    expect(switchOf(tester).value, isFalse);
    expect(find.text('Jangan optimalkan baterai'), findsOneWidget);
  });

  testWidgets('sakelar hidup saat app sudah dikecualikan', (tester) async {
    ignoring = true;
    await pumpRow(tester);

    expect(switchOf(tester).value, isTrue);
  });

  testWidgets('menyalakan sakelar meminta pengecualian ke Android', (
    tester,
  ) async {
    ignoring = false;
    await pumpRow(tester);
    calls.clear();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(calls, contains('requestIgnoreBatteryOptimizations'));
    // Izin hanya berubah setelah dialog sistem dijawab, jadi status tetap
    // ditanyakan ulang ke platform.
    expect(calls, contains('isIgnoringBatteryOptimizations'));
  });

  testWidgets('mematikan sakelar membuka daftar pengaturan baterai sistem', (
    tester,
  ) async {
    ignoring = true;
    await pumpRow(tester);
    calls.clear();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(calls, contains('openBatteryOptimizationSettings'));
    // App tidak boleh berpura-pura mematikan sendiri: nilainya masih dari
    // platform sampai user mengubahnya di pengaturan sistem.
    expect(switchOf(tester).value, isTrue);
  });
}