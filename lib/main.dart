import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/models/enums.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/settings_providers.dart';

void main() {
  runApp(const ProviderScope(child: TazkApp()));
}

class TazkApp extends ConsumerWidget {
  const TazkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final themeMode = settings?.themeMode ?? AppThemeMode.light;
    final language = settings?.language ?? AppLanguage.indonesian;

    return MaterialApp(
      title: 'Tazk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(language == AppLanguage.english ? 'en' : 'id'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
