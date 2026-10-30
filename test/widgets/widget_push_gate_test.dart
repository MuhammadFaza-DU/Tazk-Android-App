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

  test('mountedProviders returns mounted set and caches it', () async {
    List<String> mockedResult = ['calendar'];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getMountedWidgets');
      return mockedResult;
    });

    final gate = WidgetPushGate();
    expect(await gate.mountedProviders(), {'calendar'});

    // Second call must serve from cache, ignoring the (now changed) mock.
    mockedResult = <String>[];
    expect(await gate.mountedProviders(), {'calendar'});

    gate.resetCache();
    expect(await gate.mountedProviders(), <String>{});
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