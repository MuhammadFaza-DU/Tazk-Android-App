import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/features/onboarding/onboarding_screen.dart';
import 'package:tazk/features/splash/splash_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

void main() {
  testWidgets('splash navigates away within bounded time (never hangs)',
      (tester) async {
    // Without a native side, several platform channels never answer inside the
    // test binding, which would leave the splash's next-screen preparation
    // (notification init, the daily rollover's widget refresh) hanging forever.
    // Mock them so _prepareNextScreen() can complete.
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const homeWidgetChannel = MethodChannel('home_widget');
    const timezoneChannel = MethodChannel('flutter_timezone');
    const notificationsChannel =
        MethodChannel('dexterous.com/flutter/local_notifications');
    const appSettingsChannel = MethodChannel('com.tazk.tazk/app_settings');
    messenger.setMockMethodCallHandler(homeWidgetChannel, (call) async => null);
    messenger.setMockMethodCallHandler(timezoneChannel, (call) async => 'UTC');
    messenger
        .setMockMethodCallHandler(notificationsChannel, (call) async => null);
    // getMountedWidgets (added in T1-B) must answer immediately: with none
    // mounted, HomeWidgetService.refreshAll() skips every DB query, so the
    // splash's daily-rollover work completes cleanly instead of leaving a DB
    // operation hanging on the 100ms channel fallback when the test ends.
    messenger.setMockMethodCallHandler(appSettingsChannel, (call) async {
      if (call.method == 'getMountedWidgets') return <String>[];
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(homeWidgetChannel, null);
      messenger.setMockMethodCallHandler(timezoneChannel, null);
      messenger.setMockMethodCallHandler(notificationsChannel, null);
      messenger.setMockMethodCallHandler(appSettingsChannel, null);
    });

    // The splash's next-screen preparation touches the Drift database (profile
    // creation, daily rollover), so back it with an in-memory connection that
    // is deterministic and closes cleanly.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SplashScreen(),
        ),
      ),
    );

    // Splash is on screen first.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance in small steps. Under the test binding `video_player` is
    // unimplemented so `_initializeVideo()` throws into its error path (which
    // also navigates); in production the 1200ms max timer is the backstop.
    // Either way navigation must happen within a hard bound and must not hang
    // waiting for a full video clip.
    var reachedNext = false;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
        reachedNext = true;
        break;
      }
    }
    expect(reachedNext, isTrue,
        reason: 'splash must leave its own route within the bounded time');

    // Let the replacement transition finish so the old splash route is removed.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.byType(SplashScreen), findsNothing);
    // An empty profile name routes to OnboardingScreen.
    expect(find.byType(OnboardingScreen), findsOneWidget);

    // Clean teardown: dispose the tree so providers/streams close and no timer
    // is left pending when the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}