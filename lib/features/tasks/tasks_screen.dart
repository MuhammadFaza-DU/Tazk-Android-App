import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_scaffold.dart';
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
              MaterialPageRoute(builder: (_) => const TaskFormScreen()),
            );
          },
        ),
      ],
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? Center(child: Text(l10n.homeNoTasksToday))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) => _TaskListTile(task: tasks[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorLoadingTasks(error.toString()))),
      ),
    );
  }
}

class _TaskListTile extends ConsumerWidget {
  const _TaskListTile({required this.task});

  final Task task;

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.low => l10n.priorityLowShort,
        TaskPriority.medium => l10n.priorityMedShort,
        TaskPriority.high => l10n.priorityHighShort,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: task.isCompleted
            ? null
            : (_) => ref.read(taskRepositoryProvider).completeTask(task.id),
      ),
      title: Text(
        task.title,
        style: task.isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text([
        _priorityLabel(l10n),
        if (task.time != null) TimeOfDay.fromDateTime(task.time!).format(context),
        if (task.location != null && task.location!.isNotEmpty) task.location!,
      ].join(' · ')),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
        );
      },
      trailing: IconButton(
        icon: const Icon(Icons.copy_rounded),
        tooltip: l10n.taskDuplicateTooltip,
        onPressed: () => ref.read(taskRepositoryProvider).duplicateTask(task),
      ),
    );
  }
}
