import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../providers/repository_providers.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _videoAsset = 'assets/videos/tazk_growth_splash.mp4';
  static const _transitionDuration = Duration(milliseconds: 450);

  late final Future<Widget> _nextScreenFuture;
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _nextScreenFuture = _prepareNextScreen();
    _initializeVideo();
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
      controller.addListener(_handleVideoProgress);
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
    await notifications.requestPermission();
    await maintenance.runDailyRollover();
    final profile = await gamification.ensureProfile();

    return profile.name.trim().isEmpty
        ? const OnboardingScreen()
        : const HomeScreen();
  }

  void _handleVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    if (duration == Duration.zero) return;
    final almostDone = controller.value.position >=
        duration - const Duration(milliseconds: 120);
    if (almostDone && !_isNavigating) {
      _navigateNext();
    }
  }

  Future<void> _navigateNext() async {
    if (_isNavigating) return;
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
    _videoController?.removeListener(_handleVideoProgress);
    _videoController?.dispose();
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
          if (_videoReady) _SplashVideo(controller: _videoController!),
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
