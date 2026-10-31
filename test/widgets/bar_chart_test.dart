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

  group('BarChart.barRects adaptive slot', () {
    test('slot width by bar count (7/12/30) at width 316', () {
      final d7 = List.generate(7, (_) => const BarDatum(label: 'x', value: 1));
      final d12 = List.generate(12, (_) => const BarDatum(label: 'x', value: 1));
      final d30 = List.generate(30, (_) => const BarDatum(label: 'x', value: 1));

      final r7 = BarChart.barRects(316, d7, barGap: 10);
      expect(r7.first.width, closeTo(36.57, 0.05));

      final r12 = BarChart.barRects(316, d12, barGap: 10);
      expect(r12.first.width, closeTo(18.79, 0.05));

      final r30 = BarChart.barRects(316, d30, barGap: 10);
      expect(r30.first.width, greaterThanOrEqualTo(6.0));
    });

    test('gap between bars matches resolveBarGap (n=30)', () {
      final d30 = List.generate(30, (_) => const BarDatum(label: 'x', value: 1));
      final rects = BarChart.barRects(316, d30, barGap: 10);
      final gap = BarChart.resolveBarGap(316, 30, 10);
      expect(rects[1].left - rects[0].right, closeTo(gap, 0.001));
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

  group('BarChart.resolveBarGap', () {
    test('preferred for sparse, shrinks for dense, floor at 2', () {
      expect(BarChart.resolveBarGap(316, 7, 10), 10);
      expect(BarChart.resolveBarGap(316, 12, 10), closeTo(8.23, 0.05));
      expect(BarChart.resolveBarGap(316, 30, 10), closeTo(3.29, 0.05));
      expect(BarChart.resolveBarGap(100, 60, 10), 2.0);
    });
  });

  group('BarChart label alignment', () {
    testWidgets('7 labels centered on their bars', (tester) async {
      final data = List.generate(
        7,
        (i) => BarDatum(
          label: String.fromCharCode('A'.codeUnitAt(0) + i),
          value: i + 1,
        ),
      );
      const width = 319.0;
      await tester.pumpWidget(
        harness(SizedBox(width: width, child: BarChart(data: data))),
      );
      final rects = BarChart.barRects(width, data, barGap: 10, plotHeight: 88);
      final chartLeft = tester.getTopLeft(find.byType(BarChart)).dx;
      for (var i = 0; i < 7; i++) {
        final labelX = tester.getCenter(find.text(data[i].label)).dx - chartLeft;
        final barX = rects[i].center.dx;
        expect((labelX - barX).abs(), lessThan(0.6),
            reason: 'label "${data[i].label}" (i=$i) misaligned');
      }
    });

    testWidgets('renders all 12 month labels', (tester) async {
      final months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      final data = months.map((l) => BarDatum(label: l, value: 1)).toList();
      await tester.pumpWidget(
        harness(SizedBox(width: 316, child: BarChart(data: data))),
      );
      final labels = find.descendant(
        of: find.byType(BarChart),
        matching: find.byType(Text),
      );
      expect(labels, findsNWidgets(12));
    });

    testWidgets('30 bars show 6 labels at 0,5,10,15,20,25 with no overflow',
        (tester) async {
      final data = List.generate(30, (i) => BarDatum(label: '$i', value: 1));
      await tester.pumpWidget(
        harness(SizedBox(width: 316, child: BarChart(data: data))),
      );
      expect(tester.takeException(), isNull);
      final labels = find.descendant(
        of: find.byType(BarChart),
        matching: find.byType(Text),
      );
      final texts = tester.widgetList<Text>(labels).map((t) => t.data).toList();
      expect(texts, ['0', '5', '10', '15', '20', '25']);
    });

    testWidgets('no scheduled frame after settle (no ticker)', (tester) async {
      final data = List.generate(7, (i) => BarDatum(label: '$i', value: 1));
      await tester.pumpWidget(
        harness(SizedBox(width: 319, child: BarChart(data: data))),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}