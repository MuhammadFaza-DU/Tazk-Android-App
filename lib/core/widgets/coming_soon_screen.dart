import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_scaffold.dart';

/// Placeholder for screens not yet built in this pass of the build order.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.comingSoonMessage(title),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
