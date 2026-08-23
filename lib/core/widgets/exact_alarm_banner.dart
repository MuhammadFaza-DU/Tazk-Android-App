import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/exact_alarm_permission_provider.dart';
import '../../providers/notification_provider.dart';

class ExactAlarmBanner extends ConsumerWidget {
  const ExactAlarmBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exactAlarmProvider);
    if (state.status != ExactAlarmStatus.denied || state.dismissed) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.exactAlarmBannerMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(notificationServiceProvider)
                    .requestExactAlarmPermission();
                ref.read(exactAlarmProvider.notifier).check();
              },
              child: Text(l10n.exactAlarmBannerAction),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => ref.read(exactAlarmProvider.notifier).dismiss(),
            ),
          ],
        ),
      ),
    );
  }
}
