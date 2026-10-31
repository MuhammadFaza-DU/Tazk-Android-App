import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../l10n/app_localizations.dart';

/// Key petak maskot `otter-portrait`.
const Key aboutMascotKey = ValueKey('about-mascot');

/// Key nama app (Fredoka `display`).
const Key aboutNameKey = ValueKey('about-name');

/// Key baris versi dari `package_info_plus`.
const Key aboutVersionKey = ValueKey('about-version');

/// Key paragraf deskripsi.
const Key aboutDescriptionKey = ValueKey('about-description');

/// Key baris aksi "Kebijakan privasi".
const Key aboutPrivacyRowKey = ValueKey('about-privacy-row');

/// Key baris aksi "Lisensi open source".
const Key aboutLicensesRowKey = ValueKey('about-licenses-row');

/// Key footer "Dibuat dengan Flutter...".
const Key aboutFooterKey = ValueKey('about-footer');

/// Layar Tentang — board `23 Tentang`.
///
/// Blok identitas dari board (diukur @2x → /2): petak maskot `otter-portrait`
/// 84dp (radius `lg`), nama app `display` 30, versi `caption` 12 `ink-muted`,
/// lalu deskripsi 2 baris `body` 15 `ink-muted` berlebar ~290dp.
///
/// Versi dibaca dari `package_info_plus` (tidak di-hardcode); selama plugin
/// belum menjawab, baris versi tidak dirender — lebih baik kosong daripada
/// angka karangan.
///
/// Board memuat 4 baris aksi; hanya 2 yang dibangun karena punya tujuan nyata:
/// - "Kebijakan privasi" → dialog `aboutPrivacyBody` (teks nyata, tanpa server);
/// - "Lisensi open source" → `showLicensePage` bawaan Flutter.
///
/// "Beri rating" dan "Kirim masukan" sengaja ABSEN: Tazk tidak dijual di toko
/// aplikasi (distribusi APK dari landing page) dan belum ada alamat email, jadi
/// keduanya akan jadi tombol tanpa aksi (dilarang aturan R-26). Deviasi dari
/// board ini dicatat di laporan.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  /// Ukuran petak maskot (board: 168px @2x).
  static const double mascotSize = 84;

  /// Radius petak maskot (board: sudut ~36px @2x → `rounded.lg`).
  static const double mascotRadius = 18;

  /// Inset kiri/kanan paragraf deskripsi supaya terbungkus seperti board
  /// (board: blok teks 577px @2x, dua baris).
  static const double descriptionInset = 16;

  /// Tinggi minimum baris aksi. Tap target Android minimum 48dp; dipakai 56
  /// supaya baris terasa seperti kartu yang bisa disentuh, bukan teks.
  static const double actionRowHeight = 56;

  /// Radius baris aksi (`rounded.md`).
  static const double actionRowRadius = 14;

  /// Isian horizontal baris aksi (`spacing.lg`).
  static const double actionRowPadding = 16;

  /// Jarak ikon → label di dalam baris aksi.
  static const double actionRowIconGap = 12;

  /// Ukuran ikon kiri baris aksi.
  static const double actionRowIconSize = 22;

  /// Ukuran chevron kanan baris aksi.
  static const double actionRowChevronSize = 20;

  /// Jarak antar baris aksi (`spacing.md`).
  static const double actionRowGap = 12;

  /// Jarak deskripsi → baris aksi pertama, dan baris terakhir → footer
  /// (`spacing.xl`).
  static const double actionBlockGap = 24;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = info.version);
    } catch (_) {
      // MethodChannel tidak ada di widget test / platform tak dikenal:
      // biarkan kosong, jangan tampilkan versi karangan.
    }
  }

  /// Kebijakan privasi: teks nyata dari l10n, bisa digulir di layar pendek.
  Future<void> _showPrivacyPolicy(AppLocalizations l10n) {
    return showAppDialog<void>(
      context,
      title: l10n.aboutPrivacyTitle,
      content: SingleChildScrollView(child: Text(l10n.aboutPrivacyBody)),
      actions: [
        AppButton.primary(
          label: l10n.okButton,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Lisensi: halaman lisensi bawaan Flutter (bukan halaman tiruan). Nama &
  /// versi app diteruskan supaya header-nya menyebut Tazk, bukan "Flutter".
  void _showLicenses(AppLocalizations l10n) {
    showLicensePage(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: _version,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    final version = _version;

    return AppScaffold(
      title: l10n.aboutScreenTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 24), // gutter + spacing.3xl
        children: [
          Center(
            child: Container(
              key: aboutMascotKey,
              width: AboutScreen.mascotSize,
              height: AboutScreen.mascotSize,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(AboutScreen.mascotRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AboutScreen.mascotRadius),
                child: Image.asset(
                  'assets/mascot/otter-portrait.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.pets_rounded,
                    size: 36,
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12), // board: petak → nama
          Text(
            l10n.appTitle,
            key: aboutNameKey,
            textAlign: TextAlign.center,
            style: theme.displayLarge?.copyWith(color: colors.ink),
          ),
          if (version != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.aboutVersionLabel(version),
              key: aboutVersionKey,
              textAlign: TextAlign.center,
              style: theme.bodySmall?.copyWith(color: colors.inkMuted),
            ),
          ],
          const SizedBox(height: 8), // board: versi → deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AboutScreen.descriptionInset,
            ),
            child: Text(
              l10n.aboutDescription,
              key: aboutDescriptionKey,
              textAlign: TextAlign.center,
              style: theme.bodyMedium?.copyWith(color: colors.inkMuted),
            ),
          ),
          const SizedBox(height: AboutScreen.actionBlockGap),
          _AboutActionRow(
            rowKey: aboutPrivacyRowKey,
            icon: Icons.shield_outlined,
            label: l10n.aboutPrivacyTitle,
            onTap: () => _showPrivacyPolicy(l10n),
          ),
          const SizedBox(height: AboutScreen.actionRowGap),
          _AboutActionRow(
            rowKey: aboutLicensesRowKey,
            icon: Icons.description_outlined,
            label: l10n.aboutLicensesTitle,
            onTap: () => _showLicenses(l10n),
          ),
          const SizedBox(height: AboutScreen.actionBlockGap),
          Text(
            l10n.aboutFooter,
            key: aboutFooterKey,
            textAlign: TextAlign.center,
            style: theme.bodySmall?.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// Satu baris aksi Tentang: kartu sendiri (bukan grup berdivider) berisi ikon
/// kiri, label, dan chevron kanan.
///
/// Tinggi memakai `minHeight` (bukan tinggi tetap) supaya label tetap terbaca
/// saat `textScale` besar: baris ikut tumbuh, tidak memotong teks dan tidak
/// overflow. Umpan tekan dari `InkWell` (ripple) di dalam `Material`, dengan
/// `customBorder` radius 14 supaya ripple mengikuti bentuk kartu.
class _AboutActionRow extends StatelessWidget {
  const _AboutActionRow({
    required this.rowKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Key dipasang di `Container` terluar (bukan di widget ini) supaya test
  /// bisa mengukur ukuran & dekorasi kartunya langsung.
  final Key rowKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    const radius = BorderRadius.all(
      Radius.circular(AboutScreen.actionRowRadius),
    );

    return Container(
      key: rowKey,
      constraints: const BoxConstraints(
        minHeight: AboutScreen.actionRowHeight,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const RoundedRectangleBorder(borderRadius: radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AboutScreen.actionRowPadding,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: AboutScreen.actionRowIconSize,
                  color: colors.ink,
                ),
                const SizedBox(width: AboutScreen.actionRowIconGap),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AboutScreen.actionRowChevronSize,
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
