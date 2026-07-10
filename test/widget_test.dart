import 'package:drift/native.dart';
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

    await tester.pump(const Duration(seconds: 4));
  });
}
