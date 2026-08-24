import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/animated_xp_progress.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.16),
                  child: Icon(
                    _avatarIconFor(profile?.avatarId ?? 'default'),
                    size: 48,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (profile == null || profile.name.trim().isEmpty)
                          ? l10n.noNamePlaceholder
                          : profile.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      tooltip: l10n.editNameTooltip,
                      onPressed: profile == null
                          ? null
                          : () => _openRenameDialog(context, ref, profile.name),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _GamificationSummary(profile: profile, streak: streak),
          const SizedBox(height: 24),
          Text(l10n.badgeCollectionTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          badgesAsync.when(
            data: (badges) {
              final unlockedRanks = badges.map((b) => b.rank).toSet();
              return _BadgeGrid(unlockedRanks: unlockedRanks);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(l10n.errorLoadingBadges(error.toString())),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.avatarCollectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editNameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.fieldNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.saveButton),
          ),
        ],
      ),
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

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final avatarId in options)
                InkWell(
                  onTap: () => Navigator.of(sheetContext).pop(avatarId),
                  borderRadius: BorderRadius.circular(32),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: avatarId == currentAvatarId
                        ? AppColors.primaryLight.withValues(alpha: 0.31)
                        : AppColors.primaryLight.withValues(alpha: 0.12),
                    child: Icon(_avatarIconFor(avatarId), color: AppColors.primaryLight),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (selected == null) return;
    await ref.read(gamificationRepositoryProvider).updateAvatar(selected);
  }
}

class _GamificationSummary extends StatelessWidget {
  const _GamificationSummary({required this.profile, required this.streak});

  final UserProfileData? profile;
  final StreakStateData? streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final needed = 100 * level;
    final streakDays = streak?.currentStreak ?? 0;
    final rankLabel = streakDays > 0 ? streakRankForDays(streakDays).label(context) : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.levelLabel(level), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
      AnimatedXpProgress(value: needed == 0 ? 0 : xp / needed, level: level),
            const SizedBox(height: 4),
            Text(l10n.xpProgress(xp, needed)),
            const SizedBox(height: 12),
            Text(l10n.streakSummary(streakDays, rankLabel)),
          ],
        ),
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.unlockedRanks});

  final Set<StreakRank> unlockedRanks;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final rank in StreakRank.values)
          _CollectionSlot(
            isUnlocked: unlockedRanks.contains(rank),
            icon: Icons.military_tech_rounded,
            label: rank.label(context),
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
    final sorted = [...unlockedMilestones]..sort();
    final lastUnlocked = sorted.isEmpty ? 0 : sorted.last;
    final nextLocked = [lastUnlocked + 10, lastUnlocked + 20]
        .where((m) => m <= 100)
        .toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final milestone in sorted)
          _CollectionSlot(
            isUnlocked: true,
            icon: _avatarIconFor(_avatarIdForMilestone(milestone)),
            label: 'Lv $milestone',
          ),
        for (final milestone in nextLocked)
          _CollectionSlot(isUnlocked: false, icon: Icons.person_rounded, label: 'Lv $milestone'),
      ],
    );
  }
}

class _CollectionSlot extends StatefulWidget {
  const _CollectionSlot({
    required this.isUnlocked,
    required this.icon,
    required this.label,
  });

  final bool isUnlocked;
  final IconData icon;
  final String label;

  @override
  State<_CollectionSlot> createState() => _CollectionSlotState();
}

class _CollectionSlotState extends State<_CollectionSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flip;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _flip = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.5), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _shine = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 1, curve: Curves.easeOut)),
    );
    if (widget.isUnlocked) {
      // Already unlocked on first build — no entrance animation.
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _CollectionSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isUnlocked && widget.isUnlocked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final angle = _flip.value * 3.14159;
            final isFront = _flip.value < 0.5
                ? !widget.isUnlocked
                : widget.isUnlocked;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isFront
                        ? (widget.isUnlocked
                            ? AppColors.accentLight.withValues(alpha: 0.24)
                            : Theme.of(context).disabledColor.withValues(alpha: 0.12))
                        : AppColors.accentLight.withValues(alpha: 0.24),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(_flip.value < 0.5 ? 0 : 3.14159),
                      child: Icon(
                        isFront
                            ? (widget.isUnlocked ? widget.icon : Icons.lock_outline_rounded)
                            : widget.icon,
                        color: isFront
                            ? (widget.isUnlocked
                                ? AppColors.terracotta
                                : Theme.of(context).disabledColor)
                            : AppColors.terracotta,
                      ),
                    ),
                  ),
                  if (_shine.value > -1 && _shine.value < 1 && widget.isUnlocked)
                    Positioned.fill(
                      child: ClipOval(
                        child: Align(
                          alignment: Alignment(_shine.value, 0),
                          child: Container(
                            width: 18,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.55),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                            transform: Matrix4.skewX(-0.25),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(widget.label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
