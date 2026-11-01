import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/features/tasks/task_form_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';

/// Board `10 Task Form` fidelity tests.
///
/// Board diukur dari `design-export/10 Task Form.png` (@2x → /2):
/// - gutter 20dp (dipakai 16, lihat laporan), label 13 w600 `ink-muted`
/// - field: isian `surface`, garis 1px `border`, radius `md`
/// - tanggal + jam: dua kotak sejajar, tinggi 42dp
/// - prioritas: TIGA kotak sama lebar (bukan radio), terpilih `honey-container`
///   + garis `honey` + teks `warning-strong`
/// - checklist: baris kartu `surface` bergaris + kotak centang radius 6
/// - simpan: selebar isi, isian `primary`, radius `md`, tinggi ≥48
const double _screenWidth = 390;
const double _gutter = 20;

Widget _app({bool dark = false, required AppDatabase db}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      locale: const Locale('id'),
      theme: dark ? AppTheme.dark : AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TaskFormScreen(),
    ),
  );
}

/// Surface ditinggikan supaya seluruh form (termasuk tombol simpan) terbangun
/// tanpa perlu scroll.
Future<void> _pumpForm(WidgetTester tester, {bool dark = false}) async {
  await tester.binding.setSurfaceSize(const Size(_screenWidth, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  // Form kategori membaca stream dari database: DB memori + ditutup setelah
  // tree dilepas (lihat `_disposeScreen`).
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(_app(dark: dark, db: db));
  await tester.pump();
}

/// Lepas tree di dalam body test supaya langganan stream Drift berhenti dan
/// timer nol-detaknya ter-flush sebelum pemeriksaan invariant binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

BoxDecoration _segmentDecoration(WidgetTester tester, TaskPriority priority) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byKey(taskFormPrioritySegmentKey(priority)),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as BoxDecoration;
}

/// Isian segmen ada di `Material`; `Container` hanya menggambar garisnya.
Color? _segmentFill(WidgetTester tester, TaskPriority priority) {
  final material = tester.widget<Material>(
    find
        .descendant(
          of: find.byKey(taskFormPrioritySegmentKey(priority)),
          matching: find.byType(Material),
        )
        .first,
  );
  return material.color;
}

Color _segmentTextColor(WidgetTester tester, TaskPriority priority) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byKey(taskFormPrioritySegmentKey(priority)),
      matching: find.byType(Text),
    ),
  );
  return text.style!.color!;
}

BorderSide _segmentBorder(WidgetTester tester, TaskPriority priority) {
  return (_segmentDecoration(tester, priority).border! as Border).top;
}

void main() {
  testWidgets('urutan grup field mengikuti board', (tester) async {
    await _pumpForm(tester);

    // Tanggal dan Jam satu baris, jadi yang diuji urutan vertikalnya grup.
    // `Kategori (opsional)` adalah sisipan T7.3 (board 10 tidak punya field ini);
    // dipatok di sini supaya posisinya tidak bergeser tanpa ketahuan.
    const labels = [
      'Judul',
      'Tanggal',
      'Prioritas',
      'Kategori (opsional)',
      'Lokasi (opsional)',
      'Checklist/Subtask (opsional)',
    ];

    final ys = [
      for (final label in labels) tester.getTopLeft(find.text(label)).dy,
    ];
    for (var i = 1; i < ys.length; i++) {
      expect(
        ys[i],
        greaterThan(ys[i - 1]),
        reason: '"${labels[i]}" harus berada di bawah "${labels[i - 1]}"',
      );
    }

    final saveTop = tester.getTopLeft(find.byKey(taskFormSaveButtonKey)).dy;
    expect(
      saveTop,
      greaterThan(ys.last),
      reason: 'tombol simpan harus di bawah blok checklist',
    );

    await _disposeScreen(tester);
  });

  testWidgets('tanggal dan jam tampil sebagai dua kotak sejajar', (tester) async {
    await _pumpForm(tester);

    final dateBox = find.byKey(taskFormDateBoxKey);
    final timeBox = find.byKey(taskFormTimeBoxKey);
    expect(dateBox, findsOneWidget);
    expect(timeBox, findsOneWidget);

    final dateOrigin = tester.getTopLeft(dateBox);
    final timeOrigin = tester.getTopLeft(timeBox);
    expect(dateOrigin.dy, timeOrigin.dy, reason: 'satu baris');
    expect(dateOrigin.dx, lessThan(timeOrigin.dx));

    // Kedua kotak berbagi lebar isi (358 - 8 gap) / 2 = 175.
    final dateSize = tester.getSize(dateBox);
    final timeSize = tester.getSize(timeBox);
    expect(dateSize.width, moreOrLessEquals((_screenWidth - 2 * _gutter - 8) / 2));
    expect(dateSize.width, moreOrLessEquals(timeSize.width));
    // Board: tinggi kotak 42dp.
    expect(dateSize.height, moreOrLessEquals(42));
    expect(timeSize.height, moreOrLessEquals(42));

    // Board menulis tanggal sebagai "29 Okt 2026" (d MMM yyyy).
    final datePattern = RegExp(r'^\d{1,2} [A-Za-z]{3} \d{4}$');
    final dateTexts = tester
        .widgetList<Text>(
          find.descendant(of: dateBox, matching: find.byType(Text)),
        )
        .map((text) => text.data)
        .whereType<String>();
    expect(dateTexts, isNotEmpty);
    expect(dateTexts.first, matches(datePattern));

    await _disposeScreen(tester);
  });

  testWidgets('prioritas memakai segmented tiga kotak, bukan radio', (
    tester,
  ) async {
    await _pumpForm(tester);

    expect(find.byType(RadioListTile<TaskPriority>), findsNothing);
    expect(find.byType(RadioGroup<TaskPriority>), findsNothing);
    expect(find.byKey(taskFormPrioritySelectorKey), findsOneWidget);

    final sizes = [
      for (final priority in TaskPriority.values)
        tester.getSize(find.byKey(taskFormPrioritySegmentKey(priority))),
    ];
    expect(sizes, hasLength(3));
    for (final size in sizes) {
      expect(size.width, moreOrLessEquals((_screenWidth - 2 * _gutter - 16) / 3));
      expect(size.height, moreOrLessEquals(40)); // board 39dp
    }

    // Satu baris, urut Low → Medium → High.
    final origins = [
      for (final priority in TaskPriority.values)
        tester.getTopLeft(find.byKey(taskFormPrioritySegmentKey(priority))),
    ];
    expect(origins[0].dy, origins[1].dy);
    expect(origins[1].dy, origins[2].dy);
    expect(origins[0].dx, lessThan(origins[1].dx));
    expect(origins[1].dx, lessThan(origins[2].dx));

    // Default task baru = medium, dan hanya medium yang tersorot.
    const selected = AppColors.light;
    expect(_segmentFill(tester, TaskPriority.medium), selected.honeyContainer);
    expect(_segmentBorder(tester, TaskPriority.medium).color, selected.honey);
    expect(
      _segmentTextColor(tester, TaskPriority.medium),
      selected.warningStrong,
    );

    for (final priority in [TaskPriority.low, TaskPriority.high]) {
      expect(_segmentFill(tester, priority), selected.surface);
      expect(_segmentBorder(tester, priority).color, selected.border);
      expect(_segmentTextColor(tester, priority), selected.inkMuted);
    }

    await _disposeScreen(tester);
  });

  testWidgets('mengetuk segmen memindahkan sorotan prioritas', (tester) async {
    await _pumpForm(tester);

    await tester.tap(find.byKey(taskFormPrioritySegmentKey(TaskPriority.high)));
    await tester.pump();

    const colors = AppColors.light;
    expect(
      _segmentFill(tester, TaskPriority.high),
      colors.honeyContainer,
    );
    expect(
      _segmentTextColor(tester, TaskPriority.high),
      colors.warningStrong,
    );
    expect(_segmentFill(tester, TaskPriority.medium), colors.surface);
    expect(
      _segmentTextColor(tester, TaskPriority.medium),
      colors.inkMuted,
    );

    await _disposeScreen(tester);
  });

  testWidgets('tombol simpan selebar isi, primary, radius md', (tester) async {
    await _pumpForm(tester);

    final save = find.byKey(taskFormSaveButtonKey);
    expect(save, findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);

    final size = tester.getSize(save);
    expect(size.width, moreOrLessEquals(_screenWidth - 2 * _gutter));
    expect(size.height, greaterThanOrEqualTo(48)); // tap target

    final material = tester.widget<Material>(
      find.descendant(of: save, matching: find.byType(Material)).first,
    );
    expect(material.color, AppColors.light.primary);
    final shape = material.shape! as RoundedRectangleBorder;
    expect(
      (shape.borderRadius as BorderRadius).topLeft.x,
      14, // rounded.md
    );

    // Di bawah baris "Tambah item".
    expect(
      tester.getTopLeft(save).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(taskFormAddItemFieldKey)).dy,
      ),
    );

    await _disposeScreen(tester);
  });

  testWidgets('Tambah item menambah baris checklist dan menghitung 0/1', (
    tester,
  ) async {
    await _pumpForm(tester);

    await tester.enterText(find.byKey(taskFormAddItemFieldKey), 'Siapkan materi');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // Perilaku T3 dipertahankan: submit keyboard menambah item.
    expect(find.text('Siapkan materi'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('tema gelap memakai token Dusk Forest untuk sorotan prioritas', (
    tester,
  ) async {
    await _pumpForm(tester, dark: true);

    const colors = AppColors.dark;
    expect(
      _segmentFill(tester, TaskPriority.medium),
      colors.honeyContainer,
    );
    expect(_segmentBorder(tester, TaskPriority.medium).color, colors.honey);
    expect(
      _segmentTextColor(tester, TaskPriority.medium),
      colors.warningStrong,
    );

    await _disposeScreen(tester);
  });
}
