import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';
import 'app_card.dart';

/// State gagal — board `11 States` (ERROR).
///
/// Kartu `AppCard` ter-pusat: lingkaran 72dp `clay-container` berisi ikon
/// `priority_high_rounded` `danger`, judul Fredoka (`headlineSmall`, `ink`),
/// sub-judul (`bodyMedium`, `ink-muted`), lalu tombol `secondary` berikon
/// refresh. Tanpa shadow/gradient; pemisah tetap border kartu.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Coba lagi',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  /// Diameter lingkaran ikon (board: ~72dp).
  static const double badgeDiameter = 72;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            child: Container(
              width: badgeDiameter,
              height: badgeDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.clayContainer,
              ),
              child: Icon(
                Icons.priority_high_rounded,
                size: 32,
                color: colors.danger,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          Align(
            child: AppButton.secondary(
              label: retryLabel,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}