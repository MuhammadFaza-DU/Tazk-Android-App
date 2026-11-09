import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_xp_progress.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/celebration_overlay.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/exact_alarm_banner.dart';
import '../../core/widgets/notification_permission_banner.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/current_date_provider.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import '../../widgets/battery_optimization.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/task_form_screen.dart';

/// Jarak konten ke tepi layar di board `01 Home` (kartu, judul section, dan
/// tombol CTA rata di 20dp).
const double _pagePadding = 20;

/// Jarak antar section (board: kartu level → "Tugas Hari Ini" → "Habits …").
const double _sectionGap = 24;

/// Jarak antar kartu item dalam satu section.
const double _itemGap = 12;

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
    // Asks once, only if Android is restricting this app: an idle app has its
    // background work deferred, which is what made widget taps look frozen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(maybePromptBatteryOptimization(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final streak = ref.watch(streakStateProvider).valueOrNull;
    final tasksAsync = ref.watch(todayTasksProvider);
    final habitsAsync = ref.watch(activeHabitsProvider);
    final todayHabits = ref.watch(todayHabitsProvider);
    final habitCompletion =
        ref.watch(todayHabitLogCompletionProvider).valueOrNull ??
            const <int, bool>{};

    ref.listen(streakStateProvider, (previous, next) {
      final prevDays = previous?.valueOrNull?.currentStreak ?? 0;
      final nextDays = next.valueOrNull?.currentStreak ?? 0;
      final prevRank = prevDays > 0 ? streakRankForDays(prevDays) : null;
      final nextRank = nextDays > 0 ? streakRankForDays(nextDays) : null;
      if (prevRank != null &&
          nextRank != null &&
          nextRank.index > prevRank.index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showRankCelebration(context, rankLabel: nextRank.label(context));
        });
      }
    });

    final tasks = tasksAsync.valueOrNull ?? const <Task>[];
    final remainingTasks = tasks.where((task) => !task.isCompleted).length;
    final doneHabits =
        todayHabits.where((habit) => habitCompletion[habit.id] ?? false).length;

    final rawName = profile?.name.trim() ?? '';
    final displayName = rawName.isEmpty ? l10n.appTitle : rawName;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            _box(
              _HomeHeader(name: displayName, onAvatarTap: _openProfile),
              top: 20,
              // Board: jarak sapaan → kartu level ~14dp (lebih rapat daripada
              // jarak antar section); pakai token `lg` (16).
              bottom: 16,
            ),
            _box(const NotificationPermissionBanner()),
            _box(const ExactAlarmBanner()),
            _box(_LevelCard(profile: profile, streak: streak)),
            const SliverToBoxAdapter(child: SizedBox(height: _sectionGap)),
            _box(
              SectionHeader(
                title: l10n.homeTasksToday,
                action: tasksAsync.hasValue
                    ? _CountLabel(l10n.homeTasksRemaining(remainingTasks))
                    : null,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ..._taskSlivers(tasksAsync, l10n),
            const SliverToBoxAdapter(child: SizedBox(height: _sectionGap)),
            _box(
              SectionHeader(
                title: l10n.homeHabitsToday,
                action: habitsAsync.hasValue
                    ? _CountLabel(l10n.homeHabitsProgress(
                        doneHabits,
                        todayHabits.length,
                      ))
                    : null,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ..._habitSlivers(
              habitsAsync,
              todayHabits,
              habitCompletion,
              l10n,
            ),
            _box(
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton.primary(
                  label: l10n.homeStartPomodoroButton,
                  onPressed: _openPomodoro,
                  height: 59,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 23,
                    vertical: 12,
                  ),
                  labelStyle: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: 15),
                ),
              ),
              top: _sectionGap,
              bottom: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// Sliver ber-padding horizontal halaman (padding diterapkan sekali, seperti
  /// aturan `DESIGN.md` `Layout`).
  SliverPadding _pad(Widget sliver, {double top = 0, double bottom = 0}) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(_pagePadding, top, _pagePadding, bottom),
      sliver: sliver,
    );
  }

  SliverPadding _box(Widget child, {double top = 0, double bottom = 0}) {
    return _pad(SliverToBoxAdapter(child: child), top: top, bottom: bottom);
  }

  List<Widget> _taskSlivers(
    AsyncValue<List<Task>> tasksAsync,
    AppLocalizations l10n,
  ) {
    return tasksAsync.when(
      data: (tasks) => tasks.isEmpty
          ? [
              _box(
                EmptyState(
                  title: l10n.stateEmptyTasksTitle,
                  message: l10n.stateEmptyTasksSubtitle,
                  action: AppButton.primary(
                    label: l10n.stateEmptyTasksAction,
                    onPressed: _openTaskForm,
                  ),
                ),
              ),
            ]
          : [
              _pad(
                SliverList.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(
                      bottom: i == tasks.length - 1 ? 0 : _itemGap,
                    ),
                    child: _TaskCard(task: tasks[i]),
                  ),
                ),
              ),
            ],
      loading: () => [_box(const SkeletonList())],
      error: (error, _) => [
        _box(
          ErrorState(
            title: l10n.stateErrorTitle,
            message: l10n.errorLoadingTasks(error.toString()),
            retryLabel: l10n.stateRetryAction,
            onRetry: () => ref.invalidate(todayTasksProvider),
          ),
        ),
      ],
    );
  }

  List<Widget> _habitSlivers(
    AsyncValue<List<Habit>> habitsAsync,
    List<Habit> todayHabits,
    Map<int, bool> habitCompletion,
    AppLocalizations l10n,
  ) {
    return habitsAsync.when(
      data: (_) => todayHabits.isEmpty
          ? [_box(EmptyState(message: l10n.homeNoActiveHabits))]
          : [
              _pad(
                SliverList.builder(
                  itemCount: todayHabits.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(
                      bottom: i == todayHabits.length - 1 ? 0 : _itemGap,
                    ),
                    child: _HabitCard(
                      habit: todayHabits[i],
                      isCompleted: habitCompletion[todayHabits[i].id] ?? false,
                    ),
                  ),
                ),
              ),
            ],
      loading: () => [_box(const SkeletonList(rows: 2))],
      error: (error, _) => [
        _box(
          ErrorState(
            title: l10n.stateErrorTitle,
            message: l10n.errorLoadingHabits(error.toString()),
            retryLabel: l10n.stateRetryAction,
            onRetry: () => ref.invalidate(activeHabitsProvider),
          ),
        ),
      ],
    );
  }

  void _openPomodoro() {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const PomodoroScreen()),
    );
  }

  void _openTaskForm() {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const TaskFormScreen()),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
}

/// Header board `01 Home`: sapaan + tanggal hari ini di kiri, avatar inisial di
/// kanan. Tidak ada ikon menu (DESIGN `Navigation`).
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name, required this.onAvatarTap});

  final String name;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeGreeting(name),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  color: colors.ink,
                ),
              ),
              Text(
                _todayLabel(context),
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ProfileAvatar(initial: _initialOf(name), onTap: onAvatarTap),
      ],
    );
  }
}

/// Nama hari + tanggal hari ini mengikuti locale aktif ("Rabu, 29 Oktober").
String _todayLabel(BuildContext context) {
  final now = DateTime.now();
  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    return DateFormat('EEEE, d MMMM', locale).format(now);
  } catch (_) {
    return DateFormat('EEEE, d MMMM', 'en').format(now);
  }
}

/// Huruf pertama nama (rune-aware supaya emoji/karakter non-BMP tidak pecah).
String _initialOf(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initial, required this.onTap});

  static const double diameter = 48;

  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.navProfile,
      child: Material(
        key: const Key('home_avatar'),
        color: colors.honeyContainer,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: diameter,
            height: diameter,
            child: Center(
              child: Text(
                initial,
                style: theme.textTheme.headlineSmall?.copyWith(color: colors.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu gamifikasi `01 Home` — latar `primary`, radius `xl` (24), padding 16.
/// Bukan kartu surface: dia satu-satunya bidang berwarna penuh di layar.
class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.profile, required this.streak});

  final UserProfileData? profile;
  final StreakStateData? streak;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final needed = 100 * level;
    final streakDays = streak?.currentStreak ?? 0;
    final rankLabel =
        streakDays > 0 ? streakRankForDays(streakDays).label(context) : '-';

    return Container(
      key: const Key('home_level_card'),
      padding: const EdgeInsets.all(16), // spacing.lg
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24), // rounded.xl
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.levelLabel(level),
                  style: theme.textTheme.headlineLarge?.copyWith(color: colors.onPrimary),
                ),
              ),
              const SizedBox(width: 12),
              _StreakPill(days: streakDays),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedXpProgress(
            value: needed == 0 ? 0 : xp / needed,
            level: level,
            height: 8,
            trackColor: colors.primarySoft,
            fillColor: colors.honey,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeXpMeta(xp, needed, rankLabel),
            style: theme.textTheme.bodySmall?.copyWith(color: colors.onPrimaryMuted),
          ),
        ],
      ),
    );
  }
}

/// Streak pill `01 Home`: latar `honey`, label `ink`, ikon api 14.
class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      key: const Key('home_streak_pill'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.honey,
        borderRadius: BorderRadius.circular(999), // rounded.pill
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: colors.ink,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.homeStreakDays(days),
            style: theme.textTheme.labelLarge?.copyWith(color: colors.ink),
          ),
        ],
      ),
    );
  }
}

class _CountLabel extends StatelessWidget {
  const _CountLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: context.colors.inkMuted),
    );
  }
}

/// Satu task = satu kartu (`01 Home`), bukan satu kartu berisi divider.
class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final Task task;

  String _priorityLabel(AppLocalizations l10n) => switch (task.priority) {
        TaskPriority.low => l10n.priorityLowShort,
        TaskPriority.medium => l10n.priorityMedShort,
        TaskPriority.high => l10n.priorityHighShort,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      key: Key('home_task_card_${task.id}'),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CompletionCheckbox(
            value: task.isCompleted,
            onComplete: () => ref.read(taskRepositoryProvider).completeTask(task.id),
            onUncomplete: () =>
                ref.read(taskRepositoryProvider).uncompleteTask(task.id),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? colors.inkMuted : colors.ink,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    AppChip.priority(
                      task.priority,
                      label: _priorityLabel(l10n),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _timeLabel(task.time, l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.inkMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Jam 24 jam tanpa detik, sama seperti board ("08:00"). Tanpa jam → "Tanpa jam".
String _timeLabel(DateTime? time, AppLocalizations l10n) {
  if (time == null) return l10n.homeNoTime;
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Satu habit = satu kartu: judul + streak + (opsional) progress menit.
class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit, required this.isCompleted});

  final Habit habit;
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final today = ref.watch(currentDateProvider);
    final history = ref.watch(habitHistoryProvider(habit.id)).valueOrNull ??
        const <HabitLog>[];
    final streakDays = _completedRun(history, today);
    final targetMinutes = habit.targetMinutes;
    final showMinutes = habit.hasProgress && targetMinutes != null;

    return AppCard(
      key: Key('home_habit_card_${habit.id}'),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CompletionCheckbox(
            value: isCompleted,
            onComplete: () =>
                ref.read(habitRepositoryProvider).completeHabitToday(habit.id),
            onUncomplete: () =>
                ref.read(habitRepositoryProvider).uncompleteHabitToday(habit.id),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? colors.inkMuted : colors.ink,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: colors.inkMuted,
                  ),
                ),
                if (streakDays > 0 || showMinutes) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (streakDays > 0) ...[
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: colors.honey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.homeStreakDays(streakDays),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colors.inkMuted),
                        ),
                      ],
                      if (streakDays > 0 && showMinutes)
                        const SizedBox(width: 12),
                      if (showMinutes)
                        Flexible(
                          child: Text(
                            l10n.homeHabitMinutes(
                              _logOn(history, today)?.progressMinutes ?? 0,
                              targetMinutes,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: colors.inkMuted),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

DateTime _dayOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

DateTime _previousDay(DateTime day) =>
    DateTime(day.year, day.month, day.day - 1);

HabitLog? _logOn(List<HabitLog> logs, DateTime day) {
  final key = _dayOnly(day);
  for (final log in logs) {
    if (_dayOnly(log.date) == key) return log;
  }
  return null;
}

/// Jumlah hari beruntun yang selesai untuk satu habit.
///
/// Murni tampilan (tidak menyentuh streak tersimpan milik gamifikasi): hari ini
/// yang belum dicentang tidak memutus run sampai harinya benar-benar habis.
int _completedRun(List<HabitLog> logs, DateTime today) {
  final completed = <DateTime>{};
  for (final log in logs) {
    if (log.isCompleted) completed.add(_dayOnly(log.date));
  }
  var cursor = _dayOnly(today);
  if (!completed.contains(cursor)) cursor = _previousDay(cursor);
  var run = 0;
  while (completed.contains(cursor)) {
    run++;
    cursor = _previousDay(cursor);
  }
  return run;
}