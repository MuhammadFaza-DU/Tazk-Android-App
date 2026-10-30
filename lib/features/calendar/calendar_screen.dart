import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_row.dart';
import '../../core/widgets/section_header.dart';
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
  // Memoize habitsByDay to avoid O(habits*days) recomputation every build.
  DateTime? _cachedMonth;
  List<Habit>? _cachedHabitsRef;
  Map<DateTime, List<Habit>>? _cachedHabitsByDay;

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
    final colors = context.colors;
    final theme = Theme.of(context);
    final labelLarge = theme.textTheme.labelLarge ?? const TextStyle();
    final labelSmall = theme.textTheme.labelSmall ?? const TextStyle();
    final headlineSmall = theme.textTheme.headlineSmall ?? const TextStyle();

    final monthKey = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final monthTasksAsync = ref.watch(tasksInMonthProvider(monthKey));
    final activeHabitsAsync = ref.watch(activeHabitsProvider);
    final selectedDayTasksAsync = ref.watch(tasksForDateProvider(_selectedDay));
    final selectedDayHabits = ref.watch(habitsForDateProvider(_selectedDay));

    final monthTasks = monthTasksAsync.valueOrNull ?? const <Task>[];
    final activeHabits = activeHabitsAsync.valueOrNull ?? const <Habit>[];

    final tasksByDay = <DateTime, List<Task>>{};
    for (final task in monthTasks) {
      final key = _dateOnly(task.date);
      tasksByDay.putIfAbsent(key, () => []).add(task);
    }

    // Memoized habitsByDay: O(habits*days) but cached per month/habits ref.
    final Map<DateTime, List<Habit>> habitsByDay;
    if (_cachedMonth == monthKey && identical(_cachedHabitsRef, activeHabits) && _cachedHabitsByDay != null) {
      habitsByDay = _cachedHabitsByDay!;
    } else {
      habitsByDay = <DateTime, List<Habit>>{};
      final repo = ref.read(habitRepositoryProvider);
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      for (final habit in activeHabits) {
        for (DateTime d = startOfMonth; d.isBefore(endOfMonth.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
          if (repo.isDueOnDate(habit, d)) {
            habitsByDay.putIfAbsent(_dateOnly(d), () => []).add(habit);
          }
        }
      }
      _cachedMonth = monthKey;
      _cachedHabitsRef = activeHabits;
      _cachedHabitsByDay = habitsByDay;
    }

    List<Object> eventsForDay(DateTime day) {
      final tasks = tasksByDay[_dateOnly(day)] ?? const <Task>[];
      final habits = habitsByDay[_dateOnly(day)] ?? const <Habit>[];
      return [...tasks, ...habits];
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
            calendarStyle: CalendarStyle(
              markersMaxCount: 1,
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.honey, width: 2),
              ),
              todayTextStyle: labelLarge.copyWith(color: colors.ink),
              selectedDecoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: labelLarge.copyWith(color: colors.onPrimary),
              outsideTextStyle: labelLarge.copyWith(color: colors.inkMuted),
              defaultTextStyle: labelLarge.copyWith(color: colors.ink),
            ),
            // Bulan/tahun ditampilkan di AppBar (`AppScaffold`), jadi header
            // table dimatikan; headerStyle tetap memakai token agar konsisten
            // bila suatu saat header diaktifkan kembali.
            headerStyle: HeaderStyle(
              titleCentered: true,
              titleTextStyle: headlineSmall.copyWith(color: colors.ink),
              formatButtonVisible: false,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: labelSmall.copyWith(color: colors.inkMuted),
              weekendStyle: labelSmall.copyWith(color: colors.inkMuted),
            ),
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
              markerBuilder: (context, day, events) {
                final taskCount = events.whereType<Task>().length;
                final habitCount = events.whereType<Habit>().length;
                if (taskCount == 0 && habitCount == 0) return null;
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (taskCount > 0)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (taskCount > 0 && habitCount > 0) const SizedBox(width: 3),
                      if (habitCount > 0)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.honey,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
              dowBuilder: (context, day) => Center(
                child: Text(
                  _weekdayAbbrev(AppLocalizations.of(context)!)[day.weekday - 1],
                  style: labelSmall.copyWith(color: colors.inkMuted),
                ),
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
          Divider(height: 1, color: colors.border),
          Expanded(
            child: selectedDayTasksAsync.when(
              data: (tasks) => _DayDetail(
                date: _selectedDay,
                tasks: tasks,
                habits: selectedDayHabits,
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
    final colors = context.colors;
    final theme = Theme.of(context);

    return DragTarget<Task>(
      onAcceptWithDetails: (details) => onTaskDropped(details.data, day),
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? colors.primary
                : isDropTarget
                    ? colors.primaryContainer
                    : null,
            border: isToday && !isSelected
                ? Border.all(color: colors.honey, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? colors.onPrimary
                  : isOutside
                      ? colors.inkMuted
                      : colors.ink,
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
    required this.habits,
  });

  final DateTime date;
  final List<Task> tasks;
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final theme = Theme.of(context);

    if (tasks.isEmpty && habits.isEmpty) {
      return Center(
        child: EmptyState(message: l10n.noTasksHabitsThisDate),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (tasks.isNotEmpty) ...[
          SectionHeader(title: l10n.tasksLabel),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < tasks.length; i++)
                  Draggable<Task>(
                    data: tasks[i],
                    feedback: Material(
                      color: colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: colors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          tasks[i].title,
                          style: theme.textTheme.bodyLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _TaskRow(
                        task: tasks[i],
                        showDivider: i != tasks.length - 1,
                      ),
                    ),
                    child: _TaskRow(
                      task: tasks[i],
                      showDivider: i != tasks.length - 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (habits.isNotEmpty) ...[
          if (tasks.isNotEmpty) const SizedBox(height: 24),
          SectionHeader(title: l10n.dailyHabitsLabel),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < habits.length; i++)
                  _HabitRow(
                    habit: habits[i],
                    date: date,
                    showDivider: i != habits.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({
    required this.habit,
    required this.date,
    this.showDivider = true,
  });

  final Habit habit;
  final DateTime date;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitLogAsync =
        ref.watch(habitLogForDateProvider((habitId: habit.id, date: date)));
    final isCompleted = habitLogAsync.valueOrNull?.isCompleted ?? false;

    return ListRow(
      leading: CompletionCheckbox(
        value: isCompleted,
        // Calendar habit tiles must distinguish days: completing one date must
        // not affect another date even for the same habit (per-date log).
        onComplete: () => ref
            .read(habitRepositoryProvider)
            .completeHabitOnDate(habit.id, date),
        onUncomplete: () => ref
            .read(habitRepositoryProvider)
            .uncompleteHabitOnDate(habit.id, date),
      ),
      title: habit.name,
      crossedOut: isCompleted,
      subtitle: habit.hasProgress
          ? '${habitLogAsync.valueOrNull?.progressMinutes ?? 0}/${habit.targetMinutes ?? 0} menit'
          : habit.frequency.label(context),
      showDivider: showDivider,
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, this.showDivider = true});

  final Task task;
  final bool showDivider;

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.low => l10n.priorityLowShort,
        TaskPriority.medium => l10n.priorityMedShort,
        TaskPriority.high => l10n.priorityHighShort,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ListRow(
      leading: const Icon(Icons.drag_indicator_rounded),
      title: task.title,
      subtitle: _priorityLabel(l10n),
      trailing: task.isCompleted
          ? Icon(Icons.check_circle_rounded, color: colors.success)
          : null,
      crossedOut: task.isCompleted,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
        );
      },
      showDivider: showDivider,
    );
  }
}