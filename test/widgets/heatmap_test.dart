import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/heatmap.dart';

Widget harness(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('HabitHeatmap.cellRects', () {
    test('computes 91 rects for 13x7 with cellWidth ~21.35 and gap 3.5', () {
      final rects = HabitHeatmap.cellRects(width: 319, columns: 13, rows: 7);
      expect(rects.length, 91);
      expect(rects[0].width, closeTo(21.35, 0.05));
      expect(rects[0].left, 0);
      expect(rects[0].top, 0);
      expect(rects[0].height, 11.5);
      expect(rects[1].top - rects[0].bottom, closeTo(3.5, 0.001));
    });

    test('is column-major: index 7 is column 1', () {
      final rects = HabitHeatmap.cellRects(width: 319, columns: 13, rows: 7);
      expect(rects[7].left, greaterThan(rects[0].left));
    });
  });

  group('HabitHeatmap.cellColor', () {
    test('maps level to token and clamps out-of-range', () {
      const colors = AppColors.light;
      expect(HabitHeatmap.cellColor(colors, 0), colors.surfaceAlt);
      expect(HabitHeatmap.cellColor(colors, 1), colors.primaryContainer);
      expect(HabitHeatmap.cellColor(colors, 2), colors.primarySoft);
      expect(HabitHeatmap.cellColor(colors, 3), colors.primary);
      expect(HabitHeatmap.cellColor(colors, 9), colors.primary); // clamp
      expect(HabitHeatmap.cellColor(colors, -1), colors.surfaceAlt); // clamp
    });
  });

  group('render', () {
    testWidgets('13x7 heatmap renders at height 101.5 without errors',
        (tester) async {
      final weeks =
          List.generate(13, (col) => List.generate(7, (row) => (col + row) % 4));
      await tester.pumpWidget(
        harness(SizedBox(width: 319, child: HabitHeatmap(weeks: weeks))),
      );
      final size = tester.getSize(find.byType(HabitHeatmap));
      expect(size.height, 101.5);
      expect(size.width, 319);
    });

    testWidgets('legend shows 4 swatches and 2 right-aligned labels',
        (tester) async {
      await tester.pumpWidget(
        harness(const HeatmapLegend(rareLabel: 'jarang', frequentLabel: 'rutin')),
      );
      for (var i = 0; i < 4; i++) {
        expect(find.byKey(Key('heatmap_swatch_$i')), findsOneWidget);
      }
      expect(find.text('jarang'), findsOneWidget);
      expect(find.text('rutin'), findsOneWidget);
      final align = tester.widget<Align>(find.descendant(
        of: find.byType(HeatmapLegend),
        matching: find.byType(Align),
      ));
      expect(align.alignment, Alignment.centerRight);
    });
  });
}