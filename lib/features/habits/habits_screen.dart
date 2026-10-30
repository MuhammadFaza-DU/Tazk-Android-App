import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_row.dart';
import '../../core/widgets/progress_bar.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import 'habit_detail_screen.dart';
import 'habit_form_screen.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppScaffold(
      title: l10n.habitsScreenTitle,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addHabitTitle,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        onPressed: () {
          Navigator.of(context).push(
            AppPageRoute(builder: (_) => const HabitFormScreen()),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: habitsAsync.when(
        data: (habits) => habits.isEmpty
            ? Center(child: EmptyState(message: l10n.homeNoActiveHabits))
            : _HabitList(habits: habits),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.errorLoadingHabits(error.toString()),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitList extends StatelessWidget {
  const _HabitList({required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // bottom 96 = ruang FAB
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < habits.length; i++)
                _HabitRow(
                  habit: habits[i],
                  showDivider: i < habits.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit, required this.showDivider});

  final Habit habit;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(habitTodayLogProvider(habit.id)).valueOrNull;
    final isCompleted = todayLog?.isCompleted ?? false;
    final l10n = AppLocalizations.of(context)!;

    final String subtitle;
    final Widget? trailing;
    if (habit.hasProgress) {
      final current = todayLog?.progressMinutes ?? 0;
      final target = habit.targetMinutes ?? 0;
      subtitle = l10n.habitProgressLabel(current, target);
      trailing = SizedBox(
        width: 72,
        child: ProgressBar(
          value: target > 0 ? current / target : 0,
        ),
      );
    } else {
      subtitle = habit.frequency.label(context);
      trailing = null;
    }

    return ListRow(
      leading: CompletionCheckbox(
        value: isCompleted,
        onComplete: () =>
            ref.read(habitRepositoryProvider).completeHabitToday(habit.id),
        onUncomplete: () =>
            ref.read(habitRepositoryProvider).uncompleteHabitToday(habit.id),
      ),
      title: habit.name,
      crossedOut: isCompleted,
      subtitle: subtitle,
      trailing: trailing,
      showDivider: showDivider,
      onTap: () {
        Navigator.of(context).push(
          AppPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        );
      },
    );
  }
}