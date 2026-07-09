# Tazk — Design System Context

## Mood / Vibe
Playful & colorful, terasa fun dan selaras tema gamifikasi RPG (XP, level, badge, streak rank) — namun tetap tidak childish berlebihan. Hangat & terstruktur (referensi Me+). Konsisten di light & dark mode.

## Warna — Tema "Warna Alam"
- **Primary:** Hijau daun / forest green 🌿 — `#2F6B3D` (light) / `#7ED08A` (dark) — signature utama, growth metaphor
- **Secondary/Accent:** Kuning keemasan / oranye hangat 🌻 — `#F0A83C` (light) / `#FFC069` (dark) — elemen gamifikasi (XP bar, badge, celebration)
- **Supporting:** Coklat tanah / terracotta 🌰 — `#B0662E` — kartu, border, elemen sekunder
- **Background (light):** `#FAF7F0` (warm off-white, bukan putih pekat)
- **Background (dark):** `#16231A` (forest deep green, bukan hitam pekat)
- Diimplementasikan di `lib/core/theme/app_colors.dart`

## Typography
Font terpilih (dari font Google, di-bundle offline sebagai asset lokal — bukan via package `google_fonts` yang fetch runtime, karena app 100% offline):
- **Judul (headline/title):** Spicy Rice — bold, playful, jadi identitas visual utama
- **Penjelasan/body (deskripsi, teks panjang):** Sour Gummy — tetap playful tapi lebih terbaca untuk teks panjang
- **Lainnya (label, tombol, tag, UI chrome):** Unkempt — aksen playful di elemen kecil
- Diimplementasikan di `lib/core/theme/app_typography.dart`, font file di `assets/fonts/`

## Three Dials

- **DESIGN_VARIANCE:** Medium-High — banyak elemen visual (badge, avatar, XP bar, streak rank, kosmetik unlock) tapi tetap dijaga terstruktur ala Me+, bukan riuh/berantakan.
- **MOTION_INTENSITY:** Medium baseline (transisi antar halaman smooth & slow/tenang), dengan spike tinggi di momen spesifik: checkbox pop + confetti, full-screen celebration streak, XP bar fill + glow + bounce, badge/kosmetik unlock (card flip/shine), widget flicker api.
- **VISUAL_DENSITY:** Medium — Home menampilkan ringkasan gamifikasi + task hari ini + habit hari ini sekaligus, perlu hierarki jelas tapi tidak sesak (referensi Me+: compact tapi scannable).

## UI Library
Flutter built-in Material + custom theming (bukan pakai shadcn/vengeance — itu untuk web). Animasi kompleks (confetti, celebration, badge unlock) pakai Lottie.

## Device Priority
Mobile-first, Android-only, portrait.
