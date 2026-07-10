import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

enum TaskPriority { low, medium, high }

enum HabitFrequency { daily, weekly, monthly, custom }

extension HabitFrequencyLabel on HabitFrequency {
  String label(BuildContext context) => switch (this) {
        HabitFrequency.daily => AppLocalizations.of(context)!.frequencyDaily,
        HabitFrequency.weekly => AppLocalizations.of(context)!.frequencyWeekly,
        HabitFrequency.monthly => AppLocalizations.of(context)!.frequencyMonthly,
        HabitFrequency.custom => AppLocalizations.of(context)!.frequencyCustom,
      };
}

enum StreakRank { perintis, petarung, penakluk, sangAhli, sangMaster, legenda }

extension StreakRankLabel on StreakRank {
  String label(BuildContext context) => switch (this) {
        StreakRank.perintis => AppLocalizations.of(context)!.rankPerintis,
        StreakRank.petarung => AppLocalizations.of(context)!.rankPetarung,
        StreakRank.penakluk => AppLocalizations.of(context)!.rankPenakluk,
        StreakRank.sangAhli => AppLocalizations.of(context)!.rankSangAhli,
        StreakRank.sangMaster => AppLocalizations.of(context)!.rankSangMaster,
        StreakRank.legenda => AppLocalizations.of(context)!.rankLegenda,
      };
}

enum AppThemeMode { light, dark }

enum AppLanguage { indonesian, english }

StreakRank streakRankForDays(int days) {
  if (days >= 120) return StreakRank.legenda;
  if (days >= 90) return StreakRank.sangMaster;
  if (days >= 60) return StreakRank.sangAhli;
  if (days >= 30) return StreakRank.penakluk;
  if (days >= 7) return StreakRank.petarung;
  return StreakRank.perintis;
}
