import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/widgets/notification_permission_banner.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/notification_permission_provider.dart';

class FakePermissionController extends NotificationPermissionController {
  FakePermissionController(this._initial);

  final NotificationPermissionState _initial;

  @override
  NotificationPermissionState build() => _initial;
}

Widget _wrap(Widget child, NotificationPermissionState state) {
  return ProviderScope(
    overrides: [
      notificationPermissionProvider.overrideWith(
        () => FakePermissionController(state),
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
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('banner shows when permission denied and not dismissed',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const NotificationPermissionBanner(),
      const NotificationPermissionState(
        status: NotificationPermissionStatus.denied,
      ),
    ));

    expect(find.byType(NotificationPermissionBanner), findsOneWidget);
    expect(find.text('Aktifkan'), findsOneWidget);
  });

  testWidgets('banner hidden when permission granted', (tester) async {
    await tester.pumpWidget(_wrap(
      const NotificationPermissionBanner(),
      const NotificationPermissionState(
        status: NotificationPermissionStatus.granted,
      ),
    ));

    expect(find.text('Aktifkan'), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('dismiss button hides the banner', (tester) async {
    await tester.pumpWidget(_wrap(
      const NotificationPermissionBanner(),
      const NotificationPermissionState(
        status: NotificationPermissionStatus.denied,
      ),
    ));

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.text('Aktifkan'), findsNothing);
  });
}
