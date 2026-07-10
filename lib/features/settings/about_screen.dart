import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

const _appVersion = '1.0.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                Text(l10n.aboutVersionLabel(_appVersion)),
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
