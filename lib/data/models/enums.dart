enum TaskPriority { low, medium, high }

enum HabitFrequency { daily, weekly, monthly, custom }

enum StreakRank { perintis, petarung, penakluk, sangAhli, sangMaster, legenda }

extension StreakRankLabel on StreakRank {
  String get label => switch (this) {
        StreakRank.perintis => 'Perintis',
        StreakRank.petarung => 'Petarung',
        StreakRank.penakluk => 'Penakluk',
        StreakRank.sangAhli => 'Sang Ahli',
        StreakRank.sangMaster => 'Sang Master',
        StreakRank.legenda => 'Legenda',
      };
}

StreakRank streakRankForDays(int days) {
  if (days >= 120) return StreakRank.legenda;
  if (days >= 90) return StreakRank.sangMaster;
  if (days >= 60) return StreakRank.sangAhli;
  if (days >= 30) return StreakRank.penakluk;
  if (days >= 7) return StreakRank.petarung;
  return StreakRank.perintis;
}
