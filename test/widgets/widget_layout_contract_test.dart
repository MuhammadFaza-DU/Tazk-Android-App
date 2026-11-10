import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Homescreen widgets inflate through app-widget RemoteViews, which supports a
// fixed subset of view classes. Any other tag (e.g. `<View>`, `<Space>`,
// `<SurfaceView>`, or a custom view) makes the launcher fail to inflate the
// layout at runtime — a bug `dart analyze` and a successful build both miss
// and only logcat catches (docs/LESSONS.md L-001). This contract locks the
// supported set, the 48dp row tap target, and the 9sp text floor.
const Set<String> _supportedTags = {
  'FrameLayout',
  'LinearLayout',
  'RelativeLayout',
  'GridLayout',
  'TextView',
  'ImageView',
  'ImageButton',
  'Button',
  'Chronometer',
  'ProgressBar',
  'ListView',
  'GridView',
  'StackView',
  'ViewFlipper',
  'AdapterViewFlipper',
  'AnalogClock',
  'ViewStub',
  'include',
};

const List<String> _rowLayouts = [
  'widget_task_item.xml',
  'widget_habit_item.xml',
];

const String _layoutDir = 'android/app/src/main/res/layout';

List<File> _widgetLayouts() {
  final dir = Directory(_layoutDir);
  return dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.xml'))
      .where((f) => f.uri.pathSegments.last.startsWith('widget_'))
      .toList();
}

final RegExp _tagPattern = RegExp(r'<([A-Za-z][A-Za-z0-9.]*)');

final RegExp _textSizePattern = RegExp(r'android:textSize="(\d+)sp"');

final RegExp _minHeightPattern = RegExp(r'android:minHeight="(\d+)dp"');

/// The first opening tag of a layout (its root element).
String _rootOpeningTag(String xml) {
  final match = _tagPattern.firstMatch(xml);
  if (match == null) {
    return '';
  }
  // Scan to the first unquoted `>` and return the whole root open tag.
  var inQuote = false;
  for (var i = match.start; i < xml.length; i++) {
    final c = xml[i];
    if (c == '"') {
      inQuote = !inQuote;
    } else if (!inQuote && c == '>') {
      return xml.substring(match.start, i + 1);
    }
  }
  return '';
}

int _lineOf(String source, int index) => source.substring(0, index).split('\n').length;

void main() {
  final layouts = _widgetLayouts();

  test('contract covers all eight widget layouts', () {
    final names = layouts.map((f) => f.uri.pathSegments.last).toSet();
    for (final expected in [
      'widget_tasks_habits.xml',
      'widget_tasks_only.xml',
      'widget_habits_only.xml',
      'widget_streak.xml',
      'widget_calendar_tasks_habits.xml',
      'widget_task_item.xml',
      'widget_habit_item.xml',
      'widget_empty_state.xml',
    ]) {
      expect(names, contains(expected), reason: 'widget layout $expected is missing');
    }
  });

  test('every widget layout uses only RemoteViews-supported tags', () {
    final violations = <String>[];
    for (final file in layouts) {
      final xml = file.readAsStringSync().replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
      for (final match in _tagPattern.allMatches(xml)) {
        final tag = match.group(1)!;
        if (!_supportedTags.contains(tag)) {
          violations.add(
            '${file.uri.pathSegments.last}:${_lineOf(xml, match.start)} '
            'uses unsupported <$tag>',
          );
        }
      }
    }
    expect(violations, isEmpty, reason: 'unsupported RemoteViews tags found:\n${violations.join('\n')}');
  });

  test('item rows keep a 48dp tap target on their root', () {
    final violations = <String>[];
    for (final name in _rowLayouts) {
      final xml = File('$_layoutDir/$name').readAsStringSync();
      final root = _rootOpeningTag(xml);
      final minHeight = _minHeightPattern.firstMatch(root);
      if (minHeight == null) {
        violations.add('$name root has no android:minHeight');
      } else {
        final dp = int.parse(minHeight.group(1)!);
        if (dp < 48) {
          violations.add('$name root minHeight is ${dp}dp (below 48dp)');
        }
      }
    }
    expect(violations, isEmpty, reason: 'row tap targets below 48dp:\n${violations.join('\n')}');
  });

  test('no widget text sits below the 9sp floor', () {
    final violations = <String>[];
    for (final file in layouts) {
      final xml = file.readAsStringSync();
      for (final match in _textSizePattern.allMatches(xml)) {
        final sp = int.parse(match.group(1)!);
        if (sp < 9) {
          violations.add(
            '${file.uri.pathSegments.last}:${_lineOf(xml, match.start)} '
            'textSize="${sp}sp"',
          );
        }
      }
    }
    expect(violations, isEmpty, reason: 'text below 9sp found:\n${violations.join('\n')}');
  });
}