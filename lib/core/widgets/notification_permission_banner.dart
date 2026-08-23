import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/notification_permission_provider.dart';
import '../../providers/notification_provider.dart';

/// PRD "Error States": when notifications are denied, show a banner on app
/// open ("Notifikasi dimatikan, aktifkan supaya reminder berfungsi") with a
/// direct button to the OS notification settings and a dismiss (✕) for users
/// who are not ready yet.
class NotificationPermissionBanner extends ConsumerWidget {
  const NotificationPermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationPermissionProvider);
    if (state.status != NotificationPermissionStatus.denied || state.dismissed) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.permissionBannerMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref
                  .read(notificationServiceProvider)
                  .openOsNotificationSettings(),
              child: Text(l10n.permissionBannerAction),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () =>
                  ref.read(notificationPermissionProvider.notifier).dismiss(),
            ),
          ],
        ),
      ),
    );
  }
}
