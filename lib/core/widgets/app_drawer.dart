import 'package:flutter/material.dart';

import '../../features/calendar/calendar_screen.dart';
import '../../features/habits/habits_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/pomodoro/pomodoro_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineMedium),
            ),
            _DrawerItem(
              icon: Icons.home_rounded,
              label: l10n.navHome,
              builder: (_) => const HomeScreen(),
            ),
            _DrawerItem(
              icon: Icons.check_circle_outline_rounded,
              label: l10n.navTasks,
              builder: (_) => const TasksScreen(),
            ),
            _DrawerItem(
              icon: Icons.autorenew_rounded,
              label: l10n.navHabits,
              builder: (_) => const HabitsScreen(),
            ),
            _DrawerItem(
              icon: Icons.calendar_month_rounded,
              label: l10n.navCalendar,
              builder: (_) => const CalendarScreen(),
            ),
            _DrawerItem(
              icon: Icons.timer_outlined,
              label: l10n.navPomodoro,
              builder: (_) => const PomodoroScreen(),
            ),
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              label: l10n.navProfile,
              builder: (_) => const ProfileScreen(),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: l10n.navSettings,
              builder: (_) => const SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: builder));
      },
    );
  }
}
