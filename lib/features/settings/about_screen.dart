import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/app_colors.dart';
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

/// Layar Tentang — board `23 Tentang`.
///
/// Blok identitas dari board (diukur @2x → /2): petak maskot `otter-portrait`
/// 84dp (radius `lg`), nama app `display` 30, versi `body` 15 `ink-muted`,
/// lalu deskripsi 2 baris `body` 15 `ink-muted` berlebar ~290dp.
///
/// Versi dibaca dari `package_info_plus` (tidak di-hardcode); selama plugin
/// belum menjawab, baris versi tidak dirender — lebih baik kosong daripada
/// angka karangan.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  /// Ukuran petak maskot (board: 168px @2x).
  static const double mascotSize = 84;

  /// Radius petak maskot (board: sudut ~36px @2x → `rounded.lg`).
  static const double mascotRadius = 18;

  /// Inset kiri/kanan paragraf deskripsi supaya terbungkus seperti board
  /// (board: blok teks 577px @2x, dua baris).
  static const double descriptionInset = 16;

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
        ],
      ),
    );
  }
}