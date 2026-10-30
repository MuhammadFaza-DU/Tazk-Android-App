// dev-only
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_row.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/models/enums.dart';

/// Halaman preview 12 komponen design system v2, light + dark.
/// Self-contained (MaterialApp sendiri) supaya bisa dibuka dari entry debug
/// tanpa bergantung theme aplikasi utama.
class ComponentPreviewScreen extends StatefulWidget {
  const ComponentPreviewScreen({super.key});

  @override
  State<ComponentPreviewScreen> createState() => _ComponentPreviewScreenState();
}

class _ComponentPreviewScreenState extends State<ComponentPreviewScreen> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleMode() {
    setState(() {
      _mode =
          _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // dev-only
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _mode,
      home: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Component Preview'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AppButton.ghost(
                    key: const Key('preview_theme_toggle'),
                    label: _mode == ThemeMode.light ? 'Dark' : 'Light',
                    icon: _mode == ThemeMode.light
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    onPressed: _toggleMode,
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _label(context, '1 — AppCard'),
                const AppCard(child: Text('Isi kartu (surface + border + md)')),
                const SizedBox(height: 16),
                _label(context, '2 — AppButton'),
                const AppButton.primary(label: 'Primary'),
                const SizedBox(height: 8),
                const AppButton.secondary(label: 'Secondary'),
                const SizedBox(height: 8),
                const AppButton.ghost(label: 'Ghost'),
                const SizedBox(height: 8),
                const AppButton.primary(
                  label: 'Disabled',
                  icon: Icons.lock_outline,
                  onPressed: null,
                ),
                const SizedBox(height: 16),
                _label(context, '3 — AppChip'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChip(
                      label: 'Custom',
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.primary,
                    ),
                    const AppChip.priority(
                      TaskPriority.high,
                      label: 'High',
                    ),
                    const AppChip.priority(
                      TaskPriority.medium,
                      label: 'Medium',
                    ),
                    const AppChip.priority(
                      TaskPriority.low,
                      label: 'Low',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label(context, '4 — AppTextField'),
                const AppTextField(hintText: 'Hint', labelText: 'Label'),
                const SizedBox(height: 16),
                _label(context, '5 — SectionHeader'),
                SectionHeader(
                  title: 'Statistik',
                  action: AppButton.ghost(
                    label: 'Lihat',
                    onPressed: () =>
                        showAppSnackbar(context, 'Section header action'),
                  ),
                ),
                const SizedBox(height: 16),
                _label(context, '6 — EmptyState'),
                EmptyState(
                  message: 'Belum ada data. Mulai dengan menambah satu tugas.',
                  action: const AppButton.secondary(label: 'Tambah tugas'),
                ),
                const SizedBox(height: 16),
                _label(context, '7 — StatTile'),
                const Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Streak',
                        value: '12',
                        icon: Icons.local_fire_department_outlined,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatTile(label: 'XP', value: '340'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label(context, '8 — ProgressBar'),
                const ProgressBar(value: 0.35),
                const SizedBox(height: 8),
                const ProgressBar(value: 0.7),
                const SizedBox(height: 8),
                const ProgressBar(value: 0.0),
                const SizedBox(height: 16),
                _label(context, '9 — AppSheet'),
                AppButton.ghost(
                  label: 'Buka sheet',
                  onPressed: () => showAppSheet(
                    context,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Isi sheet'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _label(context, '10 — AppDialog'),
                AppButton.ghost(
                  label: 'Buka dialog',
                  onPressed: () => showAppDialog(
                    context,
                    title: 'Hapus tugas?',
                    content: const Text('Tindakan ini tidak bisa dibatalkan.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _label(context, '11 — AppSnackbar'),
                AppButton.ghost(
                  label: 'Tampilkan snackbar',
                  onPressed: () => showAppSnackbar(context, 'Berhasil disimpan'),
                ),
                const SizedBox(height: 16),
                _label(context, '12 — ListRow'),
                const AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListRow(
                        leading: Icon(Icons.check_circle_outline),
                        title: 'Selesaikan laporan',
                        subtitle: '18:00 · Medium',
                        trailing: Icon(Icons.chevron_right),
                      ),
                      ListRow(
                        leading: Icon(Icons.local_drink_outlined),
                        title: 'Minum air 8 gelas',
                        trailing: Icon(Icons.chevron_right),
                      ),
                      ListRow(
                        leading: Icon(Icons.school_outlined),
                        title: 'Belajar matematika',
                        subtitle: 'Subjudul baris',
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: context.colors.inkMuted),
      ),
    );
  }
}