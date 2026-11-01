import 'package:drift/drift.dart';

import '../database/database.dart';
import '../models/enums.dart';

/// Jenis entitas yang bisa muncul di hasil pencarian.
enum SearchResultType { task, habit }

/// Satu hasil pencarian lintas item (tugas + habit).
///
/// Model ini **hanya data**: tidak ada label, format tanggal, atau teks apa pun
/// di sini, karena setiap kata harus bisa berbeda per bahasa. Baris hasil yang
/// menyusun judul/sub-judulnya sendiri dari data ini.
sealed class SearchResult {
  const SearchResult();

  int get id;

  String get title;

  bool get isCompleted;

  int? get categoryId;

  String? get categoryName;

  CategoryColor? get categoryColor;

  SearchResultType get type;
}

/// Hasil dari tabel `tasks`.
final class TaskSearchResult extends SearchResult {
  const TaskSearchResult({required this.task, this.category});

  /// Baris task utuh, supaya baris hasil bisa langsung membuka form edit tanpa
  /// membaca ulang database.
  final Task task;

  /// Kategori hasil join; `null` saat task tidak berkategori.
  final Category? category;

  @override
  int get id => task.id;

  @override
  String get title => task.title;

  @override
  bool get isCompleted => task.isCompleted;

  @override
  int? get categoryId => task.categoryId;

  @override
  String? get categoryName => category?.name;

  @override
  CategoryColor? get categoryColor => category?.color;

  @override
  SearchResultType get type => SearchResultType.task;
}

/// Hasil dari tabel `habits`.
final class HabitSearchResult extends SearchResult {
  const HabitSearchResult({required this.habit, this.category});

  /// Baris habit utuh, supaya layar detail habit bisa dibuka apa adanya.
  final Habit habit;

  final Category? category;

  @override
  int get id => habit.id;

  @override
  String get title => habit.name;

  /// Habit tidak punya status selesai di barisnya sendiri (status hidup di
  /// `habit_logs` per tanggal), jadi selalu `false`.
  @override
  bool get isCompleted => false;

  @override
  int? get categoryId => habit.categoryId;

  @override
  String? get categoryName => category?.name;

  @override
  CategoryColor? get categoryColor => category?.color;

  @override
  SearchResultType get type => SearchResultType.habit;
}

/// Filter tunggal yang dipasang sebagai chip di board 26 bagian D.
///
/// Satu chip aktif pada satu waktu, sama seperti board: `Semua`, satu chip per
/// kategori, `Habit` (jenis), lalu `Selesai` (status).
sealed class SearchFilter {
  const SearchFilter();

  /// Semua item, tanpa penyaringan.
  static const SearchFilter all = SearchFilterAll();

  /// Hanya habit.
  static const SearchFilter habitsOnly = SearchFilterHabits();

  /// Hanya tugas yang sudah selesai.
  static const SearchFilter completedOnly = SearchFilterCompleted();

  /// Hanya item di satu kategori.
  factory SearchFilter.category(int categoryId) = SearchFilterCategory;
}

final class SearchFilterAll extends SearchFilter {
  const SearchFilterAll();

  @override
  bool operator ==(Object other) => other is SearchFilterAll;

  @override
  int get hashCode => (SearchFilterAll).hashCode;
}

final class SearchFilterCategory extends SearchFilter {
  const SearchFilterCategory(this.categoryId);

  final int categoryId;

  @override
  bool operator ==(Object other) =>
      other is SearchFilterCategory && other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(SearchFilterCategory, categoryId);
}

final class SearchFilterHabits extends SearchFilter {
  const SearchFilterHabits();

  @override
  bool operator ==(Object other) => other is SearchFilterHabits;

  @override
  int get hashCode => (SearchFilterHabits).hashCode;
}

final class SearchFilterCompleted extends SearchFilter {
  const SearchFilterCompleted();

  @override
  bool operator ==(Object other) => other is SearchFilterCompleted;

  @override
  int get hashCode => (SearchFilterCompleted).hashCode;
}

/// Pencarian lintas item: tugas dan habit dalam satu daftar.
///
/// Aturan pencocokan (board 26 bagian D):
/// - **query kosong / spasi saja → daftar kosong**, bukan seluruh data;
/// - tidak peduli besar-kecil huruf, dan **literal**: `%`, `_`, dan `\` dicari
///   sebagai karakter biasa, bukan wildcard atau escape (emoji ikut literal);
/// - tugas dicocokkan pada judul, lokasi, atau nama kategori; habit pada nama
///   atau nama kategori;
/// - tugas yang sudah selesai ikut tampil (board: `Baca jurnal · selesai 24 Okt`).
///
/// Catatan jujur soal huruf besar/kecil: `LIKE` bawaan SQLite hanya melipat
/// ASCII, jadi `KAFÉ` tidak akan menemukan `Kafé`. Untuk bahasa aplikasi ini
/// (Indonesia + Inggris) itu cukup; pengecualiannya dicatat di laporan T7.4.
class SearchRepository {
  SearchRepository(this._db);

  final AppDatabase _db;

  /// Karakter escape yang dipakai di klausa `LIKE ... ESCAPE`.
  static const String _escape = r'\';

  Future<List<SearchResult>> search(
    String query, {
    SearchFilter filter = SearchFilter.all,
  }) async {
    final needle = query.trim();
    if (needle.isEmpty) return const <SearchResult>[];

    final pattern = '%${escapeLike(needle)}%';
    final results = <SearchResult>[
      if (filter is! SearchFilterHabits)
        ...await _searchTasks(pattern, filter),
      // `Selesai` di board hanya bermakna untuk tugas: habit tidak menyimpan
      // status selesai di barisnya, jadi chip itu menyaring habit keluar.
      if (filter is! SearchFilterCompleted)
        ...await _searchHabits(pattern, filter),
    ];
    return _ordered(results, needle);
  }

  /// Melarutkan `%`, `_`, dan `\` supaya dicari sebagai karakter, bukan pola.
  ///
  /// Urutannya penting: garis miring dibalik lebih dulu, kalau tidak backslash
  /// yang baru ditambahkan untuk `%`/`_` ikut ter-escape dua kali.
  static String escapeLike(String value) {
    return value
        .replaceAll(_escape, '$_escape$_escape')
        .replaceAll('%', '$_escape%')
        .replaceAll('_', '${_escape}_');
  }

  Future<List<TaskSearchResult>> _searchTasks(
    String pattern,
    SearchFilter filter,
  ) async {
    final conditions = <String>[
      "(t.title LIKE ? ESCAPE '$_escape'"
      " OR IFNULL(t.location, '') LIKE ? ESCAPE '$_escape'"
      " OR IFNULL(c.name, '') LIKE ? ESCAPE '$_escape')",
    ];
    final variables = <Variable<Object>>[
      Variable.withString(pattern),
      Variable.withString(pattern),
      Variable.withString(pattern),
    ];

    switch (filter) {
      case SearchFilterCategory(:final categoryId):
        conditions.add('t.category_id = ?');
        variables.add(Variable.withInt(categoryId));
      case SearchFilterCompleted():
        conditions.add('t.is_completed = 1');
      case SearchFilterAll() || SearchFilterHabits():
        break;
    }

    // `readsFrom` sengaja tidak dipakai: `get()` sekali-jalan, bukan `watch()`,
    // jadi hasilnya tidak reaktif — layar Pencarian yang menyegarkan lewat
    // `invalidate`.
    final rows = await _db.customSelect(
      'SELECT t.id AS id FROM tasks t'
      ' LEFT JOIN categories c ON c.id = t.category_id'
      ' WHERE ${conditions.join(' AND ')}',
      variables: variables,
    ).get();
    if (rows.isEmpty) return const <TaskSearchResult>[];

    final ids = rows.map((row) => row.read<int>('id')).toList();
    // Dua langkah (id lalu baris utuh) supaya hasilnya memakai tipe tabel
    // Drift yang sebenarnya, bukan hasil rekonstruksi manual dari SQL mentah.
    final tasks = await (_db.select(_db.tasks)..where((t) => t.id.isIn(ids)))
        .get();
    final categories = await _categoriesFor(
      tasks.map((task) => task.categoryId),
    );

    return [
      for (final task in tasks)
        TaskSearchResult(
          task: task,
          category: task.categoryId == null
              ? null
              : categories[task.categoryId],
        ),
    ];
  }

  Future<List<HabitSearchResult>> _searchHabits(
    String pattern,
    SearchFilter filter,
  ) async {
    final conditions = <String>[
      "(h.name LIKE ? ESCAPE '$_escape'"
      " OR IFNULL(c.name, '') LIKE ? ESCAPE '$_escape')",
      // Habit non-aktif tidak tampil di layar mana pun, jadi tidak muncul juga
      // di hasil pencarian.
      'h.is_active = 1',
    ];
    final variables = <Variable<Object>>[
      Variable.withString(pattern),
      Variable.withString(pattern),
    ];

    switch (filter) {
      case SearchFilterCategory(:final categoryId):
        conditions.add('h.category_id = ?');
        variables.add(Variable.withInt(categoryId));
      case SearchFilterAll() || SearchFilterHabits() || SearchFilterCompleted():
        break;
    }

    // Sekali-jalan (`get()`, bukan `watch()`): tidak reaktif.
    final rows = await _db.customSelect(
      'SELECT h.id AS id FROM habits h'
      ' LEFT JOIN categories c ON c.id = h.category_id'
      ' WHERE ${conditions.join(' AND ')}',
      variables: variables,
    ).get();
    if (rows.isEmpty) return const <HabitSearchResult>[];

    final ids = rows.map((row) => row.read<int>('id')).toList();
    final habits = await (_db.select(_db.habits)..where((h) => h.id.isIn(ids)))
        .get();
    final categories = await _categoriesFor(
      habits.map((habit) => habit.categoryId),
    );

    return [
      for (final habit in habits)
        HabitSearchResult(
          habit: habit,
          category: habit.categoryId == null
              ? null
              : categories[habit.categoryId],
        ),
    ];
  }

  Future<Map<int, Category>> _categoriesFor(Iterable<int?> categoryIds) async {
    final ids = categoryIds.whereType<int>().toSet();
    if (ids.isEmpty) return const <int, Category>{};
    final rows =
        await (_db.select(_db.categories)..where((c) => c.id.isIn(ids))).get();
    return {for (final row in rows) row.id: row};
  }

  /// Urutan board 26: judul yang persis sama lebih dulu, lalu sisanya; saat
  /// seri tugas tampil sebelum habit, dan judul diurutkan tanpa peduli kapital.
  List<SearchResult> _ordered(List<SearchResult> results, String needle) {
    final lower = needle.toLowerCase();

    int exactRank(SearchResult result) =>
        result.title.toLowerCase() == lower ? 0 : 1;

    results.sort((a, b) {
      final byExact = exactRank(a) - exactRank(b);
      if (byExact != 0) return byExact;
      final byType = a.type.index - b.type.index;
      if (byType != 0) return byType;
      final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (byTitle != 0) return byTitle;
      return a.id.compareTo(b.id);
    });
    return results;
  }
}