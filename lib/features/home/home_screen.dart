import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/animated_xp_progress.dart';
import '../../core/widgets/celebration_overlay.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/exact_alarm_banner.dart';
import '../../core/widgets/list_row.dart';
import '../../core/widgets/notification_permission_banner.dart';
import '../../core/widgets/section_header.dart';
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
    final habitCompletion =
        ref.watch(todayHabitLogCompletionProvider).valueOrNull ?? const <int, bool>{};
    final l10n = AppLocalizations.of(context)!;

    ref.listen(streakStateProvider, (previous, next) {
      final prevDays = previous?.valueOrNull?.currentStreak ?? 0;
      final nextDays = next.valueOrNull?.currentStreak ?? 0;
      final prevRank = prevDays > 0 ? streakRankForDays(prevDays) : null;
      final nextRank = nextDays > 0 ? streakRankForDays(nextDays) : null;
      if (prevRank != null && nextRank != null && nextRank.index > prevRank.index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showRankCelebration(context, rankLabel: nextRank.label(context));
        });
      }
    });

    return AppScaffold(
      title: (profile == null || profile.name.trim().isEmpty)
          ? l10n.appTitle
          : l10n.homeGreeting(profile.name),
      body: CustomScrollView(
        slivers: [
          _paddedSliver(
            const SliverToBoxAdapter(child: NotificationPermissionBanner()),
            top: 16,
          ),
          _paddedSliver(const SliverToBoxAdapter(child: ExactAlarmBanner())),
          _paddedSliver(
            SliverToBoxAdapter(
              child: _GamificationSummary(profile: profile, streak: streak),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _paddedSliver(
            SliverToBoxAdapter(child: SectionHeader(title: l10n.homeTasksToday)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ..._buildTaskSlivers(tasksAsync, l10n),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _paddedSliver(
            SliverToBoxAdapter(
                child: SectionHeader(title: l10n.homeHabitsToday)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          if (todayHabits.isEmpty)
            _paddedSliver(
              SliverToBoxAdapter(
                  child: EmptyState(message: l10n.homeNoActiveHabits)),
            )
          else
            _paddedSliver(
              SliverList.builder(
                itemCount: todayHabits.length,
                itemBuilder: (context, i) => _HabitTile(
                  habit: todayHabits[i],
                  isCompleted: habitCompletion[todayHabits[i].id] ?? false,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          _paddedSliver(
            SliverToBoxAdapter(
              child: AppButton.primary(
                label: l10n.homeStartPomodoroButton,
                icon: Icons.play_arrow_rounded,
                expanded: true,
                onPressed: () {
                  Navigator.of(context).push(
                    AppPageRoute(builder: (_) => const PomodoroScreen()),
                  );
                },
              ),
            ),
            bottom: 16,
          ),
        ],
      ),
    );
  }

  Widget _paddedSliver(Widget sliver, {double top = 0, double bottom = 0}) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, top, 16, bottom),
      sliver: sliver,
    );
  }

  List<Widget> _buildTaskSlivers(
      AsyncValue<List<Task>> tasksAsync, AppLocalizations l10n) {
    return tasksAsync.when(
      data: (tasks) => tasks.isEmpty
          ? [
              _paddedSliver(
                SliverToBoxAdapter(
                    child: EmptyState(message: l10n.homeNoTasksToday)),
              ),
            ]
          : [
              _paddedSliver(
                SliverList.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, i) => _TaskTile(task: tasks[i]),
                ),
              ),
            ],
      loading: () =>
          [_paddedSliver(const SliverToBoxAdapter(child: _LoadingRow()))],
      error: (error, _) => [
        _paddedSliver(
          SliverToBoxAdapter(
            child: EmptyState(message: l10n.errorLoadingTasks(error.toString())),
          ),
        ),
      ],
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

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.levelLabel(level),
              style: Theme.of(context).textTheme.titleMedium),
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
    return ListRow(
      leading: CompletionCheckbox(
        value: task.isCompleted,
        onComplete: () => ref.read(taskRepositoryProvider).completeTask(task.id),
        onUncomplete: () =>
            ref.read(taskRepositoryProvider).uncompleteTask(task.id),
      ),
      title: task.title,
      subtitle: subtitleParts.join(' · '),
      crossedOut: task.isCompleted,
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.habit, required this.isCompleted});

  final Habit habit;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListRow(
      leading: CompletionCheckbox(
        value: isCompleted,
        onComplete: () => ref.read(habitRepositoryProvider).completeHabitToday(habit.id),
        onUncomplete: () =>
            ref.read(habitRepositoryProvider).uncompleteHabitToday(habit.id),
      ),
      title: habit.name,
      crossedOut: isCompleted,
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
