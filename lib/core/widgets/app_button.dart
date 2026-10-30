import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

enum _AppButtonVariant { primary, secondary, ghost, danger }

/// Key tetap di `AnimatedScale` — dipakai test untuk mengunci nilai target.
const Key _scaleKey = Key('app_button_scale');

/// Design system v2 button — tiga variant, radius `md` (14), min height 48
/// (tap target). Tidak pakai gradient/shad lebih; aksen cuma lewat token.
///
/// Press feedback: scale 0.97 selama tekan (`AppMotion.fast` 150ms,
/// `easeStandard`). Transform-only — tidak memicu layout/paint ulang.
class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final onPressed = widget.onPressed;

    final (background, foreground) = switch (widget._variant) {
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
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 18, color: foreground),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: theme.textTheme.labelLarge?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );

    // Handler press hanya dipasang saat tombol aktif: `InkWell` menganggap
    // dirinya enabled kalau `onTapDown`/`onTapUp` non-null (lihat
    // `_primaryButtonEnabled`), jadi memasangnya pada tombol disabled akan
    // memunculkan ripple/hover — mengubah perilaku disabled.
    final enabled = onPressed != null;

    final button = Material(
      color: background,
      shape: const RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48), // tap target
          child: content,
        ),
      ),
    );

    final scaled = AnimatedScale(
      key: _scaleKey,
      scale: (_pressed && enabled && !context.reduceMotion) ? 0.97 : 1.0,
      duration: context.motion(AppMotion.fast),
      curve: AppMotion.easeStandard,
      child: button,
    );

    // Disabled: turunkan opasitas + tanpa ripple (affordance non-warna).
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: widget.expanded
          ? SizedBox(width: double.infinity, child: scaled)
          : scaled,
    );
  }
}