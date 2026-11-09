import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/widgets/calendar_widget_models.dart';
import 'package:tazk/widgets/home_widget_service.dart';
import 'package:tazk/widgets/widget_push_gate.dart';

/// T8.3: the Dart side must push every row (no three-row cap) and a localized
/// empty state, so the list adapter wired in T8.2 never renders a row whose
/// keys were never written.

/// Reports only the tasks/habits providers as mounted; streak and calendar are
/// not under test here.
class _TasksHabitsGate extends WidgetPushGate {
  @override
  Future<Set<String>> mountedProviders() async =>
      {'tasksHabits', 'tasksOnly', 'habitsOnly'};
}

/// Mounts just the calendar widget, for the calendar push.
class _CalendarGate extends WidgetPushGate {
  @override
  Future<Set<String>> mountedProviders() async => {'calendar'};
}

/// Row ids the service actually wrote. The old calendar bug wrote a count
/// larger than the rows it pushed, so tests compare the count against this.
int _writtenRowCount(Map<String, Object?> saved, String prefix) {
  final key = RegExp('^${RegExp.escape(prefix)}_\\d+_id\$');
  return saved.entries
      .where((entry) => key.hasMatch(entry.key))
      .where((entry) => (entry.value! as int) >= 0)
      .length;
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late AppDatabase db;
  late SettingsRepository settings;
  late Map<String, Object?> saved;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    settings = SettingsRepository(db);
    saved = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'saveWidgetData') {
        final args = (call.arguments as Map).cast<String, Object?>();
        saved[args['id'] as String] = args['data'];
      }
      return true;
    });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
  });

  tearDown(() async => db.close());

  Future<int> insertTask(String title, {int? hour}) {
    return db.into(db.tasks).insert(
          TasksCompanion.insert(
            title: title,
            date: _today(),
            time: Value(hour == null ? null : DateTime(2026, 1, 1, hour)),
            priority: TaskPriority.medium,
          ),
        );
  }

  Future<int> insertHabit(String name) {
    return db.into(db.habits).insert(
          HabitsCompanion.insert(
            name: name,
            frequency: HabitFrequency.daily,
          ),
        );
  }

  test('pushes every task row instead of stopping at three', () async {
    for (var i = 0; i < 4; i++) {
      await insertTask('Task $i', hour: 9 + i);
    }

    final service = HomeWidgetService(db, settings, gate: _TasksHabitsGate());
    await service.refreshAll();

    for (var i = 0; i < 4; i++) {
      final hh = (9 + i).toString().padLeft(2, '0');
      expect(saved['tazk_task_${i}_id'], isNotNull, reason: 'row $i id');
      expect(saved['tazk_task_${i}_title'], 'Task $i');
      expect(saved['tazk_task_${i}_time'], '$hh:00');
    }
    expect(saved['tazk_task_count'], 4);
    expect(saved['tazk_task_count'], _writtenRowCount(saved, 'tazk_task'));
    expect(saved['tazk_tasks_empty'], isFalse);
  });

  test('pushes every habit row with its done flag', () async {
    final ids = <int>[];
    for (var i = 0; i < 4; i++) {
      ids.add(await insertHabit('Habit $i'));
    }
    await db.into(db.habitLogs).insert(
          HabitLogsCompanion.insert(
            habitId: ids.first,
            date: _today(),
            isCompleted: const Value(true),
          ),
        );

    final service = HomeWidgetService(db, settings, gate: _TasksHabitsGate());
    await service.refreshAll();

    for (var i = 0; i < 4; i++) {
      expect(saved['tazk_habit_${i}_id'], ids[i]);
      expect(saved['tazk_habit_${i}_title'], 'Habit $i');
      expect(saved['tazk_habit_${i}_done'], i == 0);
    }
    expect(saved['tazk_habit_count'], 4);
    expect(saved['tazk_habits_empty'], isFalse);
  });

  test('an empty day writes count 0 and the Indonesian empty text', () async {
    final service = HomeWidgetService(db, settings, gate: _TasksHabitsGate());
    await service.refreshAll();

    expect(saved['tazk_task_count'], 0);
    expect(saved['tazk_habit_count'], 0);
    expect(saved['tazk_tasks_empty'], isTrue);
    expect(saved['tazk_habits_empty'], isTrue);
    expect(saved['tazk_tasks_empty_text'], 'Belum ada tugas');
    expect(saved['tazk_habits_empty_text'], 'Belum ada habit');
  });

  test('the empty text follows the app language', () async {
    await settings.updateLanguage(AppLanguage.english);

    final service = HomeWidgetService(db, settings, gate: _TasksHabitsGate());
    await service.refreshAll();

    expect(saved['tazk_tasks_empty_text'], 'No tasks yet');
    expect(saved['tazk_habits_empty_text'], 'No habits yet');
  });

  test('the week strip runs Monday to Sunday around the selected date', () {
    final snapshot = CalendarWidgetWeekSnapshot.build(
      selectedDate: DateTime(2026, 11, 4),
      today: DateTime(2026, 11, 4),
      itemDates: {DateTime(2026, 11, 6)},
    );

    expect(snapshot.cells, hasLength(7));
    expect(snapshot.cells.first.date, DateTime(2026, 11, 2));
    expect(snapshot.cells.first.date.weekday, DateTime.monday);
    expect(snapshot.cells.last.date, DateTime(2026, 11, 8));
    expect(snapshot.cells[2].isSelected, isTrue);
    expect(snapshot.cells[4].hasItems, isTrue);
    expect(snapshot.cells[2].hasItems, isFalse);
  });

  test('the calendar widget pushes a seven-day strip, not a month grid', () async {
    await settings.updateLanguage(AppLanguage.indonesian);

    final service = HomeWidgetService(db, settings, gate: _CalendarGate());
    await service.refreshCalendarWidget();

    final today = _today();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    expect(saved['tazk_calendar_day_0_millis'], monday.millisecondsSinceEpoch);
    expect(
      saved['tazk_calendar_day_6_millis'],
      monday.add(const Duration(days: 6)).millisecondsSinceEpoch,
    );
    for (var i = 0; i < 7; i++) {
      expect(saved['tazk_calendar_day_${i}_label'], isNotEmpty, reason: 'cell $i label');
      expect(saved['tazk_calendar_day_${i}_dow'], isNotEmpty, reason: 'cell $i dow');
      expect(saved.containsKey('tazk_calendar_day_${i}_is_today'), isTrue);
      expect(saved.containsKey('tazk_calendar_day_${i}_is_selected'), isTrue);
      expect(saved.containsKey('tazk_calendar_day_${i}_has_items'), isTrue);
    }
    expect(saved['tazk_calendar_day_0_dow'], 'Sen');
    expect(saved['tazk_calendar_day_6_dow'], 'Min');
    expect(saved['tazk_calendar_day_${today.weekday - 1}_is_selected'], isTrue);
    expect(saved['tazk_calendar_day_${today.weekday - 1}_is_today'], isTrue);
    expect(saved.containsKey('tazk_calendar_day_7_label'), isFalse);
  });

  test('the calendar pushes every row and counts only what it wrote', () async {
    final ids = <int>[];
    for (var i = 0; i < 6; i++) {
      ids.add(await insertTask('Task $i', hour: 9 + i));
    }

    final service = HomeWidgetService(db, settings, gate: _CalendarGate());
    await service.refreshCalendarWidget();

    expect(saved['tazk_calendar_task_5_id'], ids[5]);
    expect(saved['tazk_calendar_task_count'], 6);
    expect(
      saved['tazk_calendar_task_count'],
      _writtenRowCount(saved, 'tazk_calendar_task'),
    );
  });

  test('completed tasks stay in the list with a done flag', () async {
    await insertTask('Pending', hour: 9);
    final doneId = await insertTask('Done', hour: 10);
    await (db.update(db.tasks)..where((t) => t.id.equals(doneId)))
        .write(const TasksCompanion(isCompleted: Value(true)));

    final service = HomeWidgetService(db, settings, gate: _TasksHabitsGate());
    await service.refreshAll();

    expect(saved['tazk_task_count'], 2);
    expect(saved['tazk_task_0_title'], 'Pending');
    expect(saved['tazk_task_0_done'], false);
    expect(saved['tazk_task_1_title'], 'Done');
    expect(saved['tazk_task_1_done'], true);
    expect(saved['tazk_tasks_empty'], isFalse);
  });

  test('calendar keeps completed tasks and habits with done flags', () async {
    await insertTask('Task pending', hour: 9);
    final doneTaskId = await insertTask('Task done', hour: 10);
    await (db.update(db.tasks)..where((t) => t.id.equals(doneTaskId)))
        .write(const TasksCompanion(isCompleted: Value(true)));
    final habitId = await insertHabit('Habit done');
    await db.into(db.habitLogs).insert(
          HabitLogsCompanion.insert(
            habitId: habitId,
            date: _today(),
            isCompleted: const Value(true),
          ),
        );

    final service = HomeWidgetService(db, settings, gate: _CalendarGate());
    await service.refreshCalendarWidget();

    expect(saved['tazk_calendar_task_count'], 2);
    expect(saved['tazk_calendar_task_0_title'], 'Task pending');
    expect(saved['tazk_calendar_task_0_done'], false);
    expect(saved['tazk_calendar_task_1_title'], 'Task done');
    expect(saved['tazk_calendar_task_1_done'], true);
    expect(saved['tazk_calendar_habit_count'], 1);
    expect(saved['tazk_calendar_habit_0_title'], 'Habit done');
    expect(saved['tazk_calendar_habit_0_done'], true);
  });
}