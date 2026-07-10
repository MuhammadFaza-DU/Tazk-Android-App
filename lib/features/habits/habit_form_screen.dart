import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habit});

  /// Null means "create new habit"; non-null means "edit existing habit".
  final Habit? habit;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetMinutesController;

  late HabitFrequency _frequency;
  TimeOfDay? _scheduledTime;
  late bool _hasProgress;

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _targetMinutesController =
        TextEditingController(text: habit?.targetMinutes?.toString() ?? '');
    _frequency = habit?.frequency ?? HabitFrequency.daily;
    _scheduledTime = habit?.scheduledTime != null
        ? TimeOfDay.fromDateTime(habit!.scheduledTime!)
        : null;
    _hasProgress = habit?.hasProgress ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetMinutesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _scheduledTime = picked);
  }

  DateTime? get _combinedScheduledTime {
    if (_scheduledTime == null) return null;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(habitRepositoryProvider);
    final name = _nameController.text.trim();
    final targetMinutes =
        _hasProgress ? int.tryParse(_targetMinutesController.text.trim()) : null;

    if (_isEditing) {
      final updated = widget.habit!.copyWith(
        name: name,
        frequency: _frequency,
        scheduledTime: Value(_combinedScheduledTime),
        hasProgress: _hasProgress,
        targetMinutes: Value(targetMinutes),
      );
      await repo.updateHabit(updated);
    } else {
      await repo.createHabit(
        name: name,
        frequency: _frequency,
        scheduledTime: _combinedScheduledTime,
        hasProgress: _hasProgress,
        targetMinutes: targetMinutes,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editHabitTitle : l10n.addHabitTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.fieldNameLabel),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.habitNameRequiredError
                  : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.fieldFrequencyLabel, style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<HabitFrequency>(
              groupValue: _frequency,
              onChanged: (value) => setState(() => _frequency = value!),
              child: Column(
                children: [
                  for (final frequency in HabitFrequency.values)
                    RadioListTile<HabitFrequency>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(frequency.label(context)),
                      value: frequency,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.fieldScheduledTimeOptionalLabel),
              subtitle: Text(
                _scheduledTime == null ? '-' : _scheduledTime!.format(context),
              ),
              trailing: _scheduledTime == null
                  ? const Icon(Icons.access_time_rounded)
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _scheduledTime = null),
                    ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 8),
            Text(l10n.hasProgressLabel, style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<bool>(
              groupValue: _hasProgress,
              onChanged: (value) => setState(() => _hasProgress = value!),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.yesLabel),
                    value: true,
                  ),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.noLabel),
                    value: false,
                  ),
                ],
              ),
            ),
            if (_hasProgress) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetMinutesController,
                decoration: InputDecoration(labelText: l10n.targetMinutesLabel),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_hasProgress) return null;
                  final parsed = int.tryParse(value?.trim() ?? '');
                  return (parsed == null || parsed <= 0)
                      ? l10n.targetMinutesInvalidError
                      : null;
                },
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(l10n.saveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
