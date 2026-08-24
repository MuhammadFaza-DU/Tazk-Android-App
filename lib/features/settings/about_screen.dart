import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(l10n.splashTagline, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text(l10n.aboutVersionLabel(_version)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.aboutDescription, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
