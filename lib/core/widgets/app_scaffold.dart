import 'package:flutter/material.dart';

import 'app_drawer.dart';

/// Shared shell for all main screens: hamburger + sidebar nav (PRD section 4).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
