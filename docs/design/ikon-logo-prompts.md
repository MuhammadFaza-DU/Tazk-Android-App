# Tazk — Kumpulan Prompt Ikon, Maskot, Logo & Aset Visual

Dokumen untuk kamu (owner) generate asetnya di luar, pakai generator gambar favoritmu (Midjourney, DALL·E, Ideogram, Gemini, Flame, dll). Aku yang nanti pasang hasilnya ke project (mipmap semua densitas, adaptive icon, splash, widget, favicon landing page).

Identitas visual Tazk: **tanaman/hijau tenang (Sage & Sand di light, Dusk Forest di dark) + maskot otter imut** sebagai "jiwa"-nya.

> **Status 2026-10-29:** owner sudah generate maskot otter 3D dan tersimpan di repo:
> `assets/mascot/otter-portrait.png`, `otter-waving.png`, `otter-with-sprout.png` (+ `.svg`),
> `assets/logo/tazk-logo.png`. **Yang masih perlu di-generate: ikon app persegi** (launcher +
> adaptive icon) — lihat §2 di bawah. Prompt otter di dokumen ini sudah **diganti otter**.

---

## 0. Konteks brand

- **Produk:** Tazk, app produktivitas Android. Task + habit + Pomodoro + gamifikasi ringan.
- **Maskot:** **"Tazk", seekor otter imut dengan tunas kecil di kepala**. Makna: otter = ceria, lincah, dan senang "bermain" setiap hari; tunas = pertumbuhan (selaras tema habit & streak). Warna bulu otter (krem-honey) selaras dengan token reward kita.
- **Gaya karakter:** 3D glossy empuk (clay render), pastel, mata besar, badan gemoy, TIDAK fotorealistis.
- **Mood app:** kalem, hangat, premium, dengan maskot sebagai sentuhan lucu (bukan app kekanak-kanakan).
- **Palet (Sage & Sand / light):** sage `#4A5A44`, sage muda `#6B7F5E`, clay `#C97B5A`, honey `#D69A3C`, krem `#F4F1EA`, tinta `#26251F`.
- **Palet (Dusk Forest / dark):** forest `#0F1A14`, permukaan `#152219`, mint `#8FE0A9`, honey `#F2C765`, teks `#E8F0E7`.
- **Font display:** Fredoka (rounded, ramah, bersih).

---

## 1. Negative prompt (tempel di SEMUA prompt)

```
sparkles, magic stars, glowing orb, robot, cube, diamond, lightning bolt,
blue-purple gradient, neon, glassmorphism, frosted glass, excessive glow,
photorealistic, realistic fur, scary, sharp teeth, creepy, evil, ugly, blurry,
low quality, extra limbs, distorted, watermark, text, busy background, busy
clipart, childish flash-game style, emoji style
```

---

## 2. Ikon App — wajah otter

### Prompt I-1 (ikon utama, light)

> Cute 3D clay render app icon, close-up face of an adorable chubby otter, round cream-white face with a small green sprout on top of the head, warm honey `#D69A3C` accents, big glossy sparkling eyes, tiny round ears and a small smile, soft subtle blush, gentle studio lighting, soft pastel colors, centered, generous negative space, warm cream background `#F4F1EA`, soft rounded square, no text, no border, square composition, 1024x1024.

### Prompt I-2 (ikon utama, dark)

> Cute 3D clay render app icon, close-up face of an adorable chubby otter, round cream-white face, luminous mint and honey accents matching deep forest background `#0F1A14`, big glossy sparkling eyes, tiny round ears and a small smile, soft subtle blush, gentle studio lighting, pastel-toned with a warm honey `#F2C765` glow on the cheeks, centered, generous negative space, soft rounded square, no text, no border, square composition, 1024x1024.

### Prompt I-3 (ikon minimal flat, alternatif)

> Minimalist flat app icon of a cute otter face, simple rounded shapes, cream and honey `#D69A3C` two-tone, two glossy dot eyes, tiny rounded ears, warm cream background `#F4F1EA`, flat vector style, no gradients, no text, soft rounded corners, square composition, 1024x1024.

---

## 3. Komponen adaptive icon Android

### Latar (background) solid

> Solid flat background for an Android app icon, single color warm cream `#F4F1EA`, no texture, no pattern, no gradient, no border, square, 1024x1024.

### Monokrom (themed icon, siluet)

> Minimalist monochrome silhouette of a cute otter face, single flat color deep sage `#4A5A44`, transparent background, no gradients, no stroke, square composition, 1024x1024.

---

## 4. Logo / wordmark "Tazk"

### Prompt W-1 (wordmark utama)

> Minimalist wordmark logo for a productivity app named "Tazk", lowercase rounded friendly sans-serif font (similar to Fredoka), deep sage green `#4A5A44` text on transparent background, a tiny cute otter face dotting the letter "t", warm honey `#D69A3C` accent, calm premium feel, flat vector, no gradient, no shadow, no tagline, horizontal lockup, transparent background.

### Prompt W-2 (wordmark versi gelap)

> Same minimalist wordmark logo "Tazk", lowercase rounded friendly sans-serif, luminous mint `#8FE0A9` text on transparent background, tiny cute otter face in warm honey `#F2C765`, calm premium, flat vector, transparent background.

---

## 5. Maskot "Tazk" — full body + pose / ekspresi

Karakter dasar (tempel di awal tiap prompt pose):

> A cute chubby otter mascot named Tazk, 3D clay render, soft glossy pastel, round white-cream face and belly with a small green sprout on top of the head of the head and back, warm honey `#D69A3C` accents, big glossy sparkling eyes, tiny round ears, small happy mouth, soft subtle blush, stubby limbs, pastel color palette, gentle studio lighting, centered, transparent background.

### Pose 1 — netral / senang (empty state, profil)

> ... pose: standing upright, waving one stubby paw hello, cheerful and encouraging expression, tiny leaf sprout on top of its head, soft rounded, transparent background.

### Pose 2 — selebrasi (reward, level up, badge, milestone)

> ... pose: jumping and cheering with both stubby paws raised, excited sparkling eyes, small confetti made of tiny leaves and honey drops around it, joyful expression, transparent background.

### Pose 3 — memberi semangat (empty state "belum ada apa-apa")

> ... pose: sitting and leaning forward holding a small glowing sprout with both paws, gentle encouraging smile, warm and supportive mood, a soft halo of light honey color behind it, transparent background.

### Pose 4 — memandu (onboarding)

> ... pose: sitting and pointing one stubby paw to the side as if guiding, friendly teacher expression, transparent background.

### Pose 5 — tidur / istirahat (mode fokus selesai, winding down)

> ... pose: curled up sleeping with a tiny leaf as a pillow, peaceful calm expression, soft rounded, transparent background.

---

## 6. Splash screen

Splash sekarang memakai maskot + wordmark. Video pohon tumbuh lama (`tazk_growth_splash.mp4`) sudah **diarsipkan** di `archive/v1/assets/videos/`. Kalau mau ilustrasi statis cadangan yang menampilkan maskot:

> A calm premium splash screen illustration, the cute chubby otter mascot sitting beside a small growing sprout on a soft mound of soil, watching it with gentle wonder, 3D clay render pastel, sage green `#4A5A44` and honey `#D69A3C` on warm cream `#F4F1EA`, generous empty space at the top for an app title, no text, no watermark, vertical portrait composition 1080x1920.

---

## 7. Landing page (favicon, og:image)

### Favicon (SVG/PNG 512)

> Minimalist favicon of a cute otter face, single flat color deep sage `#4A5A44`, transparent background, simple and legible at 16 pixels, flat vector.

### OG image (1200x630)

> Marketing social share image for a productivity app, the cute 3D clay otter mascot on the left smiling, warm cream `#F4F1EA` background, subtle sage `#4A5A44` and honey `#D69A3C` accents, calm premium editorial style, generous negative space, no text, no watermark, 1200x630.

---

## 8. Catatan teknis untuk hasil generate

- **Format:** ikon & logo minta **PNG transparan** (kecuali yang memang minta latar). Kalau ada **SVG**, lebih baik lagi untuk logo/wordmark.
- **Ikatan karakter:** agar konsisten, tempel bagian "karakter dasar" (§5 paragraf awal) di SETIAP prompt full-body, supaya wajah, warna, dan proporsinya seragam di semua emosi.
- **Ukuran ikon:** minta minimal **1024×1024**. Aku buat turunan 48/72/96/144/192/512 (mdpi..xxxhdpi) dari file itu.
- **Adaptive icon:** amankan elemen penting (wajah) di **66% tengah**; pinggir 18px bisa terpotong mask Android.
- **Setelah generate:** taruh di `assets/icons/` atau bagikan path-nya. Aku verifikasi ukuran, transparansi, warna, lalu pasang ke project.
- **Konsistensi:** pakai palet yang sama di semua aset (daftar hex di §0).