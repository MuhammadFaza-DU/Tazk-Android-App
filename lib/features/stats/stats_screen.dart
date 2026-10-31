import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/bar_chart.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/heatmap.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../data/repositories/stats_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/stats_providers.dart';
import 'stats_segmented.dart';

export 'stats_segmented.dart';

const Key statsStatRowKey = ValueKey('stats-stat-row');
const Key statsCompletionCardKey = ValueKey('stats-completion-card');
const Key statsFocusCardKey = ValueKey('stats-focus-card');
const Key statsXpCardKey = ValueKey('stats-xp-card');
const Key statsHeatmapCardKey = ValueKey('stats-heatmap-card');
const Key statsInsightCardKey = ValueKey('stats-insight-card');
const Key statsBarChartKey = ValueKey('stats-bar-chart');
const Key statsHeatmapKey = ValueKey('stats-heatmap');
const Key statsEmptyKey = ValueKey('stats-empty');

/// Durasi dalam format ringkas "4j 20m" / "35m" (board `07 Statistik`).
String formatDuration(int minutes, AppLocalizations l10n) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0) return l10n.statsDurationHoursMinutes(h, m);
  return l10n.statsDurationMinutes(m);
}

String _xpTitle(StatsPeriod period, AppLocalizations l10n) => switch (period) {
      StatsPeriod.week => l10n.statsXpWeek,
      StatsPeriod.month => l10n.statsXpMonth,
      StatsPeriod.year => l10n.statsXpYear,
    };

String _vsLabel(StatsPeriod period, AppLocalizations l10n) => switch (period) {
      StatsPeriod.week => l10n.statsVsLastWeek,
      StatsPeriod.month => l10n.statsVsLastMonth,
      StatsPeriod.year => l10n.statsVsLastYear,
    };

String _emptyTitle(StatsPeriod period, AppLocalizations l10n) =>
    switch (period) {
      StatsPeriod.week => l10n.statsEmptyWeek,
      StatsPeriod.month => l10n.statsEmptyMonth,
      StatsPeriod.year => l10n.statsEmptyYear,
    };

String _dayName(int weekday, AppLocalizations l10n) => switch (weekday) {
      1 => l10n.dayMonday,
      2 => l10n.dayTuesday,
      3 => l10n.dayWednesday,
      4 => l10n.dayThursday,
      5 => l10n.dayFriday,
      6 => l10n.daySaturday,
      7 => l10n.daySunday,
      _ => '',
    };

/// Layar Statistik (board `07 Statistik`): periode, kartu task selesai,
/// kartu waktu fokus, XP per periode, heatmap habit, dan kartu insight.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  /// Jarak antar blok layar — `spacing.lg`.
  static const double _blockGap = 16;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final period = ref.watch(statsPeriodProvider);

    final summaryAsync = ref.watch(statsSummaryProvider);
    final xpAsync = ref.watch(xpPerDayProvider);
    final heatmapAsync = ref.watch(habitHeatmapProvider);
    final insightAsync = ref.watch(insightProvider);

    return AppScaffold(
      title: l10n.navStats,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppScaffold.gutter,
          AppScaffold.gutter,
          AppScaffold.gutter,
          24, // spacing.xl
        ),
        children: [
          StatsSegmented(
            period: period,
            onChanged: (p) => ref.read(statsPeriodProvider.notifier).state = p,
          ),
          const SizedBox(height: _blockGap),
          ..._buildDataBlocks(
            context,
            l10n,
            period,
            summaryAsync,
            xpAsync,
            heatmapAsync,
            ref,
          ),
          const SizedBox(height: _blockGap),
          _InsightCard(insight: insightAsync, l10n: l10n),
        ],
      ),
    );
  }

  List<Widget> _buildDataBlocks(
    BuildContext context,
    AppLocalizations l10n,
    StatsPeriod period,
    AsyncValue<StatsSummary> summaryAsync,
    AsyncValue<List<XpBucket>> xpAsync,
    AsyncValue<List<List<int>>> heatmapAsync,
    WidgetRef ref,
  ) {
    if (summaryAsync.hasError ||
        xpAsync.hasError ||
        heatmapAsync.hasError) {
      return [
        ErrorState(
          title: l10n.stateErrorTitle,
          message: l10n.stateErrorMessage,
          onRetry: () {
            ref.invalidate(statsSummaryProvider);
            ref.invalidate(xpPerDayProvider);
            ref.invalidate(habitHeatmapProvider);
            ref.invalidate(insightProvider);
          },
        ),
      ];
    }

    final summary = summaryAsync.valueOrNull;
    final xp = xpAsync.valueOrNull;
    final heatmap = heatmapAsync.valueOrNull;

    // Loading pertama: jangan tampilkan isi data sebelum stream punya nilai.
    if (summary == null || xp == null || heatmap == null) {
      return const [
        SkeletonList(key: ValueKey('stats-loading'), rows: 3),
      ];
    }

    // Tidak ada data sama sekali: satu EmptyState menggantikan blok 2-4.
    // Data habit & XP ikut dihitung — pengguna yang hanya memakai habit tetap
    // harus melihat heatmap-nya walau belum ada task/sesi fokus pekan ini.
    final hasXp = xp.any((bucket) => bucket.value != 0);
    final hasHeatmap =
        heatmap.any((column) => column.any((level) => level != 0));
    if (!summary.completion.hasData &&
        !summary.focus.hasData &&
        !hasXp &&
        !hasHeatmap) {
      return [
        EmptyState(
          key: statsEmptyKey,
          title: _emptyTitle(period, l10n),
          message: l10n.statsEmptyHint,
        ),
      ];
    }

    return [
      _StatRow(l10n: l10n, period: period, summary: summary),
      const SizedBox(height: _blockGap),
      _XpCard(xp: xp, xpTitle: _xpTitle(period, l10n), l10n: l10n),
      const SizedBox(height: _blockGap),
      _HeatmapCard(heatmap: heatmap, l10n: l10n),
    ];
  }
}

/// Dua kartu statistik sejajar (task selesai `67%` + waktu fokus `4j 20m`).
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.l10n,
    required this.period,
    required this.summary,
  });

  final AppLocalizations l10n;
  final StatsPeriod period;
  final StatsSummary summary;

  @override
  Widget build(BuildContext context) {
    final vsLabel = _vsLabel(period, l10n);
    final completion = summary.completion;
    final focus = summary.focus;

    return IntrinsicHeight(
      child: Row(
        key: statsStatRowKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              key: statsCompletionCardKey,
              label: l10n.statsTasksDone,
              value: completion.hasData
                  ? '${(completion.rate * 100).round()}%'
                  : l10n.statsValueDash,
              delta: completion.hasData
                  ? _completionDelta(completion.deltaPoints, vsLabel, l10n)
                  : l10n.statsNoComparison,
            ),
          ),
          const SizedBox(width: 8), // spacing.sm
          Expanded(
            child: _StatCard(
              key: statsFocusCardKey,
              label: l10n.statsFocusTime,
              value: focus.hasData
                  ? formatDuration(focus.minutes, l10n)
                  : l10n.statsValueDash,
              delta: focus.hasData
                  ? _focusDelta(focus.deltaMinutes, vsLabel, l10n)
                  : l10n.statsNoComparison,
            ),
          ),
        ],
      ),
    );
  }

  String _completionDelta(
    int? deltaPoints,
    String vsLabel,
    AppLocalizations l10n,
  ) {
    if (deltaPoints == null) return l10n.statsNoComparison;
    return '${deltaPoints > 0 ? '+' : ''}$deltaPoints% $vsLabel';
  }

  String _focusDelta(int delta, String vsLabel, AppLocalizations l10n) {
    final sign = delta >= 0 ? '+' : '-';
    // Board menampilkan delta fokus dalam MENIT saja (nilai `4j 20m`, delta `+35m`).
    return '$sign${l10n.statsDurationMinutes(delta.abs())} $vsLabel';
  }
}

/// Satu kartu statistik: label, nilai besar Fredoka, delta + ikon panah.
class _StatCard extends StatelessWidget {
  const _StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 4), // spacing.xs
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: theme.textTheme.displayLarge?.copyWith(
              color: colors.ink,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4), // spacing.xs
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_outward_rounded, size: 14, color: colors.inkMuted),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  delta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.inkMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu XP per periode: judul + total XP + BarChart (atau pesan kosong).
class _XpCard extends StatelessWidget {
  const _XpCard({
    required this.xp,
    required this.xpTitle,
    required this.l10n,
  });

  final List<XpBucket> xp;
  final String xpTitle;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final totalXp = xp.fold<int>(0, (sum, b) => sum + b.value);
    final allZero = xp.every((b) => b.value == 0);

    return AppCard(
      key: statsXpCardKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  xpTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(width: 12), // spacing.md
              // Tanpa XP, angka "0 XP" di samping "Belum ada XP" saling
              // bertentangan: sembunyikan total, biarkan baris kosongnya bicara.
              if (!allZero)
                Text(
                  '$totalXp XP',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.inkMuted),
                ),
            ],
          ),
          const SizedBox(height: 12), // spacing.md
          if (allZero)
            Text(
              l10n.statsXpEmpty,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
            )
          else
            BarChart(
              key: statsBarChartKey,
              data: [
                for (final b in xp)
                  BarDatum(
                    label: b.label,
                    value: b.value,
                    highlight: b.isToday,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Kartu konsistensi habit: judul + hitungan hari + heatmap + legenda.
class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.heatmap, required this.l10n});

  final List<List<int>> heatmap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final allZero = heatmap.every((col) => col.every((level) => level == 0));

    return AppCard(
      key: statsHeatmapCardKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.statsHabitConsistency,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(width: 12), // spacing.md
              // Board menulis "90 hari" tapi grid 13x7 = 91 sel; pakai 91 (jujur).
              Text(
                l10n.statsDaysCount(91),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 12), // spacing.md
          if (allZero)
            Text(
              l10n.statsHeatmapEmpty,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
            )
          else
            HabitHeatmap(key: statsHeatmapKey, weeks: heatmap),
          const SizedBox(height: 12), // spacing.md
          HeatmapLegend(
            rareLabel: l10n.statsLegendRare,
            frequentLabel: l10n.statsLegendFrequent,
          ),
        ],
      ),
    );
  }
}

/// Kartu insight (board: `primaryContainer` tanpa border, radius 14).
class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.l10n});

  final AsyncValue<StatsInsight?> insight;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    // Saat masih loading kita jangan mengklaim "belum ada insight": tampilkan
    // placeholder kosong setinggi satu baris.
    final Widget textChild;
    if (insight.isLoading) {
      textChild = Text(
        '',
        key: const ValueKey('stats-insight-loading'),
        style: theme.textTheme.bodySmall?.copyWith(color: colors.ink),
      );
    } else {
      textChild = Text(
        _insightText,
        style: theme.textTheme.bodySmall?.copyWith(color: colors.ink),
      );
    }

    return Container(
      key: statsInsightCardKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(14), // rounded.md
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 20, color: colors.ink),
          const SizedBox(width: 8),
          Expanded(
            child: textChild,
          ),
        ],
      ),
    );
  }

  String get _insightText {
    // Error maupun tanpa data: kita memang tidak punya insight.
    if (insight.hasError) return l10n.statsInsightEmpty;
    final value = insight.valueOrNull;
    if (value == null || value.isEmpty) return l10n.statsInsightEmpty;
    final sentences = <String>[
      if (value.productiveWeekday != null)
        l10n.statsInsightProductive(_dayName(value.productiveWeekday!, l10n)),
      if (value.consistentHabitName != null)
        l10n.statsInsightConsistentHabit(value.consistentHabitName!),
    ];
    return sentences.join(' ');
  }
}