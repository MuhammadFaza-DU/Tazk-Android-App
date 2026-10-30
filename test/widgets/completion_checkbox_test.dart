import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/widgets/completion_checkbox.dart';

void main() {
  testWidgets('calls onComplete immediately without the 380ms delay', (
    tester,
  ) async {
    var called = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompletionCheckbox(
            value: false,
            onComplete: () async {
              called++;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    // One frame + microtask flush. With the old 380ms delay, `called` is
    // still 0 here; with the fix it is 1.
    await tester.pump();

    expect(called, 1);

    // Flush the fire-and-forget animation timers so the test ends cleanly.
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('uncheck calls onUncomplete', (tester) async {
    var called = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompletionCheckbox(
            value: true,
            onUncomplete: () async {
              called++;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(called, 1);
  });
}