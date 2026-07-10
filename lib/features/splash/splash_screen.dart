import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _videoAsset = 'assets/videos/tazk_growth_splash.mp4';
  static const _duration = Duration(milliseconds: 4200);
  static const _transitionDuration = Duration(milliseconds: 450);

  late final AnimationController _fallbackController;
  late final Animation<double> _growth;
  late final Animation<double> _titleOpacity;
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _fallbackController = AnimationController(vsync: this, duration: _duration);
    _growth = CurvedAnimation(
      parent: _fallbackController,
      curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
    );
    _titleOpacity = CurvedAnimation(
      parent: _fallbackController,
      curve: const Interval(0.68, 0.92, curve: Curves.easeInOut),
    );
    _fallbackController.forward();
    _initializeVideo();
    _navigateNext();
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.asset(_videoAsset);
    _videoController = controller;

    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.setVolume(0);
      if (!mounted) return;
      setState(() => _videoReady = true);
      await controller.play();
    } catch (_) {
      await controller.dispose();
      _videoController = null;
      if (!mounted) return;
      setState(() => _videoFailed = true);
    }
  }

  Future<void> _navigateNext() async {
    final delay = Future<void>.delayed(_duration);
    final profileFuture = ref
        .read(gamificationRepositoryProvider)
        .ensureProfile();
    await delay;
    final profile = await profileFuture;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: _transitionDuration,
        pageBuilder: (_, _, _) => profile.name.trim().isEmpty
            ? const OnboardingScreen()
            : const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _FallbackSplash(
            animation: _fallbackController,
            growth: _growth,
            titleOpacity: _titleOpacity,
            isDark: isDark,
          ),
          AnimatedOpacity(
            opacity: _videoReady && !_videoFailed ? 1 : 0,
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            child: _videoReady
                ? _SplashVideo(controller: _videoController!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SplashVideo extends StatelessWidget {
  const _SplashVideo({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _FallbackSplash extends StatelessWidget {
  const _FallbackSplash({
    required this.animation,
    required this.growth,
    required this.titleOpacity,
    required this.isDark,
  });

  final Animation<double> animation;
  final Animation<double> growth;
  final Animation<double> titleOpacity;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(painter: _TreeGrowthPainter(growth.value)),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: titleOpacity.value,
                child: Column(
                  children: [
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontFamily: AppTypography.titleFont,
                        fontSize: 40,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.splashTagline,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFont,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.accentDark
                            : AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

    final trunkHeight = 90 * progress;
    final trunkPaint = Paint()..color = AppColors.terracotta.withAlpha(alpha);
    final trunkRect = Rect.fromLTWH(
      center.dx - 7,
      center.dy + 45 - trunkHeight,
      14,
      trunkHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(trunkRect, const Radius.circular(7)),
      trunkPaint,
    );

    final leafPaint = Paint()..color = AppColors.primaryLight.withAlpha(alpha);
    final accentPaint = Paint()..color = AppColors.accentLight.withAlpha(alpha);
    final canopyRadius = 58 * progress;
    canvas.drawCircle(
      Offset(center.dx - 32, center.dy - 34),
      canopyRadius,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 36, center.dy - 48),
      canopyRadius * 0.9,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + 2, center.dy - 82),
      canopyRadius * 0.82,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TreeGrowthPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
