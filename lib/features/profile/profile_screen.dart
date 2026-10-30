import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shine_sweep.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/repository_providers.dart';

const _avatarIconPalette = [
  Icons.eco_rounded,
  Icons.local_florist_rounded,
  Icons.forest_rounded,
  Icons.park_rounded,
  Icons.grass_rounded,
  Icons.spa_rounded,
];

String _avatarIdForMilestone(int milestone) => 'level$milestone';

IconData _avatarIconFor(String avatarId) {
  if (avatarId == 'default') return Icons.person_rounded;
  final milestone = int.tryParse(avatarId.replaceFirst('level', '')) ?? 0;
  if (milestone <= 0) return Icons.person_rounded;
  final index = (milestone ~/ 10 - 1) % _avatarIconPalette.length;
  return _avatarIconPalette[index];
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final streak = ref.watch(streakStateProvider).valueOrNull;
    final badgesAsync = ref.watch(badgesProvider);
    final cosmeticsAsync = ref.watch(cosmeticsProvider);
    final l10n = AppLocalizations.of(context)!;

    final avatarId = profile?.avatarId ?? 'default';
    final name = (profile == null || profile.name.trim().isEmpty)
        ? l10n.noNamePlaceholder
        : profile.name;

    return AppScaffold(
      title: l10n.profileScreenTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          tooltip: l10n.changeAvatarTooltip,
          onPressed: profile == null
              ? null
              : () => _openAvatarPicker(
                    context,
                    ref,
                    currentAvatarId: profile.avatarId,
                    unlockedMilestones:
                        cosmeticsAsync.valueOrNull?.map((c) => c.levelMilestone).toList() ??
                            const [],
                  ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16), // spacing.lg
        children: [
          _ProfileHeader(
            avatarId: avatarId,
            name: name,
            level: profile?.level ?? 1,
            onEditName: profile == null
                ? null
                : () => _openRenameDialog(context, ref, profile.name),
          ),
          const SizedBox(height: 12), // spacing.md
          _GamificationSummary(profile: profile, streak: streak),
          const SizedBox(height: 24), // spacing.xl
          SectionHeader(title: l10n.badgeCollectionTitle),
          const SizedBox(height: 12), // spacing.md
          badgesAsync.when(
            data: (badges) {
              final unlockedRanks = badges.map((b) => b.rank).toSet();
              return _BadgeGrid(unlockedRanks: unlockedRanks);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(l10n.errorLoadingBadges(error.toString())),
          ),
          const SizedBox(height: 24), // spacing.xl
          SectionHeader(title: l10n.avatarCollectionTitle),
          const SizedBox(height: 12), // spacing.md
          cosmeticsAsync.when(
            data: (cosmetics) => _AvatarGrid(
              unlockedMilestones: cosmetics.map((c) => c.levelMilestone).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(l10n.errorLoadingAvatars(error.toString())),
          ),
        ],
      ),
    );
  }

  Future<void> _openRenameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);
    final newName = await showAppDialog<String>(
      context,
      title: l10n.editNameDialogTitle,
      content: AppTextField(
        controller: controller,
        autofocus: true,
        labelText: l10n.fieldNameLabel,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        AppButton.ghost(
          label: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton.primary(
          label: l10n.saveButton,
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
        ),
      ],
    );

    if (newName == null || newName.isEmpty) return;
    await ref.read(gamificationRepositoryProvider).updateName(newName);
  }

  Future<void> _openAvatarPicker(
    BuildContext context,
    WidgetRef ref, {
    required String currentAvatarId,
    required List<int> unlockedMilestones,
  }) async {
    final options = ['default', ...unlockedMilestones.map(_avatarIdForMilestone)];

    final selected = await showAppSheet<String>(
      context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Wrap(
          spacing: 12, // spacing.md
          runSpacing: 12, // spacing.md
          children: [
            for (final avatarId in options)
              _AvatarOption(
                avatarId: avatarId,
                selected: avatarId == currentAvatarId,
                onTap: () => Navigator.of(context).pop(avatarId),
              ),
          ],
        ),
      ),
    );

    if (selected == null) return;
    await ref.read(gamificationRepositoryProvider).updateAvatar(selected);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.avatarId,
    required this.name,
    required this.level,
    this.onEditName,
  });

  final String avatarId;
  final String name;
  final int level;
  final VoidCallback? onEditName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(24), // rounded.xl
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              _avatarIconFor(avatarId),
              size: 52,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16), // spacing.lg
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  style: theme.textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.edit_rounded, size: 18, color: colors.primary),
                tooltip: l10n.editNameTooltip,
                onPressed: onEditName,
              ),
            ],
          ),
          const SizedBox(height: 4), // spacing.xs
          Text(
            l10n.levelLabel(level),
            style: theme.textTheme.labelLarge?.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _GamificationSummary extends StatelessWidget {
  const _GamificationSummary({required this.profile, required this.streak});

  final UserProfileData? profile;
  final StreakStateData? streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final theme = Theme.of(context);

    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final needed = 100 * level;
    final streakDays = streak?.currentStreak ?? 0;
    final rankLabel = streakRankForDays(streakDays).label(context);

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.levelLabel(level),
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                  AppChip(
                    label: rankLabel,
                    backgroundColor: colors.honeyContainer,
                    foregroundColor: colors.warningStrong,
                  ),
                ],
              ),
              const SizedBox(height: 12), // spacing.md
              ProgressBar(
                value: needed == 0 ? 0 : (xp / needed).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 8), // spacing.sm
              Text(
                l10n.xpProgress(xp, needed),
                style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // spacing.md
        StatTile(
          label: l10n.widgetStreakActiveLabel,
          value: '$streakDays ${l10n.widgetStreakDaysSuffix}',
          icon: Icons.local_fire_department_rounded,
        ),
      ],
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.unlockedRanks});

  final Set<StreakRank> unlockedRanks;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 8, // spacing.sm
      runSpacing: 8, // spacing.sm
      children: [
        for (final rank in StreakRank.values)
          _ShineOnNew<StreakRank>(
            key: ValueKey(rank),
            unlocked: unlockedRanks.contains(rank)
                ? <StreakRank>{rank}
                : const <StreakRank>{},
            builder: (shining) => _CollectionChip(
              isUnlocked: unlockedRanks.contains(rank),
              icon: Icons.military_tech_rounded,
              label: rank.label(context),
              unlockedBackground: colors.honeyContainer,
              unlockedForeground: colors.warningStrong,
              shine: shining,
            ),
          ),
      ],
    );
  }
}

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({required this.unlockedMilestones});

  final List<int> unlockedMilestones;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sorted = [...unlockedMilestones]..sort();
    final lastUnlocked = sorted.isEmpty ? 0 : sorted.last;
    final nextLocked = [lastUnlocked + 10, lastUnlocked + 20]
        .where((m) => m <= 100)
        .toList();

    return Wrap(
      spacing: 8, // spacing.sm
      runSpacing: 8, // spacing.sm
      children: [
        for (final milestone in sorted)
          _ShineOnNew<int>(
            key: ValueKey(milestone),
            unlocked: <int>{milestone},
            builder: (shining) => _CollectionChip(
              isUnlocked: true,
              icon: _avatarIconFor(_avatarIdForMilestone(milestone)),
              label: 'Lv $milestone',
              unlockedBackground: colors.primaryContainer,
              unlockedForeground: colors.primary,
              shine: shining,
            ),
          ),
        for (final milestone in nextLocked)
          _CollectionChip(
            key: ValueKey(milestone),
            isUnlocked: false,
            icon: Icons.person_rounded,
            label: 'Lv $milestone',
            unlockedBackground: colors.primaryContainer,
            unlockedForeground: colors.primary,
          ),
      ],
    );
  }
}

/// Memainkan shine HANYA untuk elemen yang **baru** masuk ke [unlocked].
///
/// Kontrak:
/// * Build pertama (`_previous == null`) tidak menyala — membuka layar tidak
///   boleh menyalakan seluruh koleksi.
/// * Reduced motion → tidak pernah diisi, jadi tidak ada ticker sama sekali.
/// * Shine adalah event sesaat: `_shining` dikosongkan lewat [Timer] setelah
///   sapuan selesai (`AppMotion.slow` + jeda kecil), timer dibatalkan saat
///   dispose supaya tidak ada `setState` setelah unmount.
class _ShineOnNew<T> extends StatefulWidget {
  const _ShineOnNew({
    super.key,
    required this.unlocked,
    required this.builder,
  });

  /// Himpunan yang relevan untuk widget ini (biasanya satu elemen).
  final Set<T> unlocked;
  final Widget Function(bool shining) builder;

  @override
  State<_ShineOnNew<T>> createState() => _ShineOnNewState<T>();
}

class _ShineOnNewState<T> extends State<_ShineOnNew<T>> {
  Set<T>? _previous;
  final Set<T> _shining = <T>{};
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncUnlocked();
  }

  @override
  void didUpdateWidget(covariant _ShineOnNew<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncUnlocked();
  }

  void _syncUnlocked() {
    final previous = _previous;
    _previous = <T>{...widget.unlocked};
    if (previous == null) return; // build pertama: jangan shine apa pun
    if (context.reduceMotion) return;

    final freshlyUnlocked = widget.unlocked.difference(previous);
    if (freshlyUnlocked.isEmpty) return;

    _shining.addAll(freshlyUnlocked);
    _timer?.cancel();
    _timer = Timer(AppMotion.slow + const Duration(milliseconds: 80), () {
      if (!mounted) return;
      setState(_shining.clear);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_shining.isNotEmpty);
}

/// Chip koleksi (badge/avatar) bergaya `AppChip` + ikon leading. State
/// lock/unlock disinyalkan lewat ikon (gembok vs ikon item) — bukan warna saja.
class _CollectionChip extends StatelessWidget {
  const _CollectionChip({
    super.key,
    required this.isUnlocked,
    required this.icon,
    required this.label,
    required this.unlockedBackground,
    required this.unlockedForeground,
    this.shine = false,
  });

  final bool isUnlocked;
  final IconData icon;
  final String label;
  final Color unlockedBackground;
  final Color unlockedForeground;

  /// `true` hanya sesaat setelah item ini baru unlock.
  final bool shine;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    final background = isUnlocked ? unlockedBackground : colors.surfaceAlt;
    final foreground = isUnlocked ? unlockedForeground : colors.inkMuted;
    final leadingIcon = isUnlocked ? icon : Icons.lock_outline_rounded;

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999), // rounded.pill
        border: isUnlocked ? null : Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: foreground),
          ),
        ],
      ),
    );

    if (!shine || !isUnlocked) return chip;
    return ShineSweep(autoPlay: true, child: chip);
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.avatarId,
    required this.selected,
    required this.onTap,
  });

  final String avatarId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14), // rounded.md
      child: Container(
        width: 56, // tap target >= 48
        height: 56,
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(14), // rounded.md
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(_avatarIconFor(avatarId), size: 30, color: colors.primary),
            ),
            if (selected)
              Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: colors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}