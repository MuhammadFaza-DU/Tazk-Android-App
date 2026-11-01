import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_text_field.dart';
import 'package:tazk/core/widgets/empty_state.dart';
import 'package:tazk/core/widgets/skeleton_list.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/search_repository.dart';
import 'package:tazk/features/habits/habit_detail_screen.dart';
import 'package:tazk/features/search/search_screen.dart';
import 'package:tazk/features/tasks/task_form_screen.dart';
import 'package:tazk/features/tasks/tasks_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/task_providers.dart';

/// Uji T7.4: layar Pencarian (board `26 Backup & Pencarian` bagian D).
///
/// Semua uji memakai database Drift in-memory sungguhan lewat
/// `appDatabaseProvider`, jadi yang dibuktikan adalah pencarian atas data yang
/// benar-benar tersimpan.

/// `home_widget` tidak punya sisi native di test binding: tanpa mock, penyegaran
/// widget setelah simpan menggantung selamanya (dipakai TaskFormScreen).
void _mockHomeWidgetChannel() {
  const channel = MethodChannel('home_widget');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => null);
  addTearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
}

Widget _app({required Widget home}) {
  return MaterialApp(
    locale: const Locale('id'),
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Future<int> _category(AppDatabase db, String name) {
  return db.into(db.categories).insert(
        CategoriesCompanion.insert(name: name, color: CategoryColor.sage),
      );
}

Future<int> _task(
  AppDatabase db, {
  required String title,
  int? categoryId,
  bool isCompleted = false,
  DateTime? time,
  String? location,
}) {
  return db.into(db.tasks).insert(
        TasksCompanion.insert(
          title: title,
          date: DateTime(2026, 10, 24),
          priority: TaskPriority.medium,
          time: Value(time),
          location: Value(location),
          categoryId: Value(categoryId),
          isCompleted: Value(isCompleted),
        ),
      );
}

Future<int> _habit(AppDatabase db, {required String name, int? categoryId}) {
  return db.into(db.habits).insert(
        HabitsCompanion.insert(
          name: name,
          frequency: HabitFrequency.daily,
          categoryId: Value(categoryId),
        ),
      );
}

/// Data contoh: tiga task (satu selesai) dan satu habit.
Future<({int kuliah, int pribadi})> _seed(AppDatabase db) async {
  final kuliah = await _category(db, 'Kuliah');
  final pribadi = await _category(db, 'Pribadi');
  await _task(
    db,
    title: 'Baca bab 3',
    categoryId: kuliah,
    time: DateTime(2026, 10, 24, 20),
  );
  await _task(db, title: 'Baca novel', categoryId: pribadi);
  await _task(db, title: 'Baca jurnal', isCompleted: true);
  await _habit(db, name: 'Baca buku');
  await _task(db, title: 'Belanja bulanan');
  return (kuliah: kuliah, pribadi: pribadi);
}

/// Pump [SearchScreen] dengan DB memori. [seed] jalan **sebelum** widget
/// dibangun supaya frame pertama sudah berisi data.
Future<AppDatabase> _pumpSearch(
  WidgetTester tester, {
  Future<Object?> Function(AppDatabase db)? seed,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  if (seed != null) await seed(db);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: _app(home: const SearchScreen()),
    ),
  );
  await tester.pump();
  return db;
}

/// Menunggu jeda ketikan (250 ms) **dan** query Drift selesai.
///
/// `pumpAndSettle` tidak bisa dipakai: skeleton loading punya ticker berulang.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

/// Lepas tree supaya query stream Drift berhenti sebelum pemeriksaan
/// pending-timer milik binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Mengetuk chip filter, setelah menggulir barisnya supaya chip yang berada di
/// luar layar (nama kategori bisa banyak) benar-benar bisa ditekan.
Future<void> _tapChip(WidgetTester tester, String id) async {
  final finder = find.byKey(searchFilterChipKey(id));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

void main() {
  testWidgets('mengetik menampilkan hasil lintas jenis', (tester) async {
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'baca');
    await _settle(tester);

    expect(find.text('Baca bab 3'), findsOneWidget);
    expect(find.text('Baca buku'), findsOneWidget);
    expect(find.text('Baca jurnal'), findsOneWidget);
    expect(find.text('Belanja bulanan'), findsNothing);

    // Sub-judul mengikuti bentuk board: jenis · kategori · waktu / jadwal.
    expect(find.textContaining('Task · Kuliah · 20'), findsOneWidget);
    expect(find.text('Habit · Harian'), findsOneWidget);
    // Tugas selesai menyebut "selesai" + tanggal, bukan jam.
    expect(find.text('Task · selesai 24 Okt'), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('huruf pertama tidak hilang saat jeda ketikan', (tester) async {
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'b');
    await _settle(tester);

    // Isi kotak tetap persis seperti yang diketik ...
    final field = tester.widget<AppTextField>(find.byKey(searchFieldKey));
    expect(field.controller!.text, 'b');
    // ... dan hasil untuk satu huruf itu sudah tampil.
    expect(find.text('Baca bab 3'), findsOneWidget);
    expect(find.text('Belanja bulanan'), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('menghapus isi menampilkan prompt, bukan hasil', (tester) async {
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'baca');
    await _settle(tester);
    expect(find.text('Baca bab 3'), findsOneWidget);

    await tester.tap(find.byKey(searchClearKey));
    await tester.pump();

    expect(find.byKey(searchPromptKey), findsOneWidget);
    expect(find.byKey(searchResultsKey), findsNothing);
    expect(find.text('Baca bab 3'), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('tombol hapus hanya ada saat kotak berisi, target 48dp', (
    tester,
  ) async {
    await _pumpSearch(tester, seed: _seed);

    // Kotak kosong: tidak ada `×` yang bisa disentuh tanpa hasil.
    expect(find.byKey(searchClearKey), findsNothing);

    await tester.enterText(find.byKey(searchFieldKey), 'baca');
    await tester.pump();

    expect(find.byKey(searchClearKey), findsOneWidget);

    // Target sentuh tetap 48dp walau ikonnya 20dp (AGENTS §7).
    final size = tester.getSize(find.byKey(searchClearKey));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));

    await tester.tap(find.byKey(searchClearKey));
    await tester.pump();

    expect(find.byKey(searchClearKey), findsNothing);
    expect(find.byKey(searchPromptKey), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('chip kategori menyempitkan hasil', (tester) async {
    final ids = await _pumpSearch(tester, seed: _seed).then((db) async {
      final rows = await db.select(db.categories).get();
      return {for (final row in rows) row.name: row.id};
    });

    await tester.enterText(find.byKey(searchFieldKey), 'baca');
    await _settle(tester);
    expect(find.text('Baca novel'), findsOneWidget);

    await _tapChip(tester, 'category-${ids['Kuliah']}');
    await _settle(tester);

    expect(find.text('Baca bab 3'), findsOneWidget);
    expect(find.text('Baca novel'), findsNothing);
    expect(find.text('Baca buku'), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('chip Habit dan Selesai menyaring sesuai board', (tester) async {
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'baca');
    await _settle(tester);

    await _tapChip(tester, 'habits');
    await _settle(tester);
    expect(find.text('Baca buku'), findsOneWidget);
    expect(find.text('Baca bab 3'), findsNothing);

    await _tapChip(tester, 'completed');
    await _settle(tester);
    expect(find.text('Baca jurnal'), findsOneWidget);
    expect(find.text('Baca buku'), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('kategori yang hilang mengembalikan filter ke Semua', (
    tester,
  ) async {
    final db = await _pumpSearch(tester, seed: _seed);
    final rows = await db.select(db.categories).get();
    final kuliah = rows.firstWhere((row) => row.name == 'Kuliah').id;

    await tester.enterText(find.byKey(searchFieldKey), 'baca');
    await _settle(tester);
    await _tapChip(tester, 'category-$kuliah');
    await _settle(tester);
    expect(find.text('Baca novel'), findsNothing);

    // Kategori dihapus (dari layar lain): chip-nya lenyap, jadi filter tidak
    // boleh tertinggal di kategori yang sudah tidak ada — hasil kosong tanpa
    // sebab yang terlihat adalah bug, bukan state yang jujur.
    await (db.delete(db.categories)
          ..where((row) => row.id.equals(kuliah)))
        .go();
    await _settle(tester);

    expect(find.byKey(searchFilterChipKey('category-$kuliah')), findsNothing);
    expect(find.text('Baca novel'), findsOneWidget);
    expect(find.text('Baca buku'), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('tidak ada hasil memakai EmptyState dengan copy jujur', (
    tester,
  ) async {
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'zzz');
    await _settle(tester);

    expect(find.byKey(searchNoResultsKey), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Tidak ada hasil'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(searchNoResultsKey),
        matching: find.textContaining('zzz'),
      ),
      findsOneWidget,
    );

    await _disposeScreen(tester);
  });

  testWidgets('mengetuk hasil task membuka form task', (tester) async {
    _mockHomeWidgetChannel();
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'bab 3');
    await _settle(tester);

    await tester.tap(find.byKey(searchResultRowKey(SearchResultType.task, 1)));
    await _settle(tester);

    expect(find.byType(TaskFormScreen), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('mengetuk hasil habit membuka detail habit', (tester) async {
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'buku');
    await _settle(tester);

    await tester.tap(find.byKey(searchResultRowKey(SearchResultType.habit, 1)));
    await _settle(tester);

    expect(find.byType(HabitDetailScreen), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('ganti judul dari hasil menyegarkan baris hasil', (tester) async {
    _mockHomeWidgetChannel();
    await _pumpSearch(tester, seed: _seed);

    await tester.enterText(find.byKey(searchFieldKey), 'baca');
    await _settle(tester);
    expect(find.text('Baca bab 3'), findsOneWidget);

    await tester.tap(find.byKey(searchResultRowKey(SearchResultType.task, 1)));
    await _settle(tester);
    expect(find.byType(TaskFormScreen), findsOneWidget);

    // Field judul adalah `AppTextField` pertama **di dalam form**; layar
    // Pencarian di bawahnya juga punya `AppTextField`, jadi pencarian dibatasi.
    final titleField = find
        .descendant(
          of: find.byType(TaskFormScreen),
          matching: find.byType(AppTextField),
        )
        .first;
    await tester.enterText(titleField, 'Baca bab tiga');
    await tester.pump();

    final save = find.byKey(taskFormSaveButtonKey);
    await tester.ensureVisible(save);
    await tester.pump();
    await tester.tap(save);
    await _settle(tester);
    await _settle(tester);

    // Form tertutup dan baris hasil memakai judul **baru**, bukan judul lama
    // dari hasil query sekali-jalan.
    expect(find.byType(TaskFormScreen), findsNothing);
    expect(find.text('Baca bab tiga'), findsOneWidget);
    expect(find.text('Baca bab 3'), findsNothing);

    await _disposeScreen(tester);
  });

  testWidgets('layar dibuka dari tombol cari di header Tasks', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await _seed(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          todayTasksProvider.overrideWith((ref) => Stream.value(const [])),
          taskSubtasksProvider.overrideWith(
            (ref, taskId) => Stream.value(const []),
          ),
        ],
        child: _app(home: const TasksScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(tasksSearchButtonKey), findsOneWidget);
    await tester.tap(find.byKey(tasksSearchButtonKey));
    await _settle(tester);

    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.byKey(searchFieldKey), findsOneWidget);

    await _disposeScreen(tester);
  });

  testWidgets('state awal ringan, tanpa skeleton dan tanpa spinner', (
    tester,
  ) async {
    await _pumpSearch(tester, seed: _seed);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(searchPromptKey), findsOneWidget);
    expect(find.byType(SkeletonList), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await _disposeScreen(tester);
  });
}
