import 'package:flutter/material.dart';

/// Design system v2 typography (verbatim `DESIGN.md` `typography:`).
///
/// - Fredoka → display, title, headline (rounded, playful half of identity).
/// - Plus Jakarta Sans → body, label, caption (termasuk semua angka: XP, timer,
///   tanggal, count).
class AppTypography {
  AppTypography._();

  static const String titleFont = 'Fredoka';
  static const String bodyFont = 'PlusJakartaSans';

  /// Memetakan 6 skala `DESIGN.md` ke slot `TextTheme`.
  /// Semua slot memakai `color: onSurface` agar theme-aware.
  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      // display — Fredoka 30 / w600 / h1.2
      displayLarge: _fredoka(onSurface, 30, 1.2),
      displayMedium: _fredoka(onSurface, 30, 1.2),
      displaySmall: _fredoka(onSurface, 30, 1.2),
      // title — Fredoka 22 / w600 / h1.25
      headlineLarge: _fredoka(onSurface, 22, 1.25),
      headlineMedium: _fredoka(onSurface, 22, 1.25),
      // headline — Fredoka 18 / w600 / h1.3
      headlineSmall: _fredoka(onSurface, 18, 1.3),
      titleLarge: _fredoka(onSurface, 18, 1.3),
      // body — Plus Jakarta Sans 15 / w400 / h1.5
      bodyLarge: _jakarta(onSurface, 15, FontWeight.w400, 1.5),
      bodyMedium: _jakarta(onSurface, 15, FontWeight.w400, 1.5),
      // label — Plus Jakarta Sans 13 / w600 / h1.4
      labelLarge: _jakarta(onSurface, 13, FontWeight.w600, 1.4),
      labelMedium: _jakarta(onSurface, 13, FontWeight.w600, 1.4),
      titleMedium: _jakarta(onSurface, 13, FontWeight.w600, 1.4),
      // caption — Plus Jakarta Sans 12 / w400 / h1.4
      bodySmall: _jakarta(onSurface, 12, FontWeight.w400, 1.4),
      labelSmall: _jakarta(onSurface, 12, FontWeight.w400, 1.4),
      titleSmall: _jakarta(onSurface, 12, FontWeight.w400, 1.4),
    );
  }

  static TextStyle _fredoka(Color color, double size, double height) {
    return TextStyle(
      fontFamily: titleFont,
      fontSize: size,
      fontWeight: FontWeight.w600,
      height: height,
      color: color,
    );
  }

  static TextStyle _jakarta(
    Color color,
    double size,
    FontWeight weight,
    double height,
  ) {
    return TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }
}