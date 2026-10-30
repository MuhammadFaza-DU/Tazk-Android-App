import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Snackbar bertema: bg `ink`, teks `surface` (kontras tinggi, lolos AA di
/// light & dark). Floating + radius `md` (14).
void showAppSnackbar(BuildContext context, String message) {
  final theme = Theme.of(context);
  final colors = context.colors;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.ink,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)), // rounded.md
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.surface),
        ),
      ),
    );
}