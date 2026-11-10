import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/features/profile/profile_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Status lock/unlock koleksi clearer: tile terkunci/terbuka menampilkan baris
/// status ("Terkunci" / "Terbuka") + label [Semantics] yang menggabungkan label
/// dan status. Diuji lewat [ProfileScreen] karena `_CollectionTile` privat.

Future<void> _insertProfile(AppDatabase db, {int level = 12}) async {
  await db.into(db.userProfile).insert(
        UserProfileCompanion(
          name: const Value('Faza'),
          level: Value(level),
          xp: const Value(640),
        ),
      );
}

Future<void> _unlockCosmetics(AppDatabase db, List<int> milestones) async {
  for (final milestone in milestones) {
    await db.into(db.cosmeticUnlocks).insert(
          CosmeticUnlocksCompanion.insert(levelMilestone: milestone),
        );
  }
}

Future<void> _pumpScreen(WidgetTester tester, AppDatabase db) async {
  // Grid badge 3 kolom (tile kini lebih tinggi karena baris status) mendorong
  // bagian Kosmetik melewati viewport default — perlebar supaya seluruh konten
  // ikut terbangun (pola sama dengan profile_screen_board_test).
  tester.view.physicalSize = const Size(800 * 3, 1400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProfileScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('tile terkunci: "Terkunci" + gembok + label Semantics', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await _insertProfile(db);
    // Hanya Lv 10 terbuka → Lv 20 & 30 masih terkunci.
    await _unlockCosmetics(db, [10]);

    await _pumpScreen(tester, db);

    expect(find.text('Terkunci'), findsWidgets);
    expect(find.byIcon(Icons.lock_outline_rounded), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Lv 20, Terkunci',
      ),
      findsOneWidget,
    );

    await _disposeScreen(tester);
  });

  testWidgets('tile terbuka: "Terbuka" + label + label Semantics', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await _insertProfile(db);
    await _unlockCosmetics(db, [10]);

    await _pumpScreen(tester, db);

    expect(find.text('Terbuka'), findsWidgets);
    expect(find.text('Lv 10'), findsOneWidget);
    expect(find.byIcon(Icons.palette_rounded), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Lv 10, Terbuka',
      ),
      findsOneWidget,
    );

    await _disposeScreen(tester);
  });
}