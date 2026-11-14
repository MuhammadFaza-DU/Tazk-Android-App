# Tazk — landing page

Halaman unduhan Tazk v2.0 (Astro 7, static). Bilingual ID/EN, tema terang/gelap, memuat `version.json` untuk pemeriksaan pembaruan di app (T11).

## Perintah

```bash
npm install
npm run dev            # astro dev
npm run build          # hasil di dist/
npm run preview        # pratinjau dist/
npm run check:i18n     # pastikan kamus id/en identik strukturnya
```

## Struktur

- `src/styles/tokens.css` — token Tazk (dari `../../DESIGN.md`) + komponen + motion. Satu-satunya stylesheet.
- `src/i18n/index.ts` — kamus `id`/`en` (tipe `Copy`). Semua teks lewat sini.
- `src/layouts/Base.astro` — shell HTML, script tema (localStorage `tazk-theme`), deteksi bahasa browser, reveal.
- `src/components/` — `Header`, `Hero`, `ChipBar`, `SplitCta`, `GhostCta`, `PhoneMockup`, `FeatureCard`, `TintRow`, `Steps`, `Faq`, `Footer`, `Landing` (perakit).
- `src/pages/` — `index.astro` (ID di `/`), `en/index.astro` (EN di `/en/`), `privasi.astro`, `en/privacy.astro`.
- `public/` — `fonts/` (WOFF2 subset), `img/` (WebP maskot), `version.json`, `downloads/` (letak APK saat rilis).

## Rute & bahasa

- `/` = Indonesia, `/en/` = English.
- Bahasa default mengikuti browser (script kecil di `Base.astro`); pilihan manual disimpan di `localStorage` `tazk-lang` saat toggle diklik.

## Aset

Maskot **tidak punya alpha** (PNG 24bpp, dan SVG hanya pembungkus raster). Di hero, maskot ditempatkan di kartu dengan *blurred backdrop* dari gambar yang sama supaya tidak ada seam, tanpa menambah hex baru.

## Deploy

`vercel --prod` dari folder ini (butuh login Vercel). Setelah domain final diketahui, perbarui `downloadUrl` di `public/version.json` ke domain itu. Tombol unduh otomatis menjadi tautan nyata ketika `public/downloads/tazk.apk` ada (dicek saat build), dan checksum SHA-256 dihitung dari APK itu.

**Rilis terkini: v2.0.1 (versionCode 2002)** — tayang 2026-11-14 di `https://tazk-manager-mfdu.vercel.app`. Prosedur: `flutter build apk --release --target-platform android-arm,android-arm64` → salin APK ke `public/downloads/tazk.apk` → isi `public/version.json` (`version`, `notes`, `sha256` dari `Get-FileHash`) → `npm run build` → `vercel deploy --prod --yes`. Verifikasi: `curl` `version.json` dan APK harus 200, lalu bandingkan SHA-256 hasil unduhan dengan yang tertulis.

## Gate yang sudah diverifikasi

Lihat `../docs/artifacts/landing-gates.json`: kontras AA (light+dark), tanpa scroll horizontal 320–1440, reduced-motion 0 animasi, JS-off copy terbaca, berat 135,4 KB.