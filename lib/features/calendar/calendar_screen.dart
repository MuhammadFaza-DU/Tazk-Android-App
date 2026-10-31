import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import '../tasks/task_form_screen.dart';

/// Board `04 Kalender` (780×1546 px, dibagi 2 → frame 390dp).
///
/// Susunan dari kanvas:
/// - header bulan/tahun + dua tombol bulat panah di kanan,
/// - SATU kartu berbingkai berisi grid 7 kolom (pill hari terpilih, titik
///   `honey` sebagai penanda item),
/// - panel harian: judul "Kamis, 29 Okt" + jumlah item, lalu satu kartu per
///   item (checkbox, judul, chip, jam/sub-judul).
///
/// Ukuran board yang dipakai apa adanya: pill hari 44×40dp radius 10, baris
/// tanggal 48dp, baris nama hari 22dp, inset grid 12dp, titik penanda 4dp,
/// radius kartu grid 24dp. Angka token (`DESIGN.md`) menang bila board memakai
/// ukuran di bawah lantai sistem (mis. label chip 9,5dp di board → `labelLarge`
/// 13, dan nama hari 10,5dp → `caption` 12).
const double _gutter = 16; // spacing.lg
const double _cardGap = 12; // spacing.md
const double _sectionGap = 16; // jarak kartu grid → judul section (board ~14dp)
const double _gridRadius = 24; // rounded.xl (board ≈ 22dp)
const double _gridInset = 12; // inset horizontal grid di dalam kartu (board 13dp)
const double _gridPadding = 10; // padding vertikal kartu grid (board 10dp)
const double _rowHeight = 48; // tinggi baris tanggal (board 96px)
const double _dowHeight = 22; // tinggi baris nama hari (board ~22dp)
const double _dayWidth = 44; // pill hari terpilih (board 88px)
const double _dayHeight = 40; // board 80px
const double _dayRadius = 10; // rounded.sm (board ≈ 9,5dp)
const double _markerSize = 4; // titik penanda item (board 7-8px)
const double _cardRadius = 14; // rounded.md — kartu item (AppCard)
const double _cardVerticalPadding = 12; // board: 56dp kartu = 12 + isi + 12

const Key calendarMonthLabelKey = Key('calendar_month_label');
const Key calendarPrevMonthKey = Key('calendar_prev_month');
const Key calendarNextMonthKey = Key('calendar_next_month');
const Key calendarGridCardKey = Key('calendar_grid_card');
const Key calendarDayPanelKey = Key('calendar_day_panel');

/// Kunci sel tanggal supaya uji bisa membaca warnanya per tanggal.
Key calendarDayKey(DateTime date) =>
    Key('calendar_day_${date.year}-${date.month}-${date.day}');

/// Kunci titik penanda item per tanggal.
Key calendarMarkerKey(DateTime date) =>
    Key('calendar_marker_${date.year}-${date.month}-${date.day}');

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

/// "Oktober 2026" — dipakai header bulan dan tooltip tombol panah.
String _monthLabel(AppLocalizations l10n, DateTime month) =>
    '${_monthNames(l10n)[month.month - 1]} ${month.year}';

/// "Kamis, 29 Okt" — judul panel harian (board `04 Kalender`).
String _dayLabel(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    return DateFormat('EEEE, d MMM', locale).format(date);
  } catch (_) {
    return DateFormat('EEEE, d MMM', 'en').format(date);
  }
}

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

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final labelLarge = theme.textTheme.labelLarge ?? const TextStyle();
    final labelSmall = theme.textTheme.labelSmall ?? const TextStyle();

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
      title: l10n.navCalendar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 0),
            child: _MonthHeader(
              label: _monthLabel(l10n, _focusedDay),
              previousLabel: _monthLabel(
                l10n,
                DateTime(_focusedDay.year, _focusedDay.month - 1, 1),
              ),
              nextLabel: _monthLabel(
                l10n,
                DateTime(_focusedDay.year, _focusedDay.month + 1, 1),
              ),
              onPrevious: _goToPreviousMonth,
              onNext: _goToNextMonth,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(_gutter, 16, _gutter, 0),
            child: _GridCard(
              child: TableCalendar<Object>(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2100, 12, 31),
                focusedDay: _focusedDay,
                headerVisible: false,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
                rowHeight: _rowHeight,
                daysOfWeekHeight: _dowHeight,
                eventLoader: eventsForDay,
                selectedDayPredicate: (day) => _dateOnly(day) == _selectedDay,
                // Grid kartu sudah memakai token surface/border/rounded.xl, jadi
                // style di sini hanya jaring aman bila suatu builder dilewati.
                calendarStyle: CalendarStyle(
                  cellMargin: EdgeInsets.zero,
                  markersMaxCount: 1,
                  todayDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_dayRadius),
                    border: Border.all(color: colors.honey, width: 2),
                  ),
                  todayTextStyle: labelLarge.copyWith(color: colors.ink),
                  selectedDecoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(_dayRadius),
                  ),
                  selectedTextStyle: labelLarge.copyWith(color: colors.onPrimary),
                  outsideTextStyle: labelLarge.copyWith(color: colors.inkMuted),
                  defaultTextStyle: labelLarge.copyWith(color: colors.ink),
                ),
                // Bulan/tahun tampil di header body (board), jadi header bawaan
                // table dimatikan; headerStyle tetap memakai token agar
                // konsisten bila suatu saat diaktifkan kembali.
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextStyle: (theme.textTheme.headlineSmall ?? const TextStyle())
                      .copyWith(color: colors.ink),
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
                  // Board: SATU titik `honey` per tanggal berisi item (task
                  // maupun habit), bukan dua warna berbeda.
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return null;
                    final isSelected = _dateOnly(day) == _selectedDay;
                    return Positioned(
                      bottom: 12,
                      child: Container(
                        key: calendarMarkerKey(day),
                        width: _markerSize,
                        height: _markerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? colors.onPrimary : colors.honey,
                        ),
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
            ),
          ),
          Expanded(
            child: selectedDayTasksAsync.when(
              data: (tasks) => _DayPanel(
                key: calendarDayPanelKey,
                date: _selectedDay,
                tasks: tasks,
                habits: selectedDayHabits,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(_gutter),
                child: SkeletonList(),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(_gutter),
                  child: ErrorState(
                    title: l10n.stateErrorTitle,
                    message: l10n.stateErrorMessage,
                    retryLabel: l10n.stateRetryAction,
                    onRetry: () =>
                        ref.invalidate(tasksForDateProvider(_selectedDay)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header bulan: judul kiri, dua tombol bulat panah di kanan (board).
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.previousLabel,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final String previousLabel;
  final String nextLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            key: calendarMonthLabelKey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (theme.textTheme.headlineSmall ?? const TextStyle())
                .copyWith(color: colors.ink),
          ),
        ),
        const SizedBox(width: 8),
        _CircleIconButton(
          key: calendarPrevMonthKey,
          icon: Icons.chevron_left_rounded,
          label: previousLabel,
          onPressed: onPrevious,
        ),
        const SizedBox(width: 6),
        _CircleIconButton(
          key: calendarNextMonthKey,
          icon: Icons.chevron_right_rounded,
          label: nextLabel,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Tombol panah bulat: lingkaran visual 33dp (board 66px) di dalam area sentuh
/// 48dp supaya tetap memenuhi tap target `DESIGN.md`.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  static const double tapTarget = 48;
  static const double visualSize = 33;

  final IconData icon;

  /// Nama bulan tujuan — sekaligus nama aksesibel tombol ikon.
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Tooltip(
      message: label,
      child: SizedBox(
        width: tapTarget,
        height: tapTarget,
        child: InkResponse(
          onTap: onPressed,
          radius: tapTarget / 2,
          child: Center(
            child: Container(
              width: visualSize,
              height: visualSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border),
              ),
              child: Icon(icon, size: 16, color: colors.inkMuted),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu grid kalender: `surface` + border, radius `rounded.xl` (board 24dp).
/// Sengaja bukan [AppCard] karena [AppCard] terkunci di `rounded.md`.
class _GridCard extends StatelessWidget {
  const _GridCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      key: calendarGridCardKey,
      padding: const EdgeInsets.symmetric(
        horizontal: _gridInset,
        vertical: _gridPadding,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_gridRadius),
        border: Border.all(color: colors.border),
      ),
      child: child,
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
        return Center(
          child: Container(
            key: calendarDayKey(day),
            width: _dayWidth,
            height: _dayHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary
                  : isDropTarget
                      ? colors.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(_dayRadius),
              // Penanda "hari ini" memakai `honey`; bentuknya sama dengan pill
              // supaya grid tetap tenang (board tidak memakai lingkaran).
              border: isToday && !isSelected
                  ? Border.all(color: colors.honey, width: 2)
                  : null,
            ),
            child: Text(
              '${day.day}',
              style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
                color: isSelected
                    ? colors.onPrimary
                    : isOutside
                        ? colors.inkMuted
                        : colors.ink,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Panel harian: judul "Kamis, 29 Okt" + jumlah item, lalu satu kartu per item.
class _DayPanel extends StatelessWidget {
  const _DayPanel({
    super.key,
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
        child: Padding(
          padding: const EdgeInsets.all(_gutter),
          child: EmptyState(
            title: l10n.noTasksHabitsThisDate,
            message: l10n.stateEmptyTasksSubtitle,
          ),
        ),
      );
    }

    // Board menampilkan task lalu habit dalam satu daftar tanpa sub-judul
    // kelompok, jadi label "Habits (daily)" tidak dipakai lagi.
    final cards = <Widget>[
      for (final task in tasks) _DraggableTaskCard(task: task),
      for (final habit in habits) _HabitCard(habit: habit, date: date),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(_gutter, _sectionGap, _gutter, _gutter),
      children: [
        SectionHeader(
          title: _dayLabel(context, date),
          action: Text(
            '${cards.length} item',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
          ),
        ),
        const SizedBox(height: _cardGap),
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: _cardGap),
          cards[i],
        ],
      ],
    );
  }
}

/// Kartu task bisa diseret ke tanggal lain (drag-reschedule) — perilaku lama
/// dipertahankan; hanya tampilannya yang mengikuti board.
class _DraggableTaskCard extends StatelessWidget {
  const _DraggableTaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            task.title,
            style: theme.textTheme.bodyLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TaskCard(task: task),
      ),
      child: _TaskCard(task: task),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final Task task;

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.low => l10n.priorityLowShort,
        TaskPriority.medium => l10n.priorityMedShort,
        TaskPriority.high => l10n.priorityHighShort,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final theme = Theme.of(context);

    final time = task.time;
    final timeLabel =
        time == null ? null : TimeOfDay.fromDateTime(time).format(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(_cardRadius),
          onTap: () {
            Navigator.of(context).push(
              AppPageRoute(builder: (_) => TaskFormScreen(task: task)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: _cardVerticalPadding,
            ),
            child: Row(
              children: [
                CompletionCheckbox(
                  value: task.isCompleted,
                  onComplete: () =>
                      ref.read(taskRepositoryProvider).completeTask(task.id),
                  onUncomplete: () =>
                      ref.read(taskRepositoryProvider).uncompleteTask(task.id),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color:
                              task.isCompleted ? colors.inkMuted : colors.ink,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4), // spacing.xs
                      Row(
                        children: [
                          AppChip.priority(
                            task.priority,
                            label: _priorityLabel(l10n),
                          ),
                          if (timeLabel != null) ...[
                            const SizedBox(width: 8), // spacing.sm
                            Flexible(
                              child: Text(
                                timeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit, required this.date});

  final Habit habit;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final theme = Theme.of(context);

    final habitLogAsync =
        ref.watch(habitLogForDateProvider((habitId: habit.id, date: date)));
    final log = habitLogAsync.valueOrNull;
    final isCompleted = log?.isCompleted ?? false;

    // Board: chip "Habit" + jam. Jam diambil dari `scheduledTime`; habit tanpa
    // jadwal memakai sub-judul yang bermakna (progress menit atau frekuensi).
    final scheduledTime = habit.scheduledTime;
    final meta = scheduledTime != null
        ? TimeOfDay.fromDateTime(scheduledTime).format(context)
        : habit.hasProgress
            ? l10n.habitProgressLabel(
                log?.progressMinutes ?? 0,
                habit.targetMinutes ?? 0,
              )
            : habit.frequency.label(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: _cardVerticalPadding,
        ),
        child: Row(
          children: [
            CompletionCheckbox(
              value: isCompleted,
              // Calendar habit tiles must distinguish days: completing one date
              // must not affect another date even for the same habit.
              onComplete: () => ref
                  .read(habitRepositoryProvider)
                  .completeHabitOnDate(habit.id, date),
              onUncomplete: () => ref
                  .read(habitRepositoryProvider)
                  .uncompleteHabitOnDate(habit.id, date),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? colors.inkMuted : colors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // spacing.xs
                  Row(
                    children: [
                      AppChip(
                        label: l10n.notifHabitLabel,
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.primary,
                      ),
                      const SizedBox(width: 8), // spacing.sm
                      Flexible(
                        child: Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
