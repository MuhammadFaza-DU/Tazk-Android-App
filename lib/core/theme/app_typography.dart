import 'package:flutter/material.dart';

/// Judul → Spicy Rice, penjelasan/body → Sour Gummy, elemen kecil (label/tombol) → Unkempt.
class AppTypography {
  AppTypography._();

  static const String titleFont = 'SpicyRice';
  static const String bodyFont = 'SourGummy';
  static const String labelFont = 'Unkempt';

  static TextTheme textTheme(Color onBackground) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: titleFont, fontSize: 40, color: onBackground),
      displayMedium: TextStyle(fontFamily: titleFont, fontSize: 34, color: onBackground),
      displaySmall: TextStyle(fontFamily: titleFont, fontSize: 28, color: onBackground),
      headlineLarge: TextStyle(fontFamily: titleFont, fontSize: 26, color: onBackground),
      headlineMedium: TextStyle(fontFamily: titleFont, fontSize: 22, color: onBackground),
      headlineSmall: TextStyle(fontFamily: titleFont, fontSize: 20, color: onBackground),
      titleLarge: TextStyle(fontFamily: titleFont, fontSize: 18, color: onBackground),
      titleMedium: TextStyle(fontFamily: titleFont, fontSize: 16, color: onBackground),
      titleSmall: TextStyle(fontFamily: titleFont, fontSize: 14, color: onBackground),
      bodyLarge: TextStyle(fontFamily: bodyFont, fontSize: 16, color: onBackground),
      bodyMedium: TextStyle(fontFamily: bodyFont, fontSize: 14, color: onBackground),
      bodySmall: TextStyle(fontFamily: bodyFont, fontSize: 12, color: onBackground),
      labelLarge: TextStyle(fontFamily: labelFont, fontSize: 14, color: onBackground),
      labelMedium: TextStyle(fontFamily: labelFont, fontSize: 12, color: onBackground),
      labelSmall: TextStyle(fontFamily: labelFont, fontSize: 11, color: onBackground),
    );
  }
}
