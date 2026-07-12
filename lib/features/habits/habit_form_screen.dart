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
  late final TextEditingController _customIntervalController;

  late HabitFrequency _frequency;
  TimeOfDay? _scheduledTime;
  late bool _hasProgress;

  // Custom frequency fields
  late Set<int> _customDaysOfWeek; // 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
  late int _customInterval;
  late int _customDayOfMonth;
  late int _customFrequencyType; // 0=weeklyDays, 1=intervalDays, 2=monthlyDay

  bool get _isEditing => widget.habit != null;
  bool get _isCustomFrequency => _frequency == HabitFrequency.custom;

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

    // Initialize custom frequency fields
    _customDaysOfWeek = _intToDaySet(habit?.customDaysOfWeek ?? 0);
    _customInterval = habit?.customInterval ?? 1;
    _customDayOfMonth = habit?.customDayOfMonth ?? DateTime.now().day;
    _customFrequencyType = habit?.customFrequencyType ?? 0;
    _customIntervalController = TextEditingController(text: _customInterval.toString());
  }

  Set<int> _intToDaySet(int bitmask) {
    final days = <int>{};
    for (int i = 0; i < 7; i++) {
      final dayValue = 1 << i;
      if ((bitmask & dayValue) != 0) {
        days.add(dayValue);
      }
    }
    return days;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetMinutesController.dispose();
    _customIntervalController.dispose();
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

  void _toggleDayOfWeek(int day) {
    setState(() {
      if (_customDaysOfWeek.contains(day)) {
        _customDaysOfWeek.remove(day);
      } else {
        _customDaysOfWeek.add(day);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(habitRepositoryProvider);
    final name = _nameController.text.trim();
    final targetMinutes =
        _hasProgress ? int.tryParse(_targetMinutesController.text.trim()) : null;

    // Prepare custom frequency values
    final customDaysOfWeek = _isCustomFrequency && _customFrequencyType == 0 && _customDaysOfWeek.isNotEmpty
        ? Value(_customDaysOfWeek.fold(0, (sum, day) => sum | day))
        : const Value(null);
    final customInterval = _isCustomFrequency && _customFrequencyType == 1 && _customInterval > 0
        ? Value(_customInterval)
        : const Value(null);
    final customDayOfMonth = _isCustomFrequency && _customFrequencyType == 2 && _customDayOfMonth > 0
        ? Value(_customDayOfMonth)
        : const Value(null);
    final customFrequencyType = _isCustomFrequency ? Value(_customFrequencyType) : const Value(null);

    if (_isEditing) {
      final updated = widget.habit!.copyWith(
        name: name,
        frequency: _frequency,
        scheduledTime: Value(_combinedScheduledTime),
        hasProgress: _hasProgress,
        targetMinutes: Value(targetMinutes),
        customDaysOfWeek: customDaysOfWeek,
        customInterval: customInterval,
        customDayOfMonth: customDayOfMonth,
        customFrequencyType: customFrequencyType,
      );
      await repo.updateHabit(updated);
    } else {
      await repo.createHabit(
        name: name,
        frequency: _frequency,
        scheduledTime: _combinedScheduledTime,
        hasProgress: _hasProgress,
        targetMinutes: targetMinutes,
        customDaysOfWeek: customDaysOfWeek.value,
        customInterval: customInterval.value,
        customDayOfMonth: customDayOfMonth.value,
        customFrequencyType: customFrequencyType.value,
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
            
            // Custom frequency configuration
            if (_isCustomFrequency) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.customFrequencyConfigTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      // Custom type selector
                      Text(l10n.customFrequencyTypeLabel, style: Theme.of(context).textTheme.titleSmall),
                      RadioGroup<int>(
                        groupValue: _customFrequencyType,
                        onChanged: (value) => setState(() => _customFrequencyType = value!),
                        child: Column(
                          children: [
                            RadioListTile<int>(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.customTypeWeeklyDays),
                              value: 0,
                            ),
                            RadioListTile<int>(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.customTypeIntervalDays),
                              value: 1,
                            ),
                            RadioListTile<int>(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.customTypeMonthlyDay),
                              value: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Weekly days configuration
                      if (_customFrequencyType == 0) ...[
                        Text(l10n.customDaysOfWeekLabel, style: Theme.of(context).textTheme.titleSmall),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) {
                            final dayValue = 1 << index;
                            final isSelected = _customDaysOfWeek.contains(dayValue);
                            final dayName = [
                              l10n.weekdayMonShort,
                              l10n.weekdayTueShort,
                              l10n.weekdayWedShort,
                              l10n.weekdayThuShort,
                              l10n.weekdayFriShort,
                              l10n.weekdaySatShort,
                              l10n.weekdaySunShort,
                            ][index];
                            return FilterChip(
                              label: Text(dayName),
                              selected: isSelected,
                              onSelected: (_) => _toggleDayOfWeek(dayValue),
                            );
                          }),
                        ),
                        if (_customDaysOfWeek.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l10n.customDaysRequiredError,
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                            ),
                          ),
                      ],
                      // Interval days configuration
                      if (_customFrequencyType == 1) ...[
                        TextFormField(
                          controller: _customIntervalController,
                          decoration: InputDecoration(
                            labelText: l10n.customIntervalLabel,
                            helperText: l10n.customIntervalHelper,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_customFrequencyType != 1) return null;
                            final parsed = int.tryParse(value?.trim() ?? '');
                            return (parsed == null || parsed <= 0)
                                ? l10n.customIntervalInvalidError
                                : null;
                          },
                          onChanged: (value) {
                            final parsed = int.tryParse(value.trim());
                            if (parsed != null && parsed > 0) {
                              _customInterval = parsed;
                            }
                          },
                        ),
                      ],
                      // Monthly day configuration
                      if (_customFrequencyType == 2) ...[
                        TextFormField(
                          initialValue: _customDayOfMonth.toString(),
                          decoration: InputDecoration(
                            labelText: l10n.customDayOfMonthLabel,
                            helperText: l10n.customDayOfMonthHelper,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_customFrequencyType != 2) return null;
                            final parsed = int.tryParse(value?.trim() ?? '');
                            return (parsed == null || parsed < 1 || parsed > 31)
                                ? l10n.customDayOfMonthInvalidError
                                : null;
                          },
                          onChanged: (value) {
                            final parsed = int.tryParse(value.trim());
                            if (parsed != null && parsed >= 1 && parsed <= 31) {
                              _customDayOfMonth = parsed;
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            
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