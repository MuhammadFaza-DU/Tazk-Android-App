import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../providers/notification_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/stats_repository_provider.dart';

enum PomodoroSessionStatus { idle, running, paused }

typedef SchedulePomodoroCompletion =
    Future<void> Function(DateTime endTime, String title, String body);

List<Habit> availablePomodoroHabits({
  required Iterable<Habit> habits,
  required bool Function(Habit habit) isDueToday,
  required bool Function(int habitId) isCompletedToday,
}) {
  return habits
      .where(
        (habit) =>
            habit.hasProgress &&
            (habit.targetMinutes ?? 0) > 0 &&
            isDueToday(habit) &&
            !isCompletedToday(habit.id),
      )
      .toList();
}

final pomodoroControllerProvider = ChangeNotifierProvider<PomodoroController>((
  ref,
) {
  final habitRepository = ref.watch(habitRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);

  return PomodoroController(
    scheduleCompletionNotification: (endTime, title, body) {
      return notifications.scheduleFocusSessionComplete(
        title: title,
        body: body,
        scheduledDate: endTime,
      );
    },
    cancelCompletionNotification: notifications.cancelFocusSessionComplete,
    logHabitProgress: habitRepository.logProgress,
    completeHabitToday: habitRepository.completeHabitToday,
    logFocusSession: ref.watch(statsRepositoryProvider).logFocusSession,
    isFocusSessionNotificationEnabled: () =>
        ref.read(appSettingsProvider).valueOrNull?.notifyFocusSession ?? true,
  );
});

class PomodoroController extends ChangeNotifier {
  PomodoroController({
    required this.scheduleCompletionNotification,
    required this.cancelCompletionNotification,
    required this.logHabitProgress,
    required this.completeHabitToday,
    required this.logFocusSession,
    DateTime Function()? now,
    this.isFocusSessionNotificationEnabled,
  }) : _now = now ?? DateTime.now;

  final SchedulePomodoroCompletion scheduleCompletionNotification;
  final Future<void> Function() cancelCompletionNotification;
  final Future<void> Function(int habitId, int minutes) logHabitProgress;
  final Future<void> Function(int habitId) completeHabitToday;
  final Future<void> Function(int minutes, int? habitId) logFocusSession;

  /// Gate channel notifikasi ke-5 (`AppSetting.notifyFocusSession`). `null`
  /// berarti channel aktif — perilaku sebelum T9.2.
  final bool Function()? isFocusSessionNotificationEnabled;
  final DateTime Function() _now;

  bool _shouldNotifyFocusSession() =>
      isFocusSessionNotificationEnabled?.call() ?? true;

  bool _isHabitMode = false;
  Habit? _selectedHabit;
  PomodoroSessionStatus _status = PomodoroSessionStatus.idle;
  int _durationMinutes = 25;
  Duration _sessionDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  DateTime? _endTime;
  Timer? _ticker;
  int _completionSerial = 0;
  String? _lastCompletedHabitName;
  String _completionTitle = '';
  String _completionBody = '';
  final ValueNotifier<Duration> remainingNotifier =
      ValueNotifier(const Duration(minutes: 25));

  bool get isHabitMode => _isHabitMode;
  Habit? get selectedHabit => _selectedHabit;
  PomodoroSessionStatus get status => _status;
  int get durationMinutes => _durationMinutes;
  Duration get sessionDuration => _sessionDuration;
  Duration get remaining => _remaining;
  int get completionSerial => _completionSerial;
  String? get lastCompletedHabitName => _lastCompletedHabitName;
  bool get isEditable => _status == PomodoroSessionStatus.idle;

  bool get canStart {
    if (_durationMinutes <= 0) return false;
    if (_isHabitMode && _selectedHabit == null) return false;
    return true;
  }

  void setHabitMode(bool value) {
    if (!isEditable) return;
    if (_isHabitMode == value) return;
    _isHabitMode = value;
    if (!value) {
      _selectedHabit = null;
      setDurationMinutes(25, notify: false);
    }
    notifyListeners();
  }

  void selectHabit(Habit? habit) {
    if (!isEditable) return;
    _selectedHabit = habit;
    if (habit?.targetMinutes != null) {
      setDurationMinutes(habit!.targetMinutes!, notify: false);
    }
    notifyListeners();
  }

  void clearSelectedHabitIfUnavailable(List<Habit> availableHabits) {
    if (!isEditable || _selectedHabit == null) return;
    final selectedId = _selectedHabit!.id;
    final stillAvailable = availableHabits.any(
      (habit) => habit.id == selectedId,
    );
    if (!stillAvailable) {
      _selectedHabit = null;
      notifyListeners();
    }
  }

  void setDurationMinutes(int minutes, {bool notify = true}) {
    if (!isEditable || minutes <= 0) return;
    _durationMinutes = minutes;
    _sessionDuration = Duration(minutes: minutes);
    _remaining = _sessionDuration;
    remainingNotifier.value = _remaining;
    if (notify) notifyListeners();
  }

  Future<void> start({
    required String completionTitle,
    required String completionBody,
  }) async {
    if (!canStart) return;
    _completionTitle = completionTitle;
    _completionBody = completionBody;
    final endTime = _now().add(_sessionDuration);
    _endTime = endTime;
    _remaining = _sessionDuration;
    remainingNotifier.value = _remaining;
    _status = PomodoroSessionStatus.running;
    notifyListeners();
    _startTicker();
    if (_shouldNotifyFocusSession()) {
      await scheduleCompletionNotification(
        endTime,
        completionTitle,
        completionBody,
      );
    }
  }

  Future<void> pause() async {
    if (_status != PomodoroSessionStatus.running) return;
    _pauseKeepingRemaining();
    await cancelCompletionNotification();
  }

  Future<void> resume({
    required String completionTitle,
    required String completionBody,
  }) async {
    if (_status != PomodoroSessionStatus.paused) return;
    _completionTitle = completionTitle;
    _completionBody = completionBody;
    final endTime = _now().add(_remaining);
    _endTime = endTime;
    remainingNotifier.value = _remaining;
    _status = PomodoroSessionStatus.running;
    notifyListeners();
    _startTicker();
    if (_shouldNotifyFocusSession()) {
      await scheduleCompletionNotification(
        endTime,
        completionTitle,
        completionBody,
      );
    }
  }

  /// Reacts to the "Sesi fokus" toggle changing. Off cancels any scheduled
  /// completion; on re-arms the completion for a running session's end time.
  Future<void> onFocusSessionNotificationPrefChanged(bool enabled) async {
    if (!enabled) {
      await cancelCompletionNotification();
      return;
    }
    if (_status != PomodoroSessionStatus.running) return;
    final endTime = _endTime;
    if (endTime == null) return;
    await scheduleCompletionNotification(
      endTime,
      _completionTitle,
      _completionBody,
    );
  }

  Future<void> cancel() async {
    _ticker?.cancel();
    _endTime = null;
    _remaining = _sessionDuration;
    remainingNotifier.value = _remaining;
    _status = PomodoroSessionStatus.idle;
    notifyListeners();
    await cancelCompletionNotification();
  }

  Future<void> completeCurrentSession() async {
    _ticker?.cancel();
    _remaining = Duration.zero;
    remainingNotifier.value = _remaining;
    _status = PomodoroSessionStatus.idle;
    _endTime = null;

    final habit = _isHabitMode ? _selectedHabit : null;
    _selectedHabit = null;
    _lastCompletedHabitName = habit?.name;
    _completionSerial += 1;
    notifyListeners();

    await cancelCompletionNotification();
    await logFocusSession(_sessionDuration.inMinutes, habit?.id);
    if (habit != null) {
      await logHabitProgress(habit.id, _sessionDuration.inMinutes);
      await completeHabitToday(habit.id);
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final endTime = _endTime;
    if (endTime == null) return;
    final remaining = endTime.difference(_now());
    if (remaining <= Duration.zero) {
      completeCurrentSession();
      return;
    }
    _remaining = remaining;
    remainingNotifier.value = remaining;
  }

  void _pauseKeepingRemaining() {
    _ticker?.cancel();
    final endTime = _endTime;
    if (endTime != null) {
      final remaining = endTime.difference(_now());
      _remaining = remaining.isNegative ? Duration.zero : remaining;
      remainingNotifier.value = _remaining;
    }
    _endTime = null;
    _status = PomodoroSessionStatus.paused;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    remainingNotifier.dispose();
    super.dispose();
  }
}
