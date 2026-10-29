# Tazk — Posisi Sekarang

Dokumen penanda posisi kerja. Baca ini dulu sebelum melanjutkan, supaya tidak
mengulang keputusan yang sudah diambil atau mengerjakan hal yang sudah selesai.

Terakhir diperbarui: **2026-10-30**

---

## Ringkas satu paragraf

Tazk sedang diupgrade dari v1 ke v2. **Fase desain sudah selesai** (design system,
27 board kanvas, DESIGN.md). **Fase kode belum mulai** — app yang jalan sekarang masih
v1 dengan aset v1 yang sudah diarsipkan, jadi tipografi app jatuh ke font sistem.
Langkah berikutnya: migrasi design system ke kode (Tahap 2).

---

## Posisi git

| Item | Nilai |
|---|---|
| Branch | `main` |
| Commit terakhir | `04fa0df` — chore: arsipkan v1 + design system v2 + perbaikan kontras kanvas |
| Tag stabil terakhir | `stable-2026-10-29-v2` |
| Status push | **3 commit belum di-push** ke `origin` (GitHub) — sengaja, atas permintaan owner |
| Working tree | bersih |

Tag stabil sebelumnya: `stable-2026-10-29-v1`, `stable-2026-08-23-v1..v3`, `stable-2026-10-26-v1`

---

## Yang sudah selesai

### Fase desain (kanvas `design.pen`)

**27 board**, 2.195 node, 0 placeholder tersisa:

| Kelompok | Board |
|---|---|
| Fondasi | Foundations (30 token), Components, Library, Dark Preview |
| Layar utama | 01 Home, 01b Home-Sheet, 12 Home-Dark, 02 Tasks, 03 Habits, 04 Kalender, 05 Pomodoro |
| Layar sekunder | 06 Profil, 07 Statistik, 08 Pengaturan, 09 Onboarding, 10 Task Form, 24 Habit Form, 25 Habit Detail |
| Pelengkap | 11 States, 15 Navigation Map, 16 App Icon, 20 Widgets, 21 Notifikasi, 22 Splash, 23 Tentang, 26 Backup & Pencarian, 27 Celebration |

**Design system final:**
- Palet: **Sage & Sand** (light) / **Dusk Forest** (dark)
- Font: **Fredoka** (judul) + **Plus Jakarta Sans** (body/UI)
- Maskot: **otter** 3D clay dengan tunas
- Navigasi: tab bar 5 (Home · Tasks · Habits · Kalender · Lainnya) + sheet "Lainnya"

### Dokumen

| File | Isi |
|---|---|
| `DESIGN.md` | Design system kanonik, format DESIGN.md spec v0.4.0. 19 warna, 6 skala tipografi, 5 radius, 7 spacing, 12 komponen. Lint **0 error**, export dtcg exit 0 |
| `PRODUCT.md` | Product doc v2 |
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

## Yang BELUM selesai

### Status 16 tahap

| Tahap | Status | Catatan |
|---|---|---|
| T0 Fondasi | 🟡 sebagian | Arsip v1 selesai, `.gitignore` dirapikan. Belum ada gate CI |
| T1 Performa (lag) | ⬜ belum | Audit sudah ada (8 temuan), belum dieksekusi |
| T2 Design system | 🟡 desain selesai, kode belum | `DESIGN.md` + kanvas selesai; `app_colors.dart`/`app_typography.dart` **masih v1** |
| T3 Redesign layar | 🟡 desain selesai, kode belum | 12 layar di kanvas, kode masih v1 |
| T4 Animasi | ⬜ belum | Motion token sudah didefinisikan |
| T5 Statistik | 🟡 desain selesai | Layar 07 digambar, fitur belum |
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

1. **Font v2 belum diunduh.** `assets/fonts/` kosong; Fredoka & Plus Jakarta Sans belum ada `.ttf`-nya. App sekarang jatuh ke font sistem. Perlu diunduh sebelum T2.
2. **Ikon app persegi belum ada.** Yang ada baru wordmark horizontal (`assets/logo/tazk-logo.png`) yang **terpotong** kalau dipakai di kotak persegi. Prompt ada di `docs/design/ikon-logo-prompts.md` §2.
3. **Widget scroll belum bisa jalan.** Desainnya ada, tapi butuh `RemoteViewsService` + `RemoteViewsFactory` di Kotlin. Belum dibuat.
4. **Teks mini di widget belum terverifikasi di HP.** Huruf hari 7.5px, item 8.5px — di bawah rekomendasi Android (10–11sp). **Wajib dites di perangkat.**
5. **`graphify label` gagal** (timeout). Struktur graph benar (1.941 node / 2.737 edge / 84 komunitas) tapi nama komunitas masih turunan otomatis, belum semantik.
6. **Kode masih merujuk aset terarsip** — sengaja dibiarkan (punya fallback, tidak crash). Akan hilang di T2/T3.
7. **Provider `.env` lama mati** (`vyceai.com` HTTP 503). Sudah diganti ke SEKAI `/v2` (`ds/deepseek-v4.1-flash`). Nebius juga 401.
8. **Kanvas masih pakai 3 warna untuk "teks di atas primary"** — `$surface` (17×), `$canvas` (9×), `#DDE3D6` (3×). Semua lolos kontras (7.03 / 6.56 / 5.65:1), tapi `DESIGN.md` sekarang mendeklarasikan dua: `on-primary` (`#FBF9F4`) dan `on-primary-muted` (`#DDE3D6`). **Perlu normalisasi kanvas**: 9 node `$canvas` → `$surface`.

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

```powershell
# 1. App masih jalan?
flutter pub get
dart analyze          # harus: No issues found!
flutter test          # harus: 60/60 lulus

# 2. DESIGN.md masih valid?
npx @google/design.md lint DESIGN.md          # harus: 0 errors
npx @google/design.md export --format dtcg DESIGN.md

# 3. Kontras — jangan pernah menebak
python "C:\Users\LENOVO\.agents\skills\antislop-human\contrast-check.py" "#TEXT" "#BG"

# 4. Kanvas
# buka design.pen di pen.dev, cek get_app_state
```

**Baseline terakhir terverifikasi (2026-10-29):** `dart analyze` bersih, `flutter test` 60/60,
`lint DESIGN.md` 0 error, export dtcg exit 0, semua pasangan warna chip lolos AA.

---

## Langkah berikutnya (pilihan)

| Opsi | Isi | Kenapa |
|---|---|---|
| **A** | T2: migrasi design system ke kode — unduh font, ganti `app_colors.dart` + `app_typography.dart`, buat widget kit | Fondasi untuk semua layar v2 |
| **B** | T1: perbaikan performa (8 temuan audit) | App jadi enak dipakai sebelum UI diganti |
| **C** | Lengkapi aset: generate ikon app persegi | Dibutuhkan launcher & landing page |

Rekomendasi: **B dulu, lalu A** — sesuai alasan di §7 spec (animasi baru di atas fondasi lambat = lebih parah).
