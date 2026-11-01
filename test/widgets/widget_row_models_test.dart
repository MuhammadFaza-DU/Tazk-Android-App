import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/widgets/widget_row_models.dart';

/// These models decide what a widget row shows, and the Kotlin factory reads
/// the same SharedPreferences back. The tests pin the two things the old
/// fixed-three-row layout could not do: no cap, and progress only when the
/// habit actually tracks it.
void main() {
  group('taskWidgetRows', () {
    test('memetakan 5 task jadi 5 baris (tanpa batas 3)', () {
      final tasks = List.generate(
        5,
        (i) => _task(id: i + 1, title: 'Task ${i + 1}'),
      );

      final rows = taskWidgetRows(tasks);

      expect(rows, hasLength(5));
      expect(rows.map((row) => row.id), [1, 2, 3, 4, 5]);
      expect(rows.map((row) => row.title), [
        'Task 1',
        'Task 2',
        'Task 3',
        'Task 4',
        'Task 5',
      ]);
    });

    test('subtitle jam 24 jam dua digit, kosong saat tanpa jam', () {
      final rows = taskWidgetRows([
        _task(id: 1, title: 'Pagi', time: DateTime(2026, 11, 2, 5, 7)),
        _task(id: 2, title: 'Siang', time: DateTime(2026, 11, 2, 13, 0)),
        _task(id: 3, title: 'Tanpa jam'),
      ]);

      expect(rows.map((row) => row.subtitle), ['05:07', '13:00', '']);
    });

    test('done mengikuti isCompleted task', () {
      final rows = taskWidgetRows([
        _task(id: 1, title: 'Selesai', completed: true),
        _task(id: 2, title: 'Belum'),
      ]);

      expect(rows.map((row) => row.done), [true, false]);
    });
  });

  group('habitWidgetRows', () {
    test('memetakan 5 habit jadi 5 baris (tanpa batas 3)', () {
      final habits = List.generate(
        5,
        (i) => _habit(id: i + 1, name: 'Habit ${i + 1}'),
      );

      final rows = habitWidgetRows(habits, const {});

      expect(rows, hasLength(5));
      expect(rows.map((row) => row.id), [1, 2, 3, 4, 5]);
      expect(rows.map((row) => row.title), [
        'Habit 1',
        'Habit 2',
        'Habit 3',
        'Habit 4',
        'Habit 5',
      ]);
    });

    test('subtitle progress/target hanya untuk habit berprogress', () {
      final rows = habitWidgetRows(
        [
          _habit(id: 1, name: 'Baca', hasProgress: true, targetMinutes: 30),
          _habit(id: 2, name: 'Minum air'),
        ],
        {1: _log(habitId: 1, progressMinutes: 12)},
      );

      expect(rows.map((row) => row.subtitle), ['12/30', '']);
    });

    test('log yang tidak ada berarti progress 0 dan belum selesai', () {
      final rows = habitWidgetRows(
        [_habit(id: 7, name: 'Jalan', hasProgress: true, targetMinutes: 20)],
        const {},
      );

      expect(rows.single.subtitle, '0/20');
      expect(rows.single.done, isFalse);
    });

    test('done mengikuti isCompleted log per habit', () {
      final rows = habitWidgetRows(
        [
          _habit(id: 1, name: 'Selesai'),
          _habit(id: 2, name: 'Belum'),
        ],
        {
          1: _log(habitId: 1, completed: true),
          2: _log(habitId: 2, completed: false),
        },
      );

      expect(rows.map((row) => row.done), [true, false]);
    });
  });
}

Task _task({
  required int id,
  required String title,
  DateTime? time,
  bool completed = false,
}) {
  return Task(
    id: id,
    title: title,
    date: DateTime(2026, 11, 2),
    time: time,
    priority: TaskPriority.medium,
    isCompleted: completed,
    autoCompleteSubtasks: true,
    createdAt: DateTime(2026),
  );
}

Habit _habit({
  required int id,
  required String name,
  bool hasProgress = false,
  int? targetMinutes,
}) {
  return Habit(
    id: id,
    name: name,
    frequency: HabitFrequency.daily,
    hasProgress: hasProgress,
    targetMinutes: targetMinutes,
    isActive: true,
    createdAt: DateTime(2026),
  );
}

HabitLog _log({
  required int habitId,
  int progressMinutes = 0,
  bool completed = false,
}) {
  return HabitLog(
    id: habitId,
    habitId: habitId,
    date: DateTime(2026, 11, 2),
    isCompleted: completed,
    progressMinutes: progressMinutes,
  );
}