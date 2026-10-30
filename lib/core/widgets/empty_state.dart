import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'app_card.dart';

/// State kosong — board `11 States` (EMPTY).
///
/// Kartu `AppCard` ter-pusat berisi lingkaran maskot 96dp (`surface-alt` +
/// `ClipOval`, jadi PNG berlatar krem tidak menempel sebagai persegi), judul
/// Fredoka (`headlineSmall`, `ink`), sub-judul (`bodyMedium`, `ink-muted`), dan
/// aksi opsional. Jarak: maskot→judul 16, judul→sub-judul 8, sub-judul→aksi 16.
///
/// Entrance sekali saat mount: fade + geser 8px (`base`, `easeStandard`),
/// composite-only (`Opacity` + `Transform.translate`) dan instan saat
/// reduced-motion aktif. Call site lama (`title == null`) tetap mendapat
/// maskot + `message` seperti sebelumnya.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title,
    required this.message,
    this.action,
  });

  /// Judul Fredoka. `null` → mode lama (tanpa judul).
  final String? title;

  /// Sub-judul saat [title] diisi; teks utama saat [title] kosong.
  final String message;

  final Widget? action;

  /// Diameter lingkaran maskot (board: ~96dp).
  static const double mascotDiameter = 96;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final title = this.title;

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
      child: AppCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              child: Container(
                width: mascotDiameter,
                height: mascotDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceAlt,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/mascot/otter-portrait.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.pets_rounded,
                      size: 40,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.inkMuted,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              Align(child: action!),
            ],
          ],
        ),
      ),
    );
  }
}