import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Dialog bertema: `AlertDialog` bg `surface`, radius `md` (14), judul Fredoka,
/// teks konten `ink`.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  String? title,
  required Widget content,
  List<Widget>? actions,
}) {
  final colors = context.colors;
  final textTheme = Theme.of(context).textTheme;

  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      // Entrance tanpa controller: scale 0.96 → 1.0 + fade, `base` (220ms),
      // ease-standard. `context` di sini = caller (punya MediaQuery), aman
      // untuk reduced-motion; `Opacity` + `Transform` = composite-only.
      return TweenAnimationBuilder<double>(
        key: const Key('app_dialog_entrance'),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: context.motion(AppMotion.base),
        curve: AppMotion.easeStandard,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
        ),
        child: AlertDialog(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)), // rounded.md
          ),
          title: title == null
              ? null
              : Text(title, style: textTheme.headlineSmall), // Fredoka
          content: DefaultTextStyle.merge(
            style: textTheme.bodyLarge ?? const TextStyle(),
            child: content,
          ),
          actions: actions,
        ),
      );
    },
  );
}