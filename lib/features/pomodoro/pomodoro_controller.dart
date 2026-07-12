import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../providers/notification_provider.dart';
import '../../providers/repository_providers.dart';

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
  );
});

class PomodoroController extends ChangeNotifier {
  PomodoroController({
    required this.scheduleCompletionNotification,
    required this.cancelCompletionNotification,
    required this.logHabitProgress,
    required this.completeHabitToday,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final SchedulePomodoroCompletion scheduleCompletionNotification;
  final Future<void> Function() cancelCompletionNotification;
  final Future<void> Function(int habitId, int minutes) logHabitProgress;
  final Future<void> Function(int habitId) completeHabitToday;
  final DateTime Function() _now;

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
    if (notify) notifyListeners();
  }

  Future<void> start({
    required String completionTitle,
    required String completionBody,
  }) async {
    if (!canStart) return;
    final endTime = _now().add(_sessionDuration);
    _endTime = endTime;
    _remaining = _sessionDuration;
    _status = PomodoroSessionStatus.running;
    notifyListeners();
    _startTicker();
    await scheduleCompletionNotification(
      endTime,
      completionTitle,
      completionBody,
    );
  }

  Future<void> pause() async {
    if (_status != PomodoroSessionStatus.running) return;
    _pauseKeepingRemaining();
    await cancelCompletionNotification();
  }

  Future<void> pauseForAppExit() => pause();

  Future<void> resume({
    required String completionTitle,
    required String completionBody,
  }) async {
    if (_status != PomodoroSessionStatus.paused) return;
    final endTime = _now().add(_remaining);
    _endTime = endTime;
    _status = PomodoroSessionStatus.running;
    notifyListeners();
    _startTicker();
    await scheduleCompletionNotification(
      endTime,
      completionTitle,
      completionBody,
    );
  }

  Future<void> cancel() async {
    _ticker?.cancel();
    _endTime = null;
    _remaining = _sessionDuration;
    _status = PomodoroSessionStatus.idle;
    notifyListeners();
    await cancelCompletionNotification();
  }

  Future<void> completeCurrentSession() async {
    _ticker?.cancel();
    _remaining = Duration.zero;
    _status = PomodoroSessionStatus.idle;
    _endTime = null;

    final habit = _isHabitMode ? _selectedHabit : null;
    _selectedHabit = null;
    _lastCompletedHabitName = habit?.name;
    _completionSerial += 1;
    notifyListeners();

    await cancelCompletionNotification();
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
    notifyListeners();
  }

  void _pauseKeepingRemaining() {
    _ticker?.cancel();
    final endTime = _endTime;
    if (endTime != null) {
      final remaining = endTime.difference(_now());
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    }
    _endTime = null;
    _status = PomodoroSessionStatus.paused;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
