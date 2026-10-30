import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

class CompletionCheckbox extends StatefulWidget {
  const CompletionCheckbox({
    super.key,
    required this.value,
    this.onComplete,
    this.onUncomplete,
  });

  final bool value;
  final Future<void> Function()? onComplete;
  final Future<void> Function()? onUncomplete;

  @override
  State<CompletionCheckbox> createState() => _CompletionCheckboxState();
}

class _CompletionCheckboxState extends State<CompletionCheckbox> {
  bool _pressed = false;
  bool _burst = false;

  Timer? _pressTimer;
  Timer? _burstTimer;

  bool get _canToggleOn => !widget.value && widget.onComplete != null;
  bool get _canToggleOff => widget.value && widget.onUncomplete != null;
  bool get _enabled => _canToggleOn || _canToggleOff;

  @override
  void dispose() {
    _pressTimer?.cancel();
    _burstTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleChanged(bool? value) async {
    final isCheck = value == true;
    // value=true means user is checking; value=false means unchecking.
    // Guard against spurious calls (e.g. disabled checkbox).
    if (isCheck && !_canToggleOn) return;
    if (!isCheck && !_canToggleOff) return;
    if (isCheck) {
      if (context.reduceMotion) {
        // Reduced motion: state instan, tanpa pop/confetti.
        await widget.onComplete!();
        return;
      }
      setState(() {
        _pressed = true;
        _burst = true;
      });
      _pressTimer = Timer(AppMotion.fast, () {
        if (mounted) setState(() => _pressed = false);
      });
      _burstTimer = Timer(const Duration(milliseconds: 380), () {
        if (mounted) setState(() => _burst = false);
      });
      await widget.onComplete!();
    } else {
      await widget.onUncomplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedScale(
          scale: _pressed ? 1.15 : 1,
          duration: context.motion(AppMotion.fast),
          curve: AppMotion.easeStandard,
          child: Checkbox(
            value: widget.value,
            onChanged: _enabled ? _handleChanged : null,
          ),
        ),
        if (_burst) const _MicroConfettiBurst(key: Key('micro_confetti')),
      ],
    );
  }
}

class _MicroConfettiBurst extends StatefulWidget {
  const _MicroConfettiBurst({super.key});

  @override
  State<_MicroConfettiBurst> createState() => _MicroConfettiBurstState();
}

class _MicroConfettiBurstState extends State<_MicroConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      context.colors.honey,
      context.colors.primary,
      context.colors.clay,
    ];
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: const Size(28, 28),
            painter: _ConfettiPainter(
              progress: _controller.value,
              colors: colors,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const count = 7;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final distance = 8 + 10 * progress;
      final pos = center +
          Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      final alpha = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      final radius = 2.4 * (1 - 0.45 * progress);
      canvas.drawCircle(pos, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}