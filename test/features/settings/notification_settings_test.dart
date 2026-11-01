import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/list_row.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/repositories/settings_repository.dart';
import 'package:tazk/features/settings/notification_settings_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Uji T9.2: layar Pengaturan Notifikasi menampilkan lima channel (board
/// `design-export/21 Notifikasi.png`) — tiap baris = judul + sub-judul
/// penjelas — dan toggle ke-5 (sesi fokus) benar-benar tersimpan.
///
/// Harness meniru `test/features/settings/settings_screen_board_test.dart`:
/// DB Drift in-memory, locale `id` (copy board), viewport 390dp.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpScreen(WidgetTester tester, {double height = 900}) async {
    tester.view.physicalSize = Size(390 * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

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
          home: const NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Lepas tree supaya query stream Drift berhenti sebelum pemeriksaan
  /// pending-timer milik binding.
  Future<void> disposeScreen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  Finder focusSwitch() => find.descendant(
        of: find.widgetWithText(ListRow, 'Sesi fokus'),
        matching: find.byType(Switch),
      );

  testWidgets('lima baris channel tampil berurutan sesuai board 21', (
    tester,
  ) async {
    await pumpScreen(tester);

    const titles = [
      'Task',
      'Habit',
      'Streak Warning',
      'Freeze',
      'Sesi fokus',
    ];
    for (final title in titles) {
      expect(
        find.widgetWithText(ListRow, title),
        findsOneWidget,
        reason: 'baris "$title" hilang',
      );
    }

    final tops = [
      for (final title in titles)
        tester.getRect(find.widgetWithText(ListRow, title)).top,
    ];
    for (var i = 1; i < tops.length; i++) {
      expect(
        tops[i],
        greaterThan(tops[i - 1]),
        reason: '${titles[i]} harus di bawah ${titles[i - 1]}',
      );
    }

    await disposeScreen(tester);
  });

  testWidgets('tiap baris punya sub-judul penjelas', (tester) async {
    await pumpScreen(tester);

    const subtitles = [
      'Saat jam task tiba',
      'Saat waktu habit tiba',
      'Kalau belum ada yang selesai',
      'Saat freeze otomatis dipakai',
      'Saat timer Pomodoro habis',
    ];
    for (final subtitle in subtitles) {
      expect(
        find.text(subtitle),
        findsOneWidget,
        reason: 'sub-judul "$subtitle" hilang',
      );
    }

    // Sub-judul lebih kecil dari judul (skim-able, tidak bersaing).
    final titleSize =
        tester.widget<Text>(find.text('Streak Warning')).style!.fontSize!;
    final subtitleSize =
        tester.widget<Text>(find.text('Saat jam task tiba')).style!.fontSize!;
    expect(subtitleSize, lessThan(titleSize));

    await disposeScreen(tester);
  });

  testWidgets('toggle sesi fokus menyala secara default', (tester) async {
    await pumpScreen(tester);

    expect(tester.widget<Switch>(focusSwitch()).value, isTrue);

    await disposeScreen(tester);
  });

  testWidgets('mengetuk baris sesi fokus menyimpan preferensi ke database', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Sesi fokus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final persisted = await SettingsRepository(db).ensureSettings();
    expect(persisted.notifyFocusSession, isFalse);
    expect(
      persisted.notifyTasks,
      isTrue,
      reason: 'channel lain tidak boleh ikut berubah',
    );

    expect(tester.widget<Switch>(focusSwitch()).value, isFalse);

    await disposeScreen(tester);
  });

  testWidgets('mengetuk kedua kali menyalakan sesi fokus kembali', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Sesi fokus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Sesi fokus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final persisted = await SettingsRepository(db).ensureSettings();
    expect(persisted.notifyFocusSession, isTrue);
    expect(tester.widget<Switch>(focusSwitch()).value, isTrue);

    await disposeScreen(tester);
  });

  testWidgets('baris toggle tetap ramah sentuh (tinggi ≥48dp)', (tester) async {
    await pumpScreen(tester);

    for (final title in ['Task', 'Sesi fokus']) {
      final size = tester.getSize(find.widgetWithText(ListRow, title));
      expect(size.height, greaterThanOrEqualTo(48));
    }

    await disposeScreen(tester);
  });
}