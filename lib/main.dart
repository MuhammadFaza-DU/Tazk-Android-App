import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'core/theme/app_theme.dart';
import 'background/midnight_scheduler.dart';
import 'data/models/enums.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/current_date_provider.dart';
import 'providers/exact_alarm_permission_provider.dart';
import 'providers/gamification_providers.dart';
import 'providers/habit_providers.dart';
import 'providers/notification_permission_provider.dart';
import 'providers/repository_providers.dart';
import 'providers/settings_providers.dart';
import 'providers/task_providers.dart';
import 'widgets/widget_tap_entry.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Stores the entry-point handle that the native widget-tap receiver uses to
  // run a tap without the app being open. Best effort: a missing platform
  // channel (e.g. under `flutter test`) must never block startup.
  registerWidgetTapHandle().catchError((Object _) {});
  runApp(const ProviderScope(child: TazkApp()));
  // Arms the native midnight alarm so the widgets and reminders roll over to the
  // new day even when the app is closed. Deferred until after the first frame
  // so the (potentially slow) platform-channel init and timezone lookup in
  // MidnightScheduler/NotificationService don't block the first paint.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(
      MidnightScheduler.initialize()
          .then((_) => MidnightScheduler.armNextMidnight())
          .catchError((Object error) {
        debugPrint('MidnightScheduler: background init failed: $error');
      }),
    );
  });
}

class TazkApp extends ConsumerWidget {
  const TazkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final themeMode = settings?.themeMode ?? AppThemeMode.light;
    final language = settings?.language ?? AppLanguage.indonesian;

    return _PomodoroLifecyclePause(
      child: MaterialApp(
        title: 'Tazk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode == AppThemeMode.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        locale: Locale(language == AppLanguage.english ? 'en' : 'id'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SplashScreen(),
      ),
    );
  }
}

class _PomodoroLifecyclePause extends ConsumerStatefulWidget {
  const _PomodoroLifecyclePause({required this.child});

  final Widget child;

  @override
  ConsumerState<_PomodoroLifecyclePause> createState() =>
      _PomodoroLifecyclePauseState();
}

class _PomodoroLifecyclePauseState
    extends ConsumerState<_PomodoroLifecyclePause>
    with WidgetsBindingObserver {
  // Widget taps while the app is foregrounded arrive via this stream rather
  // than the background isolate, so the foreground Drift cache never sees the
  // write until we re-query. Listening here gives instant in-app reflection.
  StreamSubscription<Uri?>? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _widgetClickSub = HomeWidget.widgetClicked.listen((uri) {
      if (uri == null) return;
      // Re-query the streams that the widget can mutate. The background
      // isolate already wrote the DB; we just need the foreground cache to
      // pick it up. A microtask delay lets that isolate finish first.
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        ref.invalidate(todayTasksProvider);
        ref.invalidate(activeHabitsProvider);
        ref.invalidate(habitTodayLogProvider);
        ref.invalidate(habitLogForDateProvider);
        ref.invalidate(streakStateProvider);
      });
    });
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // PRD 3.4: the Pomodoro timer deliberately keeps running while the app is
    // backgrounded — no auto-pause on inactive/paused/hidden. Its completion
    // notification was scheduled at start() with the exact end time, and the
    // ticker self-corrects from the absolute end time once we're resumed.
    if (state == AppLifecycleState.resumed) {
      // Returning to the foreground may cross a day boundary the in-app timer
      // couldn't fire while suspended. Refresh "today", re-run the idempotent
      // daily rollover, and re-arm the midnight alarm in case an aggressive
      // battery manager killed it.
      ref.read(currentDateProvider.notifier).refresh();
      ref.read(dailyMaintenanceServiceProvider).runDailyRollover();
      MidnightScheduler.armNextMidnight();
      // Cross-isolate widget taps (home_widget_callback runs in a separate
      // isolate with its own DB connection) are invisible to this isolate's
      // Drift stream cache until we re-query.
      ref.invalidate(todayTasksProvider);
      ref.invalidate(activeHabitsProvider);
      ref.invalidate(habitTodayLogProvider);
      ref.invalidate(habitLogForDateProvider);
      ref.invalidate(streakStateProvider);
      // The user may have toggled notifications or exact-alarm in system
      // settings while we were backgrounded — keep banners truthful (PRD 5).
      ref.read(notificationPermissionProvider.notifier).check();
      ref.read(exactAlarmProvider.notifier).check();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
