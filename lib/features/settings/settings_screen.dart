import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_scaffold.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/notification_provider.dart';
import '../../providers/exact_alarm_permission_provider.dart';
import '../../providers/notification_permission_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import 'about_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final permission = ref.watch(notificationPermissionProvider);
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(settingsRepositoryProvider);

    final themeMode = settings?.themeMode ?? AppThemeMode.light;
    final language = settings?.language ?? AppLanguage.indonesian;
    final permissionEnabled =
        permission.status != NotificationPermissionStatus.denied;

    return AppScaffold(
      title: l10n.settingsScreenTitle,
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.settingsNotifications),
            subtitle: Text(l10n.settingsNotificationsSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),
          // PRD "Error States": passive indicator of the OS notification
          // permission so the user can check (and fix) it any time.
          ListTile(
            leading: Icon(
              permissionEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: permissionEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            title: Text(l10n.notifStatusLabel),
            subtitle: Text(
              permissionEnabled ? l10n.notifStatusEnabled : l10n.notifStatusDisabled,
            ),
            onTap: () async {
              await ref
                  .read(notificationServiceProvider)
                  .openOsNotificationSettings();
              // Re-query when the user comes back from system settings.
              ref.read(notificationPermissionProvider.notifier).check();
            },
          ),
          Consumer(builder: (context, ref, _) {
            final exact = ref.watch(exactAlarmProvider);
            final allowed = exact.status != ExactAlarmStatus.denied;
            return ListTile(
              leading: Icon(
                allowed ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                color: allowed
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              title: const Text('Alarm presisi'),
              subtitle: Text(allowed ? 'Aktif' : 'Mati — pengingat bisa telat'),
              onTap: () async {
                await ref
                    .read(notificationServiceProvider)
                    .requestExactAlarmPermission();
                ref.read(exactAlarmProvider.notifier).check();
              },
            );
          }),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(l10n.settingsAppearance, style: Theme.of(context).textTheme.titleSmall),
          ),
          RadioGroup<AppThemeMode>(
            groupValue: themeMode,
            onChanged: (value) => repo.updateThemeMode(value!),
            child: Column(
              children: [
                RadioListTile<AppThemeMode>(
                  title: Text(l10n.themeLight),
                  value: AppThemeMode.light,
                ),
                RadioListTile<AppThemeMode>(
                  title: Text(l10n.themeDark),
                  value: AppThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleSmall),
          ),
          RadioGroup<AppLanguage>(
            groupValue: language,
            onChanged: (value) => repo.updateLanguage(value!),
            child: Column(
              children: [
                RadioListTile<AppLanguage>(
                  title: Text(l10n.languageIndonesian),
                  value: AppLanguage.indonesian,
                ),
                RadioListTile<AppLanguage>(
                  title: Text(l10n.languageEnglish),
                  value: AppLanguage.english,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(l10n.settingsAbout),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
