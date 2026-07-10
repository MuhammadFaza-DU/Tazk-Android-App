import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_scaffold.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import 'task_form_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return AppScaffold(
      title: 'Tasks — Hari Ini',
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
            ? const Center(child: Text('Belum ada task hari ini'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: tasks.length,
                itemBuilder: (context, index) => _TaskListTile(task: tasks[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat task: $error')),
      ),
    );
  }
}

class _TaskListTile extends ConsumerWidget {
  const _TaskListTile({required this.task});

  final Task task;

  String get _priorityLabel => switch (task.priority) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Med',
        TaskPriority.high => 'High',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        _priorityLabel,
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
        tooltip: 'Duplikat',
        onPressed: () => ref.read(taskRepositoryProvider).duplicateTask(task),
      ),
    );
  }
}
