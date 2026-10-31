import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/list_row.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(settingsRepositoryProvider);

    return AppScaffold(
      title: l10n.notificationsScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(20), // gutter board
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ToggleRow(
                  title: l10n.notifTaskLabel,
                  value: settings?.notifyTasks ?? true,
                  onChanged: (value) {
                    repo.updateNotificationPref(notifyTasks: value);
                    ref
                        .read(dailyMaintenanceServiceProvider)
                        .rescheduleAllReminders();
                  },
                ),
                _ToggleRow(
                  title: l10n.notifHabitLabel,
                  value: settings?.notifyHabits ?? true,
                  onChanged: (value) {
                    repo.updateNotificationPref(notifyHabits: value);
                    ref
                        .read(dailyMaintenanceServiceProvider)
                        .rescheduleAllReminders();
                  },
                ),
                _ToggleRow(
                  title: l10n.notifStreakWarningLabel,
                  value: settings?.notifyStreakWarning ?? true,
                  onChanged: (value) {
                    repo.updateNotificationPref(notifyStreakWarning: value);
                    ref
                        .read(dailyMaintenanceServiceProvider)
                        .rescheduleAllReminders();
                    ref
                        .read(gamificationRepositoryProvider)
                        .refreshStreakWarningNotification();
                  },
                ),
                _ToggleRow(
                  title: l10n.notifFreezeLabel,
                  value: settings?.notifyFreezeUsed ?? true,
                  onChanged: (value) =>
                      repo.updateNotificationPref(notifyFreezeUsed: value),
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris toggle bertema: `ListRow` + `Switch` (track `primary`, thumb
/// `onPrimary`). Seluruh baris bisa diketuk (tap target ≥48), setara perilaku
/// `SwitchListTile`.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListRow(
      title: title,
      showDivider: showDivider,
      trailing: Switch(
        value: value,
        activeTrackColor: colors.primary,
        activeThumbColor: colors.onPrimary,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }
}