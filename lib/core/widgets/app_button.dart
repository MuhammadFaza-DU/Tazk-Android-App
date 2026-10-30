import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum _AppButtonVariant { primary, secondary, ghost, danger }

/// Design system v2 button — tiga variant, radius `md` (14), min height 48
/// (tap target). Tidak pakai gradient/shad lebih; aksen cuma lewat token.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : _variant = _AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
  }) : _variant = _AppButtonVariant.danger;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    final (background, foreground) = switch (_variant) {
      _AppButtonVariant.primary => (colors.primary, colors.onPrimary),
      _AppButtonVariant.secondary => (colors.primaryContainer, colors.primary),
      _AppButtonVariant.ghost => (Colors.transparent, colors.primary),
      _AppButtonVariant.danger => (colors.danger, colors.onPrimary),
    };

    const radius = BorderRadius.all(Radius.circular(14)); // rounded.md

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );

    final button = Material(
      color: background,
      shape: const RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48), // tap target
          child: content,
        ),
      ),
    );

    // Disabled: turunkan opasitas + tanpa ripple (affordance non-warna).
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}