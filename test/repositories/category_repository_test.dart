import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tazk/core/theme/app_colors.dart';
import 'package:tazk/core/theme/app_theme.dart';
import 'package:tazk/core/theme/category_palette.dart';
import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/category_repository.dart';
import 'package:tazk/providers/category_providers.dart';
import 'package:tazk/providers/database_provider.dart';
import 'package:tazk/providers/repository_providers.dart';

const _lightAccents = <CategoryColor, Color>{
  CategoryColor.sage: Color(0xFF4A5A44),
  CategoryColor.honey: Color(0xFF98681C),
  CategoryColor.rose: Color(0xFFA85A4A),
  CategoryColor.sky: Color(0xFF3F6B7A),
  CategoryColor.plum: Color(0xFF6B4A6E),
  CategoryColor.sand: Color(0xFF7A6440),
};

const _darkAccents = <CategoryColor, Color>{
  CategoryColor.sage: Color(0xFF8FE0A9),
  CategoryColor.honey: Color(0xFFF2C765),
  CategoryColor.rose: Color(0xFFE0A183),
  CategoryColor.sky: Color(0xFF9CC3CF),
  CategoryColor.plum: Color(0xFFC7A3C9),
  CategoryColor.sand: Color(0xFFD8C79E),
};

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('timed out waiting for the stream to emit');
}

void main() {
  late AppDatabase db;
  late CategoryRepository categories;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    categories = CategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertTask(String title, {int? categoryId}) {
    return db.into(db.tasks).insert(TasksCompanion.insert(
          title: title,
          date: DateTime(2026, 11, 1),
          priority: TaskPriority.medium,
          categoryId: Value(categoryId),
        ));
  }

  Future<int> insertHabit(String name, {int? categoryId}) {
    return db.into(db.habits).insert(HabitsCompanion.insert(
          name: name,
          frequency: HabitFrequency.daily,
          categoryId: Value(categoryId),
        ));
  }

  group('createCategory', () {
    test('stores a trimmed name and returns the id', () async {
      final id = await categories.createCategory('  Belanja  ', CategoryColor.plum);

      final rows = await categories.watchCategories().first;
      expect(rows, hasLength(1));
      expect(rows.single.id, id);
      expect(rows.single.name, 'Belanja');
      expect(rows.single.color, CategoryColor.plum);
    });

    test('rejects an empty or whitespace-only name', () async {
      await expectLater(
        categories.createCategory('', CategoryColor.sage),
        throwsArgumentError,
      );
      await expectLater(
        categories.createCategory('   ', CategoryColor.sage),
        throwsArgumentError,
      );

      expect(await categories.watchCategories().first, isEmpty);
    });

    test('rejects a duplicate name that differs only by case or padding',
        () async {
      await categories.createCategory('Kerja', CategoryColor.sage);

      await expectLater(
        categories.createCategory('kErJa ', CategoryColor.honey),
        throwsArgumentError,
      );

      expect(await categories.watchCategories().first, hasLength(1));
    });

    test('rejects duplicates with non-ASCII case differences', () async {
      await categories.createCategory('Kafé', CategoryColor.sand);

      await expectLater(
        categories.createCategory('KAFÉ', CategoryColor.sky),
        throwsArgumentError,
      );

      expect(await categories.watchCategories().first, hasLength(1));
    });

    test('watchCategories orders by name then id', () async {
      await categories.createCategory('Ibadah', CategoryColor.sky);
      await categories.createCategory('Belanja', CategoryColor.sand);
      await categories.createCategory('Kerja', CategoryColor.sage);

      final names = (await categories.watchCategories().first)
          .map((category) => category.name)
          .toList();

      expect(names, ['Belanja', 'Ibadah', 'Kerja']);
    });

    test('watchCategories sorts case-insensitively', () async {
      await categories.createCategory('Zebra', CategoryColor.sky);
      await categories.createCategory('kerja', CategoryColor.sage);
      await categories.createCategory('apel', CategoryColor.sand);

      final names = (await categories.watchCategories().first)
          .map((category) => category.name)
          .toList();

      expect(names, ['apel', 'kerja', 'Zebra']);
    });
  });

  group('renameCategory', () {
    test('updates the name and keeps the color', () async {
      final id = await categories.createCategory('Kerja', CategoryColor.plum);

      await categories.renameCategory(id, '  Pekerjaan  ');

      final row = await categories.watchCategories().first;
      expect(row.single.id, id);
      expect(row.single.name, 'Pekerjaan');
      expect(row.single.color, CategoryColor.plum);
    });

    test('is a no-op when the trimmed name is unchanged', () async {
      final id = await categories.createCategory('Kerja', CategoryColor.sage);

      await categories.renameCategory(id, '  Kerja  ');

      final rows = await categories.watchCategories().first;
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Kerja');
    });

    test('allows changing only the letter case of the same category', () async {
      final id = await categories.createCategory('kerja', CategoryColor.sage);

      await categories.renameCategory(id, 'Kerja');

      expect((await categories.watchCategories().first).single.name, 'Kerja');
    });

    test('rejects a name already used by another category', () async {
      await categories.createCategory('Kerja', CategoryColor.sage);
      final id = await categories.createCategory('Belanja', CategoryColor.sand);

      await expectLater(
        categories.renameCategory(id, 'kERJA'),
        throwsArgumentError,
      );

      final names = (await categories.watchCategories().first)
          .map((category) => category.name)
          .toList();
      expect(names, ['Belanja', 'Kerja']);
    });

    test('rejects an empty name', () async {
      final id = await categories.createCategory('Kerja', CategoryColor.sage);

      await expectLater(categories.renameCategory(id, '  '), throwsArgumentError);

      expect((await categories.watchCategories().first).single.name, 'Kerja');
    });
  });

  group('updateCategoryColor', () {
    test('repaints the category and keeps the name', () async {
      final id = await categories.createCategory('Kerja', CategoryColor.sage);

      await categories.updateCategoryColor(id, CategoryColor.plum);

      final row = (await categories.watchCategories().first).single;
      expect(row.id, id);
      expect(row.name, 'Kerja');
      expect(row.color, CategoryColor.plum);
    });

    test('leaves other categories and their links untouched', () async {
      final repainted =
          await categories.createCategory('Kerja', CategoryColor.sage);
      final kept = await categories.createCategory('Belanja', CategoryColor.sand);
      final taskId = await insertTask('Laporan', categoryId: repainted);

      await categories.updateCategoryColor(repainted, CategoryColor.sky);

      final rows = await categories.watchCategories().first;
      expect(
        {for (final row in rows) row.name: row.color},
        {'Belanja': CategoryColor.sand, 'Kerja': CategoryColor.sky},
      );
      final task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.categoryId, repainted);
      expect(kept, isNot(repainted));
    });

    test('rejects an unknown id and writes nothing', () async {
      final id = await categories.createCategory('Kerja', CategoryColor.sage);

      await expectLater(
        categories.updateCategoryColor(id + 999, CategoryColor.honey),
        throwsArgumentError,
      );

      expect((await categories.watchCategories().first).single.color,
          CategoryColor.sage);
    });

    test('is a silent no-op when the color is already that value', () async {
      final id = await categories.createCategory('Kerja', CategoryColor.rose);

      await categories.updateCategoryColor(id, CategoryColor.rose);

      expect((await categories.watchCategories().first).single.color,
          CategoryColor.rose);
    });
  });

  group('deleteCategory', () {
    test('clears task and habit references while keeping both rows', () async {
      // FK enforcement is OFF in this app, so the nulling must be explicit.
      final fkEnabled = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(fkEnabled.data.values.first, 0,
          reason: 'guard: this test only proves something when FKs are off');

      final categoryId = await categories.createCategory('Kerja', CategoryColor.sage);
      final taskId = await insertTask('Laporan', categoryId: categoryId);
      final habitId = await insertHabit('Baca', categoryId: categoryId);

      await categories.deleteCategory(categoryId);

      final task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
      final habit = await (db.select(db.habits)..where((h) => h.id.equals(habitId)))
          .getSingle();

      expect(task.categoryId, isNull);
      expect(habit.categoryId, isNull);
      expect(task.title, 'Laporan');
      expect(habit.name, 'Baca');
      expect(await categories.watchCategories().first, isEmpty);
    });

    test('leaves tasks and habits of other categories untouched', () async {
      final doomed = await categories.createCategory('Kerja', CategoryColor.sage);
      final kept = await categories.createCategory('Belanja', CategoryColor.sand);
      final keepsTask = await insertTask('Belanja bulanan', categoryId: kept);
      final keepsHabit = await insertHabit('Catat pengeluaran', categoryId: kept);
      final orphanTask = await insertTask('Rapat', categoryId: doomed);

      await categories.deleteCategory(doomed);

      final task = await (db.select(db.tasks)..where((t) => t.id.equals(keepsTask)))
          .getSingle();
      final habit = await (db.select(db.habits)..where((h) => h.id.equals(keepsHabit)))
          .getSingle();
      final orphan =
          await (db.select(db.tasks)..where((t) => t.id.equals(orphanTask))).getSingle();

      expect(task.categoryId, kept);
      expect(habit.categoryId, kept);
      expect(orphan.categoryId, isNull);
      expect(
        (await categories.watchCategories().first).single.name,
        'Belanja',
      );
    });

    test('is a silent no-op for an unknown id', () async {
      final id = await categories.createCategory('Kerja', CategoryColor.sage);

      await categories.deleteCategory(id + 999);

      expect(await categories.watchCategories().first, hasLength(1));
    });
  });

  group('setTaskCategory / setHabitCategory', () {
    test('assigns then clears the task reference', () async {
      final categoryId = await categories.createCategory('Kerja', CategoryColor.sage);
      final taskId = await insertTask('Laporan');

      await categories.setTaskCategory(taskId, categoryId);
      var task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.categoryId, categoryId);

      await categories.setTaskCategory(taskId, null);
      task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.categoryId, isNull);
    });

    test('assigns then clears the habit reference', () async {
      final categoryId = await categories.createCategory('Sehat', CategoryColor.honey);
      final habitId = await insertHabit('Jalan pagi');

      await categories.setHabitCategory(habitId, categoryId);
      var habit = await (db.select(db.habits)..where((h) => h.id.equals(habitId)))
          .getSingle();
      expect(habit.categoryId, categoryId);

      await categories.setHabitCategory(habitId, null);
      habit = await (db.select(db.habits)..where((h) => h.id.equals(habitId)))
          .getSingle();
      expect(habit.categoryId, isNull);
    });

    test('only touches the addressed row', () async {
      final categoryId = await categories.createCategory('Kerja', CategoryColor.sage);
      final first = await insertTask('Satu');
      final second = await insertTask('Dua');

      await categories.setTaskCategory(first, categoryId);

      final untouched =
          await (db.select(db.tasks)..where((t) => t.id.equals(second))).getSingle();
      expect(untouched.categoryId, isNull);
    });

    test('rejects a task category id that does not exist and writes nothing',
        () async {
      final taskId = await insertTask('Laporan');

      await expectLater(
        categories.setTaskCategory(taskId, 9999),
        throwsArgumentError,
      );

      final task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.categoryId, isNull);
    });

    test('rejects a habit category id that does not exist and writes nothing',
        () async {
      final habitId = await insertHabit('Baca');

      await expectLater(
        categories.setHabitCategory(habitId, 9999),
        throwsArgumentError,
      );

      final habit = await (db.select(db.habits)..where((h) => h.id.equals(habitId)))
          .getSingle();
      expect(habit.categoryId, isNull);
    });
  });

  group('categoriesProvider', () {
    test('streams categories created through the repository', () async {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await container
          .read(categoryRepositoryProvider)
          .createCategory('Belanja', CategoryColor.sand);

      final rows = await container.read(categoriesProvider.future);
      expect(rows.single.name, 'Belanja');
      expect(rows.single.color, CategoryColor.sand);
    });

    test('emits again after a second category is created', () async {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await container
          .read(categoryRepositoryProvider)
          .createCategory('Belanja', CategoryColor.sand);

      final emissions = <List<String>>[];
      final subscription = container.listen(
        categoriesProvider,
        (_, next) {
          final value = next.valueOrNull;
          if (value != null) {
            emissions.add(value.map((category) => category.name).toList());
          }
        },
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await _waitFor(() => emissions.isNotEmpty);
      expect(emissions.last, ['Belanja']);

      await container
          .read(categoryRepositoryProvider)
          .createCategory('kerja', CategoryColor.sage);

      await _waitFor(() => emissions.last.length == 2);
      expect(emissions.length, greaterThanOrEqualTo(2));
      expect(emissions.last, ['Belanja', 'kerja']);
    });
  });

  group('categoryColor', () {
    Future<Map<CategoryColor, Color>> accentsFor(
      WidgetTester tester,
      ThemeData theme,
    ) async {
      Map<CategoryColor, Color>? accents;
      await tester.pumpWidget(Theme(
        data: theme,
        child: Builder(
          builder: (context) {
            accents = {
              for (final color in CategoryColor.values)
                color: categoryColor(context, color),
            };
            return const SizedBox.shrink();
          },
        ),
      ));
      return accents!;
    }

    testWidgets('returns the documented accent for every color in both themes',
        (tester) async {
      final light = await accentsFor(tester, AppTheme.light);
      final dark = await accentsFor(tester, AppTheme.dark);

      expect(light, _lightAccents);
      expect(dark, _darkAccents);
    });

    testWidgets('reuses the design token where the token already passes',
        (tester) async {
      final light = await accentsFor(tester, AppTheme.light);
      final dark = await accentsFor(tester, AppTheme.dark);

      expect(light[CategoryColor.sage], AppColors.light.primary);
      expect(dark[CategoryColor.sage], AppColors.dark.primary);
      expect(dark[CategoryColor.honey], AppColors.dark.honey);
      expect(dark[CategoryColor.rose], AppColors.dark.clay);
    });

    testWidgets('every accent is distinct within a theme', (tester) async {
      final light = await accentsFor(tester, AppTheme.light);
      final dark = await accentsFor(tester, AppTheme.dark);

      expect(light.values.toSet(), hasLength(CategoryColor.values.length));
      expect(dark.values.toSet(), hasLength(CategoryColor.values.length));
    });
  });
}