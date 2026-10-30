import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Design system v2 theme — light "Sage & Sand" / dark "Dusk Forest".
///
/// Membangun `ColorScheme` secara EKSPLISIT (bukan `fromSeed`) dari token
/// `AppColors`, lalu `ThemeData` yang me-register `AppColors` sebagai extension
/// (akses via `context.colors.<token>`).
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);

  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  /// Pemetaan token → `ColorScheme` (verbatim arahan design-system-to-code).
  ///
  /// Catatan: `onSecondary`/`onTertiary` tidak punya token di `DESIGN.md`
  /// (hanya ada `on-primary` untuk teks di atas permukaan berwarna). Diisi
  /// best-effort ke `onPrimary`; teks di atas aksen sebenarnya memakai
  /// `context.colors.*`, bukan `colorScheme.secondary/tertiary`.
  static ColorScheme _colorScheme(AppColors c, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.primary,
      secondary: c.clay,
      onSecondary: c.onPrimary,
      secondaryContainer: c.clayContainer,
      onSecondaryContainer: c.danger,
      tertiary: c.honey,
      onTertiary: c.onPrimary,
      tertiaryContainer: c.honeyContainer,
      onTertiaryContainer: c.warningStrong,
      error: c.danger,
      onError: c.onPrimary,
      errorContainer: c.clayContainer,
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      surfaceContainerHighest: c.surfaceAlt,
      outline: c.border,
      outlineVariant: c.border,
    );
  }

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = _colorScheme(c, brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.canvas,
      textTheme: AppTypography.textTheme(c.ink),
      fontFamily: AppTypography.bodyFont,
      appBarTheme: AppBarTheme(
        backgroundColor: c.canvas,
        foregroundColor: c.ink,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.titleFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: c.ink,
        ),
      ),
      extensions: [c],
    );
  }
}