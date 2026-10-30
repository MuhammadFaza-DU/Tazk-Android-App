import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
      return AlertDialog(
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
      );
    },
  );
}