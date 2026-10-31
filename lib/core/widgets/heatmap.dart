import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Heatmap kebiasaan (mirip GitHub contribution), statis tanpa animasi/ticker.
///
/// Data `[kolom][baris]`; baris 0 = Senin. Nilai per sel adalah level 0..3.
class HabitHeatmap extends StatelessWidget {
  const HabitHeatmap({
    super.key,
    required this.weeks,
    this.cellHeight = 11.5,
    this.gap = 3.5,
  });

  /// [kolom][baris]; baris 0 = Senin. Nilai level 0..3.
  final List<List<int>> weeks;
  final double cellHeight;
  final double gap;

  /// Geometri sel: `columns * rows` rect berurutan kolom-mayor
  /// (index = `col * rows + row`), origin `(0,0)`.
  @visibleForTesting
  static List<Rect> cellRects({
    required double width,
    required int columns,
    required int rows,
    double cellHeight = 11.5,
    double gap = 3.5,
  }) {
    final cellWidth = (width - gap * (columns - 1)) / columns;
    return [
      for (var col = 0; col < columns; col++)
        for (var row = 0; row < rows; row++)
          Rect.fromLTWH(
            col * (cellWidth + gap),
            row * (cellHeight + gap),
            cellWidth,
            cellHeight,
          ),
    ];
  }

  /// Pemetaan level → warna (0..3), level di luar di-clamp.
  @visibleForTesting
  static Color cellColor(AppColors colors, int level) {
    final clamped = level < 0 ? 0 : (level > 3 ? 3 : level);
    switch (clamped) {
      case 0:
        return colors.surfaceAlt;
      case 1:
        return colors.primaryContainer;
      case 2:
        return colors.primarySoft;
      default:
        return colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final columns = weeks.length;
    if (columns == 0 || weeks.first.isEmpty) return const SizedBox.shrink();
    final rows = weeks.first.length;
    final height = rows * cellHeight + (rows - 1) * gap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Geometri dihitung SEKALI lewat `cellRects` (sumber kebenaran yang
        // sama dengan test), lalu diteruskan ke painter supaya tidak bisa
        // diverge.
        final rects = HabitHeatmap.cellRects(
          width: width,
          columns: columns,
          rows: rows,
          cellHeight: cellHeight,
          gap: gap,
        );
        return CustomPaint(
          size: Size(width, height),
          painter: _HeatmapPainter(weeks: weeks, colors: colors, rects: rects),
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.weeks,
    required this.colors,
    required this.rects,
  });

  final List<List<int>> weeks;
  final AppColors colors;
  final List<Rect> rects;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = weeks.isEmpty ? 0 : weeks.first.length;
    if (rows == 0) return;
    final paint = Paint()..isAntiAlias = true;
    for (var i = 0; i < rects.length; i++) {
      final col = i ~/ rows;
      final row = i % rows;
      paint.color = HabitHeatmap.cellColor(colors, weeks[col][row]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rects[i], const Radius.circular(3)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      oldDelegate.weeks != weeks ||
      oldDelegate.colors != colors ||
      !listEquals(oldDelegate.rects, rects);
}

/// Legenda heatmap: label "jarang"/"rutin" + 4 swatch 11×11 radius 3, rata kanan.
class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({
    super.key,
    required this.rareLabel,
    required this.frequentLabel,
  });

  final String rareLabel;
  final String frequentLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted);
    final levels = [
      colors.surfaceAlt,
      colors.primaryContainer,
      colors.primarySoft,
      colors.primary,
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              rareLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          const SizedBox(width: 6),
          for (var i = 0; i < 4; i++) ...[
            Container(
              key: Key('heatmap_swatch_$i'),
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: levels[i],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            if (i < 3) const SizedBox(width: 5),
          ],
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              frequentLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}