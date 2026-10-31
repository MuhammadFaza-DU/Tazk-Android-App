import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/habit_due.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/completion_checkbox.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';
import 'habit_detail_screen.dart';
import 'habit_form_screen.dart';

/// Board `03 Habits`.
///
/// Susunan dari kanvas (semua piksel board dibagi 2 = dp, frame 390dp):
/// header dengan satu tombol bulat tambah di kanan, kartu ringkasan
/// `primary-container` (lingkaran persen 54dp + jumlah habit hari ini +
/// satu baris penyemangat), lalu SATU kartu berbingkai per habit (checkbox,
/// judul, sub-judul frekuensi + streak + progress menit, chevron).
///
/// Board tidak memakai FAB: aksi tambah ada di header, jadi tanpilan daftar
/// tidak butuh ruang bawah ekstra untuk tombol mengambang.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  /// `spacing.lg` — gutter layar, dipakai sekali di luar daftar.
  static const double _gutter = 20;

  /// `spacing.md` — jarak antar kartu (board: 27px ≈ 13.5dp, token 12).
  static const double _cardGap = 12;

  /// Diameter lingkaran persen di kartu ringkasan (board: 108px = 54dp).
  static const double _summaryBadge = 54;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(activeHabitsProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppScaffold(
      title: l10n.habitsScreenTitle,
      // Board: tombol tambah bulat `primary-container` + ikon `primary`,
      // sejajar judul di kanan header (bukan FAB).
      actions: [
        IconButton(
          key: habitsAddButtonKey,
          icon: const Icon(Icons.add_rounded),
          tooltip: l10n.addHabitTitle,
          style: IconButton.styleFrom(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.primary,
          ),
          onPressed: () => _openForm(context),
        ),
      ],
      body: habitsAsync.when(
        data: (habits) => habits.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(_gutter),
                  child: EmptyState(
                    title: l10n.homeNoActiveHabits,
                    message: _emptyMessage,
                    action: AppButton.primary(
                      label: l10n.addHabitTitle,
                      onPressed: () => _openForm(context),
                    ),
                  ),
                ),
              )
            : _HabitList(habits: habits),
        loading: () => const Padding(
          padding: EdgeInsets.all(_gutter),
          child: SkeletonList(rows: 4),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(_gutter),
            child: ErrorState(
              title: l10n.stateErrorTitle,
              message: l10n.stateErrorMessage,
              retryLabel: l10n.stateRetryAction,
              onRetry: () => ref.invalidate(activeHabitsProvider),
            ),
          ),
        ),
      ),
    );
  }

  // TODO(l10n): belum ada key l10n untuk sub-judul state kosong habit.
  static const String _emptyMessage =
      'Habit yang kamu tambahkan muncul di sini. Mulai satu untuk menjaga ritme.';

  static void _openForm(BuildContext context) {
    Navigator.of(
      context,
    ).push(AppPageRoute(builder: (_) => const HabitFormScreen()));
  }
}

/// Key kartu ringkasan (dipakai uji fidelity board).
const Key habitsSummaryKey = ValueKey('habits-summary');

/// Key tombol tambah di header.
const Key habitsAddButtonKey = ValueKey('habits-add');

/// Key lingkaran persen di kartu ringkasan (board: 54dp).
const Key habitsSummaryBadgeKey = ValueKey('habits-summary-badge');

/// Key kartu habit ke-[id].
Key habitCardKey(int id) => ValueKey('habit-card-$id');

class _HabitList extends ConsumerWidget {
  const _HabitList({required this.habits});

  final List<Habit> habits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ringkasan dihitung dari habit yang JADWALNYA hari ini, bukan seluruh
    // habit aktif: board menulis "1 dari 2 habit hari ini" sementara daftar
    // menampilkan 4 habit aktif.
    final dueToday = ref.watch(todayHabitsProvider);
    final completions =
        ref.watch(todayHabitLogCompletionProvider).valueOrNull ??
        const <int, bool>{};
    final done = dueToday
        .where((habit) => completions[habit.id] ?? false)
        .length;
    final total = dueToday.length;

    return ListView(
      padding: const EdgeInsets.all(HabitsScreen._gutter),
      children: [
        if (total > 0) ...[
          _HabitsSummary(done: done, total: total),
          const SizedBox(height: HabitsScreen._cardGap),
        ],
        for (var i = 0; i < habits.length; i++) ...[
          if (i > 0) const SizedBox(height: HabitsScreen._cardGap),
          _HabitCard(habit: habits[i]),
        ],
      ],
    );
  }
}

/// Kartu ringkasan board `03 Habits`: `primary-container` + radius 16,
/// lingkaran persen `primary` dengan angka `on-primary`, judul `ink`, dan
/// satu baris `ink-muted`.
class _HabitsSummary extends StatelessWidget {
  const _HabitsSummary({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final percent = total == 0 ? 0 : ((done / total) * 100).round();

    final headline = l10n.habitsSummaryHeadline(done, total);
    final support = switch (done) {
      0 => l10n.habitsSummaryStart,
      _ when done >= total => l10n.habitsSummaryAllDone,
      _ => l10n.habitsSummaryOnTrack,
    };

    return Container(
      key: habitsSummaryKey,
      padding: const EdgeInsets.all(16), // spacing.lg
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            key: habitsSummaryBadgeKey,
            width: HabitsScreen._summaryBadge,
            height: HabitsScreen._summaryBadge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$percent%',
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16), // spacing.lg
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  support,
                  // `primary` di atas `primary-container` = pasangan resmi
                  // `button-primary-quiet` (5.65:1 light, 8.26:1 dark).
                  // `ink-muted` di latar ini hanya 4.38:1 sehingga gagal AA
                  // untuk teks 13dp, jadi kesunyian nada diambil dari bobot
                  // w400 + ukuran 13, bukan dari opacity.
                  style: theme.textTheme.labelLarge?.copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu kartu habit (board: tinggi 64dp, radius 14, border `border`):
/// checkbox, judul, sub-judul `frekuensi · streak · progress`, chevron.
class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final todayLog = ref.watch(habitTodayLogProvider(habit.id)).valueOrNull;
    final history =
        ref.watch(habitHistoryProvider(habit.id)).valueOrNull ??
        const <HabitLog>[];
    final isCompleted = todayLog?.isCompleted ?? false;
    final streak = habitStreakDays(
      habit: habit,
      completedDates: history
          .where((log) => log.isCompleted)
          .map((log) => log.date),
      today: DateTime.now(),
    );
    final minutes = todayLog?.progressMinutes ?? 0;
    final target = habit.targetMinutes ?? 0;

    // Board: sub-judul 13dp regular `ink-muted`.
    final subtitleStyle = theme.textTheme.labelLarge?.copyWith(
      height: 1.3,
      fontWeight: FontWeight.w400,
      color: colors.inkMuted,
    );

    return AppCard(
      key: habitCardKey(habit.id),
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14), // rounded.md
          onTap: () => Navigator.of(
            context,
          ).push(AppPageRoute(builder: (_) => HabitDetailScreen(habit: habit))),
          child: Padding(
            // Board: 12dp vertikal (kartu 64dp), 16dp horizontal seperti
            // kartu Tasks supaya kedua tab tetap sejajar.
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CompletionCheckbox(
                  value: isCompleted,
                  onComplete: () => ref
                      .read(habitRepositoryProvider)
                      .completeHabitToday(habit.id),
                  onUncomplete: () => ref
                      .read(habitRepositoryProvider)
                      .uncompleteHabitToday(habit.id),
                ),
                const SizedBox(width: 4), // spacing.xs
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
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? colors.inkMuted : colors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // `Wrap` supaya nama frekuensi panjang, streak, dan
                      // progress turun baris sendiri kalau layar sempit.
                      Wrap(
                        spacing: 8, // spacing.sm
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            habit.frequency.label(context),
                            style: subtitleStyle,
                          ),
                          if (streak > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 16,
                                  color: colors.honey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.homeStreakDays(streak),
                                  style: subtitleStyle,
                                ),
                              ],
                            ),
                          if (habit.hasProgress && target > 0)
                            Text(
                              l10n.homeHabitMinutes(minutes, target),
                              style: theme.textTheme.labelLarge?.copyWith(
                                height: 1.3,
                                color: colors.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Panjang streak (dalam hari) milik satu habit.
///
/// Dihitung mundur dari [today]: hanya hari yang benar-benar dijadwalkan
/// ([isHabitDueOnDate]) yang dihitung, hari libur dilewati tanpa memutus
/// streak. Hari ini yang belum dicentang tidak memutus streak — hari belum
/// selesai — jadi hitungan dimulai dari kemarin.
@visibleForTesting
int habitStreakDays({
  required Habit habit,
  required Iterable<DateTime> completedDates,
  required DateTime today,
  int maxLookbackDays = 366,
}) {
  final done = <DateTime>{
    for (final date in completedDates)
      DateTime(date.year, date.month, date.day),
  };
  final base = DateTime(today.year, today.month, today.day);

  bool isDue(int daysAgo) => isHabitDueOnDate(
    habit,
    DateTime(base.year, base.month, base.day - daysAgo),
  );
  bool isDone(int daysAgo) =>
      done.contains(DateTime(base.year, base.month, base.day - daysAgo));

  final start = isDue(0) && !isDone(0) ? 1 : 0;

  var streak = 0;
  for (var daysAgo = start; daysAgo < maxLookbackDays; daysAgo++) {
    if (!isDue(daysAgo)) continue;
    if (!isDone(daysAgo)) break;
    streak++;
  }
  return streak;
}
