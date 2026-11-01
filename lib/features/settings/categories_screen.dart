import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/category_palette.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/category_picker.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/list_row.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/category_providers.dart';
import '../../providers/repository_providers.dart';

/// Tombol tambah di header (lingkaran `primary-container`, pola board `02`).
const Key categoriesAddButtonKey = ValueKey('categories-add');

/// Key satu baris kategori.
Key categoryRowKey(int categoryId) => ValueKey('category-row-$categoryId');

/// Key tombol ubah dan hapus pada satu baris kategori.
Key categoryRenameButtonKey(int categoryId) =>
    ValueKey('category-rename-$categoryId');
Key categoryDeleteButtonKey(int categoryId) =>
    ValueKey('category-delete-$categoryId');

/// Key isi sheet kategori (tambah/ubah).
const Key categoryEditorSheetKey = ValueKey('category-editor');

/// Key field nama, tombol simpan, dan satu bulatan warna di sheet kategori.
const Key categoryNameFieldKey = ValueKey('category-name-field');
const Key categorySaveButtonKey = ValueKey('category-save');
Key categoryColorOptionKey(CategoryColor color) =>
    ValueKey('category-color-${color.name}');

/// Layar "Kelola kategori": daftar kategori + tambah/ubah/hapus.
///
/// Tidak ada board untuk layar ini (deviasi tercatat di laporan T7.3). Bentuknya
/// mengikuti konvensi yang sudah ada: `AppScaffold` + gutter 20, satu `AppCard`
/// berisi `ListRow` berdivider (sama dengan `08 Pengaturan`), aksi di header
/// berupa lingkaran `+` (sama dengan `02 Tasks`), dan `EmptyState` board `11`.
///
/// Hapus kategori **tidak** menghapus tugas/habit: `CategoryRepository` hanya
/// melepas referensinya, dan copy dialog menyatakan itu apa adanya.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  /// Gutter kiri/kanan — sama dengan `AppScaffold.gutter` dan semua layar lain.
  static const double gutter = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final categoriesAsync = ref.watch(categoriesProvider);

    return AppScaffold(
      title: l10n.categoriesScreenTitle,
      actions: [
        IconButton(
          key: categoriesAddButtonKey,
          icon: const Icon(Icons.add_rounded),
          tooltip: l10n.addCategoryTitle,
          style: IconButton.styleFrom(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.primary,
          ),
          onPressed: () => _openEditor(context, ref),
        ),
      ],
      body: categoriesAsync.when(
        data: (categories) => categories.isEmpty
            ? _emptyState(context, ref, l10n)
            : _list(context, ref, categories),
        loading: () => const Padding(
          padding: EdgeInsets.all(gutter),
          child: SkeletonList(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(gutter),
            child: ErrorState(
              title: l10n.stateErrorTitle,
              message: l10n.stateErrorMessage,
              retryLabel: l10n.stateRetryAction,
              onRetry: () => ref.invalidate(categoriesProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(gutter),
        child: EmptyState(
          title: l10n.categoryEmptyTitle,
          message: l10n.categoryEmptyBody,
          action: AppButton.primary(
            label: l10n.categoryEmptyAction,
            onPressed: () => _openEditor(context, ref),
          ),
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
  ) {
    return ListView(
      padding: const EdgeInsets.all(gutter),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < categories.length; i++)
                _CategoryRow(
                  category: categories[i],
                  showDivider: i < categories.length - 1,
                  onRename: () =>
                      _openEditor(context, ref, category: categories[i]),
                  onDelete: () => _confirmDelete(context, ref, categories[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) {
    final repo = ref.read(categoryRepositoryProvider);
    return showAppSheet<void>(
      context,
      child: _CategoryEditorSheet(
        category: category,
        onSubmit: (name, color) async {
          if (category == null) {
            await repo.createCategory(name, color);
            return;
          }
          // Dua jalur tulis terpisah di repository, jadi keduanya dipanggil di
          // sini: nama selalu, warna hanya kalau benar-benar diganti (supaya
          // rename tidak menulis ulang warna yang sama).
          await repo.renameCategory(category.id, name);
          if (color != category.color) {
            await repo.updateCategoryColor(category.id, color);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context,
      title: l10n.deleteCategoryTitle,
      content: Text(l10n.deleteCategoryBody),
      actions: [
        AppButton.ghost(
          label: l10n.cancelButton,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton.danger(
          label: l10n.deleteCategoryConfirm,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed != true) return;
    // Kegagalan hapus tidak boleh hilang tanpa jejak: dialog sudah tertutup,
    // jadi satu-satunya tempat melapor adalah snackbar.
    try {
      await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
    } catch (error) {
      debugPrint('deleteCategory failed: $error');
      if (!context.mounted) return;
      showAppSnackbar(
        context,
        AppLocalizations.of(context)!.categorySaveFailedMessage,
      );
    }
  }
}

/// Baris kategori: titik warna + nama, dengan aksi ubah dan hapus di kanan.
///
/// Barisnya sendiri tidak punya `onTap`: dua tombol eksplisit lebih jujur
/// daripada baris yang membuka salah satu aksi tanpa bisa ditebak. Kedua
/// `IconButton` memakai area 48×48 (`DESIGN.md` Layout), bukan ikon 20-nya.
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.showDivider,
    required this.onRename,
    required this.onDelete,
  });

  final Category category;
  final bool showDivider;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final actionStyle = IconButton.styleFrom(
      minimumSize: const Size(48, 48), // tap target
      padding: EdgeInsets.zero,
      foregroundColor: colors.inkMuted,
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    return ListRow(
      key: categoryRowKey(category.id),
      // Ukuran titik sama dengan chip picker (10dp): satu penanda, satu ukuran.
      leading: CategoryColorDot(color: category.color),
      title: category.name,
      showDivider: showDivider,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: categoryRenameButtonKey(category.id),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 20,
            tooltip: l10n.editCategoryTitle,
            style: actionStyle,
            onPressed: onRename,
          ),
          IconButton(
            key: categoryDeleteButtonKey(category.id),
            icon: const Icon(Icons.delete_outline_rounded),
            iconSize: 20,
            // Nama aksi, bukan judul pertanyaan dialognya.
            tooltip: l10n.deleteButton,
            style: actionStyle,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// Sheet tambah/ubah kategori: nama + pilihan warna.
///
/// Warna bisa dipilih di kedua mode. Saat mengubah, warna yang sekarang sudah
/// terpilih dan hanya ditulis ke database kalau pengguna memilih yang lain
/// (`updateCategoryColor`), jadi membuka sheet lalu menyimpan tanpa menyentuh
/// warna tidak menulis apa pun.
///
/// Galat repository tampil sebaris di bawah field dan sheet tetap terbuka, supaya
/// pengguna bisa membetulkan tanpa kehilangan ketikan. Tombol simpan selalu
/// hidup kembali lewat `finally`, apa pun jenis galatnya.
class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({required this.category, required this.onSubmit});

  /// Null = tambah kategori baru.
  final Category? category;

  final Future<void> Function(String name, CategoryColor color) onSubmit;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late CategoryColor _color;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.category != null;

  bool get _canSave =>
      !_saving && _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _color = widget.category?.color ?? CategoryColor.sage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Pesan galat repository dipetakan ke string l10n supaya tetap dua bahasa.
  ///
  /// **Jalan pintas:** repository masih melempar `ArgumentError` berisi pesan
  /// bahasa Inggris, jadi di sini dicocokkan teksnya. T13 sebaiknya menggantinya
  /// dengan tipe galat khusus (`DuplicateCategoryName`, dst.) supaya pencocokan
  /// string ini hilang. Galat yang bukan `ArgumentError` (mis. kegagalan DB)
  /// jatuh ke pesan umum — tidak ada pesan teknis yang bocor ke UI.
  String _messageFor(AppLocalizations l10n, Object error) {
    if (error is! ArgumentError) {
      return l10n.categorySaveFailedMessage;
    }
    final message = error.message?.toString() ?? '';
    if (message.contains('already exists')) {
      return l10n.categoryNameDuplicateError;
    }
    return message.isEmpty ? l10n.categorySaveFailedMessage : message;
  }

  Future<void> _submit() async {
    if (!_canSave) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSubmit(_nameController.text, _color);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      // Catch-all, bukan hanya `ArgumentError`: galat DB apa pun tetap harus
      // menghasilkan pesan, bukan tombol simpan yang mati selamanya.
      if (!mounted) return;
      setState(() => _error = _messageFor(AppLocalizations.of(context)!, error));
    } finally {
      // Satu-satunya tempat `_saving` kembali false: sukses (sheet ditutup),
      // gagal (pesan tampil, tombol hidup lagi), maupun galat tak terduga.
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final theme = Theme.of(context);
    final error = _error;

    return Padding(
      // Sheet sudah mengangkat diri setinggi keyboard (`showAppSheet`), jadi di
      // sini cukup padding konten.
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        key: categoryEditorSheetKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? l10n.editCategoryTitle : l10n.addCategoryTitle,
            style: theme.textTheme.headlineSmall?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.categoryNameLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            key: categoryNameFieldKey,
            controller: _nameController,
            hintText: l10n.categoryNameHint,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            // Mengetik harus menghidupkan/mematikan tombol simpan.
            onChanged: (_) => setState(() {}),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.danger),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            l10n.categoryColorLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          _ColorOptions(
            value: _color,
            onChanged: (color) => setState(() => _color = color),
          ),
          const SizedBox(height: 20),
          AppButton.primary(
            key: categorySaveButtonKey,
            label: l10n.saveCategoryLabel,
            expanded: true,
            onPressed: _canSave ? _submit : null,
          ),
        ],
      ),
    );
  }
}

/// Enam bulatan warna. Status terpilih ditandai cincin + centang, bukan warna
/// saja (`DESIGN.md` "Don't rely on color alone").
///
/// Tiap sasaran sentuh berukuran tetap 48×48 (`DESIGN.md` Layout) di dalam `Wrap`,
/// bukan `Expanded` enam arah: pada layar 320dp pembagian rata hanya menyisakan
/// ~46dp per bulatan, di bawah lantai tap target. `Wrap` membiarkan barisnya
/// turun ke baris kedua alih-alih mengecilkan sasarannya.
class _ColorOptions extends StatelessWidget {
  const _ColorOptions({required this.value, required this.onChanged});

  final CategoryColor value;
  final ValueChanged<CategoryColor> onChanged;

  /// Area sentuh per bulatan (tap target).
  static const double tapTarget = 48;

  /// Diameter bulatan visual.
  static const double dotSize = 28;

  /// Jarak antar bulatan (horizontal dan vertikal saat turun baris).
  static const double gap = 8;

  /// Nama warna per nilai enum, dua bahasa.
  static String colorName(AppLocalizations l10n, CategoryColor color) {
    return switch (color) {
      CategoryColor.sage => l10n.categoryColorSage,
      CategoryColor.honey => l10n.categoryColorHoney,
      CategoryColor.rose => l10n.categoryColorRose,
      CategoryColor.sky => l10n.categoryColorSky,
      CategoryColor.plum => l10n.categoryColorPlum,
      CategoryColor.sand => l10n.categoryColorSand,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final color in CategoryColor.values)
          Semantics(
            button: true,
            selected: value == color,
            // Bulatan warna tidak terbaca sebagai apa pun; namanya (Sage, Madu,
            // …) yang membuat pilihan ini bisa dibedakan dengan pembaca layar.
            label: colorName(l10n, color),
            excludeSemantics: true,
            child: SizedBox(
              width: tapTarget,
              height: tapTarget,
              child: InkWell(
                key: categoryColorOptionKey(color),
                onTap: () => onChanged(color),
                customBorder: const CircleBorder(),
                child: Center(
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: categoryColor(context, color),
                      border: Border.all(
                        color: value == color
                            ? colors.ink
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: value == color
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: colors.onPrimary,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}