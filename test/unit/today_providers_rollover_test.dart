import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/providers/current_date_provider.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/task_providers.dart';

/// Timer-free stand-in for [CurrentDateNotifier] so the test can drive the day
/// forward deterministically instead of waiting for a real midnight.
class _TestDateNotifier extends CurrentDateNotifier {
  _TestDateNotifier(this._initial);

  final DateTime _initial;

  @override
  DateTime build() => _initial;

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

void main() {
  test('todayTasksProvider recomputes when the current date rolls over',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final day1 = DateTime(2026, 7, 19);
    final day2 = DateTime(2026, 7, 20);

    await db.into(db.tasks).insert(TasksCompanion.insert(
          title: 'Tugas hari ini',
          date: day1,
          priority: TaskPriority.medium,
        ));
    await db.into(db.tasks).insert(TasksCompanion.insert(
          title: 'Tugas besok',
          date: day2,
          priority: TaskPriority.high,
        ));

    final notifier = _TestDateNotifier(day1);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentDateProvider.overrideWith(() => notifier),
      ],
    );
    addTearDown(container.dispose);

    // Keep the stream provider alive across the rollover.
    final sub = container.listen(todayTasksProvider, (_, _) {});
    addTearDown(sub.close);

    final beforeRollover = await container.read(todayTasksProvider.future);
    expect(beforeRollover.map((t) => t.title), ['Tugas hari ini']);

    notifier.setDate(day2);
    // Let the StreamProvider rebuild against the new date.
    await container.read(todayTasksProvider.future);
    await Future<void>.delayed(Duration.zero);

    final afterRollover = await container.read(todayTasksProvider.future);
    expect(afterRollover.map((t) => t.title), ['Tugas besok']);
  });
}
