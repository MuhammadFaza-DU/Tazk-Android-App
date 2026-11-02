import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/geo_uri.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/category_picker.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';

/// Key grup pemilih prioritas (board `10 Task Form`: tiga kotak sejajar).
const Key taskFormPrioritySelectorKey = ValueKey('task-form-priority-selector');

/// Key tiap segmen prioritas.
Key taskFormPrioritySegmentKey(TaskPriority priority) =>
    ValueKey('task-form-priority-${priority.name}');

/// Key kotak tanggal dan kotak jam (board: dua kotak berdampingan).
const Key taskFormDateBoxKey = ValueKey('task-form-date-box');
const Key taskFormTimeBoxKey = ValueKey('task-form-time-box');

/// Key tombol simpan di bawah checklist.
const Key taskFormSaveButtonKey = ValueKey('task-form-save');

/// Key input "Tambah item" di bawah baris checklist.
const Key taskFormAddItemFieldKey = ValueKey('task-form-add-item-field');

/// Key field lokasi (free text; dibuka ke aplikasi maps lewat ikon di kanan).
const Key taskFormLocationFieldKey = ValueKey('task-form-location-field');

/// Key tombol "buka di Maps" pada field lokasi.
const Key taskFormOpenMapsKey = ValueKey('task-form-open-maps');

/// Key tombol hapus task di header form (hanya muncul saat mengedit).
const Key taskFormDeleteButtonKey = ValueKey('task-form-delete');

/// Key baris sakelar "tandai tugas selesai saat semua subtask beres".
const Key taskFormAutoCompleteSwitchKey =
    ValueKey('task-form-auto-complete-switch');

/// Gutter kiri/kanan. Board `10` mengukur 20dp; instruksi task menetapkan 16
/// dan `AppScaffold.gutter` (header) sudah 16, jadi dipakai 16 agar tepi field
/// sejajar dengan lingkaran back di atasnya.
const double _gutter = AppScaffold.gutter;

/// Jarak label → kontrolnya. Board mengukur ~10dp.
const double _labelGap = 8;

/// Jarak antar grup field. Board mengukur 19–21dp (antara `lg` 16 dan `xl` 24).
const double _groupGap = 20;

/// Jarak antar baris checklist. Board mengukur 7.5dp.
const double _rowGap = 8;

/// `rounded.md` — dipakai semua kotak field, chip, dan baris checklist.
const double _radius = 14;

/// Tinggi kotak tanggal/jam (board 42dp).
const double _boxHeight = 42;

/// Tinggi baris checklist & segmen prioritas (board 39dp, dibulatkan ke 40).
const double _rowHeight = 40;

const BorderRadius _boxRadius = BorderRadius.all(Radius.circular(_radius));

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

  /// Kategori tunggal (opsional) — tidak ada di board `10`, lihat laporan.
  int? _categoryId;

  /// Task selesai otomatis saat semua subtask dicentang (AGENTS §5). Task
  /// lama tanpa nilai eksplisit memakai `true`, sama dengan default skema.
  late bool _autoCompleteSubtasks;

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
    _categoryId = task?.categoryId;
    _autoCompleteSubtasks = task?.autoCompleteSubtasks ?? true;
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

  /// Serah-terima ke aplikasi maps yang terpasang. Lokasi hanya teks, jadi URI
  /// dibangun dari isi field saat ini — tidak pernah dari koordinat tersimpan.
  Future<void> _openLocationInMaps() async {
    final uri = buildGeoUri(_locationController.text);
    if (uri == null) return;
    // `launchUrl` bisa melempar `PlatformException` (mis. aktivitas tidak
    // resolvable); itu jalur gagal yang sama dengan `false`, jadi pengguna
    // mendapat pesan yang sama, bukan error tak tertangkap.
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('launchUrl failed: $error');
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.openInMapsFailedMessage),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(taskRepositoryProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: title,
        date: _date,
        time: Value(_combinedTime),
        priority: _priority,
        location: Value(location.isEmpty ? null : location),
        autoCompleteSubtasks: _autoCompleteSubtasks,
      );
      await repo.updateTask(updated);
      // `Task.categoryId` sengaja tidak ikut `copyWith` di atas: satu-satunya
      // jalur tulis kategori adalah repository kategori (yang juga memvalidasi
      // id-nya masih ada).
      await categoryRepo.setTaskCategory(widget.task!.id, _categoryId);
    } else {
      final newId = await repo.createTask(
        title: title,
        date: _date,
        time: _combinedTime,
        priority: _priority,
        location: location.isEmpty ? null : location,
        autoCompleteSubtasks: _autoCompleteSubtasks,
      );
      await categoryRepo.setTaskCategory(newId, _categoryId);
      for (final subtaskTitle in _newSubtaskTitles) {
        await repo.addSubtask(newId, subtaskTitle);
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Edit mode only: confirm, then delete the task and leave the form.
  Future<void> _delete() async {
    final task = widget.task;
    if (task == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteTaskTitle),
        content: Text(l10n.deleteTaskBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(taskRepositoryProvider).deleteTask(task.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
  String _dateLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    try {
      return DateFormat('d MMM yyyy', locale).format(_date);
    } catch (_) {
      return DateFormat('d MMM yyyy', 'en').format(_date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppScaffold(
      title: _isEditing ? l10n.editTaskTitle : l10n.addTaskTitle,
      actions: [
        if (_isEditing)
          IconButton(
            key: taskFormDeleteButtonKey,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.deleteButton,
            onPressed: _delete,
          ),
      ],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 16),
          children: [
            // 1. Judul
            _FieldLabel(l10n.fieldTitleLabel),
            const SizedBox(height: _labelGap),
            Semantics(
              label: l10n.fieldTitleLabel,
              child: AppTextField(
                controller: _titleController,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.taskTitleRequiredError
                    : null,
              ),
            ),
            const SizedBox(height: _groupGap),

            // 2. Tanggal + jam, dua kotak berdampingan.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(l10n.fieldDateLabel),
                      const SizedBox(height: _labelGap),
                      _ValueBox(
                        key: taskFormDateBoxKey,
                        semanticsLabel:
                            '${l10n.fieldDateLabel}, ${_dateLabel(context)}',
                        text: _dateLabel(context),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(l10n.fieldTimeOptionalLabel),
                      const SizedBox(height: _labelGap),
                      _ValueBox(
                        key: taskFormTimeBoxKey,
                        semanticsLabel: _time == null
                            ? l10n.fieldTimeOptionalLabel
                            : '${l10n.fieldTimeOptionalLabel}, '
                                '${_time!.format(context)}',
                        text: _time == null ? '-' : _time!.format(context),
                        placeholder: _time == null,
                        onTap: _pickTime,
                        trailing: _time == null
                            ? null
                            : _ClearTimeButton(
                                onPressed: () => setState(() => _time = null),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: _groupGap),

            // 3. Prioritas — segmented tiga kotak, bukan radio.
            _FieldLabel(l10n.fieldPriorityLabel),
            const SizedBox(height: _labelGap),
            _PrioritySelector(
              value: _priority,
              onChanged: (value) => setState(() => _priority = value),
            ),
            const SizedBox(height: _groupGap),

            // 3b. Kategori (tidak ada di board `10`; kebutuhan produk T7).
            _FieldLabel(l10n.fieldCategoryOptionalLabel),
            const SizedBox(height: _labelGap),
            CategoryPicker(
              value: _categoryId,
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: _groupGap),

            // 4. Lokasi (tidak ada di board; dipertahankan agar field DB tetap
            // bisa diisi — lihat laporan deviasi). Ikon kanan membuka label ini
            // di aplikasi maps lewat URI `geo:`.
            _FieldLabel(l10n.fieldLocationOptionalLabel),
            const SizedBox(height: _labelGap),
            Semantics(
              label: l10n.fieldLocationOptionalLabel,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _locationController,
                builder: (context, value, _) {
                  // Hidup saat diketik, bukan saat disimpan: tombolnya langsung
                  // aktif begitu ada isi yang bisa dicari.
                  final canOpenMaps = value.text.trim().isNotEmpty;
                  return AppTextField(
                    key: taskFormLocationFieldKey,
                    controller: _locationController,
                    suffixIcon: IconButton(
                      key: taskFormOpenMapsKey,
                      icon: const Icon(Icons.map_outlined),
                      tooltip: l10n.openInMapsTooltip,
                      color: colors.primary,
                      // `inkMuted`, bukan `border`: saat mati ikonnya harus
                      // masih terbaca sebagai affordance, hanya tidak aktif.
                      disabledColor: colors.inkMuted,
                      onPressed: canOpenMaps ? _openLocationInMaps : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: _groupGap),

            // 5. Checklist/subtask.
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.checklistOptionalLabel,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: colors.inkMuted),
                  ),
                ),
                _ChecklistCounter(
                  taskId: _isEditing ? widget.task!.id : null,
                  newCount: _newSubtaskTitles.length,
                ),
              ],
            ),
            const SizedBox(height: _rowGap),
            _AutoCompleteSubtasksRow(
              key: taskFormAutoCompleteSwitchKey,
              value: _autoCompleteSubtasks,
              onChanged: (value) =>
                  setState(() => _autoCompleteSubtasks = value),
            ),
            // Baris tersimpan sudah membawa 4dp atas di dalam pita sentuhnya
            // sendiri, jadi gap depan dikurangi supaya tetap 8dp — sama dengan
            // daftar draft di bawah.
            SizedBox(
              height: _isEditing ? _rowGap - _subtaskHitPadding : _rowGap,
            ),
            if (_isEditing)
              _ExistingSubtasksList(taskId: widget.task!.id)
            else
              for (var i = 0; i < _newSubtaskTitles.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: _rowGap),
                  child: _SubtaskRow(
                    title: _newSubtaskTitles[i],
                    checkbox: const _StaticSubtaskCheckbox(),
                    trailing: _RemoveSubtaskButton(
                      onPressed: () => setState(
                        () => _newSubtaskTitles.remove(_newSubtaskTitles[i]),
                      ),
                    ),
                  ),
                ),
            _AddItemRow(
              controller: _subtaskInputController,
              hintText: l10n.addItemHint,
              onAdd: _addSubtaskField,
            ),
            const SizedBox(height: 16),

            // 6. Simpan.
            AppButton.primary(
              key: taskFormSaveButtonKey,
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

/// Label grup di atas kontrol: Plus Jakarta Sans 13 w600 `ink-muted`.
///
/// Semantiknya di-exclude karena setiap kontrol di bawahnya sudah membawa
/// labelnya sendiri (menghindari pembacaan ganda oleh TalkBack).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: context.colors.inkMuted),
      ),
    );
  }
}

/// Kotak nilai read-only yang bisa diketuk (tanggal/jam): isian `surface`,
/// garis 1px `border`, radius `md`, teks body `ink`.
class _ValueBox extends StatelessWidget {
  const _ValueBox({
    super.key,
    required this.text,
    required this.onTap,
    required this.semanticsLabel,
    this.trailing,
    this.placeholder = false,
  });

  final String text;
  final VoidCallback onTap;
  final String semanticsLabel;
  final Widget? trailing;

  /// Nilai kosong memakai `ink-muted` (`DESIGN.md` `input-field`).
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: _boxRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: _boxRadius,
          child: Container(
            height: _boxHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: _boxRadius,
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: placeholder ? colors.inkMuted : colors.ink,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol kecil untuk mengosongkan jam. Board tidak menampilkan affordance ini;
/// dipertahankan supaya jam opsional masih bisa dihapus saat mengedit task.
class _ClearTimeButton extends StatelessWidget {
  const _ClearTimeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).deleteButtonTooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Icon(Icons.close_rounded, size: 16, color: colors.inkMuted),
          ),
        ),
      ),
    );
  }
}

/// Pemilih prioritas board: tiga kotak sama lebar, jarak 8dp.
///
/// Terpilih = isian `honey-container`, garis `honey`, teks `warning-strong`
/// (`chip-priority`). Tidak terpilih = isian `surface`, garis `border`, teks
/// `ink-muted`.
class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.value, required this.onChanged});

  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = <(TaskPriority, String)>[
      (TaskPriority.low, l10n.priorityLow),
      (TaskPriority.medium, l10n.priorityMedium),
      (TaskPriority.high, l10n.priorityHigh),
    ];

    return Row(
      key: taskFormPrioritySelectorKey,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _PrioritySegment(
              key: taskFormPrioritySegmentKey(entries[i].$1),
              label: entries[i].$2,
              selected: entries[i].$1 == value,
              onTap: () => onChanged(entries[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _PrioritySegment extends StatelessWidget {
  const _PrioritySegment({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? colors.honeyContainer : colors.surface,
        borderRadius: _boxRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: _boxRadius,
          child: Container(
            height: _rowHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: _boxRadius,
              border: Border.all(
                color: selected ? colors.honey : colors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? colors.warningStrong : colors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Penghitung "selesai/total" di kanan judul checklist (board: `1/3`).
class _ChecklistCounter extends ConsumerWidget {
  const _ChecklistCounter({this.taskId, required this.newCount});

  /// Non-null saat mode edit: hitungan diambil dari subtask tersimpan.
  final int? taskId;
  final int newCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final style = theme.textTheme.labelLarge?.copyWith(color: colors.primary);

    if (taskId == null) {
      if (newCount == 0) return const SizedBox.shrink();
      return Text('0/$newCount', style: style);
    }

    final subtasks = ref.watch(taskSubtasksProvider(taskId!)).valueOrNull;
    if (subtasks == null || subtasks.isEmpty) return const SizedBox.shrink();
    final done = subtasks.where((subtask) => subtask.isCompleted).length;
    return Text('$done/${subtasks.length}', style: style);
  }
}

/// Baris checklist: kartu isian `surface`, garis 1px `border`, tinggi 40dp.
class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.title,
    required this.checkbox,
    this.trailing,
    this.completed = false,
  });

  final String title;
  final Widget checkbox;
  final Widget? trailing;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: _boxRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          checkbox,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                // Board: selesai = `ink-muted`. Status juga ditandai bentuk
                // (checkbox terisi), bukan warna saja (`DESIGN.md`).
                color: completed ? colors.inkMuted : colors.ink,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Kotak centang statis untuk subtask baru (belum tersimpan): garis 2px
/// `ink-muted`, radius 6, isian `surface`.
class _StaticSubtaskCheckbox extends StatelessWidget {
  const _StaticSubtaskCheckbox();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.inkMuted, width: 2),
      ),
    );
  }
}

/// Checkbox interaktif (mode edit) — bentuknya disamakan dengan board:
/// radius 6, garis 2px `ink-muted`, isian `primary` + centang `on-primary`.
class _SubtaskCheckbox extends StatelessWidget {
  const _SubtaskCheckbox({
    required this.value,
    required this.onComplete,
    required this.onUncomplete,
  });

  final bool value;
  final Future<void> Function() onComplete;
  final Future<void> Function() onUncomplete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CheckboxTheme(
      data: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: colors.inkMuted, width: 2),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surface,
        ),
        checkColor: WidgetStatePropertyAll(colors.onPrimary),
      ),
      child: CompletionCheckbox(
        value: value,
        onComplete: onComplete,
        onUncomplete: onUncomplete,
      ),
    );
  }
}

class _RemoveSubtaskButton extends StatelessWidget {
  const _RemoveSubtaskButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close_rounded, size: 16),
      color: context.colors.inkMuted,
      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed,
    );
  }
}

/// Baris "Tambah item": kotak isian `canvas` bergaris `border` dengan ikon `+`
/// `primary` dan input inline. Enter/`+` menambah item, sama seperti sebelumnya.
class _AddItemRow extends StatelessWidget {
  const _AddItemRow({
    required this.controller,
    required this.hintText,
    required this.onAdd,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: _rowHeight),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        // Board: isian `canvas` (bukan `surface`) agar terbaca sebagai aksi.
        color: colors.canvas,
        borderRadius: _boxRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: hintText,
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: Icon(Icons.add_rounded, size: 18, color: colors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              key: taskFormAddItemFieldKey,
              controller: controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onAdd(),
              style: theme.textTheme.bodyLarge,
              cursorColor: colors.primary,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle:
                    theme.textTheme.bodyLarge?.copyWith(color: colors.inkMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris sakelar "task selesai otomatis" tepat di bawah header checklist.
///
/// Board `10` tidak punya baris ini (keputusan produk, AGENTS §5), jadi bentuknya
/// memakai bahasa kartu yang sudah ada: baris setinggi ≥48dp, label `ink-muted`,
/// dan `Switch` M3 yang mewarisi `primary`/`surface-alt` dari tema. Seluruh baris
/// bisa diketuk supaya target sentuh tidak bergantung pada ukuran thumb.
class _AutoCompleteSubtasksRow extends StatelessWidget {
  const _AutoCompleteSubtasksRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    // Satu node pembaca layar: label + nilai sakelar, bukan dua target fokus
    // terpisah untuk baris dan thumb.
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: _boxRadius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.autoCompleteSubtasksLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tinggi minimum pita sentuh baris checklist. Baris digambar 40dp (board `10`),
/// tapi target sentuh wajib ≥48dp (AGENTS §7).
const double _subtaskTapTarget = 48;

/// Sisa pita sentuh di atas dan di bawah baris: (48 - 40) / 2 = 4dp.
const double _subtaskHitPadding = (_subtaskTapTarget - _rowHeight) / 2;

class _ExistingSubtasksList extends ConsumerWidget {
  const _ExistingSubtasksList({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(taskSubtasksProvider(taskId));
    final repo = ref.read(taskRepositoryProvider);

    /// Satu-satunya jalur tulis urutan: bangun permutasi lengkap dari daftar
    /// sekarang, lalu geser satu elemen dari indeks [from] ke [to].
    ///
    /// Indeks di luar rentang atau `from == to` = no-op, yaitu keadaan "naik"
    /// pada baris pertama dan "turun" pada baris terakhir.
    Future<void> moveSubtask(List<Subtask> subtasks, int from, int to) async {
      if (from == to || to < 0 || to >= subtasks.length) return;
      final ids = [for (final subtask in subtasks) subtask.id];
      ids.insert(to, ids.removeAt(from));
      try {
        await repo.reorderSubtasks(taskId, ids);
      } catch (error) {
        // Ditolak = tidak ada yang tertulis, jadi daftar dari stream sudah
        // menampilkan urutan yang benar; tidak ada yang di-rollback.
        debugPrint('reorderSubtasks rejected: $error');
      }
    }

    return subtasksAsync.when(
      data: (subtasks) {
        // Daftar kosong tidak menggambar baris apa pun, tapi 4dp atas tadi
        // sudah dipotong dari gap sebelum blok ini; dikembalikan supaya jarak
        // ke `+ Tambah item` tetap 8dp seperti daftar draft.
        if (subtasks.isEmpty) return const SizedBox(height: _subtaskHitPadding);
        return ReorderableListView.builder(
          // Bertumpuk di dalam ListView form: tidak punya scroll sendiri.
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Seluruh baris adalah permukaan tekan-lama, jadi handle bawaan
          // (yang muncul di kanan pada desktop) dimatikan.
          buildDefaultDragHandles: false,
          // Kartu board datar; baris yang terangkat pun tetap datar, bukan
          // memakai bayangan elevasi bawaan Material. `Material` transparan
          // tetap diperlukan: proxy drag hidup di Overlay, di luar `Scaffold`,
          // dan widget Material (Checkbox) butuh leluhur Material.
          proxyDecorator: (child, index, animation) => Material(
            type: MaterialType.transparency,
            child: child,
          ),
          itemCount: subtasks.length,
          itemBuilder: (context, index) {
            final subtask = subtasks[index];
            return Padding(
              // Kunci per id: identitas baris, bukan posisi.
              key: ValueKey<int>(subtask.id),
              padding: EdgeInsets.only(
                // Pita sentuh sudah menyumbang 4dp di bawah; sisa
                // `_rowGap - 4` membuat jarak ke `+ Tambah item` tetap 8dp.
                // Antar baris: 4 bawah + 4 atas = 8dp seperti board.
                bottom: index == subtasks.length - 1
                    ? _rowGap - _subtaskHitPadding
                    : 0,
              ),
              child: ReorderableDelayedDragStartListener(
                index: index,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _subtaskTapTarget),
                  // `Listener` bawaan ReorderableDelayedDragStartListener
                  // memakai `HitTestBehavior.deferToChild`, jadi pita 48dp baru
                  // ikut hit-test kalau ada RenderObject buram di dalamnya.
                  // Inilah yang membuat 4dp atas/bawah benar-benar bisa disentuh.
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    child: Align(
                      // `heightFactor: 1` = tinggi mengikuti baris (40dp), lalu
                      // dinaikkan ke 48dp oleh ConstrainedBox di atas.
                      heightFactor: 1,
                      child: _SubtaskRow(
                        title: subtask.title,
                        completed: subtask.isCompleted,
                        checkbox: _SubtaskCheckbox(
                          value: subtask.isCompleted,
                          onComplete: () =>
                              repo.toggleSubtask(subtask.id, true),
                          onUncomplete: () =>
                              repo.toggleSubtask(subtask.id, false),
                        ),
                        trailing: const _DragHandle(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          onReorderItem: (oldIndex, newIndex) =>
              moveSubtask(subtasks, oldIndex, newIndex),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// Penanda geser di ujung baris checklist.
///
/// Hanya penanda visual: yang menangkap tekan-lama adalah seluruh pita 48dp
/// (`ReorderableDelayedDragStartListener` + `Listener` opaque di dalamnya), jadi
/// target sentuhnya selebar kartu × 48dp, bukan 20dp ikonnya.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.drag_indicator_rounded,
      size: 20,
      color: context.colors.inkMuted,
    );
  }
}
