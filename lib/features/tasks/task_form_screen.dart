import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/list_row.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return AppScaffold(
      title: _isEditing ? l10n.editTaskTitle : l10n.addTaskTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _titleController,
              labelText: l10n.fieldTitleLabel,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.taskTitleRequiredError
                  : null,
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListRow(
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: colors.inkMuted,
                    ),
                    title: l10n.fieldDateLabel,
                    subtitle: '${_date.day}/${_date.month}/${_date.year}',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colors.inkMuted,
                    ),
                    onTap: _pickDate,
                  ),
                  ListRow(
                    leading: Icon(
                      Icons.access_time_rounded,
                      color: colors.inkMuted,
                    ),
                    title: l10n.fieldTimeOptionalLabel,
                    subtitle: _time == null ? '-' : _time!.format(context),
                    trailing: _time == null
                        ? Icon(
                            Icons.chevron_right_rounded,
                            color: colors.inkMuted,
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _time = null),
                          ),
                    onTap: _pickTime,
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fieldPriorityLabel,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: colors.inkMuted),
                  ),
                  RadioGroup<TaskPriority>(
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                    child: Column(
                      children: [
                        RadioListTile<TaskPriority>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.priorityLow),
                          value: TaskPriority.low,
                        ),
                        RadioListTile<TaskPriority>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.priorityMedium),
                          value: TaskPriority.medium,
                        ),
                        RadioListTile<TaskPriority>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.priorityHigh),
                          value: TaskPriority.high,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _locationController,
              labelText: l10n.fieldLocationOptionalLabel,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.checklistOptionalLabel,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              _ExistingSubtasksList(taskId: widget.task!.id)
            else
              Column(
                children: [
                  for (final title in _newSubtaskTitles)
                    ListRow(
                      leading: Icon(
                        Icons.check_box_outline_blank_rounded,
                        color: colors.inkMuted,
                      ),
                      title: title,
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () =>
                            setState(() => _newSubtaskTitles.remove(title)),
                      ),
                      showDivider: false,
                    ),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _subtaskInputController,
                    hintText: l10n.addItemHint,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _addSubtaskField(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  color: colors.primary,
                  onPressed: _addSubtaskField,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: l10n.saveButton,
              onPressed: _save,
              expanded: true,
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
            ListRow(
              leading: CompletionCheckbox(
                value: subtask.isCompleted,
                onComplete: () => repo.setSubtaskCompleted(subtask.id, true),
                onUncomplete: () =>
                    repo.setSubtaskCompleted(subtask.id, false),
              ),
              title: subtask.title,
              showDivider: false,
            ),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
