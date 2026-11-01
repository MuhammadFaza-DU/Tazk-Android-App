import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/search_repository.dart';
import 'database_provider.dart';

/// Akses data pencarian lintas item.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(appDatabaseProvider));
});

/// Satu permintaan pencarian: teks yang sudah di-debounce + filter aktif.
///
/// Record dipakai (bukan kelas) karena perbandingannya struktural: permintaan
/// yang sama persis tidak memicu query baru, dan yang berubah memicu query baru.
typedef SearchRequest = ({String query, SearchFilter filter});

/// Hasil pencarian untuk satu [SearchRequest].
///
/// `autoDispose` supaya hasil lama tidak menumpuk di memori setelah layar
/// Pencarian ditutup. Query kosong tidak menyentuh database sama sekali.
final searchResultsProvider =
    FutureProvider.autoDispose.family<List<SearchResult>, SearchRequest>(
  (ref, request) {
    if (request.query.trim().isEmpty) {
      return Future.value(const <SearchResult>[]);
    }
    return ref
        .watch(searchRepositoryProvider)
        .search(request.query, filter: request.filter);
  },
);