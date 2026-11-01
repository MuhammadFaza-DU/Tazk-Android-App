import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/category_providers.dart';
import '../theme/app_colors.dart';
import '../theme/category_palette.dart';

/// Key pembungkus pilihan kategori (satu `Wrap` chip).
const Key categoryPickerKey = ValueKey('category-picker');

/// Key satu chip pilihan. `null` = chip "Tanpa kategori".
Key categoryPickerChipKey(int? categoryId) =>
    ValueKey('category-picker-chip-${categoryId ?? 'none'}');

/// Titik aksen kategori (10dp). Dipakai chip picker dan baris "Kelola kategori"
/// supaya penanda warna yang sama muncul di dua tempat.
///
/// Warnanya selalu dari [categoryColor] — bukan token `honey`/`clay` mentah —
/// jadi aman sebagai penanda sekecil apa pun di tema terang.
class CategoryColorDot extends StatelessWidget {
  const CategoryColorDot({super.key, required this.color, this.size = 10});

  final CategoryColor color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: categoryColor(context, color),
      ),
    );
  }
}

/// Pemilih satu kategori untuk Task Form dan Habit Form.
///
/// Bentuknya `Wrap` chip supaya nama kategori yang panjang turun ke baris
/// berikutnya alih-alih memotong satu baris yang bisa di-scroll. Pilihan
/// pertama selalu "Tanpa kategori" (`null`) — kategori bersifat opsional, jadi
/// membatalkan pilihan tidak boleh butuh gestur khusus.
///
/// Tidak ada board untuk kontrol ini (deviasi tercatat di laporan T7.3); bahannya
/// hanya token: terpilih = `primaryContainer` + garis aksen kategori, tidak
/// terpilih = `surface` + `border`.
class CategoryPicker extends ConsumerWidget {
  const CategoryPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Id kategori terpilih; `null` = tanpa kategori.
  final int? value;

  final ValueChanged<int?> onChanged;

  /// Jarak antar chip (horizontal dan vertikal).
  static const double gap = 8;

  /// Diameter titik aksen di dalam chip.
  static const double dotSize = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Tanpa kategori belum tentu termuat saat pertama dibuka: chip "Tanpa
    // kategori" tetap tampil supaya kontrolnya tidak berkedip kosong.
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];

    return Wrap(
      key: categoryPickerKey,
      spacing: gap,
      runSpacing: gap,
      children: [
        _CategoryChoiceChip(
          chipKey: categoryPickerChipKey(null),
          label: l10n.categoryNoneLabel,
          selected: value == null,
          accent: context.colors.primary,
          onTap: () => onChanged(null),
        ),
        for (final category in categories)
          _CategoryChoiceChip(
            chipKey: categoryPickerChipKey(category.id),
            label: category.name,
            selected: value == category.id,
            accent: categoryColor(context, category.color),
            dotColor: category.color,
            onTap: () => onChanged(category.id),
          ),
      ],
    );
  }
}

/// Chip pilihan tunggal. `ChoiceChip` dipakai (bukan `Container` buatan sendiri)
/// karena sudah membawa semantik terpilih untuk pembaca layar dan ripple tekan.
class _CategoryChoiceChip extends StatelessWidget {
  const _CategoryChoiceChip({
    required this.chipKey,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.dotColor,
  });

  /// Kunci dipasang di `ChoiceChip` (bukan di wrapper) supaya test bisa membaca
  /// status terpilih langsung dari widget chip-nya.
  final Key chipKey;

  final String label;
  final bool selected;

  /// Warna garis saat terpilih: token `primary` untuk "Tanpa kategori", aksen
  /// kategori untuk chip kategori.
  final Color accent;

  final CategoryColor? dotColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final dotColor = this.dotColor;

    return ChoiceChip(
      key: chipKey,
      selected: selected,
      onSelected: (_) => onTap(),
      // Centang bawaan menggeser label setiap kali memilih; status terpilih
      // sudah dibawa garis aksen + isian `primaryContainer`.
      showCheckmark: false,
      // Target sentuh 48dp (`DESIGN.md` Layout) walau chip visualnya lebih tipis.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      selectedColor: colors.primaryContainer,
      backgroundColor: colors.surface,
      side: BorderSide(
        color: selected ? accent : colors.border,
        width: selected ? 1.5 : 1,
      ),
      shape: const StadiumBorder(), // rounded.pill
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? colors.ink : colors.inkMuted,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            CategoryColorDot(color: dotColor, size: CategoryPicker.dotSize),
            const SizedBox(width: 6),
          ],
          // `Flexible` + ellipsis: nama kategori panjang memendek di dalam chip
          // selebar layar, bukan meluber keluar `Wrap`.
          Flexible(
            child: Text(
              label,
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