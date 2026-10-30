import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Progress bar: track pill (radius 999) tinggi 8px, fill mengisi `value`
/// (0..1). Perbandingan isi/kosong adalah affordance non-warna.
///
/// Perubahan `value` dianimasikan lewat `Transform.scale(scaleX:)` —
/// composite-only, jadi tidak ada layout/paint ulang per frame. `widthFactor`
/// sengaja tidak dipakai karena memicu layout tiap frame.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.trackColor,
    this.fillColor,
  });

  final double value;
  final Color? trackColor;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clamped = value.clamp(0.0, 1.0).toDouble();
    final track = trackColor ?? colors.primaryContainer;
    final fill = fillColor ?? colors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999), // rounded.pill
      child: SizedBox(
        height: 8, // progress-track height
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: track),
            // `Tween` tanpa `begin` = mount tanpa animasi (langsung di nilai
            // akhir); perubahan `value` sesudahnya beranimasi dari nilai lama.
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: clamped),
              duration: context.motion(AppMotion.base),
              curve: AppMotion.easeStandard,
              builder: (context, animatedValue, _) => Transform.scale(
                key: const Key('progress_fill'),
                scaleX: animatedValue,
                alignment: Alignment.centerLeft,
                child: ColoredBox(color: fill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}