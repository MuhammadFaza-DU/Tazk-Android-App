import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../data/repositories/stats_repository.dart';
import '../../l10n/app_localizations.dart';

/// Key seluruh kontrol segmented (board 07: Minggu·Bulan·Tahun).
const Key statsSegmentedKey = ValueKey('stats-segmented');

/// Key satu segmen periode (dipakai test a11y: tinggi tap target >= 48).
Key statsSegmentKey(StatsPeriod period) =>
    ValueKey('stats-segment-${period.name}');

/// Segmented control bertema untuk periode Statistik (board `07 Statistik`).
///
/// Track `surfaceAlt` pill tinggi visual 39, isian aktif `surface` pill yang
/// bergeser (`AnimatedContainer` `fast`/`easeStandard`, jadi nol saat
/// reduced-motion). Tiap segmen punya tap target minimal 48dp (a11y) walau
/// visualnya 39: track digambar sebagai lapisan latar, segmen 48dp di atasnya.
class StatsSegmented extends StatelessWidget {
  const StatsSegmented({
    super.key,
    required this.period,
    required this.onChanged,
  });

  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onChanged;

  /// Tinggi visual track (board).
  static const double trackHeight = 39;

  /// Padding dalam track (board 4.5 → 4).
  static const double trackPadding = 4;

  /// Tap target minimum Android (`DESIGN.md` Layout: 48dp).
  static const double minTapTarget = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final entries = <(StatsPeriod, String)>[
      (StatsPeriod.week, l10n.statsPeriodWeek),
      (StatsPeriod.month, l10n.statsPeriodMonth),
      (StatsPeriod.year, l10n.statsPeriodYear),
    ];
    final activeIndex = entries.indexWhere((e) => e.$1 == period);
    final pillHeight = trackHeight - 2 * trackPadding;
    final duration = context.motion(AppMotion.fast);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final segWidth = width / entries.length;
        final pillWidth = segWidth - 2 * trackPadding;
        final pillTop = (minTapTarget - pillHeight) / 2;

        return SizedBox(
          key: statsSegmentedKey,
          width: width,
          height: minTapTarget,
          child: Stack(
            children: [
              // Track latar (visual 39), vertikal di tengah.
              Positioned(
                left: 0,
                right: 0,
                top: (minTapTarget - trackHeight) / 2,
                height: trackHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              // Isian aktif `surface` yang bergeser antar segmen.
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: AppMotion.easeStandard,
                    width: pillWidth,
                    height: pillHeight,
                    // Composite-only: geser lewat `transform`, bukan `margin`
                    // (margin = layout per frame — ruling T4 #15/#16).
                    transform: Matrix4.translationValues(
                      activeIndex * segWidth + trackPadding,
                      pillTop,
                      0,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              // Label + tap target 48dp (di atas track).
              Row(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    Expanded(
                      child: Semantics(
                        key: statsSegmentKey(entries[i].$1),
                        button: true,
                        selected: i == activeIndex,
                        label: entries[i].$2,
                        onTap: () => onChanged(entries[i].$1),
                        excludeSemantics: true,
                        child: SizedBox(
                          height: minTapTarget,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onChanged(entries[i].$1),
                            child: Center(
                              child: Text(
                                entries[i].$2,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: i == activeIndex
                                      ? colors.ink
                                      : colors.inkMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}