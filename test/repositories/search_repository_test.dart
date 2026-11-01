import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tazk/data/database/database.dart';
import 'package:tazk/data/models/enums.dart';
import 'package:tazk/data/repositories/search_repository.dart';

/// Uji T7.4: pencarian lintas item (tugas + habit).
///
/// Semua uji memakai database Drift in-memory sungguhan
/// (`AppDatabase.forTesting(NativeDatabase.memory())`), jadi yang dibuktikan
/// adalah data yang benar-benar tersimpan, bukan tiruan repository.
void main() {
  late AppDatabase db;
  late SearchRepository search;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    search = SearchRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> category(String name) {
    return db.into(db.categories).insert(
          CategoriesCompanion.insert(
            name: name,
            color: CategoryColor.sage,
          ),
        );
  }

  Future<int> task({
    required String title,
    String? location,
    int? categoryId,
    bool isCompleted = false,
    DateTime? time,
    DateTime? date,
  }) {
    return db.into(db.tasks).insert(
          TasksCompanion.insert(
            title: title,
            date: date ?? DateTime(2026, 10, 24),
            priority: TaskPriority.medium,
            time: Value(time),
            location: Value(location),
            categoryId: Value(categoryId),
            isCompleted: Value(isCompleted),
          ),
        );
  }

  Future<int> habit({
    required String name,
    int? categoryId,
    bool isActive = true,
  }) {
    return db.into(db.habits).insert(
          HabitsCompanion.insert(
            name: name,
            frequency: HabitFrequency.daily,
            categoryId: Value(categoryId),
            isActive: Value(isActive),
          ),
        );
  }

  List<String> titlesOf(List<SearchResult> results) =>
      results.map((result) => result.title).toList();

  group('query kosong', () {
    test('query kosong mengembalikan daftar kosong, bukan semua data', () async {
      await task(title: 'Baca buku');
      await habit(name: 'Baca jurnal');

      expect(await search.search(''), isEmpty);
    });

    test('query spasi saja juga kosong', () async {
      await task(title: 'Baca buku');

      expect(await search.search('   \t '), isEmpty);
    });

    test('query kosong tidak menyentuh database sama sekali', () async {
      // Database ditutup lebih dulu: kalau `search()` masih menjalankan query,
      // panggilan ini akan melempar, bukan mengembalikan daftar kosong.
      final closed = AppDatabase.forTesting(NativeDatabase.memory());
      await closed.close();
      final repository = SearchRepository(closed);

      expect(await repository.search(''), isEmpty);
      expect(await repository.search('   \t '), isEmpty);
    });

    test('query di-trim sebelum dicocokkan', () async {
      await task(title: 'Baca buku');

      final results = await search.search('  baca  ');

      expect(titlesOf(results), ['Baca buku']);
    });
  });

  group('sumber kecocokan', () {
    test('cocok pada judul task, tanpa peduli besar-kecil huruf', () async {
      await task(title: 'Baca buku');

      expect(titlesOf(await search.search('BACA')), ['Baca buku']);
    });

    test('cocok pada lokasi task', () async {
      await task(title: 'Revisi laporan', location: 'Perpustakaan Kampus');

      final results = await search.search('perpustakaan');

      expect(titlesOf(results), ['Revisi laporan']);
      expect(results.single, isA<TaskSearchResult>());
    });

    test('cocok pada nama kategori milik task', () async {
      final kuliah = await category('Kuliah');
      await task(title: 'Revisi laporan', categoryId: kuliah);

      final results = await search.search('kuliah');

      expect(titlesOf(results), ['Revisi laporan']);
      expect(results.single.categoryName, 'Kuliah');
    });

    test('cocok pada nama habit dan kategorinya', () async {
      final kuliah = await category('Kuliah');
      await habit(name: 'Baca buku');
      await habit(name: 'Review catatan', categoryId: kuliah);

      expect(titlesOf(await search.search('baca')), ['Baca buku']);

      final byCategory = await search.search('kuliah');
      expect(titlesOf(byCategory), ['Review catatan']);
      expect(byCategory.single.type, SearchResultType.habit);
    });

    test('task yang sudah selesai tetap ikut (board 26)', () async {
      await task(
        title: 'Baca jurnal',
        isCompleted: true,
        date: DateTime(2026, 10, 24),
      );

      final results = await search.search('baca');

      expect(titlesOf(results), ['Baca jurnal']);
      expect(results.single.isCompleted, isTrue);
    });

    test('habit non-aktif tidak muncul', () async {
      await habit(name: 'Baca koran', isActive: false);

      expect(await search.search('baca'), isEmpty);
    });
  });

  group('pencocokan literal', () {
    test('`%` dicari sebagai karakter, bukan wildcard', () async {
      await task(title: 'Diskon 50%');
      await task(title: 'Diskon 50 ribuan');

      final results = await search.search('%');

      expect(titlesOf(results), ['Diskon 50%']);
    });

    test('`_` dicari sebagai karakter, bukan satu huruf apa pun', () async {
      await task(title: 'Baca_buku');
      await task(title: 'Bacaxbuku');

      final results = await search.search('baca_b');

      expect(titlesOf(results), ['Baca_buku']);
    });

    test(r'\ dicari sebagai karakter, bukan escape', () async {
      await task(title: r'Folder C:\Users');
      await task(title: 'Folder CDUsers');

      final results = await search.search(r'C:\U');

      expect(titlesOf(results), [r'Folder C:\Users']);
    });

    test('emoji diperlakukan literal', () async {
      await task(title: 'Rapat 🌟');
      await task(title: 'Rapat harian');

      expect(titlesOf(await search.search('🌟')), ['Rapat 🌟']);
    });

    test('kata dengan `%` dan `_` sekaligus tetap aman', () async {
      await task(title: 'Laporan 20%_final');
      await task(title: 'Laporan 20 persen final');

      final results = await search.search('20%_f');

      expect(titlesOf(results), ['Laporan 20%_final']);
    });
  });

  group('filter', () {
    late int kuliah;
    late int pribadi;

    setUp(() async {
      kuliah = await category('Kuliah');
      pribadi = await category('Pribadi');
    });

    test('filter kategori hanya menyisakan satu kategori', () async {
      await task(title: 'Baca bab 3', categoryId: kuliah);
      await task(title: 'Baca novel', categoryId: pribadi);
      await habit(name: 'Baca buku', categoryId: kuliah);

      final results = await search.search(
        'baca',
        filter: SearchFilter.category(kuliah),
      );

      expect(titlesOf(results), containsAll(['Baca bab 3', 'Baca buku']));
      expect(titlesOf(results), isNot(contains('Baca novel')));
    });

    test('filter habit hanya menyisakan habit', () async {
      await task(title: 'Baca bab 3', categoryId: kuliah);
      await habit(name: 'Baca buku', categoryId: kuliah);

      final results = await search.search('baca', filter: SearchFilter.habitsOnly);

      expect(results, hasLength(1));
      expect(results.single.type, SearchResultType.habit);
    });

    test('filter selesai hanya menyisakan task yang sudah selesai', () async {
      await task(title: 'Baca bab 3');
      await task(title: 'Baca jurnal', isCompleted: true);
      await habit(name: 'Baca buku');

      final results =
          await search.search('baca', filter: SearchFilter.completedOnly);

      expect(titlesOf(results), ['Baca jurnal']);
      expect(results.single.isCompleted, isTrue);
    });

    test('filter semua mengembalikan tugas dan habit', () async {
      await task(title: 'Baca bab 3');
      await habit(name: 'Baca buku');

      final results = await search.search('baca');

      expect(results.map((result) => result.type).toSet(), {
        SearchResultType.task,
        SearchResultType.habit,
      });
    });
  });

  group('urutan', () {
    test('judul yang persis sama tampil lebih dulu', () async {
      await habit(name: 'Baca buku');
      await task(title: 'Baca');

      final results = await search.search('baca');

      expect(results.first.title, 'Baca');
    });

    test('saat seri, tugas tampil sebelum habit', () async {
      await habit(name: 'Baca buku');
      await task(title: 'Baca buku');

      final results = await search.search('baca buku');

      expect(results.map((result) => result.type).toList(), [
        SearchResultType.task,
        SearchResultType.habit,
      ]);
    });

    test('tanpa kecocokan mengembalikan daftar kosong', () async {
      await task(title: 'Baca buku');

      expect(await search.search('zzz'), isEmpty);
    });
  });

  group('data hasil', () {
    test('hasil task membawa baris task lengkap untuk membuka form', () async {
      final kuliah = await category('Kuliah');
      await task(
        title: 'Baca bab 3',
        categoryId: kuliah,
        time: DateTime(2026, 10, 24, 20),
      );

      final result = (await search.search('baca')).single as TaskSearchResult;

      expect(result.task.title, 'Baca bab 3');
      expect(result.task.time, DateTime(2026, 10, 24, 20));
      expect(result.category?.name, 'Kuliah');
      expect(result.categoryId, kuliah);
      expect(result.categoryColor, CategoryColor.sage);
    });

    test('hasil habit membawa baris habit lengkap untuk membuka detail', () async {
      final kuliah = await category('Kuliah');
      await habit(name: 'Baca buku', categoryId: kuliah);

      final result = (await search.search('baca')).single as HabitSearchResult;

      expect(result.habit.name, 'Baca buku');
      expect(result.habit.frequency, HabitFrequency.daily);
      expect(result.categoryName, 'Kuliah');
    });
  });
}