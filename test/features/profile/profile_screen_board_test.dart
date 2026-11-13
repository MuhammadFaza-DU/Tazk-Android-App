import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/animated_xp_progress.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/profile/profile_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Uji fidelity board `design-export/06 Profil.png` untuk [ProfileScreen].
///
/// Board (780×1366 px, dibagi 2 → frame 390dp) menunjukkan:
/// - kartu profil `surface` berbingkai: maskot `otter-portrait` dalam
///   lingkaran 84dp, nama Fredoka 22 `ink`, lalu SATU baris `primary` berisi
///   `Level {n}` + XP bar (`honey` di atas track `primary-soft`),
/// - tiga stat tile sejajar: streak, tugas selesai, badge,
/// - "Koleksi Badge" + "3 dari 6" berisi 6 kartu kotak (ikon di atas, label di
///   bawah; terkunci = gembok + `surface-alt`),
/// - "Kosmetik" + "2 terbuka" berisi 4 kartu kotak (`Lv {n}`).
///
/// Board TIDAK punya baris "Bergabung {n} bulan lalu" di implementasi ini:
/// tabel `UserProfile` tidak menyimpan tanggal bergabung (lihat laporan).

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Future<void> _insertProfile(
  AppDatabase db, {
  String name = 'Faza',
  int level = 12,
  int xp = 640,
}) async {
  await db.into(db.userProfile).insert(
        UserProfileCompanion(
          name: Value(name),
          level: Value(level),
          xp: Value(xp),
        ),
      );
}

Future<void> _insertStreak(AppDatabase db, {required int currentStreak}) async {
  await db.into(db.streakState).insert(
        StreakStateCompanion(currentStreak: Value(currentStreak)),
      );
}

Future<void> _unlockBadges(AppDatabase db, List<StreakRank> ranks) async {
  for (final rank in ranks) {
    await db.into(db.badgeUnlocks).insert(
          BadgeUnlocksCompanion.insert(rank: rank),
        );
  }
}

Future<void> _unlockCosmetics(AppDatabase db, List<int> milestones) async {
  for (final milestone in milestones) {
    await db.into(db.cosmeticUnlocks).insert(
          CosmeticUnlocksCompanion.insert(levelMilestone: milestone),
        );
  }
}

Future<void> _insertTask(
  AppDatabase db, {
  required String title,
  bool isCompleted = false,
}) async {
  await db.into(db.tasks).insert(
        TasksCompanion.insert(
          title: title,
          date: _today(),
          priority: TaskPriority.medium,
          isCompleted: Value(isCompleted),
        ),
      );
}

/// Pump [ProfileScreen] dengan DB memori + locale `id` (copy board).
Future<void> _pumpScreen(WidgetTester tester, AppDatabase db) async {
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
  // Frame pertama membangun layar; pump berikutnya membiarkan stream Drift
  // selesai dan animasi XP bar (220ms) tenang.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Lepas tree supaya stream Drift + timer `currentDateProvider` berhenti
/// sebelum pemeriksaan pending-timer milik binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('ProfileScreen — struktur board 06 Profil', () {
    testWidgets('kartu profil: maskot ClipOval + satu baris Level + XP bar, '
        'tanpa "Level" kedua', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(db);
      await _insertStreak(db, currentStreak: 15);

      await _pumpScreen(tester, db);

      final card = find.byKey(profileCardKey);
      expect(card, findsOneWidget);

      // Maskot di dalam lingkaran (ClipOval), bukan kotak/ikon.
      expect(
        find.descendant(of: card, matching: find.byType(ClipOval)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.byType(Image)),
        findsOneWidget,
      );
      final mascot = tester.getSize(find.byKey(profileMascotKey));
      expect(mascot.width, 84);
      expect(mascot.height, 84);

      // Nama.
      expect(find.descendant(of: card, matching: find.text('Faza')),
          findsOneWidget);

      // "Level" HANYA sekali di seluruh layar.
      expect(find.textContaining('Level'), findsOneWidget);
      expect(find.text('Level 12'), findsOneWidget);

      // Baris level = pill `primary` berisi XP bar.
      final pill = find.byKey(profileLevelPillKey);
      expect(find.descendant(of: card, matching: pill), findsOneWidget);
      expect(
        find.descendant(of: pill, matching: find.byType(AnimatedXpProgress)),
        findsOneWidget,
      );

      await _disposeScreen(tester);
    });

    testWidgets('tiga stat tile: streak, tugas selesai, badge', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(db);
      await _insertStreak(db, currentStreak: 15);
      await _insertTask(db, title: 'Sapu kamar', isCompleted: true);
      await _insertTask(db, title: 'Cuci piring', isCompleted: true);
      await _insertTask(db, title: 'Belajar', isCompleted: false);
      await _unlockBadges(db, [
        StreakRank.perintis,
        StreakRank.petarung,
        StreakRank.penakluk,
      ]);

      await _pumpScreen(tester, db);

      final row = find.byKey(profileStatRowKey);
      expect(row, findsOneWidget);
      expect(
        find.descendant(of: row, matching: find.byType(AppCard)),
        findsNWidgets(3),
      );

      // Angka besar.
      expect(find.descendant(of: row, matching: find.text('15')),
          findsOneWidget);
      expect(find.descendant(of: row, matching: find.text('2')),
          findsOneWidget);
      expect(find.descendant(of: row, matching: find.text('3')),
          findsOneWidget);

      // Label kecil.
      expect(find.text('hari streak'), findsOneWidget);
      expect(find.text('tugas selesai'), findsOneWidget);
      expect(find.text('badge'), findsOneWidget);

      // Ikon: api (streak), centang (tugas), medali (badge). Dicakup ke baris
      // statistik saja: strip riwayat di bawahnya juga memakai `check_rounded`
      // per hari aktif, jadi pencarian global akan jadi rapuh.
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      final statRow = find.byKey(profileStatRowKey);
      expect(
        find.descendant(of: statRow, matching: find.byIcon(Icons.check_rounded)),
        findsOneWidget,
      );

      await _disposeScreen(tester);
    });

    testWidgets('koleksi badge: 6 kartu kotak + gembok untuk yang terkunci, '
        'label "3 dari 6"', (tester) async {
      // Badge 3 kolom (tile lebih tinggi) mendorong bagian Kosmetik melewati
      // viewport default 600dp — perlebar supaya seluruh konten ikut terbangun.
      tester.view.physicalSize = const Size(800 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(db);
      await _unlockBadges(db, [
        StreakRank.perintis,
        StreakRank.petarung,
        StreakRank.penakluk,
      ]);
      await _unlockCosmetics(db, [10, 20]);

      await _pumpScreen(tester, db);

      expect(find.text('Koleksi Badge'), findsOneWidget);
      expect(find.text('3 dari 6'), findsOneWidget);
      expect(find.text('Kosmetik'), findsOneWidget);
      expect(find.text('2 terbuka'), findsOneWidget);

      for (final rank in StreakRank.values) {
        expect(find.byKey(profileBadgeTileKey(rank)), findsOneWidget);
      }

      // Tiga badge terbuka (medali) + tiga terkunci (gembok).
      expect(find.byIcon(Icons.military_tech_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(5));

      await _disposeScreen(tester);
    });

    testWidgets('kosmetik: kartu lebih lebar dengan "Lv {n}", dua berikutnya '
        'masih terkunci', (tester) async {
      // Badge 3 kolom (tile lebih tinggi) mendorong bagian Kosmetik melewati
      // viewport default 600dp — perlebar supaya seluruh konten ikut terbangun.
      tester.view.physicalSize = const Size(800 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(db);
      await _unlockCosmetics(db, [10, 20]);

      await _pumpScreen(tester, db);

      for (final milestone in [10, 20, 30, 40]) {
        expect(find.byKey(profileCosmeticTileKey(milestone)), findsOneWidget);
        expect(find.text('Lv $milestone'), findsOneWidget);
      }
      // Ikon palet hanya untuk yang terbuka.
      expect(find.byIcon(Icons.palette_rounded), findsNWidgets(2));

      await _disposeScreen(tester);
    });

    testWidgets('geometri board pada layar 390dp: gutter 20, kartu 350, '
        'kartu kotak 3 kolom (badge) dan 4 kolom (kosmetik)', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(db);
      await _unlockCosmetics(db, [10, 20]);

      await _pumpScreen(tester, db);

      final card = tester.getRect(find.byKey(profileCardKey));
      expect(card.left, 20); // gutter
      expect(card.width, 390 - 40);

      final statRow = tester.getRect(find.byKey(profileStatRowKey));
      expect(statRow.left, 20);
      expect(statRow.width, 390 - 40);
      expect(statRow.top - card.bottom, 16); // jarak antar blok

      // 3 kolom badge: (350 - 2*8) / 3 = 111.33. Lebar longgar supaya label
      // Indonesia dua kata ("Sang Master") muat satu baris dan sejajar.
      final grid = tester.getRect(find.byKey(profileBadgeGridKey));
      expect(grid.left, 20);
      expect(grid.width, 350);

      final badgeTile = tester.getSize(
        find.byKey(profileBadgeTileKey(StreakRank.perintis)),
      );
      expect(badgeTile.width, closeTo(111.33, 0.05));

      // 4 kolom kosmetik: (350 - 3*8) / 4 = 81.5.
      final cosmeticTile = tester.getSize(
        find.byKey(profileCosmeticTileKey(10)),
      );
      expect(cosmeticTile.width, closeTo(81.5, 0.05));

      await _disposeScreen(tester);
    });

    testWidgets('tinggi tile badge seragam per baris (3 kolom, 2 baris)', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(db);
      await _unlockBadges(db, StreakRank.values);

      await _pumpScreen(tester, db);

      // Baris pertama: Perintis, Petarung, Penakluk.
      final rowOne = [
        tester.getSize(find.byKey(profileBadgeTileKey(StreakRank.perintis))),
        tester.getSize(find.byKey(profileBadgeTileKey(StreakRank.petarung))),
        tester.getSize(find.byKey(profileBadgeTileKey(StreakRank.penakluk))),
      ];
      expect(rowOne[0].height, rowOne[1].height);
      expect(rowOne[1].height, rowOne[2].height);

      // Baris kedua: Sang Ahli, Sang Master, Legenda.
      final rowTwo = [
        tester.getSize(find.byKey(profileBadgeTileKey(StreakRank.sangAhli))),
        tester.getSize(find.byKey(profileBadgeTileKey(StreakRank.sangMaster))),
        tester.getSize(find.byKey(profileBadgeTileKey(StreakRank.legenda))),
      ];
      expect(rowTwo[0].height, rowTwo[1].height);
      expect(rowTwo[1].height, rowTwo[2].height);

      await _disposeScreen(tester);
    });

    testWidgets('label "Sang Master" utuh, tidak melebihi area label 2 baris', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(db);
      await _unlockBadges(db, StreakRank.values);

      await _pumpScreen(tester, db);

      final sangMaster = find.text('Sang Master');
      expect(sangMaster, findsOneWidget);

      // Area label = 2 baris bodySmall (12/1.4) mengikuti textScaler.
      final context = tester.element(sangMaster);
      final scaler = MediaQuery.textScalerOf(context);
      final labelAreaHeight = scaler.scale(12) * 1.4 * 2;

      final textSize = tester.getSize(sangMaster);
      expect(textSize.height, lessThanOrEqualTo(labelAreaHeight));

      await _disposeScreen(tester);
    });

    testWidgets('data ekstrem tidak overflow: layar 320dp, nama panjang, '
        'level 100, teks diperbesar', (tester) async {
      // Lebar tetap 320 (fokus uji overflow sempit); tinggi diperlebar supaya
      // seluruh konten (sampai grid kosmetik) ikut terbangun — pola sama dengan
      // test "kosmetik" di file ini.
      tester.view.physicalSize = const Size(320 * 3, 2000 * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.reset);
      addTearDown(
        tester.view.platformDispatcher.clearTextScaleFactorTestValue,
      );

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await _insertProfile(
        db,
        name: 'Muhammad Faza Abdillah Ramadhan Saputra',
        level: 100,
        xp: 10000,
      );
      await _insertStreak(db, currentStreak: 999);
      await _unlockBadges(db, StreakRank.values);

      await _pumpScreen(tester, db);

      expect(tester.takeException(), isNull);
      expect(find.text('Level 100'), findsOneWidget);
      expect(find.text('6 dari 6'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(2));

      await _disposeScreen(tester);
    });
  });
}
