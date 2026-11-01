import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/widgets/app_button.dart';
import 'package:tazk/core/widgets/category_picker.dart';
import 'package:tazk/core/widgets/empty_state.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/category_repository.dart';
import 'package:tazk/features/habits/habit_form_screen.dart';
import 'package:tazk/features/settings/categories_screen.dart';
import 'package:tazk/features/tasks/task_form_screen.dart';
import 'package:tazk/l10n/app_localizations.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/repository_providers.dart';

/// Uji T7.3: layar "Kelola kategori" + pemilih kategori di Task Form.
///
/// Semua uji memakai database Drift in-memory sungguhan
/// (`AppDatabase.forTesting(NativeDatabase.memory())`), bukan repository tiruan,
/// supaya yang dibuktikan adalah data yang benar-benar tersimpan.

/// `home_widget` tidak punya sisi native di test binding: tanpa mock, penyegaran
/// widget setelah simpan menggantung selamanya.
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
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

/// Pump [CategoriesScreen] dengan DB memori. [seed] dijalankan **sebelum** widget
/// dibangun, jadi emisi pertama stream sudah memuat datanya.
Future<AppDatabase> _pumpCategories(
  WidgetTester tester, {
  Future<void> Function(AppDatabase db)? seed,
  CategoryRepository Function(AppDatabase db)? repository,
  double width = 390,
  double height = 900,
}) async {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  if (seed != null) await seed(db);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        if (repository != null)
          categoryRepositoryProvider.overrideWithValue(repository(db)),
      ],
      child: _app(home: const CategoriesScreen()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return db;
}

/// Lepas tree supaya query stream Drift berhenti sebelum pemeriksaan
/// pending-timer milik binding.
Future<void> _disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

/// Mount satu form di dalam host route (supaya `Navigator.pop()` saat simpan
/// punya tujuan kembali) dengan DB memori sungguhan.
///
/// [seed] jalan **sebelum** widget dibangun, jadi stream kategori sudah berisi
/// data pada frame pertama dan chip sudah bisa diketuk tanpa menunggu emisi.
Future<AppDatabase> _pumpFormHost(
  WidgetTester tester, {
  required Widget Function(AppDatabase db) form,
  Future<void> Function(AppDatabase db)? seed,
}) async {
  _mockHomeWidgetChannel();
  // Surface tinggi: seluruh form (termasuk tombol simpan) terbangun tanpa
  // scroll, jadi tap mendarat di widget yang diuji.
  await tester.binding.setSurfaceSize(const Size(420, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  if (seed != null) await seed(db);
  final formWidget = form(db);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: _app(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => formWidget),
                ),
                child: const Text('BUKA FORM'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.tap(find.text('BUKA FORM'));
  await tester.pumpAndSettle();
  return db;
}

/// Status terpilih satu chip picker, dibaca dari widget chip-nya sendiri.
bool _chipSelected(WidgetTester tester, int? categoryId) {
  return tester
      .widget<ChoiceChip>(find.byKey(categoryPickerChipKey(categoryId)))
      .selected;
}

/// Warna dianggap terpilih bila bulatannya menampilkan centang â€” status tidak
/// pernah dibedakan warna saja (`DESIGN.md`).
bool _isSelected(WidgetTester tester, CategoryColor color) {
  return find
      .descendant(
        of: find.byKey(categoryColorOptionKey(color)),
        matching: find.byIcon(Icons.check_rounded),
      )
      .evaluate()
      .isNotEmpty;
}

Future<int> _insertCategory(
  AppDatabase db,
  String name, {
  CategoryColor color = CategoryColor.sage,
}) {
  return db.into(db.categories).insert(
        CategoriesCompanion.insert(name: name, color: color),
      );
}

/// Repository yang gagal dengan galat **bukan** `ArgumentError`, dipakai untuk
/// membuktikan sheet tidak terkunci: dulu `_saving` hanya direset di cabang
/// `on ArgumentError`, jadi galat lain mematikan tombol simpan selamanya.
class _FailingRepository extends CategoryRepository {
  _FailingRepository(super._db);

  @override
  Future<int> createCategory(String name, CategoryColor color) async {
    throw StateError('disk penuh');
  }
}

void main() {
  group('CategoriesScreen â€” empty state', () {
    testWidgets('menampilkan EmptyState saat belum ada kategori', (tester) async {
      final db = await _pumpCategories(tester);
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Belum ada kategori'), findsOneWidget);
      expect(find.text('Buat kategori'), findsOneWidget);
      // Judul layar + aksi tambah tetap ada di header.
      expect(find.byKey(categoriesAddButtonKey), findsOneWidget);
      expect(await db.select(db.categories).get(), isEmpty);

      await _disposeScreen(tester);
    });

    testWidgets('aksi di empty state membuka sheet kategori baru', (
      tester,
    ) async {
      await _pumpCategories(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buat kategori'));
      await tester.pumpAndSettle();

      expect(find.byKey(categoryEditorSheetKey), findsOneWidget);
      expect(find.text('Kategori baru'), findsOneWidget);

      await _disposeScreen(tester);
    });
  });

  group('CategoriesScreen â€” tambah, ubah, hapus', () {
    testWidgets('tambah kategori menyimpan ke DB dan muncul di daftar', (
      tester,
    ) async {
      final db = await _pumpCategories(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(categoriesAddButtonKey));
      await tester.pumpAndSettle();

      // Simpan mati selama nama belum diisi: tidak ada kategori kosong yang
      // bisa tercipta lewat UI.
      expect(
        tester.widget<AppButton>(find.byKey(categorySaveButtonKey)).onPressed,
        isNull,
      );

      await tester.enterText(find.byKey(categoryNameFieldKey), 'Kerja');
      await tester.pump();
      await tester.tap(find.byKey(categoryColorOptionKey(CategoryColor.plum)));
      await tester.pump();
      await tester.tap(find.byKey(categorySaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(categoryEditorSheetKey), findsNothing);
      expect(find.text('Kerja'), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);

      final rows = await db.select(db.categories).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Kerja');
      expect(rows.single.color, CategoryColor.plum);

      await _disposeScreen(tester);
    });

    testWidgets('nama duplikat ditolak dengan galat inline, sheet tetap terbuka', (
      tester,
    ) async {
      final db = await _pumpCategories(
        tester,
        seed: (db) => _insertCategory(db, 'Kerja'),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(categoriesAddButtonKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(categoryNameFieldKey), 'kErJa');
      await tester.pump();
      await tester.tap(find.byKey(categorySaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(categoryEditorSheetKey), findsOneWidget);
      expect(find.text('Nama kategori itu sudah dipakai'), findsOneWidget);
      expect(await db.select(db.categories).get(), hasLength(1));
      // Tombol simpan hidup lagi setelah galat (bukan terkunci selamanya).
      expect(
        tester.widget<AppButton>(find.byKey(categorySaveButtonKey)).onPressed,
        isNotNull,
      );

      // Dan memang masih bisa menyimpan setelah namanya dibetulkan.
      await tester.enterText(find.byKey(categoryNameFieldKey), 'Belanja');
      await tester.pump();
      await tester.tap(find.byKey(categorySaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(categoryEditorSheetKey), findsNothing);
      final names = (await db.select(db.categories).get())
          .map((row) => row.name)
          .toList();
      expect(names..sort(), ['Belanja', 'Kerja']);

      await _disposeScreen(tester);
    });

    testWidgets(
      'galat tak terduga memakai pesan umum dan tombol simpan tidak terkunci',
      (tester) async {
        await _pumpCategories(
          tester,
          repository: _FailingRepository.new,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(categoriesAddButtonKey));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(categoryNameFieldKey), 'Kerja');
        await tester.pump();
        await tester.tap(find.byKey(categorySaveButtonKey));
        await tester.pumpAndSettle();

        // Pesan umum, bukan teks teknis, dan sheet tetap terbuka.
        expect(find.byKey(categoryEditorSheetKey), findsOneWidget);
        expect(find.text('Kategori belum tersimpan. Coba lagi.'), findsOneWidget);
        // Inti perbaikan: `_saving` kembali false lewat `finally`, jadi tombol
        // simpan bisa ditekan lagi.
        expect(
          tester.widget<AppButton>(find.byKey(categorySaveButtonKey)).onPressed,
          isNotNull,
        );

        await _disposeScreen(tester);
      },
    );

    testWidgets('ubah nama memperbarui DB dan daftar tanpa mengubah warna', (
      tester,
    ) async {
      late int categoryId;
      final db = await _pumpCategories(
        tester,
        seed: (db) async {
          categoryId =
              await _insertCategory(db, 'Kerja', color: CategoryColor.sky);
        },
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(categoryRenameButtonKey(categoryId)));
      await tester.pumpAndSettle();

      // Sheet ubah memakai pemilih warna yang sudah terisi warna sekarang.
      expect(find.text('Ubah kategori'), findsOneWidget);
      expect(
        _isSelected(tester, CategoryColor.sky),
        isTrue,
        reason: 'warna kategori sekarang harus terpilih di sheet',
      );

      await tester.enterText(find.byKey(categoryNameFieldKey), 'Pekerjaan');
      await tester.pump();
      await tester.tap(find.byKey(categorySaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Pekerjaan'), findsOneWidget);
      expect(find.text('Kerja'), findsNothing);

      final row = (await db.select(db.categories).get()).single;
      expect(row.id, categoryId);
      expect(row.name, 'Pekerjaan');
      expect(row.color, CategoryColor.sky);

      await _disposeScreen(tester);
    });

    testWidgets('ubah kategori bisa mengganti warna sekaligus nama', (
      tester,
    ) async {
      late int categoryId;
      final db = await _pumpCategories(
        tester,
        seed: (db) async {
          categoryId =
              await _insertCategory(db, 'Kerja', color: CategoryColor.sky);
        },
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(categoryRenameButtonKey(categoryId)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(categoryNameFieldKey), 'Pekerjaan');
      await tester.pump();
      await tester.tap(find.byKey(categoryColorOptionKey(CategoryColor.plum)));
      await tester.pump();
      expect(_isSelected(tester, CategoryColor.plum), isTrue);
      expect(_isSelected(tester, CategoryColor.sky), isFalse);

      await tester.tap(find.byKey(categorySaveButtonKey));
      await tester.pumpAndSettle();

      final row = (await db.select(db.categories).get()).single;
      expect(row.id, categoryId);
      expect(row.name, 'Pekerjaan');
      expect(row.color, CategoryColor.plum,
          reason: 'warna baru harus tersimpan lewat updateCategoryColor');

      // Baris di daftar memakai titik warna baru.
      final dot = tester.widget<CategoryColorDot>(
        find.descendant(
          of: find.byKey(categoryRowKey(categoryId)),
          matching: find.byType(CategoryColorDot),
        ),
      );
      expect(dot.color, CategoryColor.plum);

      await _disposeScreen(tester);
    });

    testWidgets('sasaran warna tetap â‰¥48dp walau layar hanya 320dp', (
      tester,
    ) async {
      await _pumpCategories(tester, width: 320);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(categoriesAddButtonKey));
      await tester.pumpAndSettle();

      // Enam sasaran 48dp butuh 288dp + jarak; di 320dp barisnya harus turun,
      // bukan mengecil di bawah lantai tap target.
      for (final color in CategoryColor.values) {
        final size = tester.getSize(find.byKey(categoryColorOptionKey(color)));
        expect(size.width, greaterThanOrEqualTo(48),
            reason: 'lebar sasaran warna ${color.name}');
        expect(size.height, greaterThanOrEqualTo(48),
            reason: 'tinggi sasaran warna ${color.name}');
      }
      expect(tester.takeException(), isNull);

      await _disposeScreen(tester);
    });

    testWidgets('hapus kategori menjaga task & habit dengan categoryId null', (
      tester,
    ) async {
      late int categoryId;
      late int taskId;
      late int habitId;
      final db = await _pumpCategories(
        tester,
        seed: (db) async {
          categoryId =
              await _insertCategory(db, 'Kerja', color: CategoryColor.sage);
          taskId = await db.into(db.tasks).insert(
                TasksCompanion.insert(
                  title: 'Laporan',
                  date: DateTime(2026, 11, 1),
                  priority: TaskPriority.medium,
                  categoryId: Value(categoryId),
                ),
              );
          habitId = await db.into(db.habits).insert(
                HabitsCompanion.insert(
                  name: 'Baca',
                  frequency: HabitFrequency.daily,
                  categoryId: Value(categoryId),
                ),
              );
        },
      );
      await tester.pumpAndSettle();

      // Batal dulu: tidak ada yang terhapus.
      await tester.tap(find.byKey(categoryDeleteButtonKey(categoryId)));
      await tester.pumpAndSettle();
      expect(find.text('Hapus kategori?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(await db.select(db.categories).get(), hasLength(1));

      // Konfirmasi: kategori hilang, barisnya tetap.
      await tester.tap(find.byKey(categoryDeleteButtonKey(categoryId)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Kerja'), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(await db.select(db.categories).get(), isEmpty);

      final task =
          await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
              .getSingle();
      final habit =
          await (db.select(db.habits)..where((h) => h.id.equals(habitId)))
              .getSingle();
      expect(task.title, 'Laporan');
      expect(task.categoryId, isNull);
      expect(habit.name, 'Baca');
      expect(habit.categoryId, isNull);

      await _disposeScreen(tester);
    });
  });

  group('CategoriesScreen â€” stress data', () {
    testWidgets('nama sangat panjang & satu huruf muat di 320dp', (
      tester,
    ) async {
      // Id hasil insert dipakai apa adanya â€” jangan berasumsi autoincrement = 1.
      late int longId;
      await _pumpCategories(
        tester,
        width: 320,
        seed: (db) async {
          longId = await _insertCategory(
            db,
            'Kegiatan organisasi kampus yang sangat panjang sekali',
          );
          await _insertCategory(db, 'A', color: CategoryColor.plum);
        },
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('A'), findsOneWidget);
      // Dua tombol aksi per baris tetap bisa dijangkau (tap target 48dp).
      expect(find.byIcon(Icons.edit_outlined), findsNWidgets(2));
      expect(find.byIcon(Icons.delete_outline_rounded), findsNWidgets(2));

      // Tap target tombol baris: kotak tombolnya sendiri â‰¥48Ã—48.
      final rename = tester.getSize(
        find.byKey(categoryRenameButtonKey(longId)),
      );
      expect(rename.width, greaterThanOrEqualTo(48));
      expect(rename.height, greaterThanOrEqualTo(48));

      await _disposeScreen(tester);
    });
  });

  group('CategoryPicker â€” persistensi di form', () {
    testWidgets('task baru: chip terpilih tersimpan sebagai categoryId', (
      tester,
    ) async {
      late int categoryId;
      late int otherId;
      final db = await _pumpFormHost(
        tester,
        seed: (db) async {
          final repo = CategoryRepository(db);
          categoryId = await repo.createCategory('Kerja', CategoryColor.sage);
          otherId = await repo.createCategory('Belanja', CategoryColor.sand);
          // Nama panjang ikut dipasang: chip harus memendek di dalam `Wrap`,
          // bukan meluber keluar layar.
          await repo.createCategory(
            'Kegiatan organisasi kampus yang sangat panjang sekali',
            CategoryColor.plum,
          );
        },
        form: (_) => const TaskFormScreen(),
      );

      // Default: "Tanpa kategori" yang terpilih.
      expect(_chipSelected(tester, null), isTrue);
      // Setiap kategori punya chip sendiri.
      expect(find.byKey(categoryPickerChipKey(categoryId)), findsOneWidget);
      expect(find.byKey(categoryPickerChipKey(otherId)), findsOneWidget);

      // Target sentuh chip â‰¥48dp lewat padding Material (visualnya lebih tipis).
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(categoryPickerChipKey(categoryId)))
            .materialTapTargetSize,
        MaterialTapTargetSize.padded,
      );
      expect(
        tester.getSize(find.byKey(categoryPickerChipKey(categoryId))).height,
        greaterThanOrEqualTo(48),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Laporan');
      await tester.tap(find.byKey(categoryPickerChipKey(categoryId)));
      await tester.pump();

      expect(_chipSelected(tester, categoryId), isTrue);
      expect(_chipSelected(tester, null), isFalse);
      // Nama panjang tidak meluber (chip memendek dengan ellipsis).
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(taskFormSaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(TaskFormScreen), findsNothing);
      final task = (await db.select(db.tasks).get()).single;
      expect(task.title, 'Laporan');
      expect(task.categoryId, categoryId);

      await _disposeScreen(tester);
    });

    testWidgets('task baru tanpa pilihan: categoryId tetap null', (
      tester,
    ) async {
      final db = await _pumpFormHost(
        tester,
        seed: (db) => CategoryRepository(db)
            .createCategory('Kerja', CategoryColor.sage),
        form: (_) => const TaskFormScreen(),
      );

      await tester.enterText(find.byType(TextFormField).first, 'Rapat');
      await tester.tap(find.byKey(taskFormSaveButtonKey));
      await tester.pumpAndSettle();

      final task = (await db.select(db.tasks).get()).single;
      expect(task.categoryId, isNull);

      await _disposeScreen(tester);
    });

    testWidgets('task yang diedit: chip memperbarui categoryId tersimpan', (
      tester,
    ) async {
      late int categoryId;
      late Task stored;
      final db = await _pumpFormHost(
        tester,
        seed: (db) async {
          categoryId = await CategoryRepository(db)
              .createCategory('Kerja', CategoryColor.sage);
          final taskId = await db.into(db.tasks).insert(
                TasksCompanion.insert(
                  title: 'Laporan',
                  date: DateTime(2026, 11, 1),
                  priority: TaskPriority.medium,
                ),
              );
          stored = await (db.select(db.tasks)
                ..where((t) => t.id.equals(taskId)))
              .getSingle();
        },
        form: (_) => TaskFormScreen(task: stored),
      );

      // Titik awal: task tersimpan belum punya kategori.
      expect(stored.categoryId, isNull);
      expect(_chipSelected(tester, null), isTrue);

      await tester.tap(find.byKey(categoryPickerChipKey(categoryId)));
      await tester.pump();
      await tester.tap(find.byKey(taskFormSaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(TaskFormScreen), findsNothing);
      final task = (await db.select(db.tasks).get()).single;
      expect(task.id, stored.id);
      expect(task.title, 'Laporan');
      expect(task.categoryId, categoryId);

      await _disposeScreen(tester);
    });

    testWidgets('habit baru: chip terpilih tersimpan sebagai categoryId', (
      tester,
    ) async {
      late int categoryId;
      final db = await _pumpFormHost(
        tester,
        seed: (db) async {
          categoryId = await CategoryRepository(db)
              .createCategory('Sehat', CategoryColor.honey);
        },
        form: (_) => const HabitFormScreen(),
      );

      expect(_chipSelected(tester, null), isTrue);

      await tester.enterText(find.byType(TextFormField).first, 'Jalan pagi');
      await tester.pump();
      await tester.tap(find.byKey(categoryPickerChipKey(categoryId)));
      await tester.pump();
      expect(_chipSelected(tester, categoryId), isTrue);

      await tester.tap(find.byKey(habitFormSaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(HabitFormScreen), findsNothing);
      final habit = (await db.select(db.habits).get()).single;
      expect(habit.name, 'Jalan pagi');
      expect(
        habit.categoryId,
        categoryId,
        reason: 'Habit Form wajib memanggil setHabitCategory setelah createHabit',
      );

      await _disposeScreen(tester);
    });

    testWidgets('habit yang diedit: chip memperbarui categoryId tersimpan', (
      tester,
    ) async {
      late int categoryId;
      late Habit stored;
      final db = await _pumpFormHost(
        tester,
        seed: (db) async {
          categoryId = await CategoryRepository(db)
              .createCategory('Sehat', CategoryColor.honey);
          final habitId = await db.into(db.habits).insert(
                HabitsCompanion.insert(
                  name: 'Baca',
                  frequency: HabitFrequency.daily,
                ),
              );
          stored = await (db.select(db.habits)
                ..where((h) => h.id.equals(habitId)))
              .getSingle();
        },
        form: (_) => HabitFormScreen(habit: stored),
      );

      expect(stored.categoryId, isNull);
      expect(_chipSelected(tester, null), isTrue);

      await tester.tap(find.byKey(categoryPickerChipKey(categoryId)));
      await tester.pump();
      await tester.tap(find.byKey(habitFormSaveButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(HabitFormScreen), findsNothing);
      final habit = (await db.select(db.habits).get()).single;
      expect(habit.id, stored.id);
      expect(habit.name, 'Baca');
      expect(
        habit.categoryId,
        categoryId,
        reason: 'Habit Form wajib memanggil setHabitCategory setelah updateHabit',
      );

      await _disposeScreen(tester);
    });
  });
}

