import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_colors.dart';

/// Satu batang pada [BarChart]: label sumbu (mis. inisial hari), nilai, dan
/// flag `highlight` untuk batang "hari ini" (warna honey).
class BarDatum {
  const BarDatum({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final int value;
  final bool highlight;
}

/// Bar chart statis (tanpa animasi/ticker) untuk XP net per hari.
///
/// Batang positif digambar dari alas ke atas; nilai 0 dan negatif diwakili
/// "stub" setinggi 6px berwarna `surfaceAlt` (batang negatif akan menyesatkan
/// tinggi, tidak dibalik arah). Label sumbu adaptif untuk banyak batang.
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.data,
    this.plotHeight = 88,
    this.barGap = 10,
  });

  final List<BarDatum> data;
  final double plotHeight;
  final double barGap;

  /// Gap tetap [preferredGap] untuk chart renggang (≤ 10 batang, board 7 =
  /// 10 dp). Chart padat (Bulan 30) menyusutkan gap supaya batang tidak jadi
  /// garis rambut; gap tidak turun di bawah 2 dp agar batang & celah terpisah.
  static double resolveBarGap(double width, int count, double preferredGap) {
    if (count <= 10) return preferredGap;
    final scaled = width / (count * 3.2);
    return math.max(2.0, math.min(preferredGap, scaled));
  }

  /// Geometri batang untuk lebar tertentu. Dipakai painter DAN test.
  @visibleForTesting
  static List<Rect> barRects(
    double width,
    List<BarDatum> data, {
    double barGap = 10,
    double plotHeight = 88,
  }) {
    final n = data.length;
    if (n == 0) return const [];
    final gap = resolveBarGap(width, n, barGap);
    final slotWidth = (width - gap * (n - 1)) / n;
    var maxValue = 1;
    for (final d in data) {
      maxValue = math.max(maxValue, d.value.abs());
    }
    return List<Rect>.generate(n, (i) {
      final d = data[i];
      final left = i * (slotWidth + gap);
      final height =
          d.value > 0 ? math.max(6.0, plotHeight * d.value / maxValue) : 6.0;
      final top = plotHeight - height;
      return Rect.fromLTWH(left, top, slotWidth, height);
    });
  }

  // Label adaptif (keputusan PM): tampilkan semua bila tiap slot ≥ 12dp (1–2
  // karakter muat); bila lebih sempit, tampilkan setiap ((n + 6) ~/ 7)-th supaya
  // 30 batang (bulan) tidak menumpuk. Slot yang disembunyikan dirender tanpa `Text`.
  static List<String> _labels(int n, List<BarDatum> data, double slotWidth) {
    if (slotWidth >= 12) {
      return [for (final d in data) d.label];
    }
    final step = (n + 6) ~/ 7;
    return [
      for (var i = 0; i < n; i++) (i % step == 0) ? data[i].label : '',
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    final theme = Theme.of(context);
    final n = data.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = BarChart.resolveBarGap(width, n, barGap);
        final rects =
            BarChart.barRects(width, data, barGap: barGap, plotHeight: plotHeight);
        final slotWidth = (width - gap * (n - 1)) / n;
        final labels = _labels(n, data, slotWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: plotHeight,
              child: CustomPaint(
                painter: _BarPainter(rects: rects, data: data, colors: colors),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < n; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  SizedBox(
                    width: slotWidth,
                    child: labels[i].isEmpty
                        ? const SizedBox.shrink()
                        : OverflowBox(
                            minWidth: 0,
                            maxWidth: 64,
                            fit: OverflowBoxFit.deferToChild,
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: colors.inkMuted),
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.rects,
    required this.data,
    required this.colors,
  });

  final List<Rect> rects;
  final List<BarDatum> data;
  final AppColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    for (var i = 0; i < rects.length; i++) {
      final rect = rects[i];
      final d = data[i];
      final isStub = d.value <= 0;
      paint.color = isStub
          ? colors.surfaceAlt
          : (d.highlight ? colors.honey : colors.primaryContainer);
      final radius =
          math.min(7.0, math.min(rect.width / 2, rect.height / 2));
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.colors != colors ||
      !listEquals(oldDelegate.rects, rects);
}