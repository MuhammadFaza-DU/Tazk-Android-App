# Tazk v1 — Arsip

Isi folder ini adalah **Tazk versi 1**: design system lama, aset lama, dan dokumen lama.
Disimpan sebagai riwayat, **bukan** untuk dipakai lagi. Yang aktif sekarang adalah v2
di root project.

Diarsipkan: 2026-10-29

---

## Isi

| Path | Isi | Kenapa diarsipkan |
|---|---|---|
| `PRD-v1.md` | PRD asli (24 KB) | Acuan fitur v1; v2 akan punya PRD sendiri |
| `design-system/DESIGN-v1.md` | Design system lama ("Warna Alam") | Digantikan `DESIGN.md` v2 di root |
| `design-system/PRODUCT-v1.md` | Product doc lama | Digantikan `PRODUCT.md` v2 di root |
| `assets/fonts/` | SpicyRice, SourGummy, Unkempt (305 KB) | v2 memakai Fredoka + Plus Jakarta Sans |
| `assets/videos/` | `tazk_growth_splash.mp4` (1.9 MB) | v2 memakai maskot + wordmark, tanpa video |
| `docs/` | Audit, plan, spec era 2026-07-11 (44 KB) | Dokumen kerja v1 |
| `releases/` | *(kosong)* | APK v1.0.0–v1.1.5 dihapus, total 374 MB |

---

## Yang TIDAK diarsipkan (tetap di root, aktif untuk v2)

| Path | Alasan |
|---|---|
| `lib/`, `test/`, `android/` | Kode app yang masih jalan; dimigrasi bertahap ke v2 |
| `pubspec.yaml` dan config lain | Dibutuhkan agar project tetap bisa di-build |
| `DESIGN.md` | Design system v2 (kanonik) |
| `PRODUCT.md` | Product doc v2 |
| `design.pen` | Kanvas v2 (berisi 2.195 node, tersimpan lokal) |
| `assets/mascot/`, `assets/logo/` | Aset maskot otter v2 |
| `docs/design/` | Mockup & prompt aset v2 |
| `docs/superpowers/specs/2026-10-26-tazk-v2-upgrade-design.md` | Dokumen desain upgrade v2 |

---

## Dampak ke kode (sengaja dibiarkan, tidak crash)

Dua referensi di kode kini menunjuk aset yang sudah diarsipkan. Keduanya **sudah punya
jalur fallback**, jadi app tetap jalan:

1. **`lib/core/theme/app_typography.dart`** — mendeklarasikan `SpicyRice`, `SourGummy`,
   `Unkempt`. Font family yang tidak terdaftar di `pubspec.yaml` otomatis jatuh ke font
   sistem. App tetap render, hanya tampilan tipografi berubah sampai migrasi font v2.
2. **`lib/features/splash/splash_screen.dart`** — memuat `assets/videos/tazk_growth_splash.mp4`.
   `_initializeVideo()` membungkus pemuatan dalam `try/catch` dan langsung lanjut ke layar
   berikutnya kalau gagal. Diverifikasi lewat `flutter test`: splash tetap lolos.

Keduanya akan hilang saat migrasi Tahap 2 (design system) dan Tahap 3 (redesign layar).

**Verifikasi setelah pengarsipan:** `flutter pub get` OK, `dart analyze` tanpa issue,
`flutter test` 60/60 lulus.

---

## Perbedaan v1 → v2 (ringkas)

| Aspek | v1 | v2 |
|---|---|---|
| Judul | Spicy Rice | Fredoka |
| Body | Sour Gummy | Plus Jakarta Sans |
| Label | Unkempt | Plus Jakarta Sans |
| Primary (light) | `#2F6B3D` | `#4A5A44` |
| Accent | `#F0A83C` | `#D69A3C` |
| Background | `#FAF7F0` | `#F4F1EA` |
| Dark mode | forest generik | Dusk Forest (`#0F1A14`) |
| Maskot | tidak ada | Otter + tunas |
| Navigasi | drawer (☰) | tab bar 5 + sheet "Lainnya" |
| Splash | video pohon 1.9 MB | maskot + wordmark |

---

## Cara memulihkan

**Font** — kembalikan ke `assets/fonts/`, lalu tambahkan lagi di `pubspec.yaml`:

```yaml
  assets:
    - assets/fonts/

  fonts:
    - family: SpicyRice
      fonts:
        - asset: assets/fonts/SpicyRice-Regular.ttf
    - family: SourGummy
      fonts:
        - asset: assets/fonts/SourGummy-Regular.ttf
    - family: Unkempt
      fonts:
        - asset: assets/fonts/Unkempt-Regular.ttf
```

**Video splash** — kembalikan ke `assets/videos/`, tambahkan `- assets/videos/` ke
`assets:`. `splash_screen.dart` sudah menunjuk path itu, jadi tidak perlu ubah kode.

**Riwayat git** — semua file yang dipindah memakai `git mv`, jadi riwayatnya terlacak
sebagai rename:

```bash
git log --follow -- archive/v1/PRD-v1.md
```

**APK lama** — dihapus, tapi bisa di-build ulang dari tag stabil:

```bash
git tag
git checkout stable-2026-08-23-v3
flutter build apk --release
```
