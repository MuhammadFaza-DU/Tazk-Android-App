import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_id.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'app_button.dart';

/// Key kartu dialog (permukaan `surface`, radius `xl`).
const Key celebrationCardKey = ValueKey('celebration-card');

/// Key lingkaran maskot `otter-waving`.
const Key celebrationMascotKey = ValueKey('celebration-mascot');

/// Key pill label rank.
const Key celebrationRankPillKey = ValueKey('celebration-rank-pill');

/// Momen reward "rank baru" — board `27 Celebration` (kolom MILESTONE).
///
/// Komposisi dari board (diukur @2x → /2): maskot `otter-waving` dalam
/// lingkaran, judul Fredoka, label rank sebagai pill, lalu CTA `primary`.
Future<void> showRankCelebration(
  BuildContext context, {
  required String rankLabel,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'celebration',
    transitionDuration: context.motion(AppMotion.base),
    pageBuilder: (context, _, _) => _CelebrationDialog(rankLabel: rankLabel),
    transitionBuilder: (context, animation, _, child) {
      final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: AppMotion.easeStandard),
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

class _CelebrationDialog extends StatefulWidget {
  const _CelebrationDialog({required this.rankLabel});

  final String rankLabel;

  /// Diameter lingkaran maskot. Board: 200px @2x.
  static const double mascotDiameter = 100;

  /// Lebar maksimum kartu. Board: kartu 714px @2x → 357dp.
  static const double maxCardWidth = 360;

  /// Gutter layar; menyisakan 334dp di frame 390 (board: kartu 357).
  static const double screenGutter = 28;

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // One-shot: ticker berhenti sendiri setelah `celebration` selesai.
    // Jangan pernah `repeat()` — DESIGN.md: "No ticker runs while the app is idle".
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.celebration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduced motion: perubahan state instan, controller tidak pernah jalan.
    if (!context.reduceMotion) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final reduce = context.reduceMotion;
    // Fallback ke lokal template (id) hanya untuk host tanpa delegate
    // `AppLocalizations` (mis. widget test yang memakai MaterialApp polos).
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsId();

    final card = Container(
      key: celebrationCardKey,
      padding: const EdgeInsets.all(24), // spacing.xl
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24), // rounded.xl
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: celebrationMascotKey,
            width: _CelebrationDialog.mascotDiameter,
            height: _CelebrationDialog.mascotDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surfaceAlt,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/mascot/otter-waving.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.pets_rounded,
                  size: 40,
                  color: colors.inkMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24), // board: lingkaran → judul
          Text(
            l10n.celebrationRankTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 12), // board: judul → pill
          _RankPill(label: widget.rankLabel),
          const SizedBox(height: 12), // board: pill → CTA
          AppButton.primary(
            label: l10n.celebrationContinueAction,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );

    final sized = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _CelebrationDialog.screenGutter,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _CelebrationDialog.maxCardWidth,
        ),
        // Board: kartu mengisi lebar frame (357dp), bukan selebar isinya.
        child: SizedBox(width: double.infinity, child: card),
      ),
    );

    if (reduce) {
      // Tanpa confetti sama sekali: tidak ada AnimatedBuilder/painter yang dibuat.
      return Center(
        child: Material(color: Colors.transparent, child: sized),
      );
    }

    final confettiColors = [
      colors.honey,
      colors.primary,
      colors.clay,
      colors.onPrimary,
    ];
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fullscreen confetti behind the card.
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  key: const Key('celebration_confetti'),
                  painter: _FullscreenConfettiPainter(
                    progress: _controller.value,
                    colors: confettiColors,
                  ),
                ),
              ),
            ),
            sized,
          ],
        ),
      ),
    );
  }
}

/// Pill label rank — token `chip-priority` (`honey-container` + `warning-strong`,
/// 4.78:1) supaya tetap terbaca di atas kartu `surface`; board memakai
/// `surface` + border karena kartunya `canvas` (lihat laporan).
class _RankPill extends StatelessWidget {
  const _RankPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      key: celebrationRankPillKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.honeyContainer,
        borderRadius: BorderRadius.circular(999), // rounded.pill
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rosette = tanda pangkat; board menaruh ikon reward di pill.
          Icon(
            Icons.workspace_premium_rounded,
            size: 18,
            color: colors.warningStrong,
          ),
          const SizedBox(width: 8), // spacing.sm
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.warningStrong,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenConfettiPainter extends CustomPainter {
  _FullscreenConfettiPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    const count = 22;
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final startY = -20 - rng.nextDouble() * 80;
      final fall = (progress * (size.height + 160) + i * 11) % (size.height + 160);
      final y = startY + fall;
      final sway = math.sin(progress * 6 + i) * 10;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      final r = 3 + rng.nextDouble() * 3;
      canvas.drawCircle(Offset(x + sway, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullscreenConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}