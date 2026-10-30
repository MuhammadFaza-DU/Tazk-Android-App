import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/exact_alarm_permission_provider.dart';
import '../../providers/notification_permission_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/repository_providers.dart';
import '../onboarding/onboarding_screen.dart';

/// Splash statis mengikuti board `design-export/22 Splash.png`.
///
/// Komposisi (satu grup, terpusat vertikal di atas `canvas`):
/// lingkaran maskot → wordmark "Tazk" → tagline → progress bar tipis.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _transitionDuration = Duration(milliseconds: 450);

  /// Batas splash: navigasi tidak pernah menunggu lebih lama dari ini.
  static const _maxSplashDuration = Duration(milliseconds: 1200);

  // Ukuran di bawah diukur dari board `design-export/22 Splash.png`
  // (780×1688 px = frame 390×844dp @2x), bukan dikira-kira:
  //   lingkaran honey  440px → Ø220dp
  //   gambar maskot    432×324px → 216×162dp (rasio PNG 0.75, tidak di-crop;
  //                    figure otter 352px → 176dp = 80% tinggi lingkaran)
  //   progress track   240×8px → 120×4dp
  //   wordmark         46dp (cap 67px → 33.5dp, cocok)
  //   tagline          lebar glyph 319px → 159,5dp ⇒ ~11,5dp; ukuran terdekat
  //                    di skala DESIGN.md adalah caption/bodySmall (12dp).
  static const double _mascotCircleSize = 220;
  static const double _mascotImageWidth = 162;
  static const double _mascotImageHeight = 216;

  static const double _progressWidth = 120;
  static const double _progressHeight = 4;

  // Jarak di board diukur antar *glyph* (circle→cap wordmark 30,5dp;
  // wordmark→tagline 32dp; tagline→bar 19dp). Nilai di bawah sudah
  // dikompensasi terhadap leading bawaan font agar glyph jatuh di posisi itu.
  static const double _gapMascotWordmark = 18;
  static const double _gapWordmarkTagline = 17;
  static const double _gapTaglineProgress = 14;

  late final Future<Widget> _nextScreenFuture;
  Timer? _maxSplashTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _nextScreenFuture = _prepareNextScreen();
    _maxSplashTimer = Timer(_maxSplashDuration, _navigateNext);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _mascotCircleSize,
              height: _mascotCircleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.honeyContainer,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/mascot/otter-waving.png',
                  width: _mascotImageWidth,
                  height: _mascotImageHeight,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(height: _gapMascotWordmark),
            Text(
              'Tazk',
              style: TextStyle(
                fontFamily: AppTypography.titleFont,
                fontSize: 46,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: _gapWordmarkTagline),
            Text(
              l10n.splashTagline,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: _gapTaglineProgress),
            _SplashProgress(
              width: _progressWidth,
              height: _progressHeight,
              duration: context.motion(_maxSplashDuration),
              trackColor: colors.border,
              fillColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress tipis 0 → 1 selama splash, murni `Transform.scale` (composite-only)
/// sehingga tidak ada layout/paint per frame.
class _SplashProgress extends StatelessWidget {
  const _SplashProgress({
    required this.width,
    required this.height,
    required this.duration,
    required this.trackColor,
    required this.fillColor,
  });

  final double width;
  final double height;
  final Duration duration;
  final Color trackColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);
    return SizedBox(
      width: width,
      height: height,
      child: TweenAnimationBuilder<double>(
        key: const Key('splash_progress'),
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: AppMotion.easeStandard,
        builder: (context, value, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: radius,
                ),
              ),
              ClipRRect(
                borderRadius: radius,
                child: Transform.scale(
                  scaleX: value,
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: radius,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}