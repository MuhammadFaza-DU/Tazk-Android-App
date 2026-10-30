import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// PRD "Animasi Khusus": XP bar fill smooth + flash/glow + scale-bounce on
/// level up. [level] is watched for upward jumps.
///
/// Motion is composite-only by design:
/// * the glow is a **static** `BoxShadow` layer whose `opacity` animates
///   (never `blurRadius`/`spreadRadius`, which would repaint every frame);
/// * the bounce is a `Transform.scale`, and the bar subtree is passed as the
///   cached `child` of the [AnimatedBuilder] so only the transform rebuilds.
///
/// Both are skipped when the platform asks for reduced motion.
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
  /// `DESIGN.md` level-up sits in the 600–900ms celebration band.
  static const Duration _levelUpDuration = Duration(milliseconds: 600);

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _levelUpDuration);

    // Pop past 1.0 then settle back — `Transform.scale` only (composite).
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.06,
        ).chain(CurveTween(curve: AppMotion.springPop)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.06,
          end: 1.0,
        ).chain(CurveTween(curve: AppMotion.easeStandard)),
        weight: 55,
      ),
    ]).animate(_controller);

    // One-shot flash: opacity 0 → 1 → 0, so no halo lingers after settling.
    _glow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: AppMotion.easeStandard)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: AppMotion.easeStandard)),
        weight: 75,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant AnimatedXpProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.level > oldWidget.level && !context.reduceMotion) {
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
    final colors = context.colors;
    const radius = BorderRadius.all(Radius.circular(8));

    // Constant shadow geometry/colour: the render object only repaints when
    // this decoration changes, which it never does frame-to-frame.
    final glowDecoration = BoxDecoration(
      borderRadius: radius,
      boxShadow: [
        BoxShadow(
          color: colors.honey.withValues(alpha: 0.45),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ],
    );

    final bar = Stack(
      // The glow paints outside the bar bounds; don't clip it away.
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              key: const Key('xp_glow'),
              opacity: _glow,
              child: DecoratedBox(decoration: glowDecoration),
            ),
          ),
        ),
        ClipRRect(
          borderRadius: radius,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: target),
            duration: context.motion(AppMotion.base),
            curve: AppMotion.easeStandard,
            builder: (context, animatedValue, _) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: 10,
                backgroundColor: colors.clay.withValues(alpha: 0.16),
                valueColor: AlwaysStoppedAnimation<Color>(colors.honey),
              );
            },
          ),
        ),
      ],
    );

    return AnimatedBuilder(
      animation: _controller,
      // `child` is built once and reused, so only this Transform rebuilds per
      // frame — the glow layer and bar keep their render objects intact.
      builder: (context, child) => Transform.scale(
        key: const Key('xp_scale'),
        scale: _scale.value,
        child: child,
      ),
      child: bar,
    );
  }
}