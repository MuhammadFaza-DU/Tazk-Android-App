import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'app_button.dart';

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
    final reduce = context.reduceMotion;

    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration_rounded, size: 56, color: colors.honey),
          const SizedBox(height: 12),
          Text(
            'Rank Baru!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colors.honey.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.rankLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.clay,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton.primary(
            label: 'Lanjutkan',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );

    if (reduce) {
      // Tanpa confetti sama sekali: tidak ada AnimatedBuilder/painter yang dibuat.
      return Center(
        child: Material(color: Colors.transparent, child: card),
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
            card,
          ],
        ),
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