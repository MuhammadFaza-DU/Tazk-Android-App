import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

/// Kartu kecil statistik (T5): `label` caption/label (`ink-muted`) + `value`
/// title (Fredoka, `ink`), icon opsional.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.inkMuted),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: colors.inkMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineLarge),
        ],
      ),
    );
  }
}