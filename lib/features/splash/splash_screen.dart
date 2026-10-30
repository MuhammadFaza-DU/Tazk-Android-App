import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/exact_alarm_permission_provider.dart';
import '../../providers/notification_permission_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/repository_providers.dart';
import '../../core/widgets/app_shell.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _videoAsset = 'assets/videos/tazk_growth_splash.mp4';
  static const _transitionDuration = Duration(milliseconds: 450);
  static const _maxSplashDuration = Duration(milliseconds: 1200);

  late final Future<Widget> _nextScreenFuture;
  VideoPlayerController? _videoController;
  late final AnimationController _fallbackController;
  Timer? _maxSplashTimer;
  bool _videoReady = false;
  bool _showFallback = false;
  bool _showBranding = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _fallbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _nextScreenFuture = _prepareNextScreen();
    _initializeVideo();
    // Show a static fallback frame immediately while the video is still
    // loading, so users never stare at a blank screen (tests and broken
    // assets included). The video still replaces it once ready.
    Future<void>.delayed(Duration.zero, () {
      if (!mounted || _videoReady) return;
      setState(() => _showFallback = true);
    });
    // Never gate navigation on the full video length: force the transition
    // once the max splash duration elapses, whichever trigger fires first.
    _maxSplashTimer = Timer(_maxSplashDuration, _navigateNext);
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.asset(_videoAsset);
    _videoController = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(false);
      if (!mounted) return;
      await controller.setVolume(0);
      if (!mounted) return;
      setState(() => _videoReady = true);
      controller.addListener(_handleVideoProgress);
      if (!mounted) return;
      await controller.play();
    } catch (error) {
      debugPrint('SplashScreen: failed to play $_videoAsset: $error');
      await controller.dispose();
      _videoController = null;
      if (!mounted) return;
      await _navigateNext();
    }
  }

  Future<Widget> _prepareNextScreen() async {
    final gamification = ref.read(gamificationRepositoryProvider);
    final notifications = ref.read(notificationServiceProvider);
    final maintenance = ref.read(dailyMaintenanceServiceProvider);

    await notifications.initialize();
    final granted = await notifications.requestPermission();
    // PRD "Error States": surface a denied permission via the Home banner and
    // the passive Settings indicator instead of failing silently.
    ref
        .read(notificationPermissionProvider.notifier)
        .applyRequestResult(granted);
    // Exact alarm status drives its own banner; surface revocation early.
    ref.read(exactAlarmProvider.notifier).check();
    await maintenance.runDailyRollover();
    final profile = await gamification.ensureProfile();

    return profile.name.trim().isEmpty
        ? const OnboardingScreen()
        : const AppShell();
  }

  void _handleVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    if (duration == Duration.zero) return;
    final position = controller.value.position;
    // Reveal branding for the final ~35% of the clip (PRD: logo appears at end).
    if (!_showBranding && position >= duration * 0.65) {
      setState(() => _showBranding = true);
    }
    final almostDone = position >= duration - const Duration(milliseconds: 120);
    if (almostDone && !_isNavigating) {
      _navigateNext();
    }
  }

  Future<void> _navigateNext() async {
    if (_isNavigating) return;
    _maxSplashTimer?.cancel();
    _isNavigating = true;
    final nextScreen = await _nextScreenFuture;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: _transitionDuration,
        pageBuilder: (_, _, _) => nextScreen,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _maxSplashTimer?.cancel();
    _videoController?.removeListener(_handleVideoProgress);
    _videoController?.dispose();
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoReady) _SplashVideo(controller: _videoController!),
          if (_showFallback && !_videoReady)
            _FallbackTree(animation: _fallbackController),
          // Branding reveal at the tail end of the splash (growth metaphor).
          AnimatedOpacity(
            opacity: _showBranding || _showFallback ? 1 : 0,
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 64),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    context.colors.canvas.withValues(alpha: 0.72),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tazk',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.splashTagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: (isDark ? context.colors.inkMuted : context.colors.ink),
                        ),
                  ),
                ],
              ),
            ),
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

class _FallbackTree extends StatelessWidget {
  const _FallbackTree({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => CustomPaint(
          size: const Size(140, 180),
          painter: _TreePainter(
            t: animation.value,
            trunk: colors.clay,
            foliage: colors.primary,
            sparkle: colors.honey,
          ),
        ),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter({
    required this.t,
    required this.trunk,
    required this.foliage,
    required this.sparkle,
  });

  final double t;
  final Color trunk;
  final Color foliage;
  final Color sparkle;

  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = trunk
      ..style = PaintingStyle.fill;
    final foliagePaint = Paint()
      ..color = foliage.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final trunkH = 64 * (0.72 + 0.28 * t);
    final trunkW = 16.0;
    final trunkTop = size.height * 0.58 - trunkH * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, trunkTop + trunkH * 0.5), width: trunkW, height: trunkH),
        const Radius.circular(6),
      ),
      trunkPaint,
    );
    final foliageCenter = Offset(cx, trunkTop - 8 - 4 * t);
    final r = 34 + 6 * t;
    canvas.drawCircle(foliageCenter.translate(-16, 10), r * 0.72, foliagePaint);
    canvas.drawCircle(foliageCenter.translate(16, 10), r * 0.72, foliagePaint);
    canvas.drawCircle(foliageCenter, r, foliagePaint..color = foliage);
    // Sparkle
    final sparklePaint = Paint()
      ..color = sparkle.withValues(alpha: 0.55 + 0.25 * t)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(foliageCenter.translate(0, -r * 0.35), 3 + t, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) => oldDelegate.t != t;
}
