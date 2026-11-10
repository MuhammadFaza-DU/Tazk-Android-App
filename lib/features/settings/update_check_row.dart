import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/update/update_controller.dart';
import '../../core/update/update_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';

/// Baris pengaturan "periksa pembaruan" (manual). Tap memicu `checkNow()` lalu
/// hasil ditampilkan sebaris di bawah judul — loading, up-to-date, judul banner
/// + aksi Unduh/Nanti, atau gagal + Coba lagi.
class UpdateCheckRow extends ConsumerWidget {
  const UpdateCheckRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(updateControllerProvider);

    void retry() => ref.read(updateControllerProvider.notifier).checkNow();

    return InkWell(
      onTap: retry,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48), // tap target
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _IconTile(Icons.system_update_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.updateCheckLabel,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  async.when(
                    loading: () => _Loading(
                      subtitle: l10n.updateCheckSubtitle,
                    ),
                    error: (_, _) => _MessageWithAction(
                      message: l10n.updateCheckFailed,
                      actionLabel: l10n.stateRetryAction,
                      onAction: retry,
                    ),
                    data: (result) => _DataStatus(
                      l10n: l10n,
                      result: result,
                      onRetry: retry,
                      onDownload: (url) => _openDownload(context, url),
                      onDismiss: (version) => ref
                          .read(settingsRepositoryProvider)
                          .updateCheckPref(skippedUpdateVersion: version),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Buka URL unduhan. Manifest sudah di-validasi https oleh `tryParse`, tetapi
  /// jaring pengaman ini memastikan hanya skema https yang pernah dibuka.
  Future<void> _openDownload(BuildContext context, String downloadUrl) async {
    final uri = Uri.parse(downloadUrl);
    if (uri.scheme != 'https') return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('launchUrl failed: $error');
    }
  }
}

class _DataStatus extends StatelessWidget {
  const _DataStatus({
    required this.l10n,
    required this.result,
    required this.onRetry,
    required this.onDownload,
    required this.onDismiss,
  });

  final AppLocalizations l10n;
  final UpdateCheckResult? result;
  final VoidCallback onRetry;
  final ValueChanged<String> onDownload;
  final ValueChanged<String> onDismiss;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return _Subtitle(l10n.updateCheckSubtitle);
    }

    final manifest = result!.manifest;

    if (result!.error != null) {
      return _MessageWithAction(
        message: l10n.updateCheckFailed,
        actionLabel: l10n.stateRetryAction,
        onAction: onRetry,
      );
    }

    if (result!.hasUpdate && manifest != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.updateBannerTitle(manifest.version),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => onDownload(manifest.downloadUrl),
                child: Text(l10n.updateBannerAction),
              ),
              TextButton(
                onPressed: () => onDismiss(manifest.version),
                child: Text(l10n.updateBannerDismiss),
              ),
            ],
          ),
        ],
      );
    }

    return Text(
      l10n.updateCheckUpToDate,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: context.colors.success,
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Flexible(child: _Subtitle(subtitle)),
      ],
    );
  }
}

class _MessageWithAction extends StatelessWidget {
  const _MessageWithAction({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.danger,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: context.colors.inkMuted),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Petak ikon baris — 30×30 `primary-container` radius 8, ikon 18 `primary`
/// (menyamai `_IconTile` di `settings_screen.dart`).
class _IconTile extends StatelessWidget {
  const _IconTile(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: context.colors.primary),
    );
  }
}