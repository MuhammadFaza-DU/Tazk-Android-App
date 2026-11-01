import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/backup_file.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/home_widget_provider.dart';
import '../../providers/repository_providers.dart';
import 'backup_io.dart';

/// Key aksi ekspor, impor, dan konfirmasi timpa di dialog.
const Key backupExportButtonKey = ValueKey('backup-export');
const Key backupImportButtonKey = ValueKey('backup-import');
const Key backupConfirmActionKey = ValueKey('backup-confirm');

/// Cadangkan & pulihkan offline — satu file JSON, tanpa akun dan tanpa server.
///
/// Tidak ada board untuk layar ini (brief T10.2); bentuknya mengikuti token
/// `DESIGN.md` dan konvensi yang sudah ada: `AppScaffold` + gutter 20, satu
/// `AppCard` berisi catatan, lalu dua aksi setinggi 48. Google Drive sengaja
/// ditunda, jadi barisnya tidak dibuat dan keterbatasannya dinyatakan apa adanya.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key, this.io = const PlatformBackupIo()});

  /// Titik sentuh platform; test menyuntikkan pengganti.
  final BackupIo io;

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  /// Mencegah dua aksi berjalan bersamaan (berbagi & impor sama-sama modal).
  bool _busy = false;

  /// Nama file memakai jam lokal, tanpa locale data: `tazk-backup-20261102-0930`.
  static String fileNameFor(DateTime now) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'tazk-backup-${now.year}${two(now.month)}${two(now.day)}'
        '-${two(now.hour)}${two(now.minute)}.json';
  }

  Future<void> _export() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final json = await ref.read(backupRepositoryProvider).exportBackupJson();
      await widget.io.shareJson(json, fileNameFor(DateTime.now()));
      if (!mounted) return;
      showAppSnackbar(context, l10n.backupExportDone);
    } catch (error) {
      debugPrint('BackupScreen: export failed: $error');
      if (!mounted) return;
      showAppSnackbar(context, l10n.stateErrorMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final picked = await widget.io.pickJson();
      if (picked == null || !mounted) return;
      // Penyunting teks atau sinkronisasi cloud bisa menyisipkan BOM UTF-8, dan
      // `jsonDecode` menolaknya sebagai JSON tidak valid.
      final text = picked.startsWith('\uFEFF') ? picked.substring(1) : picked;
      final confirmed = await _confirmOverwrite();
      if (confirmed != true || !mounted) return;

      await ref.read(backupRepositoryProvider).importBackupJson(text);
      await _refreshAfterRestore();
      if (!mounted) return;
      showAppSnackbar(context, l10n.backupImportDone);
    } on BackupException catch (error) {
      debugPrint('BackupScreen: rejected backup: ${error.message}');
      if (!mounted) return;
      showAppSnackbar(context, l10n.backupImportInvalid);
    } on FormatException catch (error) {
      // File yang bukan UTF-8 gagal saat dibaca, sebelum sempat divalidasi.
      debugPrint('BackupScreen: unreadable backup: $error');
      if (!mounted) return;
      showAppSnackbar(context, l10n.backupImportInvalid);
    } catch (error) {
      debugPrint('BackupScreen: import failed: $error');
      if (!mounted) return;
      showAppSnackbar(context, l10n.stateErrorMessage);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmOverwrite() {
    final l10n = AppLocalizations.of(context)!;
    return showAppDialog<bool>(
      context,
      title: l10n.backupConfirmTitle,
      content: Text(l10n.backupConfirmBody),
      actions: [
        AppButton.ghost(
          label: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton.danger(
          key: backupConfirmActionKey,
          label: l10n.backupConfirmAction,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  /// Data sudah terpulihkan saat ini terjadi, jadi kegagalan menyegarkan
  /// pengingat atau widget dicatat saja dan tidak membatalkan kabar sukses.
  /// Dijaga terpisah supaya kegagalan yang pertama tidak melewati yang kedua.
  Future<void> _refreshAfterRestore() async {
    await _guardRefresh(
      'reminders',
      () => ref.read(dailyMaintenanceServiceProvider).rescheduleAllReminders(),
    );
    await _guardRefresh(
      'widgets',
      () => ref.read(homeWidgetServiceProvider).refreshAll(),
    );
  }

  Future<void> _guardRefresh(
    String target,
    Future<void> Function() run,
  ) async {
    try {
      await run();
    } catch (error) {
      debugPrint('BackupScreen: refresh $target after restore failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppScaffold(
      title: l10n.backupScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(20), // gutter board
        children: [
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.backupLocalNote,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.inkMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton.primary(
            key: backupExportButtonKey,
            label: l10n.backupExportAction,
            icon: Icons.ios_share_rounded,
            expanded: true,
            onPressed: _busy ? null : _export,
          ),
          const SizedBox(height: 12),
          AppButton.secondary(
            key: backupImportButtonKey,
            label: l10n.backupImportAction,
            icon: Icons.restore_rounded,
            expanded: true,
            onPressed: _busy ? null : _import,
          ),

          const SizedBox(height: 16),
          Text(
            l10n.backupDriveDeferred,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
