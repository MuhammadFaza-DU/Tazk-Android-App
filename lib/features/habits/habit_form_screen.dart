import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';

/// Key baris pemilih frekuensi (empat chip sejajar, sesuai board).
const Key habitFormFrequencySelectorKey = ValueKey('habit-form-frequency');

/// Key chip satu frekuensi. Dipakai test untuk memeriksa state terpilih.
Key habitFormFrequencyChipKey(HabitFrequency frequency) =>
    ValueKey('habit-form-frequency-${frequency.name}');

/// Key baris waktu pengingat (pill waktu + pill hapus).
const Key habitFormReminderRowKey = ValueKey('habit-form-reminder');

/// Key kartu "progress bertahap" (judul + switch + baris target).
const Key habitFormProgressCardKey = ValueKey('habit-form-progress');

/// Key baris target menit di dalam kartu progress.
const Key habitFormTargetRowKey = ValueKey('habit-form-target');

/// Key tombol simpan.
const Key habitFormSaveButtonKey = ValueKey('habit-form-save');

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habit});

  /// Null means "create new habit"; non-null means "edit existing habit".
  final Habit? habit;

  /// Board `design-export/24 Habit Form.png` (780×1048 px, @2x → frame 390dp),
  /// diukur per piksel lalu dibagi 2. Semua angka di bawah berasal dari sana.
  static const double gutter = 20; // px 40 → 20dp
  static const double tapTarget = 48; // lantai `DESIGN.md` Layout
  static const double frequencyChipHeight = 38; // px 74 → 37dp (dibulatkan 38)
  static const double frequencyChipRadius = 12; // px 25 → 12,5dp
  static const double frequencyChipGap = 8; // px 15 → 7,5dp
  static const double reminderPillHeight = 32; // px 64 → 32dp
  static const double progressCardPadding = 14; // px 28 → 14dp
  static const double targetRowHeight = 36; // px 70 → 35dp
  static const double targetRowRadius = 10; // rounded.sm

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetFocusNode = FocusNode();
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
    _targetFocusNode.dispose();
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
    // PRD: a custom weekly habit with zero selected days would never be due,
    // so the save must be blocked (the inline warning alone is not enough).
    if (_isCustomFrequency &&
        _customFrequencyType == 0 &&
        _customDaysOfWeek.isEmpty) {
      showAppSnackbar(
        context,
        AppLocalizations.of(context)!.customDaysRequiredError,
      );
      return;
    }

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
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppScaffold(
      title: _isEditing ? l10n.editHabitTitle : l10n.addHabitTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          // Board: gutter 20dp; jarak header → label pertama 0,75dp (AppBar
          // sudah menyisakan 8dp di bawah lingkaran back), jadi dipakai 4.
          padding: const EdgeInsets.fromLTRB(
            HabitFormScreen.gutter,
            4,
            HabitFormScreen.gutter,
            HabitFormScreen.gutter,
          ),
          children: [
            _FieldLabel(l10n.fieldNameLabel),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.habitNameRequiredError
                  : null,
            ),
            const SizedBox(height: 16),
            _FieldLabel(l10n.fieldFrequencyLabel),
            const SizedBox(height: 4),
            _FrequencySelector(
              value: _frequency,
              onChanged: (value) => setState(() => _frequency = value),
            ),

            // Custom frequency configuration
            if (_isCustomFrequency) ...[
              const SizedBox(height: 12),
              _buildCustomFrequencyCard(l10n, colors, theme),
            ],

            const SizedBox(height: 11),
            _FieldLabel(l10n.fieldScheduledTimeOptionalLabel),
            const SizedBox(height: 2),
            _buildReminderRow(l10n, colors),
            const SizedBox(height: 8),
            _buildProgressCard(l10n, colors, theme),
            const SizedBox(height: 16),
            AppButton.primary(
              key: habitFormSaveButtonKey,
              label: l10n.saveButton,
              onPressed: _save,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu frekuensi kustom (hari / interval / tanggal). Isi dan validator
  /// tidak diubah dari implementasi sebelumnya; hanya dibungkus ke method.
  Widget _buildCustomFrequencyCard(
    AppLocalizations l10n,
    AppColors colors,
    ThemeData theme,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.customFrequencyConfigTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          // Custom type selector
          Text(l10n.customFrequencyTypeLabel,
              style: theme.textTheme.labelLarge),
          RadioGroup<int>(
            groupValue: _customFrequencyType,
            onChanged: (value) =>
                setState(() => _customFrequencyType = value!),
            child: Material(
              type: MaterialType.transparency,
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
          ),
          const SizedBox(height: 12),
          // Weekly days configuration
          if (_customFrequencyType == 0) ...[
            Text(l10n.customDaysOfWeekLabel,
                style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final dayValue = 1 << index;
                final isSelected =
                    _customDaysOfWeek.contains(dayValue);
                final dayName = [
                  l10n.weekdayMonShort,
                  l10n.weekdayTueShort,
                  l10n.weekdayWedShort,
                  l10n.weekdayThuShort,
                  l10n.weekdayFriShort,
                  l10n.weekdaySatShort,
                  l10n.weekdaySunShort,
                ][index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggleDayOfWeek(dayValue),
                  child: AppChip(
                    label: dayName,
                    backgroundColor: isSelected
                        ? colors.primaryContainer
                        : colors.surfaceAlt,
                    foregroundColor: isSelected
                        ? colors.primary
                        : colors.inkMuted,
                  ),
                );
              }),
            ),
            if (_customDaysOfWeek.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.customDaysRequiredError,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.danger),
                ),
              ),
          ],
          // Interval days configuration
          if (_customFrequencyType == 1) ...[
            AppTextField(
              controller: _customIntervalController,
              labelText: l10n.customIntervalLabel,
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
            const SizedBox(height: 4),
            Text(
              l10n.customIntervalHelper,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.inkMuted),
            ),
          ],
          // Monthly day configuration
          if (_customFrequencyType == 2) ...[
            AppTextField(
              initialValue: _customDayOfMonth.toString(),
              labelText: l10n.customDayOfMonthLabel,
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
            const SizedBox(height: 4),
            Text(
              l10n.customDayOfMonthHelper,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }

  /// Board: satu pill `primary-container` berisi jam + teks waktu, lalu pill
  /// outline "Hapus" saat waktu sudah diisi. Belum ada waktu → pill ikon saja
  /// (state ini tidak digambar di board; lihat laporan deviasi).
  Widget _buildReminderRow(AppLocalizations l10n, AppColors colors) {
    final time = _scheduledTime;
    return SizedBox(
      key: habitFormReminderRowKey,
      height: HabitFormScreen.tapTarget,
      child: Row(
        children: [
          _ReminderPill(
            icon: Icons.access_time_rounded,
            label: time?.format(context),
            semanticLabel: l10n.fieldScheduledTimeOptionalLabel,
            filled: time != null,
            onTap: _pickTime,
          ),
          if (time != null) ...[
            const SizedBox(width: HabitFormScreen.frequencyChipGap),
            _ReminderPill(
              icon: Icons.close_rounded,
              label: l10n.deleteButton,
              filled: false,
              onTap: () => setState(() => _scheduledTime = null),
            ),
          ],
        ],
      ),
    );
  }

  /// Board: kartu `surface` berbingkai 1px, judul tebal + switch, lalu baris
  /// target `canvas` (radius 10) berisi label, angka, dan ikon pensil.
  Widget _buildProgressCard(
    AppLocalizations l10n,
    AppColors colors,
    ThemeData theme,
  ) {
    return AppCard(
      key: habitFormProgressCardKey,
      padding: const EdgeInsets.all(HabitFormScreen.progressCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: InkWell(
              onTap: () => setState(() => _hasProgress = !_hasProgress),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.hasProgressLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
                    ),
                  ),
                  // Switch Material membawa area sentuh 48dp sendiri, jadi
                  // baris tidak perlu padding tambahan.
                  Switch(
                    value: _hasProgress,
                    activeTrackColor: colors.primary,
                    activeThumbColor: colors.onPrimary,
                    onChanged: (value) => setState(() => _hasProgress = value),
                  ),
                ],
              ),
            ),
          ),
          if (_hasProgress) ...[
            const SizedBox(height: 6),
            _buildTargetRow(l10n, colors, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildTargetRow(
    AppLocalizations l10n,
    AppColors colors,
    ThemeData theme,
  ) {
    return GestureDetector(
      key: habitFormTargetRowKey,
      behavior: HitTestBehavior.opaque,
      onTap: _targetFocusNode.requestFocus,
      child: Padding(
        // Visual board 35dp; area sentuh dinaikkan ke 48dp lewat padding ini.
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          constraints:
              const BoxConstraints(minHeight: HabitFormScreen.targetRowHeight),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.canvas,
            borderRadius:
                BorderRadius.circular(HabitFormScreen.targetRowRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.targetMinutesLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                child: TextFormField(
                  controller: _targetMinutesController,
                  focusNode: _targetFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                  validator: (value) {
                    if (!_hasProgress) return null;
                    final parsed = int.tryParse(value?.trim() ?? '');
                    return (parsed == null || parsed <= 0)
                        ? l10n.targetMinutesInvalidError
                        : null;
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    errorStyle: theme.textTheme.bodySmall
                        ?.copyWith(color: colors.danger),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.edit_outlined, size: 16, color: colors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label field di atas kontrol (board: `labelLarge` `ink-muted`, bukan label
/// mengambang di dalam field).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: colors.inkMuted),
    );
  }
}

/// Board: empat chip sejajar (Harian · Mingguan · Bulanan · Custom), lebar
/// sama, jarak 8dp, radius 12, tinggi visual 38dp di dalam area sentuh 48dp.
class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({required this.value, required this.onChanged});

  final HabitFrequency value;
  final ValueChanged<HabitFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    const frequencies = HabitFrequency.values;
    return SizedBox(
      key: habitFormFrequencySelectorKey,
      height: HabitFormScreen.tapTarget,
      child: Row(
        children: [
          for (var i = 0; i < frequencies.length; i++) ...[
            if (i > 0)
              const SizedBox(width: HabitFormScreen.frequencyChipGap),
            Expanded(
              child: _FrequencyChip(
                frequency: frequencies[i],
                selected: frequencies[i] == value,
                onTap: () => onChanged(frequencies[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.frequency,
    required this.selected,
    required this.onTap,
  });

  final HabitFrequency frequency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    const radius = HabitFormScreen.frequencyChipRadius;
    const slack =
        (HabitFormScreen.tapTarget - HabitFormScreen.frequencyChipHeight) / 2;

    return InkWell(
      key: habitFormFrequencyChipKey(frequency),
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: slack),
        child: AnimatedContainer(
          duration: context.motion(AppMotion.fast),
          curve: AppMotion.easeStandard,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(radius),
            // Border selalu ada supaya lebar tidak bergeser saat memilih.
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Text(
            frequency.label(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? colors.onPrimary : colors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill aksi (waktu pengingat / hapus). Tinggi visual 32dp sesuai board,
/// area sentuh 48dp lewat padding vertikal.
class _ReminderPill extends StatelessWidget {
  const _ReminderPill({
    required this.icon,
    required this.filled,
    required this.onTap,
    this.label,
    this.semanticLabel,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  final String? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final foreground = filled ? colors.primary : colors.inkMuted;
    final label = this.label;
    const slack =
        (HabitFormScreen.tapTarget - HabitFormScreen.reminderPillHeight) / 2;

    final tappable = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: slack),
        child: Container(
          height: HabitFormScreen.reminderPillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: filled ? colors.primaryContainer : colors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: filled ? colors.primaryContainer : colors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style:
                      theme.textTheme.labelLarge?.copyWith(color: foreground),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Pill ikon-saja (waktu belum diisi) butuh nama aksesibel eksplisit.
    if (label != null) return tappable;
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: tappable,
    );
  }
}
