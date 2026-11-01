import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/list_row.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/exact_alarm_permission_provider.dart';
import '../../providers/notification_permission_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import 'about_screen.dart';
import 'categories_screen.dart';
import 'notification_settings_screen.dart';

/// Layar Pengaturan — fidelity board `design-export/08 Pengaturan.png`
/// (780×1482 px, dibagi 2 → frame 390dp).
///
/// Hasil ukur board:
/// - gutter kiri/kanan 20 (border kartu di x=39-40 px), radius kartu `md`,
///   satu kartu per grup berisi baris berdivider;
/// - label grup huruf besar `ink-muted` 13/w600, rata tepi kartu, 16 di atas
///   kartu, 24 dari kartu sebelumnya;
/// - tiap baris: petak ikon 30×30 `primary-container` radius 8 + ikon 18
///   `primary`, judul `body` 15, sub-judul `caption` 12 `ink-muted`, chevron
///   18 `ink-muted` di kanan;
/// - urutan grup: Pemberitahuan → Tampilan → Bahasa → Kategori → Lainnya.
///
/// Deviasi yang disengaja (dicatat di laporan): gutter memakai 16 (aturan
/// DESIGN "satu wrapper, padding diterapkan sekali" + konsisten dengan 12 layar
/// lain), dan pemilih tema/bahasa tetap `SegmentedButton` (bukan baris nilai +
/// chevron) karena brief memintanya dan l10n tidak punya string "Tema" /
/// "Ikuti sistem".
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final permission = ref.watch(notificationPermissionProvider);
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(settingsRepositoryProvider);
    final colors = context.colors;

    final themeMode = settings?.themeMode ?? AppThemeMode.light;
    final language = settings?.language ?? AppLanguage.indonesian;
    final permissionEnabled =
        permission.status != NotificationPermissionStatus.denied;

    void openNotificationSettings() {
      Navigator.of(
        context,
      ).push(AppPageRoute(builder: (_) => const NotificationSettingsScreen()));
    }

    /// Baris pengingat: petak ikon + judul + status on/off + chevron. Board
    /// memakai chevron (bukan toggle) karena toggle nyatanya ada di layar
    /// Notifikasi yang dibuka baris ini.
    Widget reminderRow({
      required IconData icon,
      required String title,
      required bool enabled,
      bool showDivider = true,
    }) {
      return ListRow(
        leading: _IconTile(icon),
        title: title,
        subtitle: enabled ? l10n.notifStatusEnabled : l10n.notifStatusDisabled,
        trailing: const _Chevron(),
        showDivider: showDivider,
        onTap: openNotificationSettings,
      );
    }

    return AppScaffold(
      title: l10n.settingsScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(20), // gutter board
        children: [
          // --- Pemberitahuan ---
          _SectionLabel(l10n.settingsNotifications),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                reminderRow(
                  icon: Icons.notifications_rounded,
                  title: l10n.notifTaskLabel,
                  enabled: settings?.notifyTasks ?? true,
                ),
                reminderRow(
                  icon: Icons.repeat_rounded,
                  title: l10n.notifHabitLabel,
                  enabled: settings?.notifyHabits ?? true,
                ),
                reminderRow(
                  icon: Icons.local_fire_department_rounded,
                  title: l10n.notifStreakWarningLabel,
                  enabled: settings?.notifyStreakWarning ?? true,
                ),
                // Baris ke-4 = perluasan produk (board 08 hanya punya 3);
                // deviasinya dicatat di laporan T9.2.
                reminderRow(
                  icon: Icons.timer_rounded,
                  title: l10n.notifFocusSessionLabel,
                  enabled: settings?.notifyFocusSession ?? true,
                ),
                ListRow(
                  leading: _IconTile(
                    permissionEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    tint: permissionEnabled ? null : colors.danger,
                  ),
                  title: l10n.notifStatusLabel,
                  subtitle: permissionEnabled
                      ? l10n.notifStatusEnabled
                      : l10n.notifStatusDisabled,
                  trailing: const _Chevron(),
                  onTap: () async {
                    await ref
                        .read(notificationServiceProvider)
                        .openOsNotificationSettings();
                    // Re-query saat balik dari pengaturan sistem.
                    ref.read(notificationPermissionProvider.notifier).check();
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final exact = ref.watch(exactAlarmProvider);
                    final allowed = exact.status != ExactAlarmStatus.denied;
                    final l10n2 = AppLocalizations.of(context)!;
                    return ListRow(
                      leading: _IconTile(
                        allowed
                            ? Icons.alarm_on_rounded
                            : Icons.alarm_off_rounded,
                        tint: allowed ? null : colors.danger,
                      ),
                      title: l10n2.exactAlarmSettingsTitle,
                      subtitle: allowed
                          ? l10n2.exactAlarmActive
                          : l10n2.exactAlarmInactive,
                      trailing: const _Chevron(),
                      showDivider: false,
                      onTap: () async {
                        await ref
                            .read(notificationServiceProvider)
                            .requestExactAlarmPermission();
                        ref.read(exactAlarmProvider.notifier).check();
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24), // spacing.xl — antar-grup
          _SectionLabel(l10n.settingsAppearance),
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

          const SizedBox(height: 24),
          _SectionLabel(l10n.settingsLanguage),
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

          const SizedBox(height: 24),
          // Grup baru — board `08` belum memilikinya (deviasi tercatat di
          // laporan T7.3). Ditaruh sebelum LAINNYA supaya grup DATA (T10) tetap
          // berisi backup/ekspor saja.
          _SectionLabel(l10n.settingsCategories),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListRow(
              leading: const _IconTile(Icons.label_outline_rounded),
              title: l10n.manageCategoriesLabel,
              trailing: const _Chevron(),
              showDivider: false,
              onTap: () {
                Navigator.of(
                  context,
                ).push(AppPageRoute(builder: (_) => const CategoriesScreen()));
              },
            ),
          ),

          const SizedBox(height: 24),
          _SectionLabel(l10n.navMore),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListRow(
              leading: const _IconTile(Icons.info_outline_rounded),
              title: l10n.settingsAbout,
              trailing: const _Chevron(),
              showDivider: false,
              onTap: () {
                Navigator.of(
                  context,
                ).push(AppPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Label grup: huruf besar `label` (13/w600) warna `ink-muted`, rata tepi
/// kartu (tanpa inset), 16 di atas kartu berikutnya.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16), // spacing.lg
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.colors.inkMuted,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

/// Petak ikon baris: 30×30 `primary-container` radius 8, ikon 18 `primary`
/// (atau `danger` saat status mati). Board mengukur 60×60 px @2x.
class _IconTile extends StatelessWidget {
  const _IconTile(this.icon, {this.tint});

  final IconData icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: tint ?? colors.primary),
    );
  }
}

/// Chevron kanan baris — 18 `ink-muted` (board: glyph 8×16 px @2x).
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 18,
      color: context.colors.inkMuted,
    );
  }
}

/// Segmented control bertema (`segmented-control` token DESIGN: bg `surface-alt`,
/// radius pill, padding `xs`). Segmen terpilih `primary`/`on-primary`, tak
/// terpilih `ink-muted` di atas `surface-alt`; tinggi 48 (tap target).
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
