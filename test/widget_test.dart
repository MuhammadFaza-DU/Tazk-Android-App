import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/data/database/database.dart';
import 'package:tazk/main.dart';
import 'package:tazk/providers/database_provider.dart';

void main() {
  testWidgets('TazkApp renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase.forTesting(NativeDatabase.memory()),
          ),
        ],
        child: const TazkApp(),
      ),
    );

    expect(find.text('Tazk'), findsWidgets);

    await tester.pump(const Duration(seconds: 5));

    // Force ProviderScope (and its Drift stream queries) to dispose now,
    // then pump once more so the zero-duration cleanup timer it schedules
    // fires before the test binding's pending-timer invariant check runs.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
