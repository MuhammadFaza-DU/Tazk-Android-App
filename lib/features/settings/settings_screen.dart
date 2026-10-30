import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/list_row.dart';
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
    return Builder(
        builder: (context) {
          final settings = ref.watch(appSettingsProvider).valueOrNull;
          final permission = ref.watch(notificationPermissionProvider);
          final l10n = AppLocalizations.of(context)!;
          final repo = ref.read(settingsRepositoryProvider);
          final colors = context.colors;

          final themeMode = settings?.themeMode ?? AppThemeMode.light;
          final language = settings?.language ?? AppLanguage.indonesian;
          final permissionEnabled =
              permission.status != NotificationPermissionStatus.denied;

          return AppScaffold(
            title: l10n.settingsScreenTitle,
            body: ListView(
              padding: const EdgeInsets.all(16), // spacing.lg (DESIGN: Layout)
              children: [
                // --- Notifikasi & izin ---
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListRow(
                        leading: const Icon(Icons.notifications_rounded),
                        title: l10n.settingsNotifications,
                        subtitle: l10n.settingsNotificationsSubtitle,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: colors.inkMuted,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      ListRow(
                        leading: Icon(
                          permissionEnabled
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_rounded,
                          color: permissionEnabled
                              ? colors.primary
                              : colors.danger,
                        ),
                        title: l10n.notifStatusLabel,
                        subtitle: permissionEnabled
                            ? l10n.notifStatusEnabled
                            : l10n.notifStatusDisabled,
                        onTap: () async {
                          await ref
                              .read(notificationServiceProvider)
                              .openOsNotificationSettings();
                          // Re-query saat balik dari pengaturan sistem.
                          ref.read(notificationPermissionProvider.notifier).check();
                        },
                      ),
                      Consumer(builder: (context, ref, _) {
                        final exact = ref.watch(exactAlarmProvider);
                        final allowed = exact.status != ExactAlarmStatus.denied;
                        final l10n2 = AppLocalizations.of(context)!;
                        return ListRow(
                          leading: Icon(
                            allowed
                                ? Icons.alarm_on_rounded
                                : Icons.alarm_off_rounded,
                            color: allowed ? colors.primary : colors.danger,
                          ),
                          title: l10n2.exactAlarmSettingsTitle,
                          subtitle: allowed
                              ? l10n2.exactAlarmActive
                              : l10n2.exactAlarmInactive,
                          showDivider: false,
                          onTap: () async {
                            await ref
                                .read(notificationServiceProvider)
                                .requestExactAlarmPermission();
                            ref.read(exactAlarmProvider.notifier).check();
                          },
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 24), // spacing.xl — antar-section
                _SectionLabel(l10n.settingsAppearance),
                const SizedBox(height: 8), // spacing.sm
                AppCard(
                  child: _SegmentedControl<AppThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: AppThemeMode.light,
                        label: Text(l10n.themeLight),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        label: Text(l10n.themeDark),
                      ),
                    ],
                    value: themeMode,
                    onChanged: repo.updateThemeMode,
                  ),
                ),

                const SizedBox(height: 24), // spacing.xl
                _SectionLabel(l10n.settingsLanguage),
                const SizedBox(height: 8), // spacing.sm
                AppCard(
                  child: _SegmentedControl<AppLanguage>(
                    segments: [
                      ButtonSegment(
                        value: AppLanguage.indonesian,
                        label: Text(l10n.languageIndonesian),
                      ),
                      ButtonSegment(
                        value: AppLanguage.english,
                        label: Text(l10n.languageEnglish),
                      ),
                    ],
                    value: language,
                    onChanged: repo.updateLanguage,
                  ),
                ),

                const SizedBox(height: 24), // spacing.xl
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ListRow(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: l10n.settingsAbout,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colors.inkMuted,
                    ),
                    showDivider: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
    );
  }
}

/// Label section kecil (Plus Jakarta Sans 13 w600 = token `label`), warna
/// `inkMuted` untuk hierarki di bawah judul baris.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: context.colors.inkMuted),
      ),
    );
  }
}

/// Segmented control bertema (`segmented-control` token DESIGN: bg `surface-alt`,
/// radius pill, padding `xs`). Segmen terpilih `primary`/`on-primary`, tak
/// terpilih `inkMuted` di atas `surface-alt`; tinggi 48 (tap target).
class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final List<ButtonSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4), // spacing.xs
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(999), // rounded.pill
      ),
      child: SegmentedButton<T>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: segments,
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          selectedBackgroundColor: colors.primary,
          foregroundColor: colors.inkMuted,
          selectedForegroundColor: colors.onPrimary,
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          minimumSize: const Size(0, 48), // tap target
          textStyle: theme.textTheme.labelLarge,
        ),
      ),
    );
  }
}