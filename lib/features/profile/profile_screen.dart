import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/animated_xp_progress.dart';
import '../../core/widgets/shine_sweep.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/gamification_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';

/// Key kartu profil (maskot + nama + baris level).
const Key profileCardKey = ValueKey('profile-card');

/// Key lingkaran maskot/avatar di dalam kartu profil.
const Key profileMascotKey = ValueKey('profile-mascot');

/// Key baris `Level {n}` + XP bar.
const Key profileLevelPillKey = ValueKey('profile-level-pill');

/// Key baris tiga stat tile.
const Key profileStatRowKey = ValueKey('profile-stat-row');

/// Key grid koleksi badge.
const Key profileBadgeGridKey = ValueKey('profile-badge-grid');

/// Key grid koleksi kosmetik.
const Key profileCosmeticsGridKey = ValueKey('profile-cosmetics-grid');

/// Key satu kartu badge.
Key profileBadgeTileKey(StreakRank rank) =>
    ValueKey('profile-badge-${rank.name}');

/// Key satu kartu kosmetik.
Key profileCosmeticTileKey(int milestone) =>
    ValueKey('profile-cosmetic-$milestone');

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

  /// Jarak antar blok layar — `spacing.lg`.
  static const double _blockGap = 16;

  /// Jarak judul section ke koleksinya — `spacing.sm`.
  static const double _headingGap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final streak = ref.watch(streakStateProvider).valueOrNull;
    final badgesAsync = ref.watch(badgesProvider);
    final cosmeticsAsync = ref.watch(cosmeticsProvider);
    final todayTasks = ref.watch(todayTasksProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;

    final avatarId = profile?.avatarId ?? 'default';
    final name = (profile == null || profile.name.trim().isEmpty)
        ? l10n.noNamePlaceholder
        : profile.name;

    // Hitungan hanya ditampilkan setelah stream benar-benar punya nilai, supaya
    // judul section tidak sesaat mengklaim "0 dari 6".
    final unlockedBadges = badgesAsync.valueOrNull;
    final unlockedCosmetics = cosmeticsAsync.valueOrNull;
    final completedToday =
        todayTasks?.where((task) => task.isCompleted).length ?? 0;

    return AppScaffold(
      title: l10n.profileScreenTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_rounded),
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
        padding: const EdgeInsets.fromLTRB(
          AppScaffold.gutter,
          AppScaffold.gutter,
          AppScaffold.gutter,
          24, // spacing.xl
        ),
        children: [
          _ProfileCard(
            avatarId: avatarId,
            name: name,
            level: profile?.level ?? 1,
            xp: profile?.xp ?? 0,
            onEditName: profile == null
                ? null
                : () => _openRenameDialog(context, ref, profile.name),
          ),
          const SizedBox(height: _blockGap),
          Row(
            key: profileStatRowKey,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  value: '${streak?.currentStreak ?? 0}',
                  label: l10n.profileStreakDaysLabel,
                ),
              ),
              const SizedBox(width: 8), // spacing.sm
              Expanded(
                child: _StatTile(
                  icon: Icons.check_rounded,
                  value: '$completedToday',
                  label: l10n.profileTasksDoneTodayLabel,
                ),
              ),
              const SizedBox(width: 8), // spacing.sm
              Expanded(
                child: _StatTile(
                  icon: Icons.military_tech_rounded,
                  value: '${unlockedBadges?.length ?? 0}',
                  label: l10n.profileBadgesLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: _blockGap),
          _SectionHeading(
            title: l10n.badgeCollectionTitle,
            trailing: unlockedBadges == null
                ? null
                : l10n.badgesUnlockedCount(
                    unlockedBadges.length,
                    StreakRank.values.length,
                  ),
          ),
          const SizedBox(height: _headingGap),
          badgesAsync.when(
            data: (badges) => _BadgeGrid(
              unlockedRanks: badges.map((b) => b.rank).toSet(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(l10n.errorLoadingBadges(error.toString())),
          ),
          const SizedBox(height: _blockGap),
          _SectionHeading(
            title: l10n.avatarCollectionTitle,
            trailing: unlockedCosmetics == null
                ? null
                : l10n.cosmeticsUnlockedCount(unlockedCosmetics.length),
          ),
          const SizedBox(height: _headingGap),
          cosmeticsAsync.when(
            data: (cosmetics) => _CosmeticGrid(
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

/// Kartu profil board `06 Profil`: maskot dalam lingkaran, nama Fredoka,
/// lalu satu baris `primary` berisi `Level {n}` + XP bar.
///
/// Board mengukur radius 22dp dan padding 20dp. Token terdekat untuk radius
/// adalah `rounded.xl` (24) — peran yang sama dengan "main progress card"
/// (`DESIGN.md` Shapes). Padding memakai ukuran board karena isi kartu ini
/// (bar level) memang lebih lapang daripada `AppCard` biasa.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.avatarId,
    required this.name,
    required this.level,
    required this.xp,
    this.onEditName,
  });

  final String avatarId;
  final String name;
  final int level;
  final int xp;
  final VoidCallback? onEditName;

  /// Diameter lingkaran maskot — board mengukur 84dp.
  static const double mascotDiameter = 84;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final needed = 100 * level;
    final progress = needed == 0 ? 0.0 : (xp / needed).clamp(0.0, 1.0);

    return Container(
      key: profileCardKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24), // rounded.xl
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        // Tombol ubah nama digantung di sudut supaya tidak menambah tinggi
        // baris nama (board tidak punya affordance ini, tapi aksi ganti nama
        // tetap harus bisa dijangkau).
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _AvatarCircle(avatarId: avatarId)),
              const SizedBox(height: 12), // spacing.md
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colors.ink,
                ),
              ),
              const SizedBox(height: 12), // spacing.md
              _LevelPill(level: level, progress: progress),
            ],
          ),
          Positioned(
            top: -8,
            right: -8,
            child: IconButton(
              icon: Icon(Icons.edit_rounded, size: 18, color: colors.primary),
              tooltip: AppLocalizations.of(context)!.editNameTooltip,
              onPressed: onEditName,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lingkaran maskot `otter-portrait` (`ClipOval`, jadi PNG berlatar krem tidak
/// menempel sebagai persegi). Avatar hasil unlock tetap memakai ikonnya sendiri
/// supaya pilihan avatar tidak hilang.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.avatarId});

  final String avatarId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMascot = avatarId == 'default';

    return Container(
      key: profileMascotKey,
      width: _ProfileCard.mascotDiameter,
      height: _ProfileCard.mascotDiameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isMascot ? colors.surfaceAlt : colors.primaryContainer,
      ),
      child: ClipOval(
        child: isMascot
            ? Image.asset(
                'assets/mascot/otter-portrait.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.pets_rounded,
                  size: 36,
                  color: colors.inkMuted,
                ),
              )
            : Icon(_avatarIconFor(avatarId), size: 40, color: colors.primary),
      ),
    );
  }
}

/// Satu-satunya tempat "Level" muncul di layar: baris `primary` (komponen
/// `progress-card` di `DESIGN.md`) dengan XP bar `honey` di atas track
/// `primary-soft`, tinggi 8.
class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level, required this.progress});

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return Container(
      key: profileLevelPillKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.levelLabel(level),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12), // spacing.md
          Expanded(
            child: AnimatedXpProgress(
              value: progress,
              level: level,
              height: 8, // progress-track
              trackColor: colors.primarySoft,
              fillColor: colors.honey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat tile board: ikon `honey` di atas, angka Fredoka `ink`, label
/// `bodySmall` `ink-muted`. Bingkai `border` tanpa bayangan, radius `md`
/// (board mengukur 14 — sama dengan `AppCard`).
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.honey),
          const SizedBox(height: 4), // spacing.xs
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineLarge?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 4), // spacing.xs
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// Judul section + hitungan di kanan (board `06 Profil`: "Koleksi Badge" /
/// "3 dari 6", "Kosmetik" / "2 terbuka").
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final trailing = this.trailing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(color: colors.ink),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12), // spacing.md
          Text(
            trailing,
            style: theme.textTheme.bodySmall?.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );
  }
}

/// Enam badge sejajar (board: 6 kolom). Nama panjang ("Conqueror", "Legend")
/// dibiarkan membungkus maksimal 2 baris alih-alih memotong grid, supaya
/// jumlah kolom tetap sesuai board dan label tetap terbaca.
class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.unlockedRanks});

  final Set<StreakRank> unlockedRanks;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ranks = StreakRank.values;

    return LayoutBuilder(
      key: profileBadgeGridKey,
      builder: (context, constraints) {
        const gap = 8.0; // spacing.sm
        final tileWidth =
            (constraints.maxWidth - gap * (ranks.length - 1)) / ranks.length;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final rank in ranks)
              SizedBox(
                width: tileWidth,
                child: _ShineOnNew<StreakRank>(
                  key: ValueKey(rank),
                  unlocked: unlockedRanks.contains(rank)
                      ? <StreakRank>{rank}
                      : const <StreakRank>{},
                  builder: (shining) => _CollectionTile(
                    key: profileBadgeTileKey(rank),
                    isUnlocked: unlockedRanks.contains(rank),
                    icon: Icons.military_tech_rounded,
                    label: rank.label(context),
                    unlockedBackground: colors.honeyContainer,
                    unlockedIconColor: colors.warningStrong,
                    shine: shining,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Kosmetik (avatar per 10 level): yang sudah terbuka + dua berikutnya yang
/// masih terkunci, 4 kolom seperti board.
class _CosmeticGrid extends StatelessWidget {
  const _CosmeticGrid({required this.unlockedMilestones});

  final List<int> unlockedMilestones;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sorted = [...unlockedMilestones]..sort();
    final lastUnlocked = sorted.isEmpty ? 0 : sorted.last;
    final nextLocked = [lastUnlocked + 10, lastUnlocked + 20]
        .where((m) => m <= 100)
        .toList();
    const columns = 4;

    return LayoutBuilder(
      key: profileCosmeticsGridKey,
      builder: (context, constraints) {
        const gap = 8.0; // spacing.sm
        final tileWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final milestone in sorted)
              SizedBox(
                width: tileWidth,
                child: _ShineOnNew<int>(
                  key: ValueKey(milestone),
                  unlocked: <int>{milestone},
                  builder: (shining) => _CollectionTile(
                    key: profileCosmeticTileKey(milestone),
                    isUnlocked: true,
                    icon: Icons.palette_rounded,
                    label: 'Lv $milestone',
                    unlockedBackground: colors.primaryContainer,
                    unlockedIconColor: colors.primary,
                    shine: shining,
                  ),
                ),
              ),
            for (final milestone in nextLocked)
              SizedBox(
                width: tileWidth,
                child: _CollectionTile(
                  key: profileCosmeticTileKey(milestone),
                  isUnlocked: false,
                  icon: Icons.palette_rounded,
                  label: 'Lv $milestone',
                  unlockedBackground: colors.primaryContainer,
                  unlockedIconColor: colors.primary,
                ),
              ),
          ],
        );
      },
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

/// Kartu koleksi (badge/kosmetik) bergaya kotak radius 12 seperti board:
/// ikon di atas, label di bawah. State lock/unlock disinyalkan lewat **ikon**
/// (gembok vs ikon item) dan warna label, bukan warna saja.
class _CollectionTile extends StatelessWidget {
  const _CollectionTile({
    super.key,
    required this.isUnlocked,
    required this.icon,
    required this.label,
    required this.unlockedBackground,
    required this.unlockedIconColor,
    this.shine = false,
  });

  final bool isUnlocked;
  final IconData icon;
  final String label;
  final Color unlockedBackground;
  final Color unlockedIconColor;

  /// `true` hanya sesaat setelah item ini baru unlock.
  final bool shine;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked ? unlockedBackground : colors.surfaceAlt,
        borderRadius: _radius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlocked ? icon : Icons.lock_outline_rounded,
            size: 16,
            color: isUnlocked ? unlockedIconColor : colors.inkMuted,
          ),
          const SizedBox(height: 4), // spacing.xs
          Text(
            label,
            // Nama seperti "Conqueror"/"Legend" butuh 2 baris di kartu 53dp;
            // memotongnya jadi "Conq…" lebih buruk daripada baris kedua.
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isUnlocked ? colors.ink : colors.inkMuted,
            ),
          ),
        ],
      ),
    );

    if (!shine || !isUnlocked) return tile;
    return ShineSweep(borderRadius: _radius, child: tile);
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
