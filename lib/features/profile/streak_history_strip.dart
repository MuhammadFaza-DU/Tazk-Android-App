import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/current_date_provider.dart';
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
    final weekday = _weekdayLabel(context, date);

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
    final today = _dateOnly(now ?? ref.watch(currentDateProvider));
    final history = ref.watch(streakHistoryProvider);

    // A missing value must not render as seven "no activity" cells: that is a
    // false statement about the user's own history while the query is still in
    // flight. Matches the Profile screen's rule for the badge/avatar counters.
    final active = history.valueOrNull;
    final activeDays = <DateTime>{
      for (final day in active ?? const <DateTime>[]) _dateOnly(day),
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
                child: active == null
                    ? const _PendingDay()
                    : StreakHistoryDay(
                        key: ValueKey('streak-history-day-$i'),
                        date: _addDays(today, -i),
                        isActive: activeDays.contains(_addDays(today, -i)),
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

/// Placeholder sel selama riwayat belum punya nilai — sengaja tanpa centang
/// maupun cincin supaya tidak menyatakan "ada" atau "tidak ada" aktivitas.
class _PendingDay extends StatelessWidget {
  const _PendingDay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.surfaceAlt,
        ),
      ),
    );
  }
}

/// Nama hari singkat mengikuti locale aktif, dengan fallback `en` seperti
/// pemformat tanggal lain di app ini.
String _weekdayLabel(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    return DateFormat.E(locale).format(date);
  } catch (_) {
    return DateFormat.E('en').format(date);
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Calendar-day arithmetic so a daylight-saving change cannot shift the key off
/// midnight and mark a genuinely active day as missed.
DateTime _addDays(DateTime day, int delta) =>
    DateTime(day.year, day.month, day.day + delta);
