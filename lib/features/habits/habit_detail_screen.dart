import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import 'habit_form_screen.dart';

List<String> _weekdayAbbrev(AppLocalizations l10n) => [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(habitTodayLogProvider(habit.id)).valueOrNull;
    final historyAsync = ref.watch(habitHistoryProvider(habit.id));
    final isActiveToday = todayLog?.isCompleted ?? false;
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppScaffold(
      title: habit.name,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          tooltip: l10n.editHabitTitle,
          onPressed: () {
            Navigator.of(context).push(
              AppPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: l10n.deleteButton,
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16), // spacing.lg
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaRow(
                  icon: Icons.repeat_rounded,
                  text: l10n.frequencyDisplay(habit.frequency.label(context)),
                ),
                const SizedBox(height: 16),
                _MetaRow(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: isActiveToday ? colors.honey : colors.inkMuted,
                  text: l10n.streakContributionDisplay(
                    isActiveToday
                        ? l10n.streakContributionActive
                        : l10n.streakContributionInactive,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: l10n.historyTitle),
          const SizedBox(height: 12),
          AppCard(
            child: historyAsync.when(
              data: (logs) => _HistoryGrid(logs: logs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(l10n.errorLoadingHistory(error.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context,
      title: l10n.deleteHabitDialogTitle,
      content: Text(l10n.deleteHabitDialogContent(habit.name)),
      actions: [
        AppButton.ghost(
          label: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton.danger(
          label: l10n.deleteButton,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (confirmed != true) return;
    await ref.read(habitRepositoryProvider).deactivateHabit(habit.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

/// Baris ringkasan di kartu detail: ikon + teks body (`ink`), ikon `ink-muted`
/// (atau diwarnai `honey` saat streak aktif — penanda reward tanpa mengubah
/// teks).
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text, this.iconColor});

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? colors.inkMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _HistoryGrid extends StatelessWidget {
  const _HistoryGrid({required this.logs});

  final List<HabitLog> logs;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final day in days) _HistoryDayTile(day: day, logs: logs),
      ],
    );
  }
}

class _HistoryDayTile extends StatelessWidget {
  const _HistoryDayTile({required this.day, required this.logs});

  final DateTime day;
  final List<HabitLog> logs;

  bool get _isCompleted {
    return logs.any(
      (log) =>
          log.date.year == day.year &&
          log.date.month == day.month &&
          log.date.day == day.day &&
          log.isCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _weekdayAbbrev(AppLocalizations.of(context)!)[day.weekday - 1],
          style: theme.textTheme.labelSmall?.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 8),
        Icon(
          _isCompleted ? Icons.check_circle_rounded : Icons.cancel_outlined,
          size: 28,
          // Bentuk ikon yang berbeda adalah affordance utama; warna hanya
          // pendukung (DESIGN: "jangan hanya warna").
          color: _isCompleted ? colors.success : colors.inkMuted,
        ),
      ],
    );
  }
}