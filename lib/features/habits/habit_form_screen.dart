import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/models/enums.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Habit' : 'Tambah Habit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Text('Frekuensi', style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<HabitFrequency>(
              groupValue: _frequency,
              onChanged: (value) => setState(() => _frequency = value!),
              child: Column(
                children: [
                  for (final frequency in HabitFrequency.values)
                    RadioListTile<HabitFrequency>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(frequency.label),
                      value: frequency,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Waktu (opsional)'),
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
            Text('Progress bertahap?', style: Theme.of(context).textTheme.titleSmall),
            RadioGroup<bool>(
              groupValue: _hasProgress,
              onChanged: (value) => setState(() => _hasProgress = value!),
              child: const Column(
                children: [
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Ya'),
                    value: true,
                  ),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Tidak'),
                    value: false,
                  ),
                ],
              ),
            ),
            if (_hasProgress) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetMinutesController,
                decoration: const InputDecoration(labelText: 'Target waktu (menit)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_hasProgress) return null;
                  final parsed = int.tryParse(value?.trim() ?? '');
                  return (parsed == null || parsed <= 0)
                      ? 'Masukkan target menit yang valid'
                      : null;
                },
              ),
            ],
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
