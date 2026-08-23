import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_provider.dart';

enum ExactAlarmStatus { unknown, allowed, denied }

class ExactAlarmState {
  const ExactAlarmState({
    this.status = ExactAlarmStatus.unknown,
    this.dismissed = false,
  });

  final ExactAlarmStatus status;
  final bool dismissed;

  ExactAlarmState copyWith({
    ExactAlarmStatus? status,
    bool? dismissed,
  }) {
    return ExactAlarmState(
      status: status ?? this.status,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}

class ExactAlarmController extends Notifier<ExactAlarmState> {
  @override
  ExactAlarmState build() => const ExactAlarmState();

  Future<void> check() async {
    final allowed =
        await ref.read(notificationServiceProvider).canScheduleExactAlarms();
    state = state.copyWith(
      status: allowed ? ExactAlarmStatus.allowed : ExactAlarmStatus.denied,
    );
  }

  void dismiss() => state = state.copyWith(dismissed: true);
}

final exactAlarmProvider =
    NotifierProvider<ExactAlarmController, ExactAlarmState>(
  ExactAlarmController.new,
);
