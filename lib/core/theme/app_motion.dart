import 'package:flutter/material.dart';

/// Motion tokens — normatif dari `DESIGN.md` section `## Motion`.
///
/// `fast`  150ms  → button press, toggle
/// `base`  220ms  → screen transition, sheet open, progress fill
/// `slow`  320ms  → card expansion
/// `celebration` 750ms (rentang desain 600–900ms) → level up, badge unlock, streak milestone
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration celebration = Duration(milliseconds: 750);

  /// Default + entrance. Setara `cubic-bezier(0.2, 0, 0, 1)`.
  static const Curve easeStandard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Enter and exit. Setara `cubic-bezier(0.4, 0, 0.2, 1)`.
  static const Curve easeGentle = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Overshoot ringan — HANYA untuk momen reward langka (pop centang, unlock).
  /// Jangan dipakai untuk interaksi frekuensi tinggi.
  static const Curve springPop = Cubic(0.34, 1.56, 0.64, 1.0);
}

/// Akses reduced-motion + skala durasi.
///
/// `DESIGN.md`: "Honor MediaQuery.disableAnimations ... No ticker runs while
/// the app is idle." Saat reduced-motion aktif, durasi menjadi nol (perubahan
/// state instan) — bukan menghapus state, hanya menghapus gerak.
extension AppMotionContext on BuildContext {
  bool get reduceMotion => MediaQuery.maybeOf(this)?.disableAnimations ?? false;

  /// `Duration.zero` saat reduced-motion, selain itu `duration` apa adanya.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}