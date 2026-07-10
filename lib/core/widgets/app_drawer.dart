import 'package:flutter/material.dart';

import '../../features/home/home_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import 'coming_soon_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Tazk', style: Theme.of(context).textTheme.headlineMedium),
            ),
            _DrawerItem(
              icon: Icons.home_rounded,
              label: 'Home',
              builder: (_) => const HomeScreen(),
            ),
            _DrawerItem(
              icon: Icons.check_circle_outline_rounded,
              label: 'Tasks',
              builder: (_) => const TasksScreen(),
            ),
            _DrawerItem(
              icon: Icons.autorenew_rounded,
              label: 'Habits',
              builder: (_) => const ComingSoonScreen(title: 'Habits'),
            ),
            _DrawerItem(
              icon: Icons.calendar_month_rounded,
              label: 'Kalender',
              builder: (_) => const ComingSoonScreen(title: 'Kalender'),
            ),
            _DrawerItem(
              icon: Icons.timer_outlined,
              label: 'Pomodoro',
              builder: (_) => const ComingSoonScreen(title: 'Pomodoro'),
            ),
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              label: 'Profil',
              builder: (_) => const ComingSoonScreen(title: 'Profil'),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Pengaturan',
              builder: (_) => const ComingSoonScreen(title: 'Pengaturan'),
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
