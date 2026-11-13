import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/widgets/battery_optimization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.tazk.tazk/app_settings');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('isIgnoring reflects the platform exemption state', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isIgnoringBatteryOptimizations') return false;
      return null;
    });

    expect(await BatteryOptimization.isIgnoring(), isFalse);
  });

  test('isIgnoring returns true when the platform allows the app', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isIgnoringBatteryOptimizations') return true;
      return null;
    });

    expect(await BatteryOptimization.isIgnoring(), isTrue);
  });

  test('request asks Android for the exemption dialog', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return null;
    });

    await BatteryOptimization.request();

    expect(calls, contains('requestIgnoreBatteryOptimizations'));
  });

  test('openSystemSettings opens the battery-optimisation list', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return null;
    });

    await BatteryOptimization.openSystemSettings();

    expect(calls, contains('openBatteryOptimizationSettings'));
  });
}