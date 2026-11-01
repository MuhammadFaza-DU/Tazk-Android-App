import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/enums.dart';

/// Data layer for the single-category tagging feature.
///
/// `PRAGMA foreign_keys` is OFF in this app, so [deleteCategory] clears the
/// referencing rows explicitly instead of relying on `onDelete`.
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<Category>> watchCategories() {
    return (_db.select(_db.categories)
          ..orderBy([
            (c) => OrderingTerm(expression: c.name.collate(Collate.noCase)),
            (c) => OrderingTerm(expression: c.id),
          ]))
        .watch();
  }

  Future<int> createCategory(String name, CategoryColor color) async {
    final trimmed = _validName(name);
    return _db.transaction(() async {
      if (await _nameTaken(trimmed)) {
        throw ArgumentError.value(name, 'name', 'Category name already exists');
      }
      return _db.into(_db.categories).insert(
            CategoriesCompanion.insert(name: trimmed, color: color),
          );
    });
  }

  Future<void> renameCategory(int id, String name) async {
    final trimmed = _validName(name);
    return _db.transaction(() async {
      final current = await (_db.select(_db.categories)
            ..where((c) => c.id.equals(id)))
          .getSingleOrNull();
      if (current == null || current.name == trimmed) {
        return;
      }
      if (await _nameTaken(trimmed, excludingId: id)) {
        throw ArgumentError.value(name, 'name', 'Category name already exists');
      }
      await (_db.update(_db.categories)..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(name: Value(trimmed)));
    });
  }

  Future<void> deleteCategory(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.categoryId.equals(id)))
          .write(const TasksCompanion(categoryId: Value<int?>(null)));
      await (_db.update(_db.habits)..where((h) => h.categoryId.equals(id)))
          .write(const HabitsCompanion(categoryId: Value<int?>(null)));
      await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    });
  }

  /// Repaints an existing category. Separate from [renameCategory] because the
  /// two are independent: a rename must not silently drop the colour, and the
  /// editor sheet only writes a colour when the user actually picked another.
  Future<void> updateCategoryColor(int id, CategoryColor color) async {
    await _db.transaction(() async {
      await _requireCategory(id);
      await (_db.update(_db.categories)..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(color: Value(color)));
    });
  }

  Future<void> setTaskCategory(int taskId, int? categoryId) async {
    await _db.transaction(() async {
      await _requireCategory(categoryId);
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskId)))
          .write(TasksCompanion(categoryId: Value(categoryId)));
    });
  }

  Future<void> setHabitCategory(int habitId, int? categoryId) async {
    await _db.transaction(() async {
      await _requireCategory(categoryId);
      await (_db.update(_db.habits)..where((h) => h.id.equals(habitId)))
          .write(HabitsCompanion(categoryId: Value(categoryId)));
    });
  }

  String _validName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name must not be empty');
    }
    return trimmed;
  }

  Future<void> _requireCategory(int? categoryId) async {
    if (categoryId == null) {
      return;
    }
    final row = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(categoryId)))
        .getSingleOrNull();
    if (row == null) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Category does not exist',
      );
    }
  }

  Future<bool> _nameTaken(String trimmed, {int? excludingId}) async {
    // Compared in Dart, not SQL: SQLite's lower() folds ASCII only, so
    // "KAFÉ" would slip past "Kafé". A category list is tiny by design.
    final needle = trimmed.toLowerCase();
    final rows = await _db.select(_db.categories).get();
    return rows.any(
      (row) => row.id != excludingId && row.name.toLowerCase() == needle,
    );
  }
}