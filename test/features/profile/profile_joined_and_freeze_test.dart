import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/utils/joined_label.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/features/profile/profile_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/current_date_provider.dart';
import 'package:tazk/providers/database_provider.dart';

/// Perbedaan bulan `joinedLabel` dihitung dari kalender `(tahun, bulan)`, bukan
/// `days ~/ 30`, supaya label tidak melompat pada batas bulan (31 Jan → 1 Feb
/// tetap "1 bulan", bukan "bulan ini").
void main() {
  final l10n = lookupAppLocalizations(const Locale('id'));

  group('joinedLabel', () {
    test('bulan yang sama → "Bergabung bulan ini"', () {
      expect(
        joinedLabel(DateTime(2026, 1, 1), DateTime(2026, 1, 31), l10n),
        l10n.profileJoinedThisMonth,
      );
    });

    test('selisih 1 bulan → profileJoinedMonths(1)', () {
      expect(
        joinedLabel(DateTime(2026, 1, 1), DateTime(2026, 2, 1), l10n),
        l10n.profileJoinedMonths(1),
      );
    });

    test('selisih 13 bulan → profileJoinedMonths(13)', () {
      expect(
        joinedLabel(DateTime(2025, 1, 1), DateTime(2026, 2, 1), l10n),
        l10n.profileJoinedMonths(13),
      );
    });

    test('createdAt di masa depan → "Bergabung bulan ini"', () {
      expect(
        joinedLabel(DateTime(2026, 5, 1), DateTime(2026, 3, 1), l10n),
        l10n.profileJoinedThisMonth,
      );
    });

    test('batas bulan: 31 Jan → 1 Feb tetap 1 bulan (bukan days ~/ 30)', () {
      expect(
        joinedLabel(DateTime(2026, 1, 31), DateTime(2026, 2, 1), l10n),
        l10n.profileJoinedMonths(1),
      );
    });
  });

  group('ProfileScreen — label bergabung & freeze', () {
    Future<void> insertProfile(
      AppDatabase db, {
      DateTime? createdAt,
    }) async {
      await db.into(db.userProfile).insert(
            UserProfileCompanion(
              name: const Value('Faza'),
              createdAt: Value(createdAt ?? DateTime(2026, 1, 1)),
            ),
          );
    }

    Future<void> insertStreak(
      AppDatabase db, {
      int freezeCount = 0,
      int freezeProgressDays = 0,
    }) async {
      await db.into(db.streakState).insert(
            StreakStateCompanion(
              freezeCount: Value(freezeCount),
              freezeProgressDays: Value(freezeProgressDays),
            ),
          );
    }

    Future<void> pumpScreen(
      WidgetTester tester,
      AppDatabase db, {
      required DateTime now,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            currentDateProvider
                .overrideWith(() => _FixedDateNotifier(now)),
          ],
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

    Future<void> disposeScreen(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    }

    testWidgets('kartu profil menampilkan "Bergabung 2 bulan lalu" untuk '
        'createdAt Januari dan now Maret', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await insertProfile(db, createdAt: DateTime(2026, 1, 1));

      await pumpScreen(tester, db, now: DateTime(2026, 3, 1));

      expect(find.text('Bergabung 2 bulan lalu'), findsOneWidget);

      await disposeScreen(tester);
    });

    testWidgets('baris freeze tampil saat freezeCount > 0', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await insertProfile(db, createdAt: DateTime(2026, 1, 1));
      await insertStreak(db, freezeCount: 2, freezeProgressDays: 4);

      await pumpScreen(tester, db, now: DateTime(2026, 3, 1));

      expect(find.text('2 freeze tersedia'), findsOneWidget);
      expect(find.text('4 hari menuju freeze berikutnya'), findsOneWidget);

      await disposeScreen(tester);
    });

    testWidgets('baris freeze disembunyikan saat freezeCount == 0', (
      tester,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await insertProfile(db, createdAt: DateTime(2026, 1, 1));
      await insertStreak(db, freezeCount: 0);

      await pumpScreen(tester, db, now: DateTime(2026, 3, 1));

      expect(find.text('2 freeze tersedia'), findsNothing);
      expect(find.text('0 freeze tersedia'), findsNothing);
      expect(find.text('4 hari menuju freeze berikutnya'), findsNothing);

      await disposeScreen(tester);
    });
  });
}

/// Stand-in bebas timer untuk [CurrentDateNotifier] supaya "hari ini" (`now`)
/// dapat dikunci pada tanggal tertentu tanpa menunggu tengah malam sungguhan.
class _FixedDateNotifier extends CurrentDateNotifier {
  _FixedDateNotifier(this._date);

  final DateTime _date;

  @override
  DateTime build() => DateTime(_date.year, _date.month, _date.day);
}