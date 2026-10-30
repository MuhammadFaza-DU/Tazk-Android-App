import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/dev/component_preview_screen.dart';
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
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...?actions,
          if (kDebugMode) _debugPreviewAction(context), // dev-only (relocated in T3)
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  // dev-only (relocated in T3)
  Widget _debugPreviewAction(BuildContext context) {
    return IconButton(
      tooltip: 'Component preview (debug)',
      icon: const Icon(Icons.widgets_outlined),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ComponentPreviewScreen()),
        );
      },
    );
  }
}
