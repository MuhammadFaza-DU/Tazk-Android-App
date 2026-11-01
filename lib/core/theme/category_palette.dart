import 'package:flutter/material.dart';

import '../../data/models/enums.dart';

/// Accent color for a category: dot, chip border, or selected label.
///
/// Each value is verified against the theme `surface` at ≥4.5:1 (light) and
/// ≥7.4:1 (dark), so it stays legible as small text, not only as a dot.
/// Not a fill color — pair it with `surface`/`surfaceAlt` behind it.
Color categoryColor(BuildContext context, CategoryColor color) {
  return switch (Theme.of(context).brightness) {
    Brightness.light => switch (color) {
        // Sage & Sand — mirrors `primary`, plus muted sage-adjacent hues.
        CategoryColor.sage => const Color(0xFF4A5A44),
        CategoryColor.honey => const Color(0xFF98681C),
        CategoryColor.rose => const Color(0xFFA85A4A),
        CategoryColor.sky => const Color(0xFF3F6B7A),
        CategoryColor.plum => const Color(0xFF6B4A6E),
        CategoryColor.sand => const Color(0xFF7A6440),
      },
    Brightness.dark => switch (color) {
        // Dusk Forest — mirrors `primary`, `honey`, and `clay`, plus lightened hues.
        CategoryColor.sage => const Color(0xFF8FE0A9),
        CategoryColor.honey => const Color(0xFFF2C765),
        CategoryColor.rose => const Color(0xFFE0A183),
        CategoryColor.sky => const Color(0xFF9CC3CF),
        CategoryColor.plum => const Color(0xFFC7A3C9),
        CategoryColor.sand => const Color(0xFFD8C79E),
      },
  };
}