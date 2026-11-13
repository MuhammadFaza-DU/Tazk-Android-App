import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/profile/streak_history_strip.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Strip "7 hari terakhir" di Profil.
///
/// Tujuannya menjawab "kenapa streak-ku tidak naik": hari yang bolong harus
/// kelihatan, dan status tidak boleh dibedakan lewat warna saja (DESIGN.md).
void main() {
  final now = DateTime(2026, 11, 14, 10);

  DateTime dayBefore(int daysAgo) =>
      DateTime(now.year, now.month, now.day - daysAgo);

  Future<AppDatabase> pumpStrip(
    WidgetTester tester, {
    required List<DateTime> activeDays,
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    for (final day in activeDays) {
      await db.into(db.xpEvents).insert(
            XpEventsCompanion.insert(
              amount: 15,
              source: XpSource.task,
              createdAt: Value(day.add(const Duration(hours: 9))),
            ),
          );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('id'),
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: StreakHistoryStrip(now: now),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return db;
  }

  /// Lepas tree supaya langganan stream Drift berhenti sebelum pemeriksaan
  /// pending-timer milik binding.
  Future<void> disposeStrip(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  List<StreakHistoryDay> daysOf(WidgetTester tester) => tester
      .widgetList<StreakHistoryDay>(find.byType(StreakHistoryDay))
      .toList();

  testWidgets('menampilkan 7 hari dan menandai hari yang aktif', (tester) async {
    await pumpStrip(
      tester,
      activeDays: [dayBefore(3), dayBefore(2), dayBefore(0)],
    );

    final days = daysOf(tester);
    expect(days, hasLength(7));
    expect(days.where((d) => d.isActive), hasLength(3));
    expect(days.last.isActive, isTrue, reason: 'hari ini punya aktivitas');
    expect(days.last.isToday, isTrue);

    await disposeStrip(tester);
  });

  testWidgets('hari bolong tidak aktif dan punya label aksesibel', (
    tester,
  ) async {
    await pumpStrip(tester, activeDays: [dayBefore(1), dayBefore(0)]);

    final days = daysOf(tester);
    expect(days.where((d) => !d.isActive), hasLength(5));

    // Status dibawa oleh semantik, bukan warna saja.
    final missed = find.byWidgetPredicate(
      (w) => w is StreakHistoryDay && !w.isActive,
    );
    expect(
      tester.getSemantics(missed.first).label,
      contains('tidak ada aktivitas'),
    );

    await disposeStrip(tester);
  });

  testWidgets('judul section memakai salinan lokal', (tester) async {
    await pumpStrip(tester, activeDays: [dayBefore(0)]);

    expect(find.text('7 HARI TERAKHIR'), findsOneWidget);

    await disposeStrip(tester);
  });

  testWidgets('tanpa aktivitas sama sekali tetap tampil tanpa error', (
    tester,
  ) async {
    await pumpStrip(tester, activeDays: const []);

    expect(tester.takeException(), isNull);
    final days = daysOf(tester);
    expect(days, hasLength(7));
    expect(days.every((d) => !d.isActive), isTrue);

    await disposeStrip(tester);
  });

  testWidgets('muat di layar sempit 320dp tanpa overflow', (tester) async {
    await pumpStrip(tester, activeDays: [dayBefore(0)], width: 320);

    expect(tester.takeException(), isNull);
    expect(
      tester.getRect(find.byType(StreakHistoryStrip)).right,
      lessThanOrEqualTo(320 - 20 + 0.01),
    );

    await disposeStrip(tester);
  });
}
