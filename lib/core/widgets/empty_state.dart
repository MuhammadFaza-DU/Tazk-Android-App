import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Kolom ter-pusat: maskot otter + `message` (body, `ink-muted`) + aksi opsional.
///
/// Entrance sekali saat mount: fade + geser 8px (`base`, `easeStandard`),
/// composite-only (`Opacity` + `Transform.translate`) dan instan saat
/// reduced-motion aktif (`context.motion` → `Duration.zero`).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.action,
    this.imageAsset = 'assets/mascot/otter-with-sprout.png',
  });

  final String message;
  final Widget? action;

  /// Maskot yang tersedia di repo: `otter-portrait`, `otter-waving`,
  /// `otter-with-sprout` (default = otter dgn tunas, sesuai brand).
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      key: const Key('empty_state_entrance'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: context.motion(AppMotion.base),
      curve: AppMotion.easeStandard,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - t)),
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) =>
                Icon(Icons.pets_rounded, size: 48, color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: colors.inkMuted),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
