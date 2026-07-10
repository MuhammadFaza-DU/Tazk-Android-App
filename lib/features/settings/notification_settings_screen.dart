import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_providers.dart';
import '../../providers/repository_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsScreenTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.notifTaskLabel),
            value: settings?.notifyTasks ?? true,
            onChanged: (value) => repo.updateNotificationPref(notifyTasks: value),
          ),
          SwitchListTile(
            title: Text(l10n.notifHabitLabel),
            value: settings?.notifyHabits ?? true,
            onChanged: (value) => repo.updateNotificationPref(notifyHabits: value),
          ),
          SwitchListTile(
            title: Text(l10n.notifStreakWarningLabel),
            value: settings?.notifyStreakWarning ?? true,
            onChanged: (value) =>
                repo.updateNotificationPref(notifyStreakWarning: value),
          ),
          SwitchListTile(
            title: Text(l10n.notifFreezeLabel),
            value: settings?.notifyFreezeUsed ?? true,
            onChanged: (value) => repo.updateNotificationPref(notifyFreezeUsed: value),
          ),
        ],
      ),
    );
  }
}
