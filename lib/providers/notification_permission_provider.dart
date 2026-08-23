import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_provider.dart';

enum NotificationPermissionStatus { unknown, granted, denied }

class NotificationPermissionState {
  const NotificationPermissionState({
    this.status = NotificationPermissionStatus.unknown,
    this.dismissed = false,
  });

  final NotificationPermissionStatus status;
  final bool dismissed;

  NotificationPermissionState copyWith({
    NotificationPermissionStatus? status,
    bool? dismissed,
  }) {
    return NotificationPermissionState(
      status: status ?? this.status,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}

/// Tracks whether the OS currently allows notifications so the Home banner and
/// the passive Settings indicator can reflect it. [dismissed] is session-only:
/// the banner may come back on the next app open until permission is granted.
class NotificationPermissionController
    extends Notifier<NotificationPermissionState> {
  @override
  NotificationPermissionState build() =>
      const NotificationPermissionState();

  /// Re-queries the OS. Called after the splash request, on resume, and when
  /// the user returns from the system settings page.
  Future<void> check() async {
    final enabled =
        await ref.read(notificationServiceProvider).areNotificationsEnabled();
    state = state.copyWith(
      status: enabled
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied,
    );
  }

  void applyRequestResult(bool granted) {
    state = state.copyWith(
      status: granted
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied,
    );
  }

  void dismiss() => state = state.copyWith(dismissed: true);
}

final notificationPermissionProvider = NotifierProvider<
    NotificationPermissionController, NotificationPermissionState>(
  NotificationPermissionController.new,
);
