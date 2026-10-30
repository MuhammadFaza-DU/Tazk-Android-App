import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
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
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import 'task_form_screen.dart';

/// Board `02 Tasks`: header with a circular add button, two grouped sections
/// ("Belum selesai" then "Selesai", each with a count), and one bordered card
/// per task. Loading / error / empty reuse board `11 States`.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  /// `spacing.lg` — screen gutter, applied once outside the list.
  static const double _gutter = 16;

  /// `spacing.md` — gap between two task cards.
  static const double _cardGap = 12;

  /// `spacing.xl` — gap between the two grouped sections.
  static const double _sectionGap = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppScaffold(
      title: l10n.tasksScreenTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: l10n.addTaskTitle,
          style: IconButton.styleFrom(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.primary,
          ),
          onPressed: () => _openForm(context),
        ),
      ],
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(_gutter),
                  child: EmptyState(
                    title: l10n.stateEmptyTasksTitle,
                    message: l10n.stateEmptyTasksSubtitle,
                    action: AppButton.primary(
                      label: l10n.stateEmptyTasksAction,
                      onPressed: () => _openForm(context),
                    ),
                  ),
                ),
              )
            : _TaskList(tasks: tasks),
        loading: () => const Padding(
          padding: EdgeInsets.all(_gutter),
          child: SkeletonList(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(_gutter),
            child: ErrorState(
              title: l10n.stateErrorTitle,
              message: l10n.stateErrorMessage,
              retryLabel: l10n.stateRetryAction,
              onRetry: () => ref.invalidate(todayTasksProvider),
            ),
          ),
        ),
      ),
    );
  }

  static void _openForm(BuildContext context, {Task? task}) {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }
}

/// Grouped task list: open tasks first, completed tasks last, each group led by
/// a [SectionHeader] carrying the group count on the right (board `02 Tasks`).
class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final pending = tasks.where((task) => !task.isCompleted).toList();
    final completed = tasks.where((task) => task.isCompleted).toList();
    final hasBoth = pending.isNotEmpty && completed.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(TasksScreen._gutter),
      children: [
        if (pending.isNotEmpty) ...[
          _GroupHeader(label: 'Belum selesai', count: pending.length),
          const SizedBox(height: TasksScreen._cardGap),
          ..._buildGroup(pending),
        ],
        if (hasBoth) const SizedBox(height: TasksScreen._sectionGap),
        if (completed.isNotEmpty) ...[
          _GroupHeader(label: 'Selesai', count: completed.length),
          const SizedBox(height: TasksScreen._cardGap),
          ..._buildGroup(completed),
        ],
      ],
    );
  }

  List<Widget> _buildGroup(List<Task> group) {
    final children = <Widget>[];
    for (var i = 0; i < group.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(height: TasksScreen._cardGap));
      }
      children.add(_TaskCard(task: group[i]));
    }
    return children;
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: label,
      action: Text(
        '$count',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.colors.inkMuted,
            ),
      ),
    );
  }
}

/// One task card: checkbox on the left, title plus a `priority` chip + time row
/// on the right, duplicate action trailing. Tapping the card opens the edit
/// form, exactly like the previous list row behaviour.
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
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final time = task.time;
    // No `Tanpa jam` l10n key exists yet (arb files are outside this task's
    // scope), so the untimed label stays literal for now.
    final timeLabel = time == null
        ? 'Tanpa jam'
        : TimeOfDay.fromDateTime(time).format(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14), // rounded.md
          onTap: () => TasksScreen._openForm(context, task: task),
          child: Padding(
            padding: const EdgeInsets.all(16), // spacing.lg
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
                          color: task.isCompleted ? colors.inkMuted : colors.ink,
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
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  iconSize: 18,
                  color: colors.inkMuted,
                  tooltip: l10n.taskDuplicateTooltip,
                  onPressed: () =>
                      ref.read(taskRepositoryProvider).duplicateTask(task),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}