import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'core/theme/app_theme.dart';
import 'background/midnight_scheduler.dart';
import 'data/models/enums.dart';
import 'features/pomodoro/pomodoro_controller.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/current_date_provider.dart';
import 'providers/repository_providers.dart';
import 'providers/settings_providers.dart';
import 'widgets/home_widget_callback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort: lets homescreen widget checkboxes complete tasks/habits
  // even while the app isn't running. No-op (and safe) if the platform
  // channel isn't available, e.g. under `flutter test`.
  HomeWidget.registerInteractivityCallback(
    homeWidgetBackgroundCallback,
  ).catchError((_) => null);
  // Arms the native midnight alarm so the widgets and reminders roll over to the
  // new day even when the app is closed.
  await MidnightScheduler.initialize();
  await MidnightScheduler.armNextMidnight();
  runApp(const ProviderScope(child: TazkApp()));
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(pomodoroControllerProvider).pauseForAppExit();
    } else if (state == AppLifecycleState.resumed) {
      // Returning to the foreground may cross a day boundary the in-app timer
      // couldn't fire while suspended. Refresh "today", re-run the idempotent
      // daily rollover, and re-arm the midnight alarm in case an aggressive
      // battery manager killed it.
      ref.read(currentDateProvider.notifier).refresh();
      ref.read(dailyMaintenanceServiceProvider).runDailyRollover();
      MidnightScheduler.armNextMidnight();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
