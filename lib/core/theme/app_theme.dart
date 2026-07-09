import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      secondary: AppColors.accentLight,
      tertiary: AppColors.terracotta,
      surface: AppColors.surfaceLight,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.textTheme(colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.titleFont,
          fontSize: 20,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      secondary: AppColors.accentDark,
      tertiary: AppColors.terracotta,
      surface: AppColors.surfaceDark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.textTheme(colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.titleFont,
          fontSize: 20,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
