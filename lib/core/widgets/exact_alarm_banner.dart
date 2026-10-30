import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/exact_alarm_permission_provider.dart';
import '../../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';
import 'app_card.dart';

class ExactAlarmBanner extends ConsumerWidget {
  const ExactAlarmBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exactAlarmProvider);
    if (state.status != ExactAlarmStatus.denied || state.dismissed) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.exactAlarmBannerMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.warningStrong),
              ),
            ),
            AppButton.ghost(
              label: l10n.exactAlarmBannerAction,
              onPressed: () async {
                await ref
                    .read(notificationServiceProvider)
                    .requestExactAlarmPermission();
                ref.read(exactAlarmProvider.notifier).check();
              },
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
