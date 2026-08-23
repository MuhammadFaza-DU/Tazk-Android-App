import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/features/settings/settings_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/exact_alarm_permission_provider.dart';
import 'package:tazk/providers/notification_permission_provider.dart';
import 'package:tazk/data/database/database.dart';

class FakePermissionController extends NotificationPermissionController {
  FakePermissionController(this._initial);

  final NotificationPermissionState _initial;

  @override
  NotificationPermissionState build() => _initial;
}

class FakeExactAlarmController extends ExactAlarmController {
  FakeExactAlarmController(this._initial);
  final ExactAlarmState _initial;
  @override
  ExactAlarmState build() => _initial;
}

Widget _wrap(NotificationPermissionState permissionState) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(
        AppDatabase.forTesting(NativeDatabase.memory()),
      ),
      notificationPermissionProvider.overrideWith(
        () => FakePermissionController(permissionState),
      ),
      exactAlarmProvider.overrideWith(
        () => FakeExactAlarmController(const ExactAlarmState(status: ExactAlarmStatus.allowed)),
      ),
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
      home: const SettingsScreen(),
    ),
  );
}

void main() {
  Future<void> tearDown(WidgetTester tester) async {
    // Force ProviderScope (and its Drift stream queries) to dispose now, then
    // pump so the zero-duration cleanup timer fires before the test binding's
    // pending-timer invariant check runs.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('settings shows passive status indicator (denied -> Mati)',
      (tester) async {
    await tester.pumpWidget(_wrap(const NotificationPermissionState(
      status: NotificationPermissionStatus.denied,
    )));
    await tester.pump();

    expect(find.text('Status notifikasi'), findsOneWidget);
    expect(find.text('Mati'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_off_rounded), findsOneWidget);
    await tearDown(tester);
  });

  testWidgets('settings shows passive status indicator (granted -> Aktif)',
      (tester) async {
    await tester.pumpWidget(_wrap(const NotificationPermissionState(
      status: NotificationPermissionStatus.granted,
    )));
    await tester.pump();

    expect(find.text('Status notifikasi'), findsOneWidget);
    // Now 2 tiles show "Aktif" (notification + exact alarm) so allow multiple.
    expect(find.text('Aktif'), findsWidgets);
    expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    await tearDown(tester);
  });
}
