import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page_route.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/category_picker.dart' show CategoryColorDot;
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/search_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/category_providers.dart';
import '../../providers/search_providers.dart';
import '../habits/habit_detail_screen.dart';
import '../tasks/task_form_screen.dart';

/// Key kotak pencarian.
const Key searchFieldKey = ValueKey('search-field');

/// Key tombol hapus isi kotak pencarian.
const Key searchClearKey = ValueKey('search-clear');

/// Key daftar hasil.
const Key searchResultsKey = ValueKey('search-results');

/// Key state "belum mengetik".
const Key searchPromptKey = ValueKey('search-prompt');

/// Key state "tidak ada hasil".
const Key searchNoResultsKey = ValueKey('search-no-results');

/// Key satu chip filter. Ids: `all`, `category-<id>`, `habits`, `completed`.
Key searchFilterChipKey(String id) => ValueKey('search-filter-$id');

/// Key satu baris hasil.
Key searchResultRowKey(SearchResultType type, int id) =>
    ValueKey('search-result-${type.name}-$id');

/// Cari lintas item (tugas + habit) — board `26 Backup & Pencarian` bagian
/// **D — PENCARIAN & FILTER**.
///
/// Susunan dari board: kotak pencarian berpembesar di kiri dan `×` di kanan,
/// baris chip (`Semua` aktif berisi `primary`, chip lain bergaris), lalu daftar
/// hasil datar (bukan dikelompokkan per jenis) berisi baris ikon kecil di
/// `primary-container`, judul, sub-judul `type · kategori · waktu`, label jenis
/// di kanan, dan chevron.
///
/// Penyaringan berjalan saat mengetik dengan jeda 250 ms supaya tiap huruf tidak
/// memicu query sendiri. Yang ditunda hanya hasilnya: teks di kotak tetap
/// mengikuti ketikan apa adanya, jadi huruf pertama tidak pernah hilang.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  /// Jeda sebelum ketikan dijalankan sebagai query.
  static const Duration debounce = Duration(milliseconds: 250);

  /// Gutter layar (`spacing.lg`), sama dengan `AppScaffold.gutter`.
  static const double gutter = AppScaffold.gutter;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  /// Query yang sudah lolos jeda; hanya ini yang menghasilkan pencarian.
  String _query = '';
  SearchFilter _filter = SearchFilter.all;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    // Tombol `×` muncul/hilang mengikuti isi kotak, bukan mengikuti hasil.
    setState(() {});
    if (value.trim().isEmpty) {
      // Menghapus isi langsung mengembalikan state awal, tanpa jeda.
      _commit('');
      return;
    }
    _debounce = Timer(
      SearchScreen.debounce,
      () => _commit(_controller.text.trim()),
    );
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _query = '');
  }

  void _commit(String value) {
    if (!mounted || value == _query) return;
    setState(() => _query = value);
  }

  void _selectFilter(SearchFilter filter) {
    if (_filter == filter) return;
    setState(() => _filter = filter);
  }

  /// Membuka hasil, lalu **menyegarkan daftar** setelah layar tujuan ditutup.
  ///
  /// `searchResultsProvider` sekali-jalan (bukan stream), jadi tanpa
  /// invalidasi di sini baris hasil masih menampilkan judul lama setelah tugas
  /// diganti namanya di form.
  Future<void> _openResult(SearchResult result) async {
    final screen = switch (result) {
      TaskSearchResult(:final task) => TaskFormScreen(task: task),
      HabitSearchResult(:final habit) => HabitDetailScreen(habit: habit),
    };
    await Navigator.of(context).push(AppPageRoute(builder: (_) => screen));
    if (mounted) ref.invalidate(searchResultsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Kategori yang sedang dipilih bisa hilang (dihapus di layar lain). Tanpa
    // koreksi, chipnya lenyap dan hasilnya kosong tanpa sebab yang terlihat —
    // jadi filter kategori yang sudah tidak ada jatuh ke `all`.
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    if (categoriesAsync.hasValue) _filter = _resolveFilter(categories);
    final filter = _filter;

    return AppScaffold(
      title: l10n.searchScreenTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SearchScreen.gutter,
            ),
            // Satu sumber gaya input: `AppTextField` (radius `md`, isian
            // `surface`, garis `border`, fokus `primary`).
            child: AppTextField(
              key: searchFieldKey,
              controller: _controller,
              hintText: l10n.searchFieldHint,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              // Board `26` D: kaca pembesar di kiri.
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: colors.inkMuted,
              ),
              // `×` hanya saat kotak berisi; target sentuhnya tetap 48dp walau
              // ikonnya 20dp.
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      key: searchClearKey,
                      icon: const Icon(Icons.close_rounded),
                      iconSize: 20,
                      color: colors.inkMuted,
                      constraints:
                          const BoxConstraints(minWidth: 48, minHeight: 48),
                      tooltip: l10n.searchClearTooltip,
                      onPressed: _clear,
                    ),
            ),
          ),
          const SizedBox(height: 12), // spacing.md
          _FilterChips(filter: filter, onSelected: _selectFilter),
          const SizedBox(height: 12), // spacing.md
          Expanded(child: _results(l10n, filter)),
        ],
      ),
    );
  }

  /// Filter kategori hanya sah selama kategorinya masih ada.
  SearchFilter _resolveFilter(List<Category> categories) {
    final filter = _filter;
    if (filter is SearchFilterCategory &&
        !categories.any((category) => category.id == filter.categoryId)) {
      return SearchFilter.all;
    }
    return filter;
  }

  Widget _results(AppLocalizations l10n, SearchFilter filter) {
    final query = _query;
    if (query.isEmpty) return const _SearchPrompt();

    final request = (query: query, filter: filter);
    return ref.watch(searchResultsProvider(request)).when(
          loading: () => const Padding(
            padding: EdgeInsets.all(SearchScreen.gutter),
            child: SkeletonList(rows: 4),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(SearchScreen.gutter),
              child: ErrorState(
                title: l10n.stateErrorTitle,
                message: l10n.stateErrorMessage,
                retryLabel: l10n.stateRetryAction,
                onRetry: () => ref.invalidate(searchResultsProvider(request)),
              ),
            ),
          ),
          data: (results) => results.isEmpty
              ? _NoResults(query: query)
              : _ResultList(results: results, onTap: _openResult),
        );
  }
}

/// Baris chip filter: `Semua`, satu chip per kategori, `Habit`, `Selesai`.
///
/// Satu chip aktif pada satu waktu, sama seperti board. Dipakai `ChoiceChip`
/// karena sudah membawa semantik terpilih untuk pembaca layar dan ripple tekan.
class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.filter, required this.onSelected});

  final SearchFilter filter;
  final ValueChanged<SearchFilter> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Daftar kategori belum tentu termuat saat layar pertama dibuka; chip
    // inti (`Semua`/`Habit`/`Selesai`) tetap tampil supaya barisnya tidak
    // berkedip kosong.
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];

    _ChipSpec chip(
      String id,
      String label,
      SearchFilter value, {
      CategoryColor? dot,
    }) =>
        _ChipSpec(
          id: id,
          label: label,
          value: value,
          dot: dot,
          selected: filter == value,
        );

    final chips = <_ChipSpec>[
      chip('all', l10n.searchFilterAll, SearchFilter.all),
      for (final category in categories)
        chip(
          'category-${category.id}',
          category.name,
          SearchFilter.category(category.id),
          dot: category.color,
        ),
      chip('habits', l10n.searchFilterHabits, SearchFilter.habitsOnly),
      chip('completed', l10n.searchFilterCompleted, SearchFilter.completedOnly),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: SearchScreen.gutter),
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8), // spacing.sm
            _FilterChip(spec: chips[i], onSelected: onSelected),
          ],
        ],
      ),
    );
  }
}

/// Data satu chip (supaya daftarnya bisa disusun sebelum dirender).
class _ChipSpec {
  const _ChipSpec({
    required this.id,
    required this.label,
    required this.value,
    required this.selected,
    this.dot,
  });

  final String id;
  final String label;
  final SearchFilter value;
  final bool selected;
  final CategoryColor? dot;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.spec, required this.onSelected});

  final _ChipSpec spec;
  final ValueChanged<SearchFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final dot = spec.dot;

    return ChoiceChip(
      key: searchFilterChipKey(spec.id),
      selected: spec.selected,
      onSelected: (_) => onSelected(spec.value),
      // Centang bawaan menggeser label setiap kali memilih; status terpilih
      // sudah dibawa isian `primary` + label `on-primary` seperti board.
      showCheckmark: false,
      // Target sentuh 48dp (`DESIGN.md` Layout) walau chip visualnya lebih tipis.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      side: BorderSide(
        color: spec.selected ? colors.primary : colors.border,
      ),
      shape: const StadiumBorder(), // rounded.pill
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: spec.selected ? colors.onPrimary : colors.ink,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            // Titik aksen kategori, penanda yang sama dengan pemilih kategori.
            CategoryColorDot(color: dot),
            const SizedBox(width: 6),
          ],
          // Nama kategori panjang memendek di dalam chip, bukan meluber keluar.
          Flexible(
            child: Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// State awal: belum ada yang diketik. Sengaja ringan (bukan kartu maskot)
/// karena keyboard sudah terbuka dan mengisi separuh layar.
class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        key: searchPromptKey,
        padding: const EdgeInsets.symmetric(horizontal: 32), // spacing.2xl
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 32, color: colors.inkMuted),
            const SizedBox(height: 12), // spacing.md
            Text(
              l10n.searchPromptBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tidak ada yang cocok. Board tidak menggambar state ini, jadi dipakai pola
/// state kosong board `11` dan copy yang menyebut query-nya apa adanya.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SearchScreen.gutter),
        // `liveRegion` supaya pembaca layar mengumumkan hasil kosong saat
        // ketikan berubah, tanpa perlu pindah fokus dari kotak pencarian.
        child: Semantics(
          liveRegion: true,
          child: EmptyState(
            key: searchNoResultsKey,
            title: l10n.searchNoResultsTitle,
            message: l10n.searchNoResultsBody(query),
          ),
        ),
      ),
    );
  }
}

/// Daftar hasil datar (campur tugas + habit), dipisah garis `border`.
class _ResultList extends StatelessWidget {
  const _ResultList({required this.results, required this.onTap});

  final List<SearchResult> results;
  final ValueChanged<SearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SearchScreen.gutter,
        0,
        SearchScreen.gutter,
        SearchScreen.gutter,
      ),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          // Baris teratas/bawah ikut terpotong radius kartu, bukan menonjol.
          borderRadius: BorderRadius.circular(14), // rounded.md
          child: ListView.separated(
            key: searchResultsKey,
            padding: EdgeInsets.zero,
            itemCount: results.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: colors.border,
            ),
            itemBuilder: (context, index) => _ResultRow(
              result: results[index],
              onTap: () => onTap(results[index]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Satu baris hasil (board `26` D): kotak ikon 30dp `primary-container`,
/// judul `body`, sub-judul `caption` `ink-muted`, label jenis, chevron.
class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.onTap});

  final SearchResult result;
  final VoidCallback onTap;

  /// Kotak ikon board: 30×30dp, radius 8.
  static const double tileSize = 30;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = switch (result.type) {
      SearchResultType.task => l10n.searchTypeTask,
      SearchResultType.habit => l10n.searchTypeHabit,
    };

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: searchResultRowKey(result.type, result.id),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56), // tap target
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconFor(result),
                  size: 18,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12), // spacing.md
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(context, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // spacing.sm
              Text(
                typeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.inkMuted,
                ),
              ),
              const SizedBox(width: 4), // spacing.xs
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ikon mengikuti board: habit → buku, tugas belum selesai → checklist,
  /// tugas selesai → pembatas buku.
  static IconData _iconFor(SearchResult result) => switch (result) {
        HabitSearchResult() => Icons.menu_book_rounded,
        TaskSearchResult() when result.isCompleted => Icons.bookmark_rounded,
        TaskSearchResult() => Icons.checklist_rounded,
      };

  /// `Habit · Harian` / `Task · Kuliah · 20:00` / `Task · selesai 24 Okt`
  /// (bentuk board, tanpa emoji).
  String _subtitle(BuildContext context, AppLocalizations l10n) {
    final parts = <String>[
      switch (result.type) {
        SearchResultType.task => l10n.searchTypeTask,
        SearchResultType.habit => l10n.searchTypeHabit,
      },
    ];

    final categoryName = result.categoryName;
    if (categoryName != null && categoryName.isNotEmpty) {
      parts.add(categoryName);
    }

    switch (result) {
      case TaskSearchResult(:final task):
        final time = task.time;
        if (task.isCompleted) {
          parts.add('${l10n.searchCompletedLabel} ${_shortDate(context, task.date)}');
        } else if (time != null) {
          parts.add(TimeOfDay.fromDateTime(time).format(context));
        }
      case HabitSearchResult(:final habit):
        // Streak habit tidak ditampilkan: `habitStreakDays` di `habits_screen`
        // ditandai `@visibleForTesting`, jadi memakainya dari sini akan
        // menghasilkan peringatan analyzer. Penggantinya jadwal frekuensi
        // (bentuk yang diizinkan brief: `Habit` + jadwal).
        parts.add(habit.frequency.label(context));
    }

    return parts.join(' · ');
  }

  /// "24 Okt" mengikuti bahasa aktif, dengan cadangan `en` seperti layar lain.
  static String _shortDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    try {
      return DateFormat('d MMM', locale).format(date);
    } catch (_) {
      return DateFormat('d MMM', 'en').format(date);
    }
  }
}