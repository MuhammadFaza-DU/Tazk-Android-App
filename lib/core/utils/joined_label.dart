import 'package:tazk/l10n/app_localizations.dart';

/// Label "Bergabung X bulan lalu" berdasarkan selisih bulan kalender.
///
/// Selisih dihitung dari `(tahun, bulan)` — bukan `days ~/ 30` — supaya label
/// tidak melompat pada batas bulan (contoh: 31 Jan → 1 Feb tetap "1 bulan").
/// Selisih 0 (bulan yang sama) atau [createdAt] di masa depan sama-sama
/// menghasilkan teks "bulan ini".
String joinedLabel(DateTime createdAt, DateTime now, AppLocalizations l10n) {
  final monthDiff =
      (now.year - createdAt.year) * 12 + (now.month - createdAt.month);
  if (monthDiff <= 0) return l10n.profileJoinedThisMonth;
  return l10n.profileJoinedMonths(monthDiff);
}