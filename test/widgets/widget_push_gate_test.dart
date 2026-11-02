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
    mockedResult = <String>[];
    expect(await gate.mountedProviders(), <String>{});

    mockedResult = ['tasksHabits', 'calendar'];
    expect(await gate.mountedProviders(), {'tasksHabits', 'calendar'});
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