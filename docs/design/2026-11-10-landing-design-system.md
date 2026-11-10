# Tazk Landing — Design System (v1)

> Dibuat 2026-11-10. Turunan dari: token `DESIGN.md` (dibaca langsung, bukan diingat) +
> **pengukuran render** `https://openbot.run/` di 3 viewport. Ini **bukan** salinan visual
> openbot: yang dipinjam hanya prinsip ritme, pola komponen, dan disiplin motion.

## 0. Bukti, metode, dan koreksi

| Diukur | Cara | Hasil |
|---|---|---|
| Tipografi responsif | `getComputedStyle` di 3 salinan halaman (390/768/1440) | lihat §1 |
| Tinggi section | `getBoundingClientRect` per section | lihat §1 |
| Motion | `document.getAnimations()` + `transition` terhitung | lihat §6 |
| Aset & berat | `performance.getEntriesByType('resource')` | 1.214 KB total; CSS 49 KB; font 47 KB (Inter woff2); WebP art 433 KB |
| Framework | marker SSR `$_TSR`/`$tsr` + route manifest di HTML | TanStack Start + React; motion = CSS + `IntersectionObserver` (2 kemunculan); **tanpa** Framer/GSAP/Lottie |

**Koreksi terhadap laporan sebelumnya (penting, agar tidak terulang — lihat L-013):**
1. Font openbot = **Inter Variable**, bukan system font.
2. Easing hover = **`cubic-bezier(.23,1,.32,1)`**; `.22,1,.36,1` hanya untuk reveal.
3. Mereka **punya aset raster**: 4 WebP bentuk (carré/pentagone/losange/galet) ±433 KB —
   bukan "art murni CSS" seperti klaimku sebelumnya.
4. Token Tazk: **canvas = `#F4F1EA`**, `#FBF9F4` adalah `surface` (aku pernah tertukar).

Belum diukur: Lighthouse, perangkat asli, pembaca layar. Jangan diklaim.

## 1. Referensi ritme (openbot, terukur)

| Properti | 390px | 768px | 1440px |
|---|---|---|---|
| h1 | **48px** / lh 46,08 / ls −3,12 / w500 | 61,44 / 58,98 / −3,99 / w500 | **104px** / 99,84 / −6,76 / w500 |
| Body lead | 16 / 24 (lebar 343) | 17 / 26,35 (691) | 20 / 31 (720) |
| Gutter | **16px** | 30,72px | **48px** |
| Tinggi hero | 1.140 | 1.132 | 1.400 |
| Tinggi features | 3.495 | 2.857 | 1.942 |
| Tinggi halaman | 16.019 | 13.859 | 12.545 |

Kesimpulan yang dipakai:
- h1 = `clamp(3rem, 8vw, 6.5rem)`, **weight 500**, `letter-spacing: −0.065em`, `line-height: 0.96`.
- Body lead membesar mengikuti viewport (16 → 20px), `line-height 1.5–1.55`, **kolom baca 720px**.
- Gutter mengikuti `clamp(16px, 4vw, 48px)`.
- Section tinggi mengikuti isi, bukan dipatok; jarak antar-section 64–128px.

## 2. Token Tazk untuk landing (dari `DESIGN.md`, terverifikasi)

| Token | Light | Dark |
|---|---|---|
| `canvas` | `#F4F1EA` | `#0F1A14` |
| `surface` | `#FBF9F4` | `#152219` |
| `surface-alt` | `#EDE7DA` | `#1C2C21` |
| `border` | `#E2DACB` | `#23382A` |
| `ink` | `#26251F` | `#E8F0E7` |
| `ink-muted` | `#6A6659` | `#9DAF9F` |
| `primary` | `#4A5A44` | `#8FE0A9` |
| `primary-container` | `#DDE3D6` | `#20362A` |
| `on-primary` | `#FBF9F4` | `#0F1A14` |
| `clay` / `clay-container` | `#C97B5A` / `#F2DCD1` | `#E0A183` / `#3A2620` |
| `honey` / `honey-container` | `#D69A3C` / `#F6E4C2` | `#F2C765` / `#3A3220` |
| `warning-strong` | `#8A5A12` | `#EBCB7E` |

**Aturan permukaan (dari openbot, diadopsi):**
- Border halus = `color-mix(in srgb, ink 8%, transparent)`; hover `16%`.
- Fill kartu = `color-mix(in srgb, ink 4%, transparent)` di light, `surface-alt` di dark.
- **Inset highlight 1px** di tepi atas kartu/hero frame: light `rgba(255,255,255,.7)`, dark `rgba(255,255,255,.10)`.
- Glass (header/CTA sekunder): `backdrop-filter: blur(16px) saturate(160%)` + `surface` 88% — **maksimal 2 elemen per halaman** (biaya paint).
- **Dilarang** menambah hex baru. Semua turunan dari token di atas.

## 3. Tipografi landing

| Peran | Font | Light | Desktop | Aturan |
|---|---|---|---|---|
| Hero h1 | Fredoka 500–600 | 44px | `clamp(2.75rem, 6.4vw, 5rem)` → 80px | `ls −0.03em`, `lh 1.02` |
| Section h2 | Fredoka 600 | 30px | 44px | `ls −0.02em`, `lh 1.1` |
| Card h3 | PJS 600 | 19px | 22px | `lh 1.25` |
| Lead | PJS 400 | 16px | 19px | `lh 1.55`, max 68ch |
| Body | PJS 400 | 15px | 16px | `lh 1.6`, max 70ch |
| Eyebrow | PJS 600 | 11px | 12px | `uppercase`, `ls 0.14em`, warna `ink-muted` |
| Label tombol | PJS 600 | 15px | 16px | `lh 1` |

Catatan: Fredoka punya lebar optik lebih besar dari Inter → ukuran hero Tazk **sengaja lebih
kecil** dari acuan (80px vs 104px) agar tidak memotong di 320px.

## 4. Spacing & grid

- Spacing scale (dipakai saja, jangan bikin baru): `4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 96`.
- Container: `max-width: 1200px`, gutter `clamp(16px, 4vw, 48px)`.
- Kolom baca: `max-width: 680px` (Tazk lebih pendek dari 720 karena PJS lebih lebar).
- Padding section: `clamp(56px, 8vw, 112px)` atas, `clamp(40px, 6vw, 80px)` bawah.
- Grid fitur: **1 kolom < 640px · 2 kolom ≥ 640px**; kartu `min-height` bukan dipatok.
- Radius: `card 20px`, `button pill 999px`, `mockup 28px`, `chip 999px`.

## 5. Komponen (10) — spesifikasi

1. **Header** — tinggi `clamp(56px, 6vw, 76px)`, logo lockup (SVG) + 4 tautan + CTA pill.
   Saat scroll > 24px: `surface` 88% + blur 16 + border-bottom `border`. Tanpa drawer di mobile;
   tautan jadi baris horizontal yang bisa di-scroll, CTA tetap terlihat.
2. **Chip bar hero** — tiga chip: `Gratis` · `Offline` · `Tanpa akun` (pengganti strip
   "Available on"). Fungsi: janji utama terbaca dalam 1 detik.
3. **Hero** — eyebrow → h1 (**maskot inline** di dalam judul bila ruang ≥ 768px) → lead 2–3 baris
   → 1 CTA utama + 1 CTA ghost → mockup ponsel.
4. **Split CTA** — pill `primary` + segmen chevron terpisah (divider 1px `on-primary` 20%).
   Aksi: unduh APK arm64 / pilih varian. Tinggi 48px, padding `0 24px`.
5. **Ghost CTA** — border `border` + `ink`, tinggi 48px, blur hanya di desktop.
6. **Mockup ponsel** — frame 28px radius, border 1px `border`, inset highlight, layar berisi
   **screenshot asli** (`docs/artifacts/hp-*.png`) dengan `object-fit: cover`.
   Di desktop tampil 2 ponsel bersebelahan (offset vertikal 24px); mobile 1 ponsel.
7. **Kartu fitur** — radius 20, border 1px, fill 4%, padding 24, isi: ikon 20px `primary`,
   h3, body 1–2 baris. Hover: translateY(−2px) + border 16% (150ms).
8. **Baris blok warna** — 3 kartu bertint `primary-container`, `honey-container`, `clay-container`
   dengan teks `ink`. Maksimal 3, isi 1 ide masing-masing (bukan dekorasi).
9. **FAQ** — item `border-bottom 1px border`, judul 17px 600, ikon +/−, jawaban 15px `ink-muted`,
   animasi tinggi `grid-template-rows: 0fr → 1fr` 220ms.
10. **Footer** — 4 kolom: Produk · Sumber daya · Privasi · Kontak. Baris bawah: hak cipta,
    "Dibuat dengan Flutter", tautan changelog.

## 6. Motion (nilai Tazk, bukan salinan)

| Momen | Properti | Durasi | Easing | Catatan |
|---|---|---|---|---|
| Reveal masuk viewport | `opacity`, `translateY(12px)`, `filter: blur(3px)` | 320ms | `easeStandard` | stagger 40ms via `--i`; **sekali saja** |
| Header saat scroll | `background`, `border-color` | 150ms | `easeStandard` | tanpa blur di mobile |
| Hover kartu | `transform: translateY(-2px)` | 150ms | `easeGentle` | hanya `pointer:fine` |
| Hover tombol | `background-color` | 150ms | `easeStandard` | tanpa scale |
| FAQ buka/tutup | `grid-template-rows` | 220ms | `easeStandard` | hormati reduced-motion |
| Press | `scale 0.98` | 120ms | `springPop` | hanya di layar sentuh |

**Aturan implementasi (dari jebakan openbot):**
- Konten **terlihat by default**; JS hanya menambah kelas `is-visible`. Tanpa JS → semua terbaca.
- Hanya `opacity`/`transform`/`filter`; dilarang animasi `height`, `top`, `margin`.
- `@media (prefers-reduced-motion: reduce)` → semua `transition/animation: none`.
- Blur saat reveal dibatasi ≤ 3px dan hanya pada ≤ 12 elemen per section (biaya paint).

## 7. Aset & anggaran berat

Referensi openbot: **1.214 KB** total (CSS 49 · font 47 · WebP bentuk 433 · JS ±115).

Aset Tazk yang **sudah diproduksi** (`assets/landing/`, Pillow, WebP q82):

| Aset | Sumber | Hasil |
|---|---|---|
| `otter-sprout-480/720.webp` | 1.475 KB (941×1672, tanpa alpha) | **13 / 21 KB** |
| `otter-waving-480/720/1080.webp` | 1.477 KB (1086×1448) | **11 / 18 / 31 KB** |
| `otter-portrait-480/720/1080.webp` | 1.534 KB (1254×1254) | **10 / 17 / 30 KB** |
| `logo-lockup-480/720/1080.webp` | 472 KB (1774×887) | **5 / 8 / 15 KB** |

Anggaran halaman (target, bukan klaim): **≤ 900 KB** total; hero image ≤ 60 KB; font ≤ 2 file
(Fredoka 600 + PJS 400/600 subset latin); CSS ≤ 40 KB; tanpa video.

Batasan yang harus disebut ke owner: **PNG maskot tidak punya alpha channel** (24bpp), jadi
tidak bisa dipotong jadi stiker transparan. Dua opsi: (a) tampilkan dalam kartu dengan latar
token (aman sekarang), (b) owner menyediakan ekspor ber-alpha (PNG-32) bila ingin maskot
menempel langsung di canvas.

## 8. Arsitektur konten + copy deck

Urutan section: **Hero → 3 bukti singkat → 6 fitur → blok warna (3) → cara pakai (3 langkah) →
FAQ (6) → unduh APK → footer**. Tidak ada section "harga" (produk gratis) dan tidak ada
section "teams" (produk personal).

Copy deck (ID / EN) — nada tenang + hangat, tanpa buzzword:

| Slot | ID | EN |
|---|---|---|
| Eyebrow | `Tazk · v2.0` | `Tazk · v2.0` |
| H1 | `Selesai lebih tenang.` | `Done, calmer.` |
| Lead | `Tugas, habit, dan sesi fokus dalam satu tempat. Semua tersimpan di HP-mu — tanpa akun, tanpa internet.` | `Tasks, habits, and focus sessions in one place. Everything stays on your phone — no account, no internet.` |
| Chip | `Gratis` · `Offline` · `Tanpa akun` | `Free` · `Offline` · `No account` |
| CTA utama | `Unduh APK` | `Download APK` |
| CTA sekunder | `Lihat fitur` | `See features` |
| Fitur 1 | `Centang dua arah` — `Tandai selesai, batalkan, XP tetap benar.` | `Two-way check` — `Complete, undo, XP stays correct.` |
| Fitur 2 | `Subtask & lokasi` — `Pecah tugas, urutkan, buka lokasi di Maps.` | `Subtasks & places` — `Split tasks, reorder, open a place in Maps.` |
| Fitur 3 | `Habit dengan streak` — `Streak jujur, freeze transparan.` | `Habit streaks` — `Honest streaks, visible freezes.` |
| Fitur 4 | `Widget yang bekerja` — `Centang dari layar utama, bahkan saat app mati.` | `A widget that works` — `Check from the home screen, even when the app is closed.` |
| Fitur 5 | `Statistik dari data nyata` — `Tanpa angka karangan; kosong berarti kosong.` | `Stats from real data` — `No invented numbers; empty means empty.` |
| Fitur 6 | `Cadangan milikmu` — `Ekspor JSON kapan saja, simpan di tempatmu.` | `Your own backup` — `Export JSON anytime, store it where you choose.` |
| Langkah | `Unduh APK` → `Izinkan instalasi` → `Mulai dari nol` | `Download` → `Allow install` → `Start fresh` |
| FAQ 1 | `Apakah Tazk gratis?` — `Ya, tanpa iklan dan tanpa fitur terkunci.` | `Is Tazk free?` — `Yes, no ads and no locked features.` |
| FAQ 2 | `Apakah data saya dikirim keluar?` — `Tidak. Tidak ada akun dan tidak ada unggahan otomatis.` | `Is my data sent anywhere?` — `No. No account, no automatic upload.` |
| FAQ 3 | `Kenapa tidak ada di Play Store?` — `Didistribusikan langsung sebagai APK; pembaruan diunduh manual.` | `Why not on Play Store?` — `Shipped directly as an APK; updates are manual.` |
| FAQ 4 | `Bagaimana kalau saya ganti HP?` — `Ekspor file JSON, pindahkan, lalu pulihkan.` | `What if I change phones?` — `Export the JSON file, move it, restore it.` |
| FAQ 5 | `Apakah butuh internet?` — `Tidak untuk pemakaian harian. Hanya cek versi baru yang memakai jaringan.` | `Does it need internet?` — `Not for daily use. Only the version check goes online.` |
| FAQ 6 | `Apakah aman memasang APK manual?` — `Unduh dari halaman ini, cocokkan checksum yang ditampilkan.` | `Is installing an APK safe?` — `Download from this page and compare the checksum shown.` |
| Footer | `Privasi · Changelog · Kontak` | `Privacy · Changelog · Contact` |

## 9. Gerbang verifikasi (lantai minimum — penilaian akhir tetap visual owner)

1. Tanpa scroll horizontal di **320 / 390 / 768 / 1024 / 1440**.
2. Kontras AA: body ≥ 4.5:1, teks besar ≥ 3:1 — diukur `contrast-check.py`, dua tema.
3. `prefers-reduced-motion` → tidak ada animasi tersisa.
4. **JS dimatikan** → seluruh copy tetap terbaca.
5. Total berat ≤ 900 KB; gambar punya `srcset` + `width`/`height` (cegah CLS).
6. Screenshot bukti 3 viewport × 2 tema disimpan di `docs/artifacts/`.

## 10. Jangan ditiru dari openbot

Warna ungu `#d6adf2` / biru `#007cf7` · Inter · honeycomb · desain gelap sebagai default ·
marquee 36 detik · typing di mockup · `opacity:0` yang membuat konten hilang tanpa JS ·
struktur "pricing/teams" yang tidak relevan untuk produk gratis.