import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.task});

  /// Null means "create new task"; non-null means "edit existing task".
  final Task? task;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;

  late DateTime _date;
  TimeOfDay? _time;
  late TaskPriority _priority;

  final List<String> _newSubtaskTitles = [];
  final _subtaskInputController = TextEditingController();

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _locationController = TextEditingController(text: task?.location ?? '');
    _date = task?.date ?? DateTime.now();
    _time = task?.time != null ? TimeOfDay.fromDateTime(task!.time!) : null;
    _priority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _addSubtaskField() {
    final title = _subtaskInputController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _newSubtaskTitles.add(title);
      _subtaskInputController.clear();
    });
  }

  DateTime? get _combinedTime {
    if (_time == null) return null;
    return DateTime(_date.year, _date.month, _date.day, _time!.hour, _time!.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(taskRepositoryProvider);
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: title,
        date: _date,
        time: Value(_combinedTime),
        priority: _priority,
        location: Value(location.isEmpty ? null : location),
      );
      await repo.updateTask(updated);
    } else {
      final newId = await repo.createTask(
        title: title,
        date: _date,
        time: _combinedTime,
        priority: _priority,
        location: location.isEmpty ? null : location,
      );
      for (final subtaskTitle in _newSubtaskTitles) {
        await repo.addSubtask(newId, subtaskTitle);
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'Tambah Task')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal'),
              subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Jam (opsional)'),
              subtitle: Text(_time == null ? '-' : _time!.format(context)),
              trailing: _time == null
                  ? const Icon(Icons.access_time_rounded)
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _time = null),
                    ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 8),
            Text('Prioritas', style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<TaskPriority>(
              groupValue: _priority,
              onChanged: (value) => setState(() => _priority = value!),
              child: const Column(
                children: [
                  RadioListTile<TaskPriority>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Low'),
                    value: TaskPriority.low,
                  ),
                  RadioListTile<TaskPriority>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Medium'),
                    value: TaskPriority.medium,
                  ),
                  RadioListTile<TaskPriority>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('High'),
                    value: TaskPriority.high,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lokasi (opsional)'),
            ),
            const SizedBox(height: 16),
            Text('Checklist/Subtask (opsional)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_isEditing)
              _ExistingSubtasksList(taskId: widget.task!.id)
            else
              Column(
                children: [
                  for (final title in _newSubtaskTitles)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_box_outline_blank_rounded),
                      title: Text(title),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () =>
                            setState(() => _newSubtaskTitles.remove(title)),
                      ),
                    ),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskInputController,
                    decoration: const InputDecoration(hintText: 'Tambah item'),
                    onSubmitted: (_) => _addSubtaskField(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: _addSubtaskField,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExistingSubtasksList extends ConsumerWidget {
  const _ExistingSubtasksList({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(taskSubtasksProvider(taskId));
    final repo = ref.read(taskRepositoryProvider);

    return subtasksAsync.when(
      data: (subtasks) => Column(
        children: [
          for (final subtask in subtasks)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: subtask.isCompleted,
              title: Text(subtask.title),
              onChanged: (value) =>
                  repo.setSubtaskCompleted(subtask.id, value ?? false),
            ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
