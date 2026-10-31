import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/bar_chart.dart';

Widget harness(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('BarChart.barRects', () {
    test('lays out 7 bars across 319 width with 10 gap', () {
      final data = List.generate(7, (i) => BarDatum(label: 'L$i', value: 1));
      final rects = BarChart.barRects(319, data, barGap: 10, plotHeight: 88);
      expect(rects.length, 7);
      for (final r in rects) {
        expect(r.width, closeTo(37.0, 0.05));
      }
      expect(rects[1].left - rects[0].right, closeTo(10, 0.001));
    });

    test('bottom is plot height; max value fills; zero is 6 stub', () {
      final data = [
        const BarDatum(label: 'a', value: 0),
        const BarDatum(label: 'b', value: 10),
        const BarDatum(label: 'c', value: 5),
      ];
      final rects = BarChart.barRects(200, data);
      for (final r in rects) {
        expect(r.bottom, 88);
      }
      expect(rects[1].height, 88); // max value -> full height
      expect(rects[0].height, 6); // zero -> 6 stub
      expect(rects[2].height, closeTo(44, 0.001)); // 88 * 5/10
    });

    test('negative value renders as 6 stub at bottom', () {
      final data = [
        const BarDatum(label: 'a', value: -30),
        const BarDatum(label: 'b', value: 10),
      ];
      final rects = BarChart.barRects(200, data);
      expect(rects[0].height, 6);
      expect(rects[0].top, 82);
    });

    test('single datum spans full width without divide by zero', () {
      final data = [const BarDatum(label: 'a', value: 3)];
      final rects = BarChart.barRects(250, data, barGap: 10, plotHeight: 88);
      expect(rects.length, 1);
      expect(rects[0].left, 0);
      expect(rects[0].width, 250);
    });
  });

  group('BarChart render', () {
    testWidgets('renders chart at 88 height with 7 labels', (tester) async {
      final data = ['S', 'S', 'R', 'K', 'J', 'S', 'M']
          .map((l) => BarDatum(label: l, value: 1))
          .toList();
      await tester.pumpWidget(
        harness(SizedBox(width: 319, child: BarChart(data: data))),
      );
      final paint = find.descendant(
        of: find.byType(BarChart),
        matching: find.byType(CustomPaint),
      );
      expect(tester.getSize(paint).height, 88);
      final labels = find.descendant(
        of: find.byType(BarChart),
        matching: find.byType(Text),
      );
      expect(labels, findsNWidgets(7));
    });

    testWidgets('narrow chart with 30 bars does not overflow and hides labels',
        (tester) async {
      final data =
          List.generate(30, (i) => BarDatum(label: '$i', value: 1));
      await tester.pumpWidget(
        harness(SizedBox(width: 350, child: BarChart(data: data))),
      );
      expect(tester.takeException(), isNull);
      final labels = find.descendant(
        of: find.byType(BarChart),
        matching: find.byType(Text),
      );
      expect(tester.widgetList<Text>(labels).length, lessThan(30));
    });
  });
}