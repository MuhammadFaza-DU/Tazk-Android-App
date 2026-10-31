import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('light & dark masing-masing 19 token non-null dan tidak identik', () {
      final light = AppColors.light;
      final dark = AppColors.dark;

      expect(_tokens(light).length, 19);
      expect(_tokens(dark).length, 19);

      for (final color in [..._tokens(light), ..._tokens(dark)]) {
        expect(color, isNotNull);
      }

      expect(light.primary, isNot(dark.primary));
      expect(light.canvas, isNot(dark.canvas));
      expect(light.surface, isNot(dark.surface));
    });

    test('nilai hex token light persis DESIGN.md', () {
      expect(AppColors.light.primary, const Color(0xFF4A5A44));
      expect(AppColors.light.canvas, const Color(0xFFF4F1EA));
      expect(AppColors.light.surface, const Color(0xFFFBF9F4));
      expect(AppColors.light.surfaceAlt, const Color(0xFFEDE7DA));
      expect(AppColors.light.border, const Color(0xFFE2DACB));
      expect(AppColors.light.ink, const Color(0xFF26251F));
      expect(AppColors.light.inkMuted, const Color(0xFF6A6659));
      expect(AppColors.light.primarySoft, const Color(0xFF6B7F5E));
      expect(AppColors.light.primaryContainer, const Color(0xFFDDE3D6));
      expect(AppColors.light.onPrimary, const Color(0xFFFBF9F4));
      expect(AppColors.light.onPrimaryMuted, const Color(0xFFDDE3D6));
      expect(AppColors.light.clay, const Color(0xFFC97B5A));
      expect(AppColors.light.clayContainer, const Color(0xFFF2DCD1));
      expect(AppColors.light.honey, const Color(0xFFD69A3C));
      expect(AppColors.light.honeyContainer, const Color(0xFFF6E4C2));
      expect(AppColors.light.danger, const Color(0xFFA5432A));
      expect(AppColors.light.warning, const Color(0xFFB4791F));
      expect(AppColors.light.warningStrong, const Color(0xFF8A5A12));
      expect(AppColors.light.success, const Color(0xFF4A5A44));
    });

    test('nilai hex token dark persis DESIGN.md', () {
      expect(AppColors.dark.primary, const Color(0xFF8FE0A9));
      expect(AppColors.dark.canvas, const Color(0xFF0F1A14));
      expect(AppColors.dark.surface, const Color(0xFF152219));
      expect(AppColors.dark.surfaceAlt, const Color(0xFF1C2C21));
      expect(AppColors.dark.border, const Color(0xFF23382A));
      expect(AppColors.dark.ink, const Color(0xFFE8F0E7));
      expect(AppColors.dark.inkMuted, const Color(0xFF9DAF9F));
      expect(AppColors.dark.primarySoft, const Color(0xFF5FAE7C));
      expect(AppColors.dark.primaryContainer, const Color(0xFF20362A));
      expect(AppColors.dark.onPrimary, const Color(0xFF0F1A14));
      expect(AppColors.dark.onPrimaryMuted, const Color(0xFF20362A));
      expect(AppColors.dark.clay, const Color(0xFFE0A183));
      expect(AppColors.dark.clayContainer, const Color(0xFF3A2620));
      expect(AppColors.dark.honey, const Color(0xFFF2C765));
      expect(AppColors.dark.honeyContainer, const Color(0xFF3A3220));
      expect(AppColors.dark.danger, const Color(0xFFF0A48C));
      expect(AppColors.dark.warning, const Color(0xFFEBCB7E));
      expect(AppColors.dark.warningStrong, const Color(0xFFEBCB7E));
      expect(AppColors.dark.success, const Color(0xFF8FE0A9));
    });
  });

  group('AppTheme', () {
    test('light → canvas + primary + extension<AppColors>', () {
      final theme = AppTheme.light;

      expect(theme.scaffoldBackgroundColor, AppColors.light.canvas);
      expect(theme.colorScheme.primary, AppColors.light.primary);
      expect(theme.extension<AppColors>(), isNotNull);
      expect(theme.extension<AppColors>()!.primary, AppColors.light.primary);
      expect(theme.extension<AppColors>()!.canvas, AppColors.light.canvas);
    });

    test('dark → canvas + primary + extension<AppColors>', () {
      final theme = AppTheme.dark;

      expect(theme.scaffoldBackgroundColor, AppColors.dark.canvas);
      expect(theme.colorScheme.primary, AppColors.dark.primary);
      expect(theme.extension<AppColors>(), isNotNull);
      expect(theme.extension<AppColors>()!.primary, AppColors.dark.primary);
      expect(theme.extension<AppColors>()!.canvas, AppColors.dark.canvas);
    });
  });
}

List<Color> _tokens(AppColors c) {
  return [
    c.canvas,
    c.surface,
    c.surfaceAlt,
    c.border,
    c.ink,
    c.inkMuted,
    c.primary,
    c.primarySoft,
    c.primaryContainer,
    c.onPrimary,
    c.onPrimaryMuted,
    c.clay,
    c.clayContainer,
    c.honey,
    c.honeyContainer,
    c.danger,
    c.warning,
    c.warningStrong,
    c.success,
  ];
}