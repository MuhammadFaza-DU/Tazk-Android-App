import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_card.dart';
import 'package:tazk/core/widgets/app_scaffold.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/habits/habit_form_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Uji fidelity board `design-export/24 Habit Form.png` untuk
/// [HabitFormScreen].
///
/// Board (780×1048 px, dibagi 2 → frame 390dp) menunjukkan, dari atas:
/// - header `AppScaffold` (lingkaran back + judul Fredoka),
/// - label "Nama habit" di ATAS field (bukan label mengambang di dalam field),
/// - label "Frekuensi" + **empat chip sejajar** (Harian · Mingguan · Bulanan ·
///   Custom), bukan daftar radio,
/// - label "Waktu pengingat (opsional)" + pill jam (`primary-container`) dan
///   pill outline "Hapus",
/// - kartu "Progress bertahap" berisi judul + **switch** + baris target
///   (`canvas`, radius 10) dengan angka + ikon pensil,
/// - tombol simpan `primary` selebar layar di paling bawah.
///
/// Semua jarak di bawah diukur dari board: gutter 20, label→field 8,
/// field→label 16, label→chip 4, chip→label 11, label→pill 2, pill→kartu 8,
/// kartu→tombol 16, tinggi chip visual 38 di area sentuh 48, pill 32 di 48,
/// tombol 48.

Future<void> _pumpForm(WidgetTester tester, {Habit? habit}) async {
  tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // Tanpa sisi native, channel `home_widget` tidak pernah menjawab sehingga
  // `HomeWidgetService.refreshAll()` (dipanggil saat simpan) menggantung.
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('home_widget');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
  addTearDown(() => TestDefaultBinaryMessengerBinding.instance
      .defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('id'),
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HabitFormScreen(habit: habit),
                  ),
                ),
                child: const Text('BUKA FORM'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('BUKA FORM'));
  await tester.pumpAndSettle();
}

AppColors _colors(WidgetTester tester) => Theme.of(
      tester.element(find.byType(HabitFormScreen)),
    ).extension<AppColors>()!;

BoxDecoration _chipDecoration(WidgetTester tester, HabitFrequency frequency) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byKey(habitFormFrequencyChipKey(frequency)),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return container.decoration! as BoxDecoration;
}

Habit _habit({
  int id = 1,
  String name = 'Baca buku',
  HabitFrequency frequency = HabitFrequency.daily,
  DateTime? scheduledTime,
  bool hasProgress = false,
  int? targetMinutes,
}) {
  return Habit(
    id: id,
    name: name,
    frequency: frequency,
    scheduledTime: scheduledTime,
    hasProgress: hasProgress,
    targetMinutes: targetMinutes,
    isActive: true,
    createdAt: DateTime(2026, 10, 1),
  );
}

void main() {
  group('HabitFormScreen — struktur board 24 Habit Form', () {
    testWidgets('urutan field, gutter, dan jarak mengikuti board', (
      tester,
    ) async {
      await _pumpForm(tester);

      // Header board: lingkaran back + judul (AppScaffold).
      expect(find.byType(AppScaffold), findsOneWidget);
      expect(find.byKey(appScaffoldBackKey), findsOneWidget);
      expect(find.byKey(appScaffoldTitleKey), findsOneWidget);

      final nameLabel = tester.getRect(find.text('Nama'));
      final nameField = tester.getRect(find.byType(TextFormField).first);
      final frequencyLabel = tester.getRect(find.text('Frekuensi'));
      final selector = tester.getRect(find.byKey(habitFormFrequencySelectorKey));
      final reminderLabel = tester.getRect(find.text('Waktu (opsional)'));
      final reminderRow = tester.getRect(find.byKey(habitFormReminderRowKey));
      final card = tester.getRect(find.byKey(habitFormProgressCardKey));
      final save = tester.getRect(find.byKey(habitFormSaveButtonKey));

      // Urutan persis board: nama → frekuensi → waktu → progress → simpan.
      expect(nameLabel.top, lessThan(nameField.top));
      expect(nameField.bottom, lessThan(frequencyLabel.top));
      expect(frequencyLabel.bottom, lessThan(selector.top));
      expect(selector.bottom, lessThan(reminderLabel.top));
      expect(reminderLabel.bottom, lessThan(reminderRow.top));
      expect(reminderRow.bottom, lessThan(card.top));
      expect(card.bottom, lessThan(save.top));

      // Gutter board: 20dp di kiri & kanan, elemen selebar 350dp.
      for (final rect in [nameLabel, nameField, selector, card, save]) {
        expect(rect.left, HabitFormScreen.gutter);
      }
      expect(nameField.width, 390 - 2 * HabitFormScreen.gutter);
      expect(selector.width, 390 - 2 * HabitFormScreen.gutter);
      expect(card.width, 390 - 2 * HabitFormScreen.gutter);
      expect(save.width, 390 - 2 * HabitFormScreen.gutter);

      // Jarak antar blok (board, @2x ÷ 2).
      expect(nameField.top - nameLabel.bottom, 8);
      expect(frequencyLabel.top - nameField.bottom, 16);
      expect(selector.top - frequencyLabel.bottom, 4);
      expect(reminderLabel.top - selector.bottom, 11);
      expect(reminderRow.top - reminderLabel.bottom, 2);
      expect(card.top - reminderRow.bottom, 8);
      expect(save.top - card.bottom, 16);

      // Tombol simpan: `primary`, 48dp, label l10n.
      expect(save.height, 48);
      expect(find.text('Simpan'), findsOneWidget);

      // Label field berada DI ATAS field, bukan label mengambang di dalamnya.
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.decoration?.labelText, isNull);
    });

    testWidgets('pemilih frekuensi = empat chip sejajar, bukan radio', (
      tester,
    ) async {
      await _pumpForm(tester);

      // Board tidak memakai daftar radio untuk frekuensi.
      expect(find.byType(RadioListTile<HabitFrequency>), findsNothing);

      final rects = <HabitFrequency, Rect>{
        for (final frequency in HabitFrequency.values)
          frequency: tester.getRect(find.byKey(habitFormFrequencyChipKey(frequency))),
      };
      expect(rects.length, 4);
      // Satu baris, lebar sama, jarak 8dp.
      expect(rects[HabitFrequency.weekly]!.top, rects[HabitFrequency.daily]!.top);
      expect(rects[HabitFrequency.custom]!.top, rects[HabitFrequency.daily]!.top);
      final width = rects[HabitFrequency.daily]!.width;
      for (final rect in rects.values) {
        expect(rect.width, closeTo(width, 0.01));
      }
      expect(
        rects[HabitFrequency.weekly]!.left - rects[HabitFrequency.daily]!.right,
        HabitFormScreen.frequencyChipGap,
      );
      expect(rects[HabitFrequency.daily]!.height, HabitFormScreen.tapTarget);

      // Label keempat pilihan = copy board.
      expect(find.text('Harian'), findsOneWidget);
      expect(find.text('Mingguan'), findsOneWidget);
      expect(find.text('Bulanan'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Default: Harian terpilih (isi `primary`), sisanya `surface`.
      final colors = _colors(tester);
      expect(
        _chipDecoration(tester, HabitFrequency.daily).color,
        colors.primary,
      );
      expect(
        _chipDecoration(tester, HabitFrequency.weekly).color,
        colors.surface,
      );

      // Memilih chip lain memindahkan isian `primary`.
      await tester.tap(find.text('Mingguan'));
      await tester.pumpAndSettle();
      expect(
        _chipDecoration(tester, HabitFrequency.weekly).color,
        colors.primary,
      );
      expect(
        _chipDecoration(tester, HabitFrequency.daily).color,
        colors.surface,
      );
    });

    testWidgets('memilih Custom memunculkan opsi frekuensi kustom', (
      tester,
    ) async {
      await _pumpForm(tester);

      expect(find.text('Pengaturan frekuensi kustom'), findsNothing);

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan frekuensi kustom'), findsOneWidget);
      expect(find.text('Hari tertentu tiap minggu'), findsOneWidget);
      expect(find.text('Setiap N hari'), findsOneWidget);
      expect(find.text('Tanggal tertentu tiap bulan'), findsOneWidget);
      // Opsi hari (board tidak menggambar state ini, tapi harus tetap ada).
      expect(find.text('Sen'), findsOneWidget);
    });

    testWidgets('waktu pengingat: pill jam + Hapus saat terisi', (tester) async {
      await _pumpForm(
        tester,
        habit: _habit(scheduledTime: DateTime(2026, 10, 1, 20, 0)),
      );

      final context = tester.element(find.byType(HabitFormScreen));
      final expectedTime = const TimeOfDay(
        hour: 20,
        minute: 0,
      ).format(context);

      expect(find.text(expectedTime), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Baris tetap 48dp walau pill visual 32dp.
      expect(
        tester.getSize(find.byKey(habitFormReminderRowKey)).height,
        HabitFormScreen.tapTarget,
      );

      // "Hapus" mengosongkan waktu: pill jam jadi ikon saja.
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus'), findsNothing);
      expect(find.text(expectedTime), findsNothing);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
    });

    testWidgets('progress: switch (bukan radio) + baris target saat aktif', (
      tester,
    ) async {
      await _pumpForm(tester);

      // Board memakai switch, bukan pasangan radio Ya/Tidak.
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(RadioListTile<bool>), findsNothing);
      expect(find.byKey(habitFormTargetRowKey), findsNothing);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.byKey(habitFormTargetRowKey), findsOneWidget);
      // Visual baris 36dp, area sentuh 48dp (6 + 36 + 6).
      expect(
        tester.getSize(find.byKey(habitFormTargetRowKey)).height,
        HabitFormScreen.tapTarget,
      );

      await tester.enterText(find.byType(TextFormField).last, '30');
      await tester.pump();
      expect(find.text('30'), findsOneWidget);

      // Mematikan switch menyembunyikan baris target lagi.
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.byKey(habitFormTargetRowKey), findsNothing);
    });

    testWidgets('edit mode: judul, nama, dan target terisi dari habit', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        habit: _habit(name: 'Jurnal malam', hasProgress: true, targetMinutes: 30),
      );

      expect(find.text('Edit Habit'), findsOneWidget);
      expect(find.text('Jurnal malam'), findsOneWidget);
      expect(find.byKey(habitFormTargetRowKey), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      // Kartu progress memakai `AppCard` berbingkai (bukan kartu di kartu).
      expect(find.byType(AppCard), findsOneWidget);
    });
  });
}
