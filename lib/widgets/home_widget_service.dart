import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../core/utils/habit_due.dart' as habit_due;
import '../data/database/database.dart';
import '../data/models/enums.dart';
import '../data/repositories/settings_repository.dart';
import '../l10n/app_localizations.dart';
import 'calendar_widget_models.dart';
import 'widget_push_gate.dart';
import 'widget_row_models.dart';

/// Pushes today's tasks/habits and current streak into Android homescreen widgets.
class HomeWidgetService {
  HomeWidgetService(this._db, this._settings, {WidgetPushGate? gate})
      : _gate = gate ?? WidgetPushGate();

  final AppDatabase _db;
  final SettingsRepository _settings;
  final WidgetPushGate _gate;

  /// Number of times [_pushAll] has actually run. Incremented at the start of
  /// every real push, so it counts pushes — not callers of [refreshAll].
  @visibleForTesting
  int debugPushCount = 0;

  static const maxRows = 100;
  static const calendarMaxRows = 100;

  /// Slots the pre-ListView layouts still render as fixed rows (three task and
  /// habit rows, five calendar rows). Slots past the last real row are cleared
  /// so a day that shrinks from three items to one does not leave yesterday's
  /// title behind. The list adapter that T8.2 wires reads `*_count` instead, so
  /// this tail clear is a handful of writes and nothing more.
  static const _staticTaskSlots = 3;
  static const _staticCalendarSlots = 5;

  static const tasksHabitsProviderName = 'TazkTasksHabitsWidgetProvider';
  static const tasksOnlyProviderName = 'TazkTasksOnlyWidgetProvider';
  static const habitsOnlyProviderName = 'TazkHabitsOnlyWidgetProvider';
  static const streakProviderName = 'TazkStreakWidgetProvider';
  static const calendarTasksHabitsProviderName =
      'TazkCalendarTasksHabitsWidgetProvider';

  static List<Task> calendarTaskRowsForDate(
    Iterable<Task> tasks,
    DateTime date,
  ) {
    final selected = _dateOnly(date);
    final rows = tasks.where((task) {
      return !task.isCompleted && _dateOnly(task.date) == selected;
    }).toList();

    rows.sort((a, b) {
      final byPriority = b.priority.index.compareTo(a.priority.index);
      if (byPriority != 0) return byPriority;

      final aTime = a.time;
      final bTime = b.time;
      if (aTime == null && bTime == null) {
        return a.id.compareTo(b.id);
      }
      if (aTime == null) return -1;
      if (bTime == null) return 1;
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) return byTime;
      return a.id.compareTo(b.id);
    });

    return rows;
  }

  Future<void>? _pendingRefresh;

  Future<void> refreshAll() {
    return _pendingRefresh ??= _pushAll().whenComplete(() {
      _pendingRefresh = null;
    });
  }

  Future<void> _pushAll() async {
    debugPushCount++;
    try {
      final mounted = await _gate.mountedProviders();
      await Future.wait([
        if (mounted.contains('tasksHabits') ||
            mounted.contains('tasksOnly') ||
            mounted.contains('habitsOnly'))
          _refreshTasksAndHabits(),
        if (mounted.contains('streak')) _refreshStreak(),
        if (mounted.contains('calendar')) refreshCalendarWidget(),
      ]);
    } catch (error) {
      debugPrint('HomeWidgetService: refreshAll failed: $error');
    }
  }

  Future<void> updateCalendarSelection({
    required DateTime visibleMonth,
    required DateTime selectedDate,
  }) async {
    try {
      await _refreshCalendar(
        visibleMonth: visibleMonth,
        selectedDate: selectedDate,
        updateWidget: true,
      );
    } catch (error) {
      debugPrint('HomeWidgetService: updateCalendarSelection failed: $error');
    }
  }

  Future<void> refreshCalendarWidget() async {
    final today = _dateOnly(DateTime.now());
    await _refreshCalendar(
      visibleMonth: DateTime(today.year, today.month),
      selectedDate: today,
      updateWidget: true,
    );
  }

  Future<void> _refreshTasksAndHabits() async {
    final today = _dateOnly(DateTime.now());

    final taskRows = taskWidgetRows(await _tasksForDate(today));
    final habits = await _habitsForDate(today);
    final habitRows = habitWidgetRows(
      habits,
      await _logsForHabits(habits.map((habit) => habit.id).toList(), today),
    );

    final taskCount = await _writeTaskRows(taskRows);
    final habitCount = await _writeHabitRows(habitRows);

    final settings = await _settings.ensureSettings();
    final l10n = lookupAppLocalizations(
      Locale(settings.language == AppLanguage.english ? 'en' : 'id'),
    );
    await HomeWidget.saveWidgetData('tazk_tasks_empty', taskCount == 0);
    await HomeWidget.saveWidgetData(
      'tazk_tasks_empty_text',
      l10n.widgetTasksEmpty,
    );
    await HomeWidget.saveWidgetData('tazk_habits_empty', habitCount == 0);
    await HomeWidget.saveWidgetData(
      'tazk_habits_empty_text',
      l10n.widgetHabitsEmpty,
    );

    await HomeWidget.updateWidget(androidName: tasksHabitsProviderName);
    await HomeWidget.updateWidget(androidName: tasksOnlyProviderName);
    await HomeWidget.updateWidget(androidName: habitsOnlyProviderName);
  }

  /// Writes every task row and returns how many were written, so
  /// `tazk_task_count` can never claim more rows than the keys that exist.
  Future<int> _writeTaskRows(List<WidgetRow> rows) async {
    final written = _rowsToWrite(rows.length, maxRows);
    for (var i = 0; i < written; i++) {
      final row = rows[i];
      await HomeWidget.saveWidgetData('tazk_task_${i}_id', row.id);
      await HomeWidget.saveWidgetData('tazk_task_${i}_title', row.title);
      await HomeWidget.saveWidgetData('tazk_task_${i}_time', row.subtitle);
    }
    for (var i = written; i < _staticTaskSlots; i++) {
      await HomeWidget.saveWidgetData('tazk_task_${i}_id', -1);
      await HomeWidget.saveWidgetData('tazk_task_${i}_title', '');
      await HomeWidget.saveWidgetData('tazk_task_${i}_time', '');
    }
    await HomeWidget.saveWidgetData('tazk_task_count', written);
    return written;
  }

  /// Habit twin of [_writeTaskRows].
  Future<int> _writeHabitRows(List<WidgetRow> rows) async {
    final written = _rowsToWrite(rows.length, maxRows);
    for (var i = 0; i < written; i++) {
      final row = rows[i];
      await HomeWidget.saveWidgetData('tazk_habit_${i}_id', row.id);
      await HomeWidget.saveWidgetData('tazk_habit_${i}_title', row.title);
      await HomeWidget.saveWidgetData('tazk_habit_${i}_subtitle', row.subtitle);
      await HomeWidget.saveWidgetData('tazk_habit_${i}_done', row.done);
    }
    for (var i = written; i < _staticTaskSlots; i++) {
      await HomeWidget.saveWidgetData('tazk_habit_${i}_id', -1);
      await HomeWidget.saveWidgetData('tazk_habit_${i}_title', '');
      await HomeWidget.saveWidgetData('tazk_habit_${i}_subtitle', '');
      await HomeWidget.saveWidgetData('tazk_habit_${i}_done', false);
    }
    await HomeWidget.saveWidgetData('tazk_habit_count', written);
    return written;
  }

  static int _rowsToWrite(int rowCount, int ceiling) =>
      rowCount > ceiling ? ceiling : rowCount;

  /// One query for every habit's log on [date]; the row builder wants a map.
  Future<Map<int, HabitLog>> _logsForHabits(
    List<int> habitIds,
    DateTime date,
  ) async {
    if (habitIds.isEmpty) return const {};
    final logs = await (_db.select(_db.habitLogs)
          ..where((l) => l.habitId.isIn(habitIds) & l.date.equals(date)))
        .get();
    return {for (final log in logs) log.habitId: log};
  }

  Future<void> _refreshCalendar({
    required DateTime visibleMonth,
    required DateTime selectedDate,
    required bool updateWidget,
  }) async {
    final normalizedMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final normalizedSelected = _dateOnly(selectedDate);
    final settings = await _settings.ensureSettings();
    final itemDates = await _itemDatesForMonthGrid(normalizedMonth);
    final snapshot = CalendarWidgetMonthSnapshot.build(
      visibleMonth: normalizedMonth,
      selectedDate: normalizedSelected,
      today: DateTime.now(),
      itemDates: itemDates,
    );
    final tasks = await _calendarTasksForDate(normalizedSelected);
    final habits = await _calendarHabitsForDate(normalizedSelected);

    await HomeWidget.saveWidgetData(
      'tazk_calendar_month_millis',
      normalizedMonth.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData(
      'tazk_calendar_selected_millis',
      normalizedSelected.millisecondsSinceEpoch,
    );
    await HomeWidget.saveWidgetData(
      'tazk_calendar_header',
      _monthHeader(normalizedMonth, settings.language),
    );
    await HomeWidget.saveWidgetData(
      'tazk_calendar_selected_label',
      _selectedDateLabel(normalizedSelected, settings.language),
    );

    for (var i = 0; i < snapshot.cells.length; i++) {
      final cell = snapshot.cells[i];
      await HomeWidget.saveWidgetData(
        'tazk_calendar_day_${i}_millis',
        cell.date.millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData('tazk_calendar_day_${i}_label', cell.dayLabel);
      await HomeWidget.saveWidgetData(
        'tazk_calendar_day_${i}_in_month',
        cell.isInVisibleMonth,
      );
      await HomeWidget.saveWidgetData(
        'tazk_calendar_day_${i}_is_today',
        cell.isToday,
      );
      await HomeWidget.saveWidgetData(
        'tazk_calendar_day_${i}_is_selected',
        cell.isSelected,
      );
      await HomeWidget.saveWidgetData(
        'tazk_calendar_day_${i}_has_items',
        cell.hasItems,
      );
    }

    final calendarTaskCount = _rowsToWrite(tasks.length, calendarMaxRows);
    for (var i = 0; i < calendarTaskCount; i++) {
      final task = tasks[i];
      await HomeWidget.saveWidgetData('tazk_calendar_task_${i}_id', task.id);
      await HomeWidget.saveWidgetData(
        'tazk_calendar_task_${i}_title',
        task.title,
      );
    }
    for (var i = calendarTaskCount; i < _staticCalendarSlots; i++) {
      await HomeWidget.saveWidgetData('tazk_calendar_task_${i}_id', -1);
      await HomeWidget.saveWidgetData('tazk_calendar_task_${i}_title', '');
    }
    await HomeWidget.saveWidgetData(
      'tazk_calendar_task_count',
      calendarTaskCount,
    );

    final calendarHabitCount = _rowsToWrite(habits.length, calendarMaxRows);
    for (var i = 0; i < calendarHabitCount; i++) {
      final habit = habits[i];
      await HomeWidget.saveWidgetData('tazk_calendar_habit_${i}_id', habit.id);
      await HomeWidget.saveWidgetData(
        'tazk_calendar_habit_${i}_title',
        habit.name,
      );
    }
    for (var i = calendarHabitCount; i < _staticCalendarSlots; i++) {
      await HomeWidget.saveWidgetData('tazk_calendar_habit_${i}_id', -1);
      await HomeWidget.saveWidgetData('tazk_calendar_habit_${i}_title', '');
    }
    await HomeWidget.saveWidgetData(
      'tazk_calendar_habit_count',
      calendarHabitCount,
    );
    await HomeWidget.saveWidgetData('tazk_calendar_tasks_label', 'TASKS');
    await HomeWidget.saveWidgetData('tazk_calendar_habits_label', 'HABITS');
    await HomeWidget.saveWidgetData(
      'tazk_calendar_tasks_empty',
      settings.language == AppLanguage.english ? 'No tasks' : 'Tidak ada task',
    );
    await HomeWidget.saveWidgetData(
      'tazk_calendar_habits_empty',
      settings.language == AppLanguage.english ? 'No habits' : 'Tidak ada habit',
    );

    if (updateWidget) {
      await HomeWidget.updateWidget(androidName: calendarTasksHabitsProviderName);
    }
  }

  Future<void> _refreshStreak() async {
    final state = await _db.select(_db.streakState).getSingleOrNull();
    final days = state?.currentStreak ?? 0;
    final settings = await _settings.ensureSettings();
    final l10n = lookupAppLocalizations(
      Locale(settings.language == AppLanguage.english ? 'en' : 'id'),
    );
    final rankLabel = days > 0 ? _rankLabel(streakRankForDays(days), l10n) : '-';

    // PRD 3.7 + gap D2: streak widget must respect the app language, not
    // hardcode Indonesian. Push fully-localized strings for the launcher.
    final daysText = '$days ${l10n.widgetStreakDaysSuffix}';
    final activeText = l10n.widgetStreakActiveLabel;
    await HomeWidget.saveWidgetData('tazk_streak_days', days);
    await HomeWidget.saveWidgetData('tazk_streak_days_text', daysText);
    await HomeWidget.saveWidgetData('tazk_streak_rank', rankLabel);
    await HomeWidget.saveWidgetData('tazk_streak_active_text', activeText);
    await HomeWidget.updateWidget(androidName: streakProviderName);
  }

  String _rankLabel(StreakRank rank, AppLocalizations l10n) => switch (rank) {
        StreakRank.perintis => l10n.rankPerintis,
        StreakRank.petarung => l10n.rankPetarung,
        StreakRank.penakluk => l10n.rankPenakluk,
        StreakRank.sangAhli => l10n.rankSangAhli,
        StreakRank.sangMaster => l10n.rankSangMaster,
        StreakRank.legenda => l10n.rankLegenda,
      };

  Future<List<Task>> _tasksForDate(DateTime date) {
    final start = _dateOnly(date);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end) &
                t.isCompleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.time, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<Habit>> _habitsForDate(DateTime date) async {
    final allHabits = await (_db.select(_db.habits)
          ..where((h) => h.isActive.equals(true)))
        .get();
    return allHabits.where((habit) => _isDueOnDate(habit, date)).toList();
  }

  Future<List<Task>> _calendarTasksForDate(DateTime date) async {
    return calendarTaskRowsForDate(await _tasksForDate(date), date);
  }

  Future<List<Habit>> _calendarHabitsForDate(DateTime date) async {
    final selectedDate = _dateOnly(date);
    final habits = await _habitsForDate(selectedDate);
    final incomplete = <Habit>[];
    for (final habit in habits) {
      final log = await (_db.select(_db.habitLogs)
            ..where(
              (l) =>
                  l.habitId.equals(habit.id) &
                  l.date.equals(selectedDate) &
                  l.isCompleted.equals(true),
            ))
          .getSingleOrNull();
      if (log == null) {
        incomplete.add(habit);
      }
    }
    incomplete.sort((a, b) {
      final aTime = a.scheduledTime;
      final bTime = b.scheduledTime;
      if (aTime == null && bTime == null) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) return byTime;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return incomplete;
  }

  Future<Set<DateTime>> _itemDatesForMonthGrid(DateTime visibleMonth) async {
    final snapshot = CalendarWidgetMonthSnapshot.build(
      visibleMonth: visibleMonth,
      selectedDate: _dateOnly(DateTime.now()),
      today: DateTime.now(),
      itemDates: const {},
    );
    final start = snapshot.cells.first.date;
    final end = snapshot.cells.last.date.add(const Duration(days: 1));
    final dates = <DateTime>{};

    final tasks = await (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end) &
                t.isCompleted.equals(false),
          ))
        .get();
    for (final task in tasks) {
      dates.add(_dateOnly(task.date));
    }

    final habits = await (_db.select(_db.habits)
          ..where((h) => h.isActive.equals(true)))
        .get();
    for (final cell in snapshot.cells) {
      if (habits.any((habit) => _isDueOnDate(habit, cell.date))) {
        dates.add(cell.date);
      }
    }
    return dates;
  }

  String _monthHeader(DateTime month, AppLanguage language) {
    final names = language == AppLanguage.english
        ? const [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December',
          ]
        : const [
            'Januari',
            'Februari',
            'Maret',
            'April',
            'Mei',
            'Juni',
            'Juli',
            'Agustus',
            'September',
            'Oktober',
            'November',
            'Desember',
          ];
    return '${names[month.month - 1]} ${month.year}';
  }

  String _selectedDateLabel(DateTime date, AppLanguage language) {
    final names = language == AppLanguage.english
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return '${names[date.weekday - 1]}, ${date.day}/${date.month}/${date.year}';
  }

  bool _isDueOnDate(Habit habit, DateTime date) => habit_due.isHabitDueOnDate(habit, date);

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
