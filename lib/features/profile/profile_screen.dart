import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
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

    return AppScaffold(
      title: 'Profil',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          tooltip: 'Ganti Avatar',
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
                  backgroundColor: AppColors.primaryLight.withAlpha(40),
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
                          ? '(Belum ada nama)'
                          : profile.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      tooltip: 'Edit Nama',
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
          Text('Badge Collection', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          badgesAsync.when(
            data: (badges) {
              final unlockedRanks = badges.map((b) => b.rank).toSet();
              return _BadgeGrid(unlockedRanks: unlockedRanks);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Gagal memuat badge: $error'),
          ),
          const SizedBox(height: 24),
          Text(
            'Avatar Collection — unlock per 10 level',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          cosmeticsAsync.when(
            data: (cosmetics) => _AvatarGrid(
              unlockedMilestones: cosmetics.map((c) => c.levelMilestone).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Gagal memuat avatar: $error'),
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
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Nama'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Simpan'),
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
                        ? AppColors.primaryLight.withAlpha(80)
                        : AppColors.primaryLight.withAlpha(30),
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
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;
    final needed = 100 * level;
    final streakDays = streak?.currentStreak ?? 0;
    final rankLabel = streakDays > 0 ? streakRankForDays(streakDays).label : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level $level', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: needed == 0 ? 0 : (xp / needed).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppColors.terracotta.withAlpha(40),
                valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
              ),
            ),
            const SizedBox(height: 4),
            Text('$xp/$needed XP'),
            const SizedBox(height: 12),
            Text('🔥 Streak $streakDays hari · $rankLabel'),
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
            label: rank.label,
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
    final nextLocked = [lastUnlocked + 10, lastUnlocked + 20];

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

class _CollectionSlot extends StatelessWidget {
  const _CollectionSlot({
    required this.isUnlocked,
    required this.icon,
    required this.label,
  });

  final bool isUnlocked;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: isUnlocked
              ? AppColors.accentLight.withAlpha(60)
              : Theme.of(context).disabledColor.withAlpha(30),
          child: Icon(
            isUnlocked ? icon : Icons.lock_outline_rounded,
            color: isUnlocked ? AppColors.terracotta : Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
