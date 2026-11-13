import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/gamification_providers.dart';

/// Jumlah hari yang ditampilkan strip riwayat (termasuk hari ini).
const int streakHistoryLength = 7;

/// Satu sel hari di [StreakHistoryStrip].
///
/// Diekspos sebagai widget publik supaya uji bisa memeriksa statusnya tanpa
/// membaca warna piksel.
class StreakHistoryDay extends StatelessWidget {
  const StreakHistoryDay({
    super.key,
    required this.date,
    required this.isActive,
    required this.isToday,
    required this.activeLabel,
    required this.missedLabel,
  });

  final DateTime date;
  final bool isActive;
  final bool isToday;
  final String activeLabel;
  final String missedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final weekday = DateFormat.E(Localizations.localeOf(context).toString())
        .format(date);

    return Semantics(
      // Status tidak boleh hanya dibedakan warna (DESIGN.md): sel aktif memakai
      // centang, sel kosong memakai cincin, dan semantik menyebut statusnya.
      label: '$weekday, ${isActive ? activeLabel : missedLabel}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weekday,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isToday ? colors.ink : colors.inkMuted,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? colors.primary : Colors.transparent,
              border: Border.all(
                color: isActive
                    ? colors.primary
                    : (isToday ? colors.primary : colors.border),
                width: isToday ? 2 : 1,
              ),
            ),
            child: isActive
                ? Icon(Icons.check_rounded, size: 16, color: colors.onPrimary)
                : null,
          ),
        ],
      ),
    );
  }
}

/// Riwayat [streakHistoryLength] hari terakhir: hari mana yang ada penyelesaian
/// dan mana yang bolong.
///
/// Dibuat karena streak bisa direset tanpa penjelasan; angka yang tidak naik
/// baru bisa dipahami kalau hari bolongnya kelihatan.
class StreakHistoryStrip extends ConsumerWidget {
  const StreakHistoryStrip({super.key, this.now});

  /// Waktu acuan; diisi uji supaya hasilnya tidak bergantung jam mesin.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = context.colors;
    final today = _dateOnly(now ?? DateTime.now());
    final active = ref.watch(streakHistoryProvider).valueOrNull ?? const [];

    final activeDays = {
      for (final day in active) _dateOnly(day),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.streakHistoryTitle.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.inkMuted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = streakHistoryLength - 1; i >= 0; i--)
              Expanded(
                child: StreakHistoryDay(
                  key: ValueKey('streak-history-day-$i'),
                  date: today.subtract(Duration(days: i)),
                  isActive:
                      activeDays.contains(today.subtract(Duration(days: i))),
                  isToday: i == 0,
                  activeLabel: l10n.streakHistoryActive,
                  missedLabel: l10n.streakHistoryMissed,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
