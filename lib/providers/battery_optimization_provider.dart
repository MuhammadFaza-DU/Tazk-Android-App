import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/battery_optimization.dart';

enum BatteryExemptionStatus { unknown, exempt, restricted }

class BatteryExemptionState {
  const BatteryExemptionState({this.status = BatteryExemptionStatus.unknown});

  final BatteryExemptionStatus status;

  bool get isExempt => status == BatteryExemptionStatus.exempt;
}

class BatteryExemptionController extends Notifier<BatteryExemptionState> {
  @override
  BatteryExemptionState build() => const BatteryExemptionState();

  /// Reads the current exemption from Android. Called on screen open and again
  /// after returning from the system UI, which is where the value can change.
  Future<void> check() async {
    final ignoring = await BatteryOptimization.isIgnoring();
    state = BatteryExemptionState(
      status: ignoring
          ? BatteryExemptionStatus.exempt
          : BatteryExemptionStatus.restricted,
    );
  }

  Future<void> requestExemption() async {
    await BatteryOptimization.request();
    await check();
  }

  Future<void> openSystemSettings() async {
    await BatteryOptimization.openSystemSettings();
  }
}

final batteryExemptionProvider =
    NotifierProvider<BatteryExemptionController, BatteryExemptionState>(
  BatteryExemptionController.new,
);
