# Design System Reference — openbot.run (bedah RENDER, 2026-11-10)

> **Cara data ini diambil (bisa diulang):** halaman dibuka di browser in-app
> (`https://openbot.run/`), viewport **1000×700**, DPR 1.5, dokumen **11.631 px** tinggi.
> Diukur lewat `getComputedStyle` + `getBoundingClientRect` + `document.getAnimations()` +
> pencacahan `[data-revealed]`, lalu diverifikasi dengan screenshot (full-page 900px,
> viewport 1400px) dan screenshot saat scroll.
>
> **Yang TIDAK diukur (jangan diklaim):** perilaku di HP asli, TalkBack/screen reader,
> skor Lighthouse, dan animasi di dalam mockup yang dipicu input user.
>
> **Status versi pertama dokumen ini (sebelum render) sudah DIBATALKAN.** Dua klaim lama salah:
> (1) "openbot pakai system font" → **salah, yang dirender `Inter Variable`**;
> (2) "easing utama `.22,1,.36,1`" → hanya untuk reveal hero; **hover transform pakai
> `.23,1,.32,1`**. Nilai di bawah = hasil render.

---

## 1. Struktur halaman terukur

Viewport 1000px. Kolom konten efektif **≈720–753px**, gutter kiri/kanan 32–40px.

| # | Section | y (px) | Tinggi | Heading | Padding |
|---|---|---|---|---|---|
| 1 | `header.landing-header` | 10 | 76 | — | `18px 40px` |
| 2 | `section.landing-hero` | 76 | 1149 | "Meet OpenBot" | `80px 40px 72px` |
| 3 | `section.landing-network` | 1225 | 756 | "Your agents work together." | 0 |
| 4 | `section.landing-features` | 1981 | 2205 | "What OpenBot does" | 0 |
| 5 | `section.landing-pricing` | 4186 | 595 | "Free for personal use" | 0 |
| 6 | `section.landing-teams` | 4781 | 1692 | "OpenBot for Teams" | 0 |
| 7 | `section.landing-faq` | 6473 | 1861 | "Questions" | 0 |
| 8 | `section.landing-download` | 8334 | 1183 | "Download OpenBot" | 0 |
| 9 | `section.post-cta` | 9597 | 620 | "Meet your first teammate" | 0 |
| 10 | `footer.landing-footer` | 10217 | 1029 | "Product" (kolom) | `clamp(53px,5.6vw,78px) … 32px` |

Pola: **satu ide per section**, jarak antar-section besar (600–2200px isi), heading section
selalu di tengah, lalu satu visual besar di bawahnya.

---

## 2. Tipografi (terukur, bukan dari token)

| Elemen | Nilai render |
|---|---|
| Family | **`Inter Variable`** (variable 100–900) + fallback system stack |
| h1 hero | **64px @ vw1000** (`clamp(3rem, 8vw, 6.5rem)` → 80px @ vw1000 penuh), weight **500**, line-height **0.96** (61.44/64), letter-spacing **−0.065em** (−4.16px) |
| h2 section | 40–50px, weight 500–600 |
| h3 kartu fitur | **24px**, weight 600, line-height 1.15, letter-spacing −0.035em (−0.84px) |
| Body hero (description) | **17px / 26.35px (1.55)**, warna `#dcdcdc`, max-width **720px**, `text-align:center` |
| Body kartu | 15–16px / 1.5, warna `#979797`–`#dcdcdc` |
| Nav / label | **13px**, weight 500, letter-spacing −0.01em |
| Eyebrow (label kecil huruf besar) | 11px, weight 600, letter-spacing **0.08em** |

Skala nyata yang muncul di halaman: 11 · 13 · 15 · 16 · 17 · 18 · 24 · 30 · 40 · 46 · 50 · 64 · 80.

**Pelajaran UX:** display besar tapi **weight 500** (bukan 700) + tracking negatif → terasa
modern/tenang, bukan "teriak". Body 17px/1.55 dengan kolom 720px → enak dibaca.
**Tazk** punya Fredoka (display) — pakai Fredoka untuk h1/h2, PJS 16–17px untuk body,
tracking negatif tipis pada judul. Jangan tiru Inter.

---

## 3. Warna — frekuensi pemakaian nyata (bukan teori)

Diambil dari computed style seluruh elemen (5.000 node pertama):

| Warna | Jumlah | Peran |
|---|---|---|
| `#fff` | 1.569 | teks utama di atas gelap |
| `#979797` | 200 | teks muted |
| `#dcdcdc` | 131 | teks sekunder (body) |
| `#141414` | 119 | teks di atas terang / warna "ink" |
| `#1a1a1a` | 46 | **canvas** (latar halaman) |
| `rgb(255 255 255 / 0.05)` | 45 | fill kartu |
| `#212121` | 16 | surface kartu |
| `#d97757` | 16 | aksen hangat (art) |
| `#8e75b2` | 12 | ungu (art) |

Aturan sistem (dari CSS + dikonfirmasi render):
- **Satu warna dasar + alpha**, bukan palet lebar: border kartu = `text 8%`,
  hover = `text 16%`, fill = `text 5%`, glass = `white 7%` + blur 16px saturate 160%.
- **Inset highlight 1px** di tepi atas kartu/mockup: `inset 0 1px 0 rgba(255,255,255,.12)`
  → inilah yang memberi kesan "bahan" (bukan shadow tebal).
- Kartu "penawaran" Teams memakai **blok warna pastel penuh** (lavender, mint, amber, sky)
  sebagai jeda visual — warna dipakai untuk **ritme section**, bukan dekorasi acak.

**Tazk mapping:** canvas `#FBF9F4`, surface putih, border `#E2DACB`, primary `#4A5A44`,
aksen `honey #F2C765`, ink `#26251F`, muted `#6A6659`. Blok warna pastel Tazk = turunan
`primaryContainer`/`honeyContainer` (bukan palet baru).

---

## 4. Komponen khas (yang menciptakan "mahal")

1. **Availability strip** — pill gelap berisi `NEW` + "Available on macOS Windows Linux iOS Android".
   Fungsi UX: **bukti sosial instan** sebelum user scroll.
2. **Mascot di dalam H1** — logo (kotak ungu rounded dengan dua mata) *diselipkan di tengah
   judul* "Meet ▩ OpenBot". Ini ciri brand paling kuat; teks tetap terbaca oleh screen reader.
3. **Split download button** — pill putih "Download for Windows" + segmen chevron terpisah
   (divider 1px). Satu komponen, dua aksi: unduh default / pilih platform.
4. **Mockup aplikasi asli di hero** — bukan collage screenshot: jendela dengan traffic lights,
   sidebar berisi daftar agen (avatar blob berwarna), panel kanan dengan tab
   `Mermaid · Preview · Code · Copy · Expand`, lalu kartu file. Radius 12, inset highlight 1px.
5. **Kartu fitur** — radius ~20–24, border `text 8%`, fill `text 5%`, isi: visual mini +
   h3 24px + satu paragraf 15–16px. Grid **1 kolom** pada lebar 753 (bukan 2–3) → tiap kartu
   dapat ruang; alternatif untuk Tazk: 2 kolom di desktop.
6. **Kartu penawaran berwarna** (4 buah: pastel lavender/mint/amber/sky) dengan ikon besar
   di kanan atas, eyebrow kecil, judul, deskripsi.
7. **FAQ** — daftar pertanyaan + jawaban (progressive disclosure).
8. **Art honeycomb** — heksagon berisi radial-gradient multi-warna; **murni CSS**, bukan gambar.
9. **Footer** — brand + deskripsi + CTA + 6 sosial + 4 kolom link + baris bawah (hak cipta,
   ketersediaan platform). Total link ~40: pola "link farm" untuk SEO.

---

## 5. Motion — yang benar-benar berjalan (diukur `getAnimations`)

| Animasi | Durasi | Easing | Target |
|---|---|---|---|
| `landing-header-enter` | 240ms | linear | header |
| `landing-hero-in` | **500ms** | linear (delay via stagger) | availability, title, description |
| `landing-hero-in` (aksi) | **400ms** | linear | baris tombol |
| `landing-enter` | 240ms | linear | mockup app di hero |
| `landing-typing` | **1200ms** ×3 | linear | teks di dalam mockup |
| `landing-marquee` | **36.000ms** | linear | pita kata (marquee) |
| `landing-footer-heart` | 1800ms | linear | ikon hati di footer |
| **Reveal saat scroll** | 500ms + stagger **40ms** | `cubic-bezier(.22,1,.36,1)` | `[data-revealed]` |
| Hover: warna/border/bg | **160ms** | default | 61+52 elemen |
| Hover: transform | **120–200ms** | **`cubic-bezier(.23,1,.32,1)`** | 48–52 elemen (tombol/kartu) |

Detail reveal: properti = `opacity 0→1`, `translateY 12px→0`, `blur 3px→0`.
**Bukti render:** saat scroll, kartu tertangkap dalam keadaan blur + setengah transparan
(screenshot `features`), artinya efeknya nyata dan bertahap per elemen.

Catatan penting:
- Reveal baru aktif setelah masuk viewport: pada load **0/16** elemen berstatus
  `data-revealed="true"`; setelah scroll ke section berikutnya baru bertambah.
- Reduced-motion: seluruh animasi dimatikan (`animation:none`).
- Motion-nya **tidak mengganggu**: tidak ada loop besar kecuali marquee 36 detik (sangat lambat)
  dan typing kecil di dalam mockup.

**Tazk mapping (token sendiri):** reveal 320ms `easeStandard` + stagger 40ms; hover 150ms
`easeStandard`; hover transform 160ms `easeGentle`; tanpa marquee/typing (itu ciri mereka,
bukan kebutuhan kita). Wajib hormati `MediaQuery.disableAnimations`.

---

## 6. Strategi aset (temuan paling berdampak)

| Jenis | Jumlah | Catatan |
|---|---|---|
| `<svg>` | **198** | logo, ikon fungsional (`download`, `arrow-right`, `check`, `users`, `puzzle`, …) |
| Gambar raster | **2** | hanya ikon plugin kecil 24px (natural size 0 = gagal load) |
| Video | **0** | tidak ada |
| `background-image` | 12 | semuanya `radial-gradient`/`linear-gradient` CSS (art honeycomb) |

Artinya: **seluruh kekayaan visual dibangun dari kode** — tajam di semua DPR, tanpa
waterfall gambar, tanpa CLS dari gambar. Ini yang membuatnya terasa cepat & premium.

**Konsekuensi untuk Tazk:** jangan tempel PNG maskot 1,5 MB (`otter-with-sprout.png`
941×1672, **tanpa alpha**, `Format24bppRgb`) sebagai gambar hero. Wajib: turunkan ukuran
(WebP/AVIF + `srcset`), pakai SVG logo untuk lockup, dan CSS gradient untuk aksen.
Maskot tetap dipakai — tapi sebagai **elemen komposisi** (mis. diselipkan di judul seperti
pola #2), bukan gambar tempelan.

---

## 7. Pola UX yang layak dipinjam

1. Bukti sosial/kompatibilitas **sebelum** scroll (availability strip).
2. CTA utama = **satu tombol dominan** + satu sekunder (tidak ada 4 tombol bersaing).
3. Tunjukkan **produknya**, bukan ilustrasi abstrak: mockup UI asli > screenshot collage.
4. Satu kolom baca 720px untuk teks penjelas; visual boleh lebar penuh.
5. Jeda ritme lewat **blok warna pastel** setelah 2 section gelap.
6. Reveal = alat **urutan baca**, bukan hiasan: hanya elemen yang masuk viewport.
7. FAQ menjawab keberatan ("gratis?", "data ke mana?", "aman?") — bukan fitur.
8. Footer lengkap: privacy, changelog, status, kontak.

## 8. Jebakan yang TIDAK boleh ditiru

| Jebakan openbot | Risiko | Aturan Tazk |
|---|---|---|
| Elemen `opacity:0` sampai JS reveal jalan | Tanpa JS / JS gagal → **konten tak terlihat**; screenshot/SEO rapuh | Teks kritis tetap terlihat tanpa JS (reveal hanya untuk elemen dekoratif) |
| H1 80px weight 500 + tracking −5.2px | Bisa memotong di 320px / text-scale besar | Uji 320dp & textScale 1.3; clamp huruf |
| 198 SVG + banyak blur/backdrop | Bisa berat di HP kelas bawah | Batasi backdrop-filter; ukur before/after |
| Blok warna pastel sebagai dekorasi | Mudah jadi slop kalau sembarangan | Hanya turunan token Tazk (`primaryContainer`/`honeyContainer`) |
| Marquee + typing | Distraksi | Tidak dipakai |
| Brand mereka (ungu `#d6adf2`, biru `#007cf7`, honeycomb, Inter) | Plagiarisme visual | Dilarang; pakai Sage & Sand + Fredoka/PJS + otter |

---

## 9. Yang masih menunggu keputusan owner (mode desain terpisah)

- Arah hero: maskot **diselipkan di judul** (pola openbot) atau maskot besar terpisah?
- Urutan section untuk Tazk: mana 6 fitur yang pantas jadi kartu?
- Intensitas motion: subset mana yang dipakai (reveal saja? + hover lift?).
- Aset: perlu generate turunan maskot untuk web (WebP/AVIF) — siapa yang menghasilkan.

---

## 10. Resep mengulang bedah ini (standar minimal, jangan diturunkan)

Kalau ada referensi web baru, jalankan **urutan ini**, bukan fetch CSS:

1. **Render dulu.** Buka di browser in-app, `tabs.open` + `wait(load)`. Jangan menyimpulkan apa pun
   dari CSS/markup mentah.
2. **Ukur struktur & tipografi** dengan `evaluate`: `getComputedStyle` + `getBoundingClientRect`
   untuk h1/h2/h3/body/CTA, lalu simpan `y` dan tinggi tiap section.
3. **Ukur 3 viewport** (390/768/1440) dengan trik iframe same-origin selebar target, lalu baca
   `contentWindow.innerWidth` + computed style **di dalam** iframe. Verifikasi `innerWidth` benar.
4. **Ukur motion yang berjalan**: `document.getAnimations()` (durasi/easing/nama) **dan**
   `transition` per elemen — dua peran berbeda (reveal vs hover). Jangan hanya baca `@keyframes`.
5. **Hitung aset & berat**: `performance.getEntriesByType('resource')` → transferSize per initiatorType,
   daftar 8 file terberat, total KB. Cek juga `<img>`/`<video>`/`background-image` nyata.
6. **Screenshot sebagai bukti**: viewport + full-page (patuhi batas 16 MP) + satu tangkapan saat
   scroll untuk melihat state animasi.
7. **Fingerprint framework** dari marker HTML (`$_TSR` = TanStack) atau grep nama library di bundle;
   jangan menebak dari nama file.
8. **Tulis dokumen dengan kolom bukti**, dan bagian **"yang tidak diukur"** wajib ada.
9. **Aset sendiri, bukan milik mereka.** Ambil pola/teknik; produksi aset Tazk dari `assets/mascot`/
   `assets/logo` (Pillow → WebP, `srcset`), lalu hitung ulang KB sebelum/sesudah.

**Larangan:** mengklaim cakupan tanpa metode; menyimpulkan font/easing/aset dari deklarasi CSS;
menyalin warna/logo/ilustrasi/teks brand referensi.