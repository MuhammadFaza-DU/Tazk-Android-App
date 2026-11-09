import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/widgets/widget_push_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.tazk.tazk/app_settings');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('mountedProviders re-queries every call (no stale cache)', () async {
    List<String> mockedResult = ['calendar'];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getMountedWidgets');
      return mockedResult;
    });

    final gate = WidgetPushGate();
    expect(await gate.mountedProviders(), {'calendar'});

    // The mounted set can change when the user adds/removes a widget; every
    // call must observe the current set rather than a pinned first answer.
    // Before the fix an empty first result pinned the whole process, so tasks
    // created later were never pushed.
    mockedResult = ['tasksHabits', 'calendar'];
    expect(await gate.mountedProviders(), {'tasksHabits', 'calendar'});

    mockedResult = ['streak'];
    expect(await gate.mountedProviders(), {'streak'});
  });

  test('mountedProviders treats an empty answer as unknown, not as none', () async {
    // The background isolate has no handler for the app channel, so a tap that
    // updates the database used to resolve to an empty list: the push was then
    // skipped and the widget stayed visually stale until the app was reopened.
    // "No answer" therefore has to mean "push every provider".
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => <String>[]);

    final gate = WidgetPushGate();
    expect(
      await gate.mountedProviders(),
      {'tasksHabits', 'tasksOnly', 'habitsOnly', 'streak', 'calendar'},
    );
  });

  test('mountedProviders falls back to all names on channel error', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'unavailable');
    });

    final gate = WidgetPushGate();
    expect(
      await gate.mountedProviders(),
      {'tasksHabits', 'tasksOnly', 'habitsOnly', 'streak', 'calendar'},
    );
  });
}