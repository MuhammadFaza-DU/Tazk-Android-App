import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
