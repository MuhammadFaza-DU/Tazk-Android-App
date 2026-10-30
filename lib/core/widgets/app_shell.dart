import 'package:flutter/material.dart';

import '../../features/calendar/calendar_screen.dart';
import '../../features/habits/habits_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/about_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'app_page_route.dart';
import 'app_sheet.dart';
import 'list_row.dart';

/// Root shell v2 — floating pill tab bar (Home · Tasks · Habits · Kalender ·
/// Lainnya) plus a "Lainnya" bottom sheet. No hamburger / drawer
/// (DESIGN.md `Navigation`, boards `01 Home` / `15 Navigation Map`).
///
/// The four tab screens keep their own in-screen header (via [AppScaffold]);
/// this shell only owns the tab bar, so there is no global AppBar here.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Tinggi pill (`tab-bar.height`), measured on the board's 62dp bar.
  static const double tabBarHeight = 62;

  /// Jarak pill ke tepi layar kiri/kanan/bawah di board `01 Home`.
  /// Bawah ditambah `MediaQuery.paddingOf(context).bottom` (safe area).
  static const double tabBarInset = 16;

  /// `rounded.pill` — bar dan indikator item aktif sama-sama stadium.
  static const double tabBarRadius = 999;

  /// Padding dalam pill supaya item tidak menempel ke tepi kiri/kanan.
  static const double tabBarPadding = 8;

  /// Satu item bar: selalu 4 tab layar + aksi "Lainnya" yang membuka sheet.
  static const int tabCount = 4;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onSelect(int index) => setState(() => _selectedIndex = index);

  void _openMoreSheet() {
    showAppSheet<void>(context, child: const _MoreSheet());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // IndexedStack (bukan rebuild per tab): tiap tab menjaga state scroll,
      // filter, dan isian form saat berpindah.
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
          TasksScreen(),
          HabitsScreen(),
          CalendarScreen(),
        ],
      ),
      bottomNavigationBar: PillTabBar(
        selectedIndex: _selectedIndex,
        onSelect: _onSelect,
        onMore: _openMoreSheet,
        destinations: [
          PillTabDestination(icon: Icons.home_outlined, label: l10n.navHome),
          PillTabDestination(
            icon: Icons.checklist_rounded,
            label: l10n.navTasks,
          ),
          PillTabDestination(
            icon: Icons.autorenew_rounded,
            label: l10n.navHabits,
          ),
          PillTabDestination(
            icon: Icons.calendar_month_outlined,
            label: l10n.navCalendar,
          ),
        ],
        moreLabel: l10n.navMore,
      ),
    );
  }
}

/// Satu tujuan tab di dalam pill.
class PillTabDestination {
  const PillTabDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Tab bar v2: kontainer mengambang (bukan `NavigationBar` M3 yang selebar
/// layar) supaya latar canvas tetap terlihat di kiri/kanan/bawah seperti board.
///
/// Board `01 Home`: bg `surface`, border 1px `border`, radius `pill`, tinggi 62,
/// padding horizontal 8, margin 16 (+ safe area) di semua sisi yang mengambang.
class PillTabBar extends StatelessWidget {
  const PillTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.onMore,
    required this.destinations,
    required this.moreLabel,
  }) : assert(
          destinations.length == AppShell.tabCount,
          'Tab bar v2 punya tepat ${AppShell.tabCount} layar tab',
        );

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onMore;
  final List<PillTabDestination> destinations;
  final String moreLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Safe area ditambah manual (bukan SafeArea) supaya jarak ke gesture bar
    // tetap 16dp di atas inset, bukan tertimpa inset saja.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      key: shellTabBarInsetKey,
      padding: EdgeInsets.only(
        left: AppShell.tabBarInset,
        right: AppShell.tabBarInset,
        bottom: AppShell.tabBarInset + bottomInset,
      ),
      child: Container(
        key: shellTabBarKey,
        height: AppShell.tabBarHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppShell.tabBarPadding,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppShell.tabBarRadius),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            for (var i = 0; i < destinations.length; i++)
              _PillTabItem(
                key: shellTabItemKey(i),
                icon: destinations[i].icon,
                label: destinations[i].label,
                selected: i == selectedIndex,
                onTap: () => onSelect(i),
              ),
            _PillTabItem(
              key: shellTabMoreKey,
              icon: Icons.more_horiz_rounded,
              label: moreLabel,
              // "Lainnya" adalah aksi, bukan tab: tidak pernah tampil aktif.
              selected: false,
              onTap: onMore,
            ),
          ],
        ),
      ),
    );
  }
}

/// Key bar untuk uji fidelity board (radius/margin/tinggi).
const Key shellTabBarKey = ValueKey('shell-tab-bar');
const Key shellTabBarInsetKey = ValueKey('shell-tab-bar-inset');

/// Key item tab ke-[index] (0..3).
Key shellTabItemKey(int index) => ValueKey('shell-tab-item-$index');

/// Key item aksi "Lainnya".
const Key shellTabMoreKey = ValueKey('shell-tab-more');

/// Satu item pill: indikator aktif `primaryContainer` berbentuk stadium,
/// ikon+label `primary` saat aktif dan `inkMuted` saat tidak.
///
/// Tap target minimal 48dp: tinggi pill 62 − border 1×2 − padding vertikal 6×2.
class _PillTabItem extends StatelessWidget {
  const _PillTabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final ink = selected ? colors.primary : colors.inkMuted;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          onTap: onTap,
          // Label dibaca dari `label` di atas, bukan dari teks di dalamnya.
          excludeSemantics: true,
          child: AnimatedContainer(
            // `fast` 150ms, jadi nol saat reduced-motion (state tetap berubah).
            duration: context.motion(AppMotion.fast),
            curve: AppMotion.easeStandard,
            decoration: BoxDecoration(
              color: selected ? colors.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(AppShell.tabBarRadius),
            ),
            child: Material(
              // Transparan: agar ripple mengecat di atas indikator, bukan
              // tertutup warna `primaryContainer`.
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const StadiumBorder(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 22, color: ink),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ink,
                        // Bobot ikut menandai item aktif, bukan warna saja.
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Items of the "Lainnya" sheet (DESIGN `sheet`): Profil, Pengaturan, Tentang.
///
/// Statistik (T5) is deliberately absent — no screen exists yet, and a tab or
/// row must never point at a screen that does not exist (board `15`).
class _MoreSheet extends StatelessWidget {
  const _MoreSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(l10n.navMore, style: theme.textTheme.titleLarge),
          ),
          ListRow(
            showDivider: false,
            leading: _SheetIcon(icon: Icons.person_outline_rounded),
            title: l10n.navProfile,
            trailing: Icon(Icons.chevron_right_rounded, color: colors.inkMuted),
            onTap: () => _push(context, const ProfileScreen()),
          ),
          ListRow(
            showDivider: false,
            leading: _SheetIcon(icon: Icons.settings_outlined),
            title: l10n.navSettings,
            trailing: Icon(Icons.chevron_right_rounded, color: colors.inkMuted),
            onTap: () => _push(context, const SettingsScreen()),
          ),
          ListRow(
            showDivider: false,
            leading: _SheetIcon(icon: Icons.info_outline_rounded),
            title: l10n.navAbout,
            trailing: Icon(Icons.chevron_right_rounded, color: colors.inkMuted),
            onTap: () => _push(context, const AboutScreen()),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Closes the sheet first, then pushes the screen. The navigator is captured
  /// before `pop` so we never touch a deactivated sheet context afterwards.
  void _push(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(AppPageRoute(builder: (_) => screen));
  }
}

/// Kotak ikon baris sheet (board `01b`): 44dp, `rounded.md`, `surface-alt`.
class _SheetIcon extends StatelessWidget {
  const _SheetIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(14), // rounded.md
      ),
      child: Icon(icon, size: 22, color: colors.ink),
    );
  }
}