import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Widget rows inflate through RemoteViews, so TalkBack has no layout content to
// infer meaning from. The factory must hand it meaningful descriptions: the
// toggle *action* on the check icon (what the next tap will do) and the item
// title on the row root. This contract reads the Kotlin source because the
// behaviour lives in setContentDescription calls, not in any Dart-visible code.
void main() {
  final factory = File(
    'android/app/src/main/kotlin/com/tazk/tazk/TazkRemoteViewsFactory.kt',
  ).readAsStringSync();
  final strings = File(
    'android/app/src/main/res/values/strings.xml',
  ).readAsStringSync();

  test('check icon exposes a content description', () {
    expect(
      factory,
      matches(RegExp(r'setContentDescription\(\s*R\.id\.item_check\b')),
    );
  });

  test('row root exposes a content description', () {
    expect(
      factory,
      matches(RegExp(r'setContentDescription\(\s*R\.id\.item_root\b')),
    );
  });

  test('check label maps the done state to mark done vs mark undone', () {
    expect(factory, contains('R.string.widget_mark_done'));
    expect(factory, contains('R.string.widget_mark_undone'));
  });

  test('widget_mark_done and widget_mark_undone strings are defined', () {
    expect(strings, contains('name="widget_mark_done"'));
    expect(strings, contains('name="widget_mark_undone"'));
    expect(strings, contains('Tandai selesai'));
    expect(strings, contains('Tandai belum selesai'));
  });
}