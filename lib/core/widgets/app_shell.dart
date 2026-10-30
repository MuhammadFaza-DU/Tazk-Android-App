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
import 'app_page_route.dart';
import 'app_sheet.dart';
import 'list_row.dart';

/// Root shell v2 — tab bar 5 (Home · Tasks · Habits · Kalender · Lainnya) plus
/// a "Lainnya" bottom sheet. No hamburger / drawer (DESIGN.md `Navigation`).
///
/// The four tab screens keep their own in-screen header (via [AppScaffold]);
/// this shell only owns the tab bar, so there is no global AppBar here.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    // The 5th destination ("Lainnya") is an action, not a tab: it opens a
    // sheet and must not move the selection away from the current tab.
    if (index == _moreIndex) {
      _openMoreSheet();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _openMoreSheet() {
    showAppSheet<void>(context, child: const _MoreSheet());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeScreen(),
          TasksScreen(),
          HabitsScreen(),
          CalendarScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 62, // tab-bar.height
          backgroundColor: colors.surface,
          indicatorColor: colors.primaryContainer,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999), // rounded.pill
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.inkMuted,
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.inkMuted,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: l10n.navTasks,
            ),
            NavigationDestination(
              icon: const Icon(Icons.autorenew_rounded),
              label: l10n.navHabits,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_rounded),
              label: l10n.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.grid_view_rounded),
              label: l10n.navMore,
            ),
          ],
        ),
      ),
    );
  }
}

const int _moreIndex = 4;

/// Items of the "Lainnya" sheet (DESIGN `sheet`): Profil, Pengaturan, Tentang.
///
/// Statistik (T5) is deliberately absent — no screen exists yet, and a tab or
/// row must never point at a screen that does not exist.
class _MoreSheet extends StatelessWidget {
  const _MoreSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListRow(
            showDivider: false,
            leading: const Icon(Icons.person_outline_rounded),
            title: l10n.navProfile,
            onTap: () => _push(context, const ProfileScreen()),
          ),
          ListRow(
            showDivider: false,
            leading: const Icon(Icons.settings_outlined),
            title: l10n.navSettings,
            onTap: () => _push(context, const SettingsScreen()),
          ),
          ListRow(
            showDivider: false,
            leading: const Icon(Icons.info_outline_rounded),
            title: l10n.navAbout,
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
