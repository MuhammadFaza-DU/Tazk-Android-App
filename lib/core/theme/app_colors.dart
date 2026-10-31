import 'package:flutter/material.dart';

/// Design system v2 — tema "Sage & Sand" (light) / "Dusk Forest" (dark).
///
/// 19 token semantik yang memetakan 1:1 ke `DESIGN.md` (section `colors` untuk
/// light, tabel "Themes" untuk dark). Akses lewat `context.colors.<token>`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.ink,
    required this.inkMuted,
    required this.primary,
    required this.primarySoft,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryMuted,
    required this.clay,
    required this.clayContainer,
    required this.honey,
    required this.honeyContainer,
    required this.danger,
    required this.warning,
    required this.warningStrong,
    required this.success,
    required this.levelCard,
    required this.levelCardOn,
    required this.levelCardOnMuted,
    required this.levelCardTrack,
    required this.levelCardAccent,
    required this.levelCardOnAccent,
  });

  /// Latar halaman.
  final Color canvas;

  /// Latar kartu.
  final Color surface;

  /// Isian sekunder & input.
  final Color surfaceAlt;

  /// Setiap separator (pengganti bayangan).
  final Color border;

  /// Teks utama.
  final Color ink;

  /// Teks sekunder.
  final Color inkMuted;

  /// Warna aksi sage.
  final Color primary;

  /// Isian & ikon aksen (BUKAN teks di atas permukaan berwarna).
  final Color primarySoft;

  /// Latar terpilih & tombol quiet.
  final Color primaryContainer;

  /// Label utama di atas `primary`.
  final Color onPrimary;

  /// Baris sekunder di bawah label utama `primary`.
  final Color onPrimaryMuted;

  /// Aksen sekunder (sinyal prioritas tinggi).
  final Color clay;

  /// Latar `clay`.
  final Color clayContainer;

  /// Penanda progress & reward (XP, streak, badge).
  final Color honey;

  /// Latar `honey` (chip prioritas).
  final Color honeyContainer;

  /// Tindakan destruktif.
  final Color danger;

  /// Keadaan perhatian (ikon/titik/border — BUKAN teks kecil).
  final Color warning;

  /// Teks peringatan ukuran body (pengganti `warning` untuk teks kecil).
  final Color warningStrong;

  /// Sukses / positif.
  final Color success;

  // ---------------------------------------------------------------------------
  // "Hero" card (kartu Level di Home). Token terpisah karena di light theme
  // kartu ini berlatarkan warna AKSI gelap dengan teks terang, sedangkan di dark
  // theme latar terang itu justru menyilaukan: nilainya dibalik jadi panel hijau
  // gelap dengan teks terang. Tanpa token ini, kartu harus bercabang `isDark` dan
  // menyimpan hex di dalam widget fitur.
  // ---------------------------------------------------------------------------

  /// Latar kartu Level.
  final Color levelCard;

  /// Teks utama di atas [levelCard].
  final Color levelCardOn;

  /// Baris sekunder di bawah teks utama [levelCard].
  final Color levelCardOnMuted;

  /// Track progress XP di [levelCard] (isi memakai [levelCardAccent]).
  final Color levelCardTrack;

  /// Aksen di dalam kartu Level: isi XP dan pil streak.
  final Color levelCardAccent;

  /// Ikon + label di atas [levelCardAccent].
  final Color levelCardOnAccent;

  /// Light — "Sage & Sand" (verbatim `DESIGN.md` `colors:`).
  static const AppColors light = AppColors(
    canvas: Color(0xFFF4F1EA),
    surface: Color(0xFFFBF9F4),
    surfaceAlt: Color(0xFFEDE7DA),
    border: Color(0xFFE2DACB),
    ink: Color(0xFF26251F),
    inkMuted: Color(0xFF6A6659),
    primary: Color(0xFF4A5A44),
    primarySoft: Color(0xFF6B7F5E),
    primaryContainer: Color(0xFFDDE3D6),
    onPrimary: Color(0xFFFBF9F4),
    onPrimaryMuted: Color(0xFFDDE3D6),
    clay: Color(0xFFC97B5A),
    clayContainer: Color(0xFFF2DCD1),
    honey: Color(0xFFD69A3C),
    honeyContainer: Color(0xFFF6E4C2),
    danger: Color(0xFFA5432A),
    warning: Color(0xFFB4791F),
    warningStrong: Color(0xFF8A5A12),
    success: Color(0xFF4A5A44),
    // Light: kartu Level identik dengan board 01 (latar `primary`, teks
    // `on-primary`, aksen `honey`) — jadi tampilan light tidak berubah.
    levelCard: Color(0xFF4A5A44),
    levelCardOn: Color(0xFFFBF9F4),
    levelCardOnMuted: Color(0xFFDDE3D6),
    levelCardTrack: Color(0xFF6B7F5E),
    levelCardAccent: Color(0xFFD69A3C),
    levelCardOnAccent: Color(0xFF26251F),
  );

  /// Dark — "Dusk Forest" (verbatim tabel "Themes" `DESIGN.md`).
  static const AppColors dark = AppColors(
    canvas: Color(0xFF0F1A14),
    surface: Color(0xFF152219),
    surfaceAlt: Color(0xFF1C2C21),
    border: Color(0xFF23382A),
    ink: Color(0xFFE8F0E7),
    inkMuted: Color(0xFF9DAF9F),
    primary: Color(0xFF8FE0A9),
    primarySoft: Color(0xFF5FAE7C),
    primaryContainer: Color(0xFF20362A),
    onPrimary: Color(0xFF0F1A14),
    onPrimaryMuted: Color(0xFF20362A),
    clay: Color(0xFFE0A183),
    clayContainer: Color(0xFF3A2620),
    honey: Color(0xFFF2C765),
    honeyContainer: Color(0xFF3A3220),
    danger: Color(0xFFF0A48C),
    warning: Color(0xFFEBCB7E),
    warningStrong: Color(0xFFEBCB7E),
    success: Color(0xFF8FE0A9),
    // Dark: panel hijau dalam + teks terang, aksen amber tua (opsi 3 owner).
    // Kontras terukur: judul 9,81 · meta 5,99 · pil 7,40 · isi-vs-track 5,61.
    levelCard: Color(0xFF21402F),
    levelCardOn: Color(0xFFE8F0E7),
    levelCardOnMuted: Color(0xFFA8C2B0),
    levelCardTrack: Color(0xFF182F23),
    levelCardAccent: Color(0xFFC99B3F),
    levelCardOnAccent: Color(0xFF14110A),
  );

  @override
  AppColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? ink,
    Color? inkMuted,
    Color? primary,
    Color? primarySoft,
    Color? primaryContainer,
    Color? onPrimary,
    Color? onPrimaryMuted,
    Color? clay,
    Color? clayContainer,
    Color? honey,
    Color? honeyContainer,
    Color? danger,
    Color? warning,
    Color? warningStrong,
    Color? success,
    Color? levelCard,
    Color? levelCardOn,
    Color? levelCardOnMuted,
    Color? levelCardTrack,
    Color? levelCardAccent,
    Color? levelCardOnAccent,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      onPrimaryMuted: onPrimaryMuted ?? this.onPrimaryMuted,
      clay: clay ?? this.clay,
      clayContainer: clayContainer ?? this.clayContainer,
      honey: honey ?? this.honey,
      honeyContainer: honeyContainer ?? this.honeyContainer,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      warningStrong: warningStrong ?? this.warningStrong,
      success: success ?? this.success,
      levelCard: levelCard ?? this.levelCard,
      levelCardOn: levelCardOn ?? this.levelCardOn,
      levelCardOnMuted: levelCardOnMuted ?? this.levelCardOnMuted,
      levelCardTrack: levelCardTrack ?? this.levelCardTrack,
      levelCardAccent: levelCardAccent ?? this.levelCardAccent,
      levelCardOnAccent: levelCardOnAccent ?? this.levelCardOnAccent,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryMuted: Color.lerp(onPrimaryMuted, other.onPrimaryMuted, t)!,
      clay: Color.lerp(clay, other.clay, t)!,
      clayContainer: Color.lerp(clayContainer, other.clayContainer, t)!,
      honey: Color.lerp(honey, other.honey, t)!,
      honeyContainer: Color.lerp(honeyContainer, other.honeyContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningStrong: Color.lerp(warningStrong, other.warningStrong, t)!,
      success: Color.lerp(success, other.success, t)!,
      levelCard: Color.lerp(levelCard, other.levelCard, t)!,
      levelCardOn: Color.lerp(levelCardOn, other.levelCardOn, t)!,
      levelCardOnMuted:
          Color.lerp(levelCardOnMuted, other.levelCardOnMuted, t)!,
      levelCardTrack: Color.lerp(levelCardTrack, other.levelCardTrack, t)!,
      levelCardAccent: Color.lerp(levelCardAccent, other.levelCardAccent, t)!,
      levelCardOnAccent:
          Color.lerp(levelCardOnAccent, other.levelCardOnAccent, t)!,
    );
  }

  // ---------------------------------------------------------------------------
  // Backward-compat (nama v1) — dipertahankan agar kode v1 tetap compile
  // sampai T3. Nilai memetakan ke token light/dark barunya.
  // ---------------------------------------------------------------------------

  // @deprecated use context.colors.primary (light)
  @Deprecated('use context.colors.primary')
  static const Color primaryLight = Color(0xFF4A5A44);

  // @deprecated use context.colors.primary (dark)
  @Deprecated('use context.colors.primary')
  static const Color primaryDark = Color(0xFF8FE0A9);

  // @deprecated use context.colors.honey (light)
  @Deprecated('use context.colors.honey')
  static const Color accentLight = Color(0xFFD69A3C);

  // @deprecated use context.colors.honey (dark)
  @Deprecated('use context.colors.honey')
  static const Color accentDark = Color(0xFFF2C765);

  // @deprecated use context.colors.clay
  @Deprecated('use context.colors.clay')
  static const Color terracotta = Color(0xFFC97B5A);

  // @deprecated use context.colors.canvas (light)
  @Deprecated('use context.colors.canvas')
  static const Color backgroundLight = Color(0xFFF4F1EA);

  // @deprecated use context.colors.canvas (dark)
  @Deprecated('use context.colors.canvas')
  static const Color backgroundDark = Color(0xFF0F1A14);

  // @deprecated use context.colors.surface (light)
  @Deprecated('use context.colors.surface')
  static const Color surfaceLight = Color(0xFFFBF9F4);

  // @deprecated use context.colors.surface (dark)
  @Deprecated('use context.colors.surface')
  static const Color surfaceDark = Color(0xFF152219);
}

/// Helper akses cepat: `context.colors.primary`.
extension AppColorsTheme on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}