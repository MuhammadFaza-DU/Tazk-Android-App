import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_row.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import 'task_form_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.tasksScreenTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            Navigator.of(context).push(
              AppPageRoute(builder: (_) => const TaskFormScreen()),
            );
          },
        ),
      ],
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? Center(child: EmptyState(message: l10n.homeNoTasksToday))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) => _TaskRow(task: tasks[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorLoadingTasks(error.toString()))),
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task});

  final Task task;

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.low => l10n.priorityLowShort,
        TaskPriority.medium => l10n.priorityMedShort,
        TaskPriority.high => l10n.priorityHighShort,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final subtitleParts = <String>[
      if (task.time != null) TimeOfDay.fromDateTime(task.time!).format(context),
      if (task.location != null && task.location!.isNotEmpty) task.location!,
    ];

    return ListRow(
      leading: CompletionCheckbox(
        value: task.isCompleted,
        onComplete: () => ref.read(taskRepositoryProvider).completeTask(task.id),
        onUncomplete: () => ref.read(taskRepositoryProvider).uncompleteTask(task.id),
      ),
      title: task.title,
      crossedOut: task.isCompleted,
      subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' · '),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppChip.priority(task.priority, label: _priorityLabel(l10n)),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: l10n.taskDuplicateTooltip,
            onPressed: () => ref.read(taskRepositoryProvider).duplicateTask(task),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          AppPageRoute(builder: (_) => TaskFormScreen(task: task)),
        );
      },
    );
  }
}