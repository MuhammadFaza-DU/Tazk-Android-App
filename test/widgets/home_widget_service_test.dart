import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
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
}