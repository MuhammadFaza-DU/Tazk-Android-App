import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/animated_xp_progress.dart';
import '../../core/widgets/celebration_overlay.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/exact_alarm_banner.dart';
import '../../core/widgets/notification_permission_banner.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import '../pomodoro/pomodoro_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreakRank? _previousRank;

  @override
  void initState() {
    super.initState();
    // PRD "Error States": if the corrupt database had to be reset, tell the
    // user plainly instead of letting their tasks silently vanish.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!databaseRecoveredFromCorruption.value) return;
      databaseRecoveredFromCorruption.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.dbResetMessage)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final streak = ref.watch(streakStateProvider).valueOrNull;
    final tasksAsync = ref.watch(todayTasksProvider);
    final todayHabits = ref.watch(todayHabitsProvider);
    final l10n = AppLocalizations.of(context)!;

    // PRD "Animasi Khusus": full-screen celebration on new streak/rank milestone.
    final streakDays = streak?.currentStreak ?? 0;
    final currentRank = streakDays > 0 ? streakRankForDays(streakDays) : null;
    if (currentRank != null) {
      if (_previousRank != null && currentRank.index > _previousRank!.index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showRankCelebration(context, rankLabel: currentRank.label(context));
        });
      }
      _previousRank = currentRank;
    }

    return AppScaffold(
      title: (profile == null || profile.name.trim().isEmpty)
          ? l10n.appTitle
          : l10n.homeGreeting(profile.name),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const NotificationPermissionBanner(),
          const ExactAlarmBanner(),
          _GamificationSummary(profile: profile, streak: streak),
          const SizedBox(height: 24),
          Text(l10n.homeTasksToday, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          tasksAsync.when(
            data: (tasks) => tasks.isEmpty
                ? _EmptyState(message: l10n.homeNoTasksToday)
                : Column(children: [for (final task in tasks) _TaskTile(task: task)]),
            loading: () => const _LoadingRow(),
            error: (error, _) => _EmptyState(message: l10n.errorLoadingTasks(error.toString())),
          ),
          const SizedBox(height: 24),
          Text(l10n.homeHabitsToday, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          todayHabits.isEmpty
              ? _EmptyState(message: l10n.homeNoActiveHabits)
              : Column(children: [for (final habit in todayHabits) _HabitTile(habit: habit)]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PomodoroScreen()),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.homeStartPomodoroButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _GamificationSummary extends StatelessWidget {
  const _GamificationSummary({required this.profile, required this.streak});

  final UserProfileData? profile;
  final StreakStateData? streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final needed = 100 * level;
    final streakDays = streak?.currentStreak ?? 0;
    final rankLabel = streakDays > 0 ? streakRankForDays(streakDays).label(context) : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.levelLabel(level), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedXpProgress(
              value: needed == 0 ? 0 : xp / needed,
              level: level,
            ),
            const SizedBox(height: 4),
            Text(l10n.xpProgress(xp, needed)),
            const SizedBox(height: 12),
            Text(l10n.streakSummary(streakDays, rankLabel)),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.low => l10n.priorityLowShort,
        TaskPriority.medium => l10n.priorityMedShort,
        TaskPriority.high => l10n.priorityHighShort,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final subtitleParts = <String>[
      _priorityLabel(l10n),
      if (task.time != null) TimeOfDay.fromDateTime(task.time!).format(context),
    ];
    return ListTile(
      leading: CompletionCheckbox(
        value: task.isCompleted,
        onComplete: () => ref.read(taskRepositoryProvider).completeTask(task.id),
        onUncomplete: () => ref.read(taskRepositoryProvider).uncompleteTask(task.id),
      ),
      title: Text(
        task.title,
        style: task.isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(subtitleParts.join(' · ')),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted =
        ref.watch(habitTodayLogProvider(habit.id)).valueOrNull?.isCompleted ?? false;

    return ListTile(
      leading: CompletionCheckbox(
        value: isCompleted,
        onComplete: () => ref.read(habitRepositoryProvider).completeHabitToday(habit.id),
        onUncomplete: () => ref.read(habitRepositoryProvider).uncompleteHabitToday(habit.id),
      ),
      title: Text(
        habit.name,
        style: isCompleted
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
