# Tazk — Posisi Sekarang

Dokumen penanda posisi kerja. Baca ini dulu sebelum melanjutkan, supaya tidak
mengulang keputusan yang sudah diambil atau mengerjakan hal yang sudah selesai.

Terakhir diperbarui: **2026-10-31**

## Log Perubahan (terbaru duluan)

- 2026-10-31 — **Percobaan ubah token hijau dark DIBATALKAN (G1-revert)**: perubahan `primary`/`success` dark `#8FE0A9` → `#78C994` (commit `1a9c37c`, tag `v6`) **di-revert**. Alasan: owner menunjuk **kartu Level di layar Home** (latar hijau kartu + kuning XP/pil di dalamnya) yang terasa terlalu terang di tema gelap — bukan token hijau global. Token dark kembali `#8FE0A9`, `DESIGN.md` + `app_theme_test` ikut kembali, dan **kanvas `design.pen` sinkron lagi** (tidak perlu ubah Pen). Masalah aslinya dicatat sebagai **isu terbuka no. 13** + gambar kandidat warna disimpan sebagai `docs/artifacts/warna-kartu-level-dark-kandidat.png` untuk dikerjakan lain waktu — *(commit ini)*

- 2026-10-31 — **Bug tambahan dari verifikasi HP (W7)**: sheet "Atur durasi" Pomodoro **tertutup keyboard numerik** sehingga tombol Simpan tidak bisa dijangkau (terpotret: `hp-05-pomodoro-sheet-keyboard-sebelum.png`). `showAppSheet` tidak menambahkan inset keyboard; sekarang mengangkat konten setinggi `viewInsets.bottom` (optik sama saat keyboard tertutup, jadi sheet lain tidak berubah). Test regresi `app_sheet_keyboard_test` sudah divalidasi **merah tanpa fix** lalu hijau. **344 test, analyze 0**, APK arm64 32.6 MB di-install & diverifikasi ulang di HP — *(belum commit)*

- 2026-10-31 — **Batch perbaikan dari uji HP (W1–W6) terverifikasi di HP** (foto di `docs/artifacts/hp-*`): Habits "100%" muat + teks English benar; Tentang "Version 2.0.0" + 2 baris + footer; Profil badge 3 kolom rapi; CTA Home **155 px = 59 dp** (terukur `uiautomator`); Statistik Bulan 30 batang **7,35 dp** dengan label 2/7/12/17/22/27, Tahun 12 inisial bulan (J…D) dengan batang bulan berjalan honey; Pomodoro caption "Ready to focus" + ketuk angka → sheet → **90:00**; tekan lama chip → sheet "Edit duration chip": (1) **chart Bulan rusak** — `barGap` dipatok 10 dp membuat batang 30-bucket jadi **0,87 dp** (garis rambut); sekarang gap adaptif (`resolveBarGap`), Minggu tetap 36,57 dp, Bulan 7,35 dp, Tahun 18,79 dp, label sejajar pusat batang (sebelumnya meleset ~4 dp) dan Tahun menampilkan 12 inisial bulan. (2) **CTA Home 48 → 59 dp** (board 01) + label 15/padding 23; `AppButton` dapat parameter opsional `height`/`padding`/`labelStyle`. (3) **Habits "100%" meluber** dari lingkaran 54 dp (lebar teks 54 → 42 dp setelah `FittedBox`) + teks kartu ringkasan dipindah ke l10n (sebelumnya hardcode Indonesia di UI English). (4) **Tentang**: versi `1.1.5+4` → **`2.0.0+5`**, + baris Kebijakan privasi (dialog) + Lisensi open source (`showLicensePage`) + footer; "Beri rating"/"Kirim masukan" sengaja absen (belum ada tujuan nyata). (5) **Profil**: Koleksi Badge 6 → **3 kolom** (pilihan owner), tile 51,67 → 111,33 dp, area label 2 baris supaya sejajar. (6) **Pomodoro**: ketuk angka waktu → sheet durasi 1–180 menit, 4 chip bisa diubah via long-press (nilai chip hanya bertahan selama app hidup, **tidak** disimpan), caption status "Siap fokus/Fokus berjalan/Dijeda" (board 05); bonus fix durasi ≥60 menit yang sebelumnya tampil salah (90 → "30:00", sekarang "90:00"). **343 test hijau, analyze 0.** Deviasi dicatat: baris Tentang 56 dp (board 42, di bawah tap target 48), badge 3 kolom (board 6), ikon pensil di timer (affordance) — *(belum commit)*

- 2026-10-31 — **T5 Statistik & Insight tuntas (T5-A..D) + verifikasi HP**: schema **v4** (`focus_sessions` + `xp_events`, 2 index, migrasi v3→v4 terbukti di perangkat nyata), titik tulis XP & sesi fokus, `StatsRepository` (completion rate + delta, menit fokus + delta, XP per bucket net, heatmap 13×7, insight 90 hari), 5 provider, layar Statistik + segmented Minggu/Bulan/Tahun (`BarChart` + `HabitHeatmap` via `CustomPainter`, tanpa dependency baru), entri "Statistik" di sheet "Lainnya" (4 item). **Tanpa angka palsu**: empty state per periode, `–` bila metrik belum punya data. **2 bug data-asli ditemukan & diperbaiki** (kartu tersembunyi saat hanya ada data habit; "0 XP" vs "Belum ada XP"). 306 test hijau, analyze 0, APK arm64 32.3 MB terpasang & dipotret di Galaxy A52 (light+dark). Bukti: `docs/artifacts/` — *(belum commit)*

- 2026-10-31 — **Checkpoint `stable-2026-10-31-v1`**: fidelity 15 board tuntas + ikon otter final + gutter 20dp + i18n Habit Detail. Rencana T5 (jalur A: schema v4 `focus_sessions`+`xp_events`) ditulis di ledger — *(commit ini)*

- 2026-10-31 — **Fidelity batch 4** (Onboarding, Task Form, Habit Form, Habit Detail, Celebration, Tentang) + **gutter diseragamkan 20dp** (board) + ikon launcher final otter terpasang (adaptive + notifikasi). 255 test hijau — *(commit ini)*
- 2026-10-31 — **Audit fidelity kanvas** (gerbang AGENTS §11) batch 1–3: Splash, States, Home, tab bar floating, Tasks, Habits, Kalender, Pomodoro, Profil, Pengaturan, AppScaffold back-bulat dibangun ulang dari board `design-export/` (diukur piksel). Video v1 dihapus. Fix Gradle `splits` vs `abiFilters`. 199 test hijau — *(commit ini)*

- 2026-10-31 — Verifikasi visual HP (Galaxy A52, 24 screenshot) + fix bug: FAB menutupi baris terakhir (Habits), plural "1 days", kalimat dialog hapus (ICU apostrophe), tombol Delete jadi `danger`, XP bar Profile disamakan (AnimatedXpProgress). **Aturan baru AGENTS §11: gerbang fidelity kanvas.** 60fps terukur (0 jank/126 frame) — *(commit ini)*

- 2026-10-31 — T4 Motion tuntas: token motion di kode (`AppMotion` + `context.reduceMotion`) + `AppPageRoute`; press scale 0.97; checkbox pop/confetti reduced-motion; XP glow composite-only; celebration `repeat()`→one-shot; progress fill `Transform.scale`; sheet/dialog motion; badge shine sweep; entrance EmptyState/Onboarding; splash sway tergerbangi — commit `714d14d` (+ `dfd17b8`, `ec348dc`), 111/111 test

- 2026-10-30 — T3 tuntas: app shell (tab bar 5 + sheet "Lainnya", tanpa drawer) + redesign 12 layar ke design system v2 + migrasi shared-widget (0 `AppColors.*` deprecated tersisa) — commit `622801a` (+ batch 38d4328, 7e0a744)
- 2026-10-30 — T2-B: widget kit 12 komponen + preview dev-only — commit `5989955`
- 2026-10-30 — T2-A: font Fredoka+PJS + 19 token ThemeExtension + ColorScheme eksplisit — commit `69587d2`
- 2026-10-30 — T1 Performa tuntas (batch 2): checkbox tulis DB langsung (buang delay 380ms) + home lazy sliver & satu query log habit — commit `9cc313e`
- 2026-10-30 — T1 Performa (batch 1): coalesce + gate push widget, pomodoro label-only rebuild, startup non-blocking + rollover 1×/hari, splash decouple video, minify+shrink+split ABI (176→~30 MB/ABI) — commit `7e902bc`
- 2026-10-30 — T1-A: 4 index DB + migrasi schema v3 — commit `bfbdd72`
- 2026-10-30 — Menambah file aturan project `AGENTS.md` (root) + section log ini (mekanisme "selalu update STATUS.md") — commit `06d48a9`
- 2026-10-30 — Menambah `PRD-v2.md` (scope & requirement v2, disetujui owner) — commit `65afac8`
- 2026-10-30 — Perketat §2 `AGENTS.md`: wajib *Skill Plan* (announce di awal) + matriks skill per jenis task + *Skill Report* di akhir — commit `707c283`

---

## Ringkas satu paragraf

Tazk sedang diupgrade dari v1 ke v2. **Fase desain selesai**. **T1 Performa selesai** (8/8),
**T2 design system selesai** (font, 19 token, ColorScheme, widget kit 12), **T3 redesign
layar selesai** (tab bar 5 + sheet "Lainnya" tanpa drawer, 12 layar pakai widget kit + token),
**T4 motion selesai** (token motion di kode, tanpa `easeIn`/`scale(0)`/ticker idle,
reduced-motion dihormati di semua animasi), dan **T5 statistik selesai** (schema v4
`focus_sessions` + `xp_events`, query agregat, layar Statistik dengan chart + heatmap,
tanpa angka palsu). Fase berikutnya: **T6 — subtask & lokasi**.

---

## Posisi git

| Item | Nilai |
|---|---|
| Branch | `main` |
| Commit terakhir | jalankan `git log -1` — dokumen ini di-commit sesudahnya, jadi hash di teks akan selalu tertinggal satu |
| Commit terakhir yang tercatat saat dokumen ditulis | `8627cf7` — fix(canvas): tengahkan sheet grab handle + jadikan komponen |
| Tag stabil terakhir | `stable-2026-10-30-v2` (lihat `git tag \| Select-String stable` untuk yang terbaru) |
| Status push | **7 commit belum di-push** ke `origin` (GitHub) — sengaja, atas permintaan owner |
| Working tree | bersih |

> Catatan: hash commit dan jumlah commit di dokumen ini **selalu tertinggal satu** dari
> kenyataan, karena commit yang menulis dokumen ini mengubah keduanya. Kalau butuh angka
> pasti, jalankan `git log -1` dan `git log --oneline origin/main..HEAD | Measure-Object`.

Tag stabil sebelumnya: `stable-2026-10-30-v1`, `stable-2026-10-29-v1`, `stable-2026-10-29-v2`, `stable-2026-10-26-v1`, `stable-2026-08-23-v1..v3`

**Riwayat commit sesi ini (lokal, belum di-push).** Tabel ini berhenti di commit sebelum dokumen ditulis; commit dokumentasi sesudahnya tidak tercantum.

| Commit | Isi |
|---|---|
| `8627cf7` | Tengahkan sheet grab handle + jadikan komponen `Sheet/Handle` |
| `b1ed785` | Commit perbaikan `warning-strong` di kanvas yang tertinggal |
| `8b281b5` | Tambah `docs/STATUS.md` + pecah token `on-primary` / `on-primary-muted` |
| `04fa0df` | Arsipkan v1 ke `archive/v1/` + `DESIGN.md` v2 + perbaikan kontras |
| `07fbe14` | Maskot otter + prompt aset + design system v2 di kanvas |
| `9aa7c7c` | Dokumen desain upgrade v2 + mockup 3 arah visual |

---

## Yang sudah selesai

### Fase desain (kanvas `design.pen`)

**27 board**, 2.145 node, 0 placeholder tersisa, **18 komponen reusable** (31 token):

| Kelompok | Board |
|---|---|
| Fondasi | Foundations (31 token), Components, Library, Dark Preview |
| Layar utama | 01 Home, 01b Home-Sheet, 12 Home-Dark, 02 Tasks, 03 Habits, 04 Kalender, 05 Pomodoro |
| Layar sekunder | 06 Profil, 07 Statistik, 08 Pengaturan, 09 Onboarding, 10 Task Form, 24 Habit Form, 25 Habit Detail |
| Pelengkap | 11 States, 15 Navigation Map, 16 App Icon, 20 Widgets, 21 Notifikasi, 22 Splash, 23 Tentang, 26 Backup & Pencarian, 27 Celebration |

**Perbaikan kanvas terakhir (2026-10-30):**
- **Sheet grab handle ditengahkan.** Sebelumnya meleset 18px (= persis padding kiri sheet): handle center 177 vs sheet center 195. Sekarang **center 195 = 195, selisih 0**.
- Dijadikan **komponen reusable `Sheet/Handle`** (40×4, radius pill), bukan node lepas.
- Anak lain sheet (judul + 4 item) tidak tersentuh, tetap rata kiri.

**Design system final:**
- Palet: **Sage & Sand** (light) / **Dusk Forest** (dark)
- Font: **Fredoka** (judul) + **Plus Jakarta Sans** (body/UI)
- Maskot: **otter** 3D clay dengan tunas
- Navigasi: tab bar 5 (Home · Tasks · Habits · Kalender · Lainnya) + sheet "Lainnya"

### Dokumen

| File | Isi |
|---|---|
| `DESIGN.md` | Design system kanonik, format DESIGN.md spec v0.4.0. 19 warna, 6 skala tipografi, 5 radius, 7 spacing, 13 komponen. Lint **0 error**, export dtcg exit 0 |
| `PRODUCT.md` | Product doc v2 |
| `PRD-v2.md` | PRD v2 — scope & requirement v2 (disetujui owner) |
| `docs/STATUS.md` | Dokumen ini |
| `docs/superpowers/specs/2026-10-26-tazk-v2-upgrade-design.md` | Rencana upgrade lengkap 16 tahap |
| `docs/design/2026-10-26-arahan-visual.html` | Mockup 3 arah visual awal |
| `docs/design/ikon-logo-prompts.md` | Prompt generate aset (sudah dipakai, hasilnya di `assets/mascot/`) |
| `archive/v1/README.md` | Dokumentasi arsip v1 + cara restore |

### Arsip v1

Semua di `archive/v1/` (pakai `git mv`, riwayat terjaga): PRD v1, design system v1,
font lama (SpicyRice/SourGummy/Unkempt), video splash 1.9 MB, dokumen 2026-07-11.
APK lama (374 MB) dihapus, bisa di-build ulang dari tag.

### Perbaikan kontras (4 putaran)

Semua terverifikasi dengan `contrast-check.py`, bukan perkiraan:

| Bug | Sebelum | Sesudah |
|---|---|---|
| `primary-soft` sbg teks di `primary` (3 tempat) | 1.70:1 ❌ | `#DDE3D6` 5.65:1 ✅ |
| Label hari aktif di widget Calendar | 1.70:1 ❌ | `#DDE3D6` 5.65:1 ✅ |
| `warning` sbg teks di `honey-container` (10 node) | 2.95:1 ❌ | `warning-strong` 4.73:1 ✅ |
| Tabel dark `on-primary-muted` = sama dgn `primary` (tak terlihat) | — | `#20362A` 8.26:1 ✅ |

Token baru: **`warning-strong`** = `#8A5A12` (light) / `#EBCB7E` (dark).
Token dipecah: **`on-primary`** `#FBF9F4` (teks utama) + **`on-primary-muted`** `#DDE3D6` (label sekunder).

---

## T5 — fidelity board 07 Statistik

Board acuan: `design-export/07 Statistik.png` (780×1492 px @2x → **390×746 dp**), diukur
piksel-per-piksel (bukan diperkirakan). Render pembanding:
`docs/artifacts/07-statistik-render.png` (widget test, font asli, 780×1492 px).
Angka "implementasi" di bawah diambil dari `tester.getRect` pada render itu.

| Elemen | Board (dp) | Implementasi (dp) | Selisih / alasan |
|---|---|---|---|
| Header: lingkaran back + judul | Ø36, cap 18 | Ø40, Fredoka 24 | `AppScaffold` existing — sudah diterima di audit batch 1 (board 06 identik) |
| Gutter kiri/kanan | 19.5–20 | 20 | 0 |
| Segmented: lebar / tinggi visual | 350 / 39 | 350 / 39 | 0 |
| Segmented: padding dalam | 4.5 | 4 | −0.5 |
| Segmented: tap target | (tidak diukur) | **48** | +9 vs visual 39 → a11y wajib ≥48 dp (deviasi disengaja) |
| Segmented: label | 13 | 13 (`labelLarge`) | 0 |
| Jarak segmented → kartu | 16 | 16 | 0 |
| Kartu stat: lebar / gap | 171 / 9.5 | 171 / 8 | gap −1.5 (token `spacing.sm`) |
| Kartu stat: tinggi | 102.5 | **124** (delta 2 baris) / 107 (delta 1 baris) | delta dibiarkan membungkus 2 baris supaya **tidak terpotong**; board 1 baris karena contohnya pendek |
| Kartu stat: radius / padding | 14–15 / 16 | 14 / 16 | ≤1 |
| Label / nilai / delta | 12 / ≈28 / 12 | `bodySmall` 12 / `displayLarge` 30 / `bodySmall` 12 | nilai +2 (token `display`) |
| Kartu XP: lebar / tinggi | 351 / 167.5 | 350 / **177** | +9.5 → label sumbu memakai line-height token 1.4 (board ≈1.2) |
| Bar: lebar / gap / pitch | 36.5 / 10.5 / 47 | 36.6 / 10 / 46.6 | ≤0.5 |
| Bar: tinggi plot / radius | 87.5 / 7 | 88 / 7 | +0.5 |
| Bar: warna | `primaryContainer` / `honey` / `surfaceAlt` | idem | 0 |
| Label hari | S S R K J S M (Senin..Minggu) | idem, `isToday` = honey | 0 |
| Kartu heatmap: tinggi | 181.5 | 194.5 | +13 → baris legenda `bodySmall` (1.4) vs board ≈12 |
| Heatmap: sel / gap | 21.5×11.5 / 3.5 | 21.3×11.5 / 3.5 | ≤0.2 |
| Heatmap: grid | 13 kolom × 7 baris = 91 | idem, baris 0 = Senin | 0 |
| Heatmap: 4 level warna | `surfaceAlt`→`pC`→`pSoft`→`primary` | idem | 0 |
| Trailing hari | "90 hari" | "**91** hari" | board menulis 90 tapi grid-nya 13×7 = 91 → pakai 91 (jujur ke data) |
| Legenda | swatch 11×11 gap 5, rata kanan | idem | 0 |
| Kartu insight: ukuran | 351×55.5 | 350×58 | +2.5 |
| Ikon insight | ≈20 | 20 | 0 |
| Teks insight | 12–13, 2 baris | `bodySmall` 12 | ≤1 |
| Jarak antar blok | 16–17 | 16 | ≤1 |

**Deviasi yang tidak diperbaiki (dengan alasan):**
- Kalimat kedua insight board ("Pertahankan ritual pagi.") **tidak** dirender — itu klaim tentang
  kebiasaan pengguna yang tidak berasal dari data. Diganti kalimat kedua yang dihitung dari data
  ("{habit} paling konsisten belakangan ini."). Bila tidak ada dasar data → teks
  "Insight muncul setelah kamu menyelesaikan beberapa tugas dan habit."
- Tinggi kartu stat mengikuti isi (1–2 baris delta). Board 102.5 dp tercapai saat delta muat
  satu baris; dipilih membungkus daripada memotong informasi.

**Tidak terverifikasi:** —

**Verifikasi di HP (2026-10-31, Galaxy A52 / SM-A525F, Android 14, 1080×2400 @420dpi):**
APK release arm64 di-install ulang di atas data asli (schema **v3 → v4 dimigrasikan di perangkat
nyata**, aplikasi langsung jalan, XP/level/streak/habit utuh). Yang terbukti di perangkat:
- Sheet "Lainnya" **4 baris** (Statistik · Profil · Pengaturan · Tentang), Statistik membuka layar.
- Segmented 3 periode berfungsi: kosong per periode berganti teks ("minggu"/"bulan"/"tahun") dan
  pil aktif berpindah. Tap target terukur **126 px / 420 dpi = 48 dp** (a11y).
- **Dua bug yang hanya muncul di data asli, ditemukan & diperbaiki di sesi ini:**
  1. Kelima kartu (termasuk heatmap habit) tersembunyi saat pengguna hanya punya data habit —
     `EmptyState` hanya memeriksa task+fokus. Sekarang XP & heatmap ikut dihitung.
  2. Kartu XP menampilkan "0 XP" bersamaan dengan "Belum ada XP". Sekarang total disembunyikan
     saat tidak ada event XP.
- `–` + "belum ada pembanding" tampil benar saat metrik belum punya data (`waktu fokus` di Tahun,
  kedua kartu di Minggu) — **tidak ada `0%` palsu**.
- Insight memakai data nyata: "Kamu paling produktif hari Senin. Strecing + Joging paling
  konsisten belakangan ini."
- **Tema gelap** dipotret (`hp-07-statistik-minggu-dark-id.png`): canvas/kartu/segmented/heatmap/
  insight konsisten, tidak ada teks hilang.
- Setelan perangkat dikembalikan seperti semula (Light + English) setelah pengujian.

**Yang tetap perlu dicatat:** heatmap level-0 vs kartu hanya **1.17:1** (light) / 1.12 (dark) —
lihat isu terbuka no. 12. Di HP sel yang kosong memang nyaris tak terlihat.

---

## Yang BELUM selesai

### Status 16 tahap

| Tahap | Status | Catatan |
|---|---|---|
| T0 Fondasi | 🟡 sebagian | Arsip v1 selesai, `.gitignore` dirapikan. Belum ada gate CI |
| T1 Performa (lag) | ✅ selesai | 8/8: index DB, push coalesce+gate, checkbox DB-langsung, home lazy sliver, pomodoro label-only, startup non-blocking, splash decouple, minify+split ABI |
| T2 Design system | ✅ selesai | font Fredoka+PJS, 19 token `ThemeExtension`, `ColorScheme` eksplisit (bukan fromSeed), widget kit 12 komponen + preview dev-only |
| T3 Redesign layar | ✅ selesai | app shell tab bar 5 + sheet "Lainnya" (tanpa drawer); 12 layar pakai widget kit + token; shared-widget & 0 `AppColors.*` deprecated |
| T4 Animasi | ✅ selesai | motion token di kode (`app_motion.dart`), `AppPageRoute` 220ms fade+slide, press scale, celebration one-shot (ticker idle hilang), XP glow composite-only, shine sweep, reduced-motion (`MediaQuery.disableAnimations`) di semua animasi |
| T5 Statistik | ✅ selesai | schema v4 `focus_sessions` + `xp_events` (index), titik tulis XP (net, termasuk refund) + sesi fokus, `StatsRepository` + 5 provider, layar board 07 (segmented 3 periode, 2 kartu stat + delta, bar chart 7/30/12 bucket, heatmap 13×7, kartu insight), entri sheet "Lainnya" 4 item. Empty state per periode, `–` bila metrik belum ada data. 304 test |
| T6 Subtask & Lokasi | ⬜ belum | |
| T7 Kategori/tag & pencarian | 🟡 desain selesai | Board 26, fitur belum |
| T8 Widget | 🟡 desain selesai | 5 varian + state kosong digambar; scroll butuh `RemoteViewsService` (belum ada) |
| T9 Notifikasi | 🟡 desain selesai | 5 channel + banner + layar pengaturan digambar |
| T10 Backup/restore | 🟡 desain selesai | Alur Google Drive digambar, belum dikode |
| T11 Cek update | ⬜ belum | |
| T12 Gamifikasi polish | ⬜ belum | |
| T13 Bug audit | ⬜ belum | |
| T14 Ikon & logo | 🟡 sebagian | Maskot & logo ada; **ikon app persegi belum di-generate** |
| T15 Landing page | ⬜ belum | Rencana: Astro + Vercel |
| T16 Docs final + rilis | ⬜ belum | |

### Isu terbuka yang harus diingat

0. **AUDIT FIDELITY KANVAS (2026-10-31) — status per board:**

   | Board | Status | Catatan deviasi |
   |---|---|---|
   | 22 Splash | ✅ sesuai | dibangun ulang dari board (maskot lingkaran 220dp `honeyContainer`, wordmark Fredoka 46, tagline `bodySmall`, progress 120×4). Video v1 + pohon gambar tangan **dihapus**; dep `video_player` dicabut |
   | 11 States | ✅ sesuai | `EmptyState` (maskot `ClipOval` + judul + subjudul + aksi), `SkeletonList`, `ErrorState` |
   | 01 Home | ✅ sesuai | kartu level `primary` r24 + pill streak + XP bar; avatar 48 + tanggal; kartu per item + chip prioritas + jam; CTA auto-width |
   | 01b/15 | ✅ sesuai | tab bar floating pill ✅; sheet **4 item** (Statistik · Profil · Pengaturan · Tentang) sesuai board 15. Deviasi: sub-judul sheet belum ada (butuh key l10n) |
   | 02 Tasks | ✅ sesuai | section + count, kartu per item, chip + jam. Deviasi: chip filter kategori (T7), "x/y subtask" (T6), judul AppBar 24 (DESIGN token `title` 22) |
   | 03 Habits | ✅ sesuai | ringkasan `primaryContainer` + badge persen, kartu per item + streak + menit |
   | 04 Kalender | ✅ sesuai | grid kartu r24, pill hari terpilih 44×40, dot honey, panel harian kartu-per-item; label "Habits (harian)" **dihapus** |
   | 05 Pomodoro | ✅ sesuai | cakram 261 + cincin honey, chip durasi 15/25/45/60, stop persegi. **Regresi: input durasi bebas dihapus** (board hanya chip) |
   | 06 Profil | ✅ sesuai | kartu maskot + **Level sekali** (duplikat dihapus) + 3 stat tile + badge/kosmetik kartu kotak. Deviasi: "Bergabung X bulan lalu" tidak bisa (tabel tanpa `createdAt`), "tugas selesai" → "hari ini" |
   | 08 Pengaturan | ✅ sesuai | grup + ListRow + chevron + segmented. Deviasi: grup DATA (backup/ekspor) belum ada (T10), label "PEMBERITAHUAN" belum ada key |
   | AppScaffold | ✅ sesuai | back **lingkaran** 40dp (board 37) `canvas` + border, judul Fredoka 24 rata kiri, aksi debug dipindah ke sheet dev-only |
   | 09 Onboarding | ✅ sesuai | maskot `ClipOval` 168dp, judul 26, dots 3 halaman, field+CTA; overflow keyboard diperbaiki (scrollable) |
   | 10 Task Form | ✅ sesuai | prioritas **segmented 3 kotak** (bukan radio), tanggal+jam sejajar h42, checklist 40dp, simpan full-width. Deviasi: field Lokasi dipertahankan (ada di DB), X hapus subtask dipertahankan |
   | 24 Habit Form | ✅ sesuai | 4 chip frekuensi sejajar, pill jam + hapus, kartu progress + switch, simpan full-width, gutter 20 |
   | 25 Habit Detail | ✅ sesuai | 3 kartu statistik, kartu ringkasan 3 baris, **grid histori 7×4** (bukan strip 7 hari), legenda 4 swatch. **Perbaikan logika:** hari masa depan / tidak dijadwalkan tidak lagi ditandai gagal |
   | 27 Celebration | ✅ sesuai | maskot 100dp, pill rank, CTA; one-shot 750ms + reduced-motion (T4 dipertahankan) |
   | 23 Tentang | ✅ sesuai | petak maskot 84dp rounded, nama, versi dari `package_info_plus` (tidak hardcode), deskripsi. Deviasi: 4 baris aksi (privasi/lisensi/rating/masukan) belum dibangun — butuh tujuan nyata |
   | 07 Statistik | ✅ sesuai | board 07 dibangun + **diverifikasi di HP (Galaxy A52, Android 14)**. Tabel selisih lengkap di section "T5 — fidelity board 07 Statistik". Screenshot HP: `docs/artifacts/hp-07-statistik-*.png` (light Mingu/Tahun, dark), render pembanding `07-statistik-render.png` |
   | 20/21/26 | 🔒 | menunggu T8/T9/T10 |

   **Gutter:** diseragamkan **20dp** (nilai board 19.5–20) di `AppScaffold.gutter` + Kalender/Habits/Tasks/HabitDetail/Pengaturan/NotifSettings/Home/HabitForm/Profil. Onboarding tetap 24 sesuai board 09.

   **Keputusan yang menunggu owner:** (a) `DESIGN.md` token `title` = 22 vs board 24 → samakan ke 24?; (b) XP fill `honey` di track `primarySoft` = 1,77:1 (di bawah 3:1 non-teks) — pertahankan board atau ganti track; (c) durasi Pomodoro bebas dikembalikan?; (d) `createdAt` profil (butuh migrasi schema) untuk "Bergabung X bulan lalu".

1. ~~Font v2 belum diunduh.~~ **Selesai di T2** — `assets/fonts/` berisi Fredoka + Plus Jakarta Sans (3 file), terdaftar di `pubspec.yaml`.
2. **Ikon app persegi belum ada.** Yang ada baru wordmark horizontal (`assets/logo/tazk-logo.png`) yang **terpotong** kalau dipakai di kotak persegi. Prompt ada di `docs/design/ikon-logo-prompts.md` §2.
3. **Widget scroll belum bisa jalan.** Desainnya ada, tapi butuh `RemoteViewsService` + `RemoteViewsFactory` di Kotlin. Belum dibuat.
4. **Teks mini di widget belum terverifikasi di HP.** Huruf hari 7.5px, item 8.5px — di bawah rekomendasi Android (10–11sp). **Wajib dites di perangkat.**
5. **`graphify label` gagal** (timeout). Struktur graph benar (1.941 node / 2.737 edge / 84 komunitas) tapi nama komunitas masih turunan otomatis, belum semantik.
6. ~~Kode masih merujuk aset terarsip~~ — **Selesai di T2/T3**: seluruh layar memakai widget kit + token v2; `grep AppColors.<deprecated>` di `lib/` = 0.
7. **Provider `.env` lama mati** (`vyceai.com` HTTP 503). Sudah diganti ke SEKAI `/v2` (`ds/deepseek-v4.1-flash`). Nebius juga 401.
8. **Kanvas masih pakai 3 warna untuk "teks di atas primary"** — `$surface` (17×), `$canvas` (9×), `#DDE3D6` (3×). Semua lolos kontras (7.03 / 6.56 / 5.65:1), tapi `DESIGN.md` sekarang mendeklarasikan dua: `on-primary` (`#FBF9F4`) dan `on-primary-muted` (`#DDE3D6`). **Perlu normalisasi kanvas**: 9 node `$canvas` → `$surface`.
9. **Kontras grab handle masih 1.32:1** (`#E2DACB` di atas `#FBF9F4`) — hampir tak terlihat. Owner minta hanya ditengahkan, jadi kontras sengaja dibiarkan. Kalau mau dibuat terlihat, standar elemen non-teks = 3:1; kandidat `#918A7C` (3.26:1) / dark `#6A7A6E` (3.63:1).
10. ~~Screenshot HP layar Statistik belum ada~~ **Selesai 2026-10-31** — device tersambung, APK release di-install di atas data asli (migrasi v3→v4 terbukti jalan di perangkat), 6 screenshot di `docs/artifacts/`.
11. ~~Tema gelap layar Statistik belum dipotret~~ **Selesai 2026-10-31** — `hp-07-statistik-minggu-dark-id.png`.
12. **Kontras GRAPHIC pada chart/heatmap di bawah 3:1 (light)** — dihitung, bukan ditebak: batang `primaryContainer` vs `surface` = **1.24**, batang terpilih `honey` vs `surface` = **2.34**, level-0 heatmap `surfaceAlt` vs `surface` = **1.17**, `primaryContainer` vs `surfaceAlt` = **1.06**, `primary` vs `primarySoft` (level 2 vs 3) = **1.70**. Semua **teks** lolos AA (`ink` di `primaryContainer` 11.73/11.12, `inkMuted` di `surface` 5.46/7.11). Ini warisan board 07 → **menunggu keputusan owner** (pertahankan board vs pertegas ramp). Kandidat pertegas tanpa ubah token: beri tepi 1px `border` pada batang/sel.
13. **Kartu Level di Home (tema gelap) terasa terlalu terang** — owner menunjuk latar hijau kartu (`primary` dark `#8FE0A9`) **dan** kuning di dalamnya (isi XP `honey` + pil streak `honey`). Belum dikerjakan; keputusan warna harus dari owner dulu. Catatan penting: percobaan menurunkan token `primary` global **dibatalkan** (lihat log G1-revert) karena sasarannya kartu ini, bukan seluruh tema. Gambar kandidat: `docs/artifacts/warna-kartu-level-dark-kandidat.png`. Kemungkinan arah: (a) latar kartu pakai `primaryContainer` khusus dark, (b) turunkan `honey` isi XP, (c) keduanya — masing-masing perlu ukur kontras `onPrimary`/`onPrimaryMuted` ulang.

---

## Keputusan yang sudah final (jangan ditanya ulang)

| Topik | Keputusan |
|---|---|
| Palet | Sage & Sand (light) / Dusk Forest (dark) |
| Font | Fredoka + Plus Jakarta Sans |
| Maskot | Otter (bukan honey badger — aset final owner adalah otter) |
| Navigasi | Tab bar 5 + sheet "Lainnya", **tanpa ☰** |
| Widget | Solid ikut tema, maskot di semua kecuali Calendar, scroll + hint teks |
| Backup | Google Drive milik user (`drive.appdata`), tanpa server sendiri |
| Distribusi | APK dari landing page sendiri (Astro + Vercel), **bukan Play Store** |
| Rilis | Satu rilis besar **v2.0** |
| Verifikasi | HP Android via USB |
| Anti-slop | Mode **DURING** |
| Git | Commit lokal boleh, **push hanya dengan izin eksplisit** |
| Urutan kerja | Performa (T1) sebelum redesign UI — supaya animasi baru tidak menambah lag |

---

## Cara memverifikasi kondisi sekarang

> ⚠️ **Jebakan `design.pen`:** pen.dev menulis file ke disk **dengan jeda**, bukan saat
> perintah selesai. Kalau commit dilakukan tepat setelah mengubah kanvas, perubahan itu
> bisa tertinggal. Selalu jalankan `git status` lagi beberapa saat setelah edit kanvas,
> dan pastikan `design.pen` tidak muncul sebagai `M` sebelum menganggap kanvas tersimpan.
>
> **Terbukti 2×:** (1) perbaikan `warning-strong` tertinggal dari commit `04fa0df`;
> (2) grab handle tertahan **~90 detik** sebelum muncul di file. Cara aman: cek isi file,
> bukan hanya ukurannya — mis. `Select-String design.pen -Pattern "namaNodeBaru"`.

> ⚠️ **Jebakan pen.dev: `justifyContent: center` tidak bekerja pada node `ref`.**
> Menengahkan instance komponen di dalam frame flexbox tidak bereaksi. Solusi yang
> terbukti: beri wrapper `layout: "none"` lalu set `x` eksplisit pada instance.
> Terverifikasi pada `Sheet/Handle` (x=175 → center 195 = center sheet 195).

```powershell
# 1. App masih jalan?
flutter pub get
dart analyze          # harus: No issues found!
flutter test          # harus: 306/306 lulus

# 2. DESIGN.md masih valid?
npx @google/design.md lint DESIGN.md          # harus: 0 errors
npx @google/design.md export --format dtcg DESIGN.md

# 3. Kontras — jangan pernah menebak
python "C:\Users\LENOVO\.agents\skills\antislop-human\contrast-check.py" "#TEXT" "#BG"

# 4. Kanvas
# buka design.pen di pen.dev, cek get_app_state
```

**Baseline terakhir terverifikasi (2026-10-30):** `dart analyze` bersih, `flutter test` 60/60,
`lint DESIGN.md` 0 error, export dtcg exit 0, semua pasangan warna chip lolos AA,
sheet grab handle center 195 = sheet center 195 (selisih 0).

---

## Langkah berikutnya (pilihan)

| Opsi | Isi | Kenapa |
|---|---|---|
| **A** | T2: migrasi design system ke kode — unduh font, ganti `app_colors.dart` + `app_typography.dart`, buat widget kit | Fondasi untuk semua layar v2 |
| **B** | T1: perbaikan performa (8 temuan audit) | App jadi enak dipakai sebelum UI diganti |
| **C** | Lengkapi aset: generate ikon app persegi | Dibutuhkan launcher & landing page |

Rekomendasi: **B dulu, lalu A** — sesuai alasan di §7 spec (animasi baru di atas fondasi lambat = lebih parah).
