import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/pomodoro/pomodoro_controller.dart';

void main() {
  test('availablePomodoroHabits only includes due timed incomplete habits', () {
    final timed = _habit(id: 1, name: 'Baca buku', targetMinutes: 10);
    final noTimer = _habit(
      id: 2,
      name: 'Minum air',
      hasProgress: false,
      targetMinutes: null,
    );
    final completed = _habit(id: 3, name: 'Olahraga', targetMinutes: 20);
    final notDue = _habit(id: 4, name: 'Weekly', targetMinutes: 15);

    final habits = availablePomodoroHabits(
      habits: [timed, noTimer, completed, notDue],
      isDueToday: (habit) => habit.id != notDue.id,
      isCompletedToday: (habitId) => habitId == completed.id,
    );

    expect(habits, [timed]);
  });

  test('selecting a timed habit immediately applies its target duration', () {
    final controller = _controller();
    final habit = _habit(id: 1, name: 'Baca buku', targetMinutes: 10);

    controller.setHabitMode(true);
    controller.selectHabit(habit);

    expect(controller.selectedHabit, habit);
    expect(controller.durationMinutes, 10);
    expect(controller.sessionDuration, const Duration(minutes: 10));
    expect(controller.remaining, const Duration(minutes: 10));
  });

  test('running session blocks changing mode, habit, and duration', () async {
    final controller = _controller();
    final first = _habit(id: 1, name: 'Baca buku', targetMinutes: 10);
    final second = _habit(id: 2, name: 'Menulis', targetMinutes: 15);

    controller.setHabitMode(true);
    controller.selectHabit(first);
    await controller.start(completionTitle: 'Selesai', completionBody: 'Done');

    controller.selectHabit(second);
    controller.setHabitMode(false);
    controller.setDurationMinutes(30);

    expect(controller.selectedHabit, first);
    expect(controller.isHabitMode, isTrue);
    expect(controller.durationMinutes, 10);
  });

  test(
    'pauseForAppExit pauses a running session and preserves remaining time',
    () async {
      var now = DateTime(2026, 7, 12, 10);
      final controller = _controller(now: () => now);

      controller.setDurationMinutes(10);
      await controller.start(
        completionTitle: 'Selesai',
        completionBody: 'Done',
      );
      now = now.add(const Duration(minutes: 3));

      await controller.pauseForAppExit();

      expect(controller.status, PomodoroSessionStatus.paused);
      expect(controller.remaining, const Duration(minutes: 7));
    },
  );

  test(
    'completing a habit session logs progress and completes the habit today',
    () async {
      final completed = <int>[];
      final progress = <({int habitId, int minutes})>[];
      final controller = _controller(
        completeHabitToday: (habitId) async {
          completed.add(habitId);
        },
        logHabitProgress: (habitId, minutes) async {
          progress.add((habitId: habitId, minutes: minutes));
        },
      );
      final habit = _habit(id: 7, name: 'Baca buku', targetMinutes: 10);

      controller.setHabitMode(true);
      controller.selectHabit(habit);
      await controller.start(
        completionTitle: 'Selesai',
        completionBody: 'Done',
      );
      await controller.completeCurrentSession();

      expect(progress, [(habitId: 7, minutes: 10)]);
      expect(completed, [7]);
      expect(controller.status, PomodoroSessionStatus.idle);
      expect(controller.selectedHabit, isNull);
      expect(controller.completionSerial, 1);
      expect(controller.lastCompletedHabitName, 'Baca buku');
    },
  );
}

PomodoroController _controller({
  DateTime Function()? now,
  Future<void> Function(int habitId)? completeHabitToday,
  Future<void> Function(int habitId, int minutes)? logHabitProgress,
}) {
  return PomodoroController(
    now: now,
    scheduleCompletionNotification: (_, _, _) async {},
    cancelCompletionNotification: () async {},
    completeHabitToday: completeHabitToday ?? (_) async {},
    logHabitProgress: logHabitProgress ?? (_, _) async {},
  );
}

Habit _habit({
  required int id,
  required String name,
  bool hasProgress = true,
  int? targetMinutes,
}) {
  return Habit(
    id: id,
    name: name,
    frequency: HabitFrequency.daily,
    hasProgress: hasProgress,
    targetMinutes: targetMinutes,
    isActive: true,
    createdAt: DateTime(2026, 7, 12),
  );
}
