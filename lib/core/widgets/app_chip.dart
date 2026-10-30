import 'package:flutter/material.dart';

import '../../data/models/enums.dart';
import '../theme/app_colors.dart';

/// Design system v2 chip — pill radius (999), padding `xs` (4) vertical +
/// `md` (12) horizontal, label Plus Jakarta Sans 13 w600.
///
/// `AppChip.priority` memetakan `TaskPriority` ke pasangan warna container/teks
/// yang lolos AA (high → `clay-container`/`danger`, medium → `honey-container`/
/// `warning-strong`). "low" memakai `surface-alt`/`ink-muted` (ekstensi lokal —
/// belum ada token `low` di DESIGN.md).
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  }) : _priority = null;

  const AppChip.priority(
    TaskPriority priority, {
    super.key,
    required this.label,
  })  : _priority = priority,
        backgroundColor = null,
        foregroundColor = null;

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TaskPriority? _priority;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    final (background, foreground) = _priority != null
        ? _priorityColors(_priority, colors)
        : (backgroundColor!, foregroundColor!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999), // rounded.pill
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }

  static (Color, Color) _priorityColors(TaskPriority priority, AppColors c) {
    return switch (priority) {
      TaskPriority.high => (c.clayContainer, c.danger),
      TaskPriority.medium => (c.honeyContainer, c.warningStrong),
      TaskPriority.low => (c.surfaceAlt, c.inkMuted),
    };
  }
}