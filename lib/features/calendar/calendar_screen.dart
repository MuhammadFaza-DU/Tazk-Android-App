import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/widgets/app_scaffold.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import '../tasks/task_form_screen.dart';

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

List<String> _weekdayAbbrev(AppLocalizations l10n) => [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

List<String> _monthNames(AppLocalizations l10n) => [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = _dateOnly(DateTime.now());
    _selectedDay = _focusedDay;
  }

  Future<void> _onTaskDropped(Task task, DateTime day) async {
    final newDate = _dateOnly(day);
    if (newDate == _dateOnly(task.date)) return;
    await ref.read(taskRepositoryProvider).updateTask(task.copyWith(date: newDate));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.taskMovedMessage(task.title, _formatDate(newDate)),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final monthKey = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final monthTasksAsync = ref.watch(tasksInMonthProvider(monthKey));
    final activeHabitsAsync = ref.watch(activeHabitsProvider);
    final selectedDayTasksAsync = ref.watch(tasksForDateProvider(_selectedDay));

    final monthTasks = monthTasksAsync.valueOrNull ?? const <Task>[];
    final hasDailyHabit = (activeHabitsAsync.valueOrNull ?? const <Habit>[])
        .any((habit) => habit.frequency == HabitFrequency.daily);

    final tasksByDay = <DateTime, List<Task>>{};
    for (final task in monthTasks) {
      final key = _dateOnly(task.date);
      tasksByDay.putIfAbsent(key, () => []).add(task);
    }

    List<Object> eventsForDay(DateTime day) {
      final tasks = tasksByDay[_dateOnly(day)] ?? const <Task>[];
      return [...tasks, if (hasDailyHabit) 'habit'];
    }

    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.calendarScreenTitle(
        _monthNames(l10n)[_focusedDay.month - 1],
        _focusedDay.year,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => setState(() {
            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
          }),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => setState(() {
            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
          }),
        ),
      ],
      body: Column(
        children: [
          TableCalendar<Object>(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2100, 12, 31),
            focusedDay: _focusedDay,
            headerVisible: false,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
            eventLoader: eventsForDay,
            selectedDayPredicate: (day) => _dateOnly(day) == _selectedDay,
            calendarStyle: const CalendarStyle(markersMaxCount: 1),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = _dateOnly(selectedDay);
                _focusedDay = _dateOnly(focusedDay);
              });
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = _dateOnly(focusedDay));
            },
            calendarBuilders: CalendarBuilders<Object>(
              dowBuilder: (context, day) => Center(
                child: Text(_weekdayAbbrev(AppLocalizations.of(context)!)[day.weekday - 1]),
              ),
              defaultBuilder: (context, day, focusedDay) =>
                  _DayCell(day: day, onTaskDropped: _onTaskDropped),
              outsideBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                onTaskDropped: _onTaskDropped,
                isOutside: true,
              ),
              todayBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                onTaskDropped: _onTaskDropped,
                isToday: true,
              ),
              selectedBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                onTaskDropped: _onTaskDropped,
                isSelected: true,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: selectedDayTasksAsync.when(
              data: (tasks) => _DayDetail(
                date: _selectedDay,
                tasks: tasks,
                hasDailyHabit: hasDailyHabit,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text(l10n.errorLoadingCalendar(error.toString()))),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.onTaskDropped,
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
  });

  final DateTime day;
  final void Function(Task task, DateTime day) onTaskDropped;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DragTarget<Task>(
      onAcceptWithDetails: (details) => onTaskDropped(details.data, day),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? colorScheme.primary
                : isDropTarget
                    ? colorScheme.primary.withAlpha(60)
                    : isToday
                        ? colorScheme.primary.withAlpha(30)
                        : null,
            border: isToday && !isSelected
                ? Border.all(color: colorScheme.primary)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected
                  ? colorScheme.onPrimary
                  : isOutside
                      ? Theme.of(context).disabledColor
                      : null,
            ),
          ),
        );
      },
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({
    required this.date,
    required this.tasks,
    required this.hasDailyHabit,
  });

  final DateTime date;
  final List<Task> tasks;
  final bool hasDailyHabit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (tasks.isEmpty && !hasDailyHabit) {
      return Center(child: Text(l10n.noTasksHabitsThisDate));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (tasks.isNotEmpty) ...[
          Text(l10n.tasksLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final task in tasks)
            Draggable<Task>(
              data: task,
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(task.title),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _TaskRow(task: task),
              ),
              child: _TaskRow(task: task),
            ),
        ],
        if (hasDailyHabit) ...[
          const SizedBox(height: 16),
          Text(l10n.dailyHabitsLabel, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(l10n.dailyHabitInfo),
        ],
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final Task task;

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.low => l10n.priorityLowShort,
        TaskPriority.medium => l10n.priorityMedShort,
        TaskPriority.high => l10n.priorityHighShort,
      };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.drag_indicator_rounded),
      title: Text(task.title),
      subtitle: Text(_priorityLabel(AppLocalizations.of(context)!)),
      trailing: task.isCompleted ? const Icon(Icons.check_circle_rounded) : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
        );
      },
    );
  }
}
