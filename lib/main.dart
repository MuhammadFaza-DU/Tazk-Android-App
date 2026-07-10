import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TazkApp()));
}

class TazkApp extends StatelessWidget {
  const TazkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tazk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _TazkPlaceholderHome(),
    );
  }
}

class _TazkPlaceholderHome extends StatelessWidget {
  const _TazkPlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tazk')),
      body: Center(
        child: Text('Tazk', style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }
}
