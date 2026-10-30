import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Transisi layar bertema: `base` (220ms), `easeStandard`, fade + slide 2%
/// vertikal. Saat reduced-motion aktif, layar muncul instan (tanpa gerak).
///
/// Pakai `CurveTween`/`Tween` (bukan `CurvedAnimation`) agar tidak perlu
/// dispose — `CurvedAnimation` yang dibuat di `transitionsBuilder` akan
/// mendaftarkan listener tiap build.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: AppMotion.base,
          reverseTransitionDuration: AppMotion.base,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
              return child;
            }
            final curved = animation.drive(
              CurveTween(curve: AppMotion.easeStandard),
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: curved.drive(
                  Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}