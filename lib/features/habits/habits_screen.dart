import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/completion_checkbox.dart';
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

    return AppScaffold(
      title: l10n.habitsScreenTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HabitFormScreen()),
            );
          },
        ),
      ],
      body: habitsAsync.when(
        data: (habits) => habits.isEmpty
            ? Center(child: Text(l10n.homeNoActiveHabits))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: habits.length,
                itemBuilder: (context, index) => _HabitListTile(habit: habits[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorLoadingHabits(error.toString()))),
      ),
    );
  }
}

class _HabitListTile extends ConsumerWidget {
  const _HabitListTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(habitTodayLogProvider(habit.id)).valueOrNull;
    final isCompleted = todayLog?.isCompleted ?? false;
    final l10n = AppLocalizations.of(context)!;

    final subtitle = habit.hasProgress
        ? l10n.habitProgressLabel(todayLog?.progressMinutes ?? 0, habit.targetMinutes ?? 0)
        : habit.frequency.label(context);

    return ListTile(
      leading: CompletionCheckbox(
        value: isCompleted,
        onComplete: isCompleted
            ? null
            : () => ref.read(habitRepositoryProvider).completeHabitToday(habit.id),
      ),
      title: Text(
        habit.name,
        style: isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(subtitle),
      trailing: habit.hasProgress ? const Icon(Icons.timer_outlined) : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
        );
      },
    );
  }
}
