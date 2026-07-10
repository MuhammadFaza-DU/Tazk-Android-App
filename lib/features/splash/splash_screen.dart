import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/repository_providers.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

/// Placeholder growth animation until the real 3D tree-growth video
/// (PRD section 8) is rendered and dropped into assets/videos/.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 3000);

  late final AnimationController _controller;
  late final Animation<double> _growth;
  late final Animation<double> _titleOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _growth = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
    );
    _titleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );
    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final delay = Future<void>.delayed(_duration + const Duration(milliseconds: 200));
    final profile = await ref.read(gamificationRepositoryProvider).ensureProfile();
    await delay;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => profile.name.trim().isEmpty
            ? const OnboardingScreen()
            : const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: _TreeGrowthPainter(_growth.value)),
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: _titleOpacity.value,
                  child: Text(
                    'Tazk',
                    style: TextStyle(
                      fontFamily: AppTypography.titleFont,
                      fontSize: 36,
                      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TreeGrowthPainter extends CustomPainter {
  _TreeGrowthPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final alpha = (255 * progress.clamp(0.0, 1.0)).round();

    final trunkHeight = 80 * progress;
    final trunkPaint = Paint()..color = AppColors.terracotta.withAlpha(alpha);
    final trunkRect = Rect.fromLTWH(
      center.dx - 6,
      center.dy + 40 - trunkHeight,
      12,
      trunkHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(trunkRect, const Radius.circular(6)),
      trunkPaint,
    );

    final canopyRadius = 70 * progress;
    final canopyPaint = Paint()..color = AppColors.primaryLight.withAlpha(alpha);
    canvas.drawCircle(Offset(center.dx, center.dy - 40), canopyRadius, canopyPaint);
  }

  @override
  bool shouldRepaint(covariant _TreeGrowthPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
