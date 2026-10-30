import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Progress bar: track pill (radius 999) tinggi 8px, fill mengisi `value`
/// (0..1). Perbandingan isi/kosong adalah affordance non-warna.
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
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: ColoredBox(color: fill),
            ),
          ],
        ),
      ),
    );
  }
}