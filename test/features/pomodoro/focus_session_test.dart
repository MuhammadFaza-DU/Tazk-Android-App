import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/pomodoro/pomodoro_controller.dart';

void main() {
  test('completing a plain focus session logs focus with no habit', () async {
    final logged = <({int minutes, int? habitId})>[];
    final controller = _controller(logFocusSession: (minutes, habitId) async {
      logged.add((minutes: minutes, habitId: habitId));
    });

    await controller.completeCurrentSession();

    expect(logged, [(minutes: 25, habitId: null)]);
  });

  test('completing a habit session logs focus with the habit id', () async {
    final logged = <({int minutes, int? habitId})>[];
    final controller = _controller(logFocusSession: (minutes, habitId) async {
      logged.add((minutes: minutes, habitId: habitId));
    });
    final habit = _habit(id: 7, name: 'Baca buku', targetMinutes: 30);

    controller.setHabitMode(true);
    controller.selectHabit(habit);
    await controller.completeCurrentSession();

    expect(logged, [(minutes: 30, habitId: 7)]);
  });

  test('cancel does not log a focus session', () async {
    final logged = <({int minutes, int? habitId})>[];
    final controller = _controller(logFocusSession: (minutes, habitId) async {
      logged.add((minutes: minutes, habitId: habitId));
    });

    await controller.cancel();

    expect(logged, isEmpty);
  });
}

PomodoroController _controller({
  Future<void> Function(int minutes, int? habitId)? logFocusSession,
}) {
  return PomodoroController(
    scheduleCompletionNotification: (_, _, _) async {},
    cancelCompletionNotification: () async {},
    logHabitProgress: (_, _) async {},
    completeHabitToday: (_) async {},
    logFocusSession: logFocusSession ?? (_, _) async {},
  );
}

Habit _habit({
  required int id,
  required String name,
  int? targetMinutes,
}) {
  return Habit(
    id: id,
    name: name,
    frequency: HabitFrequency.daily,
    hasProgress: targetMinutes != null,
    targetMinutes: targetMinutes,
    isActive: true,
    createdAt: DateTime(2026, 7, 12),
  );
}