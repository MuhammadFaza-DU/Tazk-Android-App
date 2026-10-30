import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Design system v2 card — `surface` + 1px `border`, radius `md` (14), padding
/// `lg` (16). Tanpa shadow: border & divider menggantikan bayangan (DESIGN:
/// "cards never need a shadow").
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: padding ?? const EdgeInsets.all(16), // spacing.lg
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14), // rounded.md
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}