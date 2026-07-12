import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AnimatedXpProgress extends StatelessWidget {
  const AnimatedXpProgress({
    super.key,
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: target),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) {
          return LinearProgressIndicator(
            value: animatedValue,
            minHeight: 10,
            backgroundColor: AppColors.terracotta.withAlpha(40),
            valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
          );
        },
      ),
    );
  }
}
