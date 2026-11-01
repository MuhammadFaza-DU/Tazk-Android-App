import '../data/database/database.dart';

/// One row rendered by the scrollable widget's `RemoteViewsFactory`.
class WidgetRow {
  const WidgetRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  final int id;
  final String title;
  final String subtitle;
  final bool done;
}

/// Maps [tasks] to rows in the given order. No cap: the widget decides how
/// many rows fit, so a long day is no longer truncated to three.
List<WidgetRow> taskWidgetRows(List<Task> tasks) {
  return [
    for (final task in tasks)
      WidgetRow(
        id: task.id,
        title: task.title,
        subtitle: _formatTime(task.time),
        done: task.isCompleted,
      ),
  ];
}

/// Maps [habits] to rows in the given order. [logs] is keyed by habit id; a
/// habit without a log is not done and has 0 progress.
List<WidgetRow> habitWidgetRows(
  List<Habit> habits,
  Map<int, HabitLog> logs,
) {
  final rows = <WidgetRow>[];
  for (final habit in habits) {
    final log = logs[habit.id];
    rows.add(
      WidgetRow(
        id: habit.id,
        title: habit.name,
        subtitle: habit.hasProgress
            ? '${log?.progressMinutes ?? 0}/${habit.targetMinutes ?? 0}'
            : '',
        done: log?.isCompleted ?? false,
      ),
    );
  }
  return rows;
}

String _formatTime(DateTime? time) {
  if (time == null) return '';
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}