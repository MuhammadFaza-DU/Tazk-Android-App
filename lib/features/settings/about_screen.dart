import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../l10n/app_localizations.dart';

// Fallback matches pubspec.yaml version so the screen never shows a hard-coded
// lie when the platform channel is unavailable (e.g. in widget tests).
const _fallbackVersion = '1.1.5';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = _fallbackVersion;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      final v = info.version;
      final b = info.buildNumber;
      setState(() => _version = b.isEmpty ? v : '$v+$b');
    } catch (_) {
      // Keep fallback — the plugin's MethodChannel doesn't exist in tests or
      // on unusual platforms. Showing the pubspec version is still truthful.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final colors = context.colors;
    return AppScaffold(
      title: l10n.aboutScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(16), // spacing.lg (DESIGN: Layout)
        children: [
          AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appTitle,
                  style: theme.displayLarge, // display — Fredoka 30
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4), // spacing.xs
                Text(
                  l10n.splashTagline,
                  style: theme.bodyLarge?.copyWith(color: colors.inkMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12), // spacing.md
                Text(
                  l10n.aboutVersionLabel(_version),
                  style: theme.bodySmall?.copyWith(color: colors.inkMuted), // caption
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), // spacing.xl — antar-section
          AppCard(
            child: Text(
              l10n.aboutDescription,
              textAlign: TextAlign.center,
              style: theme.bodyLarge, // body — Plus Jakarta Sans 15
            ),
          ),
        ],
      ),
    );
  }
}