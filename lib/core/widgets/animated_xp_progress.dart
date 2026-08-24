import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// PRD "Animasi Khusus": XP bar fill smooth + flash/glow + scale-bounce on
/// level up. [level] is watched for upward jumps.
class AnimatedXpProgress extends StatefulWidget {
  const AnimatedXpProgress({
    super.key,
    required this.value,
    required this.level,
  });

  final double value;
  final int level;

  @override
  State<AnimatedXpProgress> createState() => _AnimatedXpProgressState();
}

class _AnimatedXpProgressState extends State<AnimatedXpProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.06), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 0.98), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _glow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.45, curve: Curves.easeOut)),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedXpProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.level > oldWidget.level) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.value.clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: _glow.value > 0
                  ? [
                      BoxShadow(
                        color: AppColors.accentLight
                            .withValues(alpha: 0.45 * (1 - _glow.value) + 0.15),
                        blurRadius: 10 * _glow.value + 2,
                        spreadRadius: 1 * _glow.value,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: target),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, _) {
                  return LinearProgressIndicator(
                    value: animatedValue,
                    minHeight: 10,
                    backgroundColor: AppColors.terracotta.withValues(alpha: 0.16),
                    valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
