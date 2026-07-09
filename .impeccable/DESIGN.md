# Tazk — Design System Context

## Mood / Vibe
Playful & colorful, terasa fun dan selaras tema gamifikasi RPG (XP, level, badge, streak rank) — namun tetap tidak childish berlebihan. Hangat & terstruktur (referensi Me+). Konsisten di light & dark mode.

## Warna — Tema "Warna Alam"
- **Primary:** Hijau daun / forest green 🌿 — signature utama, growth metaphor
- **Secondary/Accent:** Kuning keemasan / oranye hangat 🌻 — elemen gamifikasi (XP bar, badge, celebration)
- **Supporting:** Coklat tanah / terracotta 🌰 — kartu, border, elemen sekunder
- **Dark Mode:** Background forest deep green (bukan hitam pekat), aksen hijau muda & kuning tetap vibrant
- Hex/shade spesifik ditentukan saat implementasi tema (`lib/core/theme/`)

## Typography
Belum dipilih — pilih Google Font yang playful tapi tetap terbaca & terstruktur (bukan font dekoratif/sulit dibaca), sesuai vibe "hangat & terstruktur". Tunggu konfirmasi user sebelum setup di tema.

## Three Dials

- **DESIGN_VARIANCE:** Medium-High — banyak elemen visual (badge, avatar, XP bar, streak rank, kosmetik unlock) tapi tetap dijaga terstruktur ala Me+, bukan riuh/berantakan.
- **MOTION_INTENSITY:** Medium baseline (transisi antar halaman smooth & slow/tenang), dengan spike tinggi di momen spesifik: checkbox pop + confetti, full-screen celebration streak, XP bar fill + glow + bounce, badge/kosmetik unlock (card flip/shine), widget flicker api.
- **VISUAL_DENSITY:** Medium — Home menampilkan ringkasan gamifikasi + task hari ini + habit hari ini sekaligus, perlu hierarki jelas tapi tidak sesak (referensi Me+: compact tapi scannable).

## UI Library
Flutter built-in Material + custom theming (bukan pakai shadcn/vengeance — itu untuk web). Animasi kompleks (confetti, celebration, badge unlock) pakai Lottie.

## Device Priority
Mobile-first, Android-only, portrait.
