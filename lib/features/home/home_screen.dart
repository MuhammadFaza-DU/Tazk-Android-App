import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import '../pomodoro/pomodoro_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final streak = ref.watch(streakStateProvider).valueOrNull;
    final tasksAsync = ref.watch(todayTasksProvider);
    final habitsAsync = ref.watch(activeHabitsProvider);

    return AppScaffold(
      title: (profile == null || profile.name.trim().isEmpty)
          ? 'Tazk'
          : 'Halo, ${profile.name}!',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GamificationSummary(profile: profile, streak: streak),
          const SizedBox(height: 24),
          Text('Tasks Hari Ini', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          tasksAsync.when(
            data: (tasks) => tasks.isEmpty
                ? const _EmptyState(message: 'Belum ada task hari ini')
                : Column(children: [for (final task in tasks) _TaskTile(task: task)]),
            loading: () => const _LoadingRow(),
            error: (error, _) => _EmptyState(message: 'Gagal memuat task: $error'),
          ),
          const SizedBox(height: 24),
          Text('Habits Hari Ini', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          habitsAsync.when(
            data: (habits) => habits.isEmpty
                ? const _EmptyState(message: 'Belum ada habit aktif')
                : Column(children: [for (final habit in habits) _HabitTile(habit: habit)]),
            loading: () => const _LoadingRow(),
            error: (error, _) => _EmptyState(message: 'Gagal memuat habit: $error'),
          ),
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
              label: const Text('Mulai Pomodoro'),
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
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final needed = 100 * level;
    final streakDays = streak?.currentStreak ?? 0;
    final rankLabel = streakDays > 0 ? streakRankForDays(streakDays).label : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level $level', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: needed == 0 ? 0 : (xp / needed).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppColors.terracotta.withAlpha(40),
                valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
              ),
            ),
            const SizedBox(height: 4),
            Text('$xp/$needed XP'),
            const SizedBox(height: 12),
            Text('🔥 Streak $streakDays hari · $rankLabel'),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleParts = <String>[
      task.priority.name,
      if (task.time != null) TimeOfDay.fromDateTime(task.time!).format(context),
    ];
    return CheckboxListTile(
      value: task.isCompleted,
      onChanged: task.isCompleted
          ? null
          : (_) => ref.read(taskRepositoryProvider).completeTask(task.id),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(task.title),
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

    return CheckboxListTile(
      value: isCompleted,
      onChanged: isCompleted
          ? null
          : (_) => ref.read(habitRepositoryProvider).completeHabitToday(habit.id),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(habit.name),
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
