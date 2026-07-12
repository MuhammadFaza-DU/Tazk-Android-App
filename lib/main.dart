import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'core/theme/app_theme.dart';
import 'data/models/enums.dart';
import 'features/pomodoro/pomodoro_controller.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/settings_providers.dart';
import 'widgets/home_widget_callback.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort: lets homescreen widget checkboxes complete tasks/habits
  // even while the app isn't running. No-op (and safe) if the platform
  // channel isn't available, e.g. under `flutter test`.
  HomeWidget.registerInteractivityCallback(
    homeWidgetBackgroundCallback,
  ).catchError((_) => null);
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
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
