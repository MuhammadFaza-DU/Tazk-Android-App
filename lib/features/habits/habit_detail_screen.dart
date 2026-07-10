import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => HabitFormScreen(habit: habit)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.frequencyDisplay(habit.frequency.label(context))),
          const SizedBox(height: 8),
          Text(
            l10n.streakContributionDisplay(
              isActiveToday ? l10n.streakContributionActive : l10n.streakContributionInactive,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.historyTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          historyAsync.when(
            data: (logs) => _HistoryGrid(logs: logs),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(l10n.errorLoadingHistory(error.toString())),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteHabitDialogTitle),
        content: Text(l10n.deleteHabitDialogContent(habit.name)),
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

    if (confirmed != true) return;
    await ref.read(habitRepositoryProvider).deactivateHabit(habit.id);
    if (context.mounted) Navigator.of(context).pop();
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
    return Column(
      children: [
        Text(_weekdayAbbrev(AppLocalizations.of(context)!)[day.weekday - 1]),
        const SizedBox(height: 4),
        Icon(
          _isCompleted ? Icons.check_circle_rounded : Icons.cancel_outlined,
          color: _isCompleted ? Colors.green : Colors.grey,
        ),
      ],
    );
  }
}
