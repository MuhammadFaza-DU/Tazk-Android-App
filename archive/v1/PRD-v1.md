# PRD — Tazk

> Aplikasi mobile produktivitas untuk Gen Z

---

## 1. Inti Produk

- **Nama Project:** Tazk
- **Masalah yang Diselesaikan:**
  Gen Z sering merasa *overwhelmed* dengan banyaknya tugas yang menumpuk, kesulitan membangun habit/rutinitas yang konsisten, serta kesulitan mengatur waktu di antara kuliah, kerja, dan kehidupan sosial.
- **Solusi / Differentiator Utama:**
  Kombinasi task management + habit tracking + sistem gamifikasi RPG-style (XP, level, streak rank, unlock kosmetik) yang jarang digabungkan dalam satu app produktivitas — dilengkapi widget homescreen dan Pomodoro/Focus Timer yang terintegrasi langsung dengan progress habit *(detail lengkap di section 3 — Fitur & Fungsi)*
- **Target Pengguna:** Gen Z secara umum (mahasiswa, pekerja muda, dan yang sejenis — tidak dibatasi satu segmen spesifik)
- **Value Utama:**
  Membantu user lebih mudah mengelola waktu, menstruktur tugas, membangun habit, tetap produktif, dan lebih bersemangat menjalani hari.

---

## 2. Budget, Constraint & Target Platform

- **Budget:** Full gratis — seluruh tools & library yang digunakan open-source, tanpa biaya development (tidak butuh hosting/server karena aplikasi 100% offline)
- **Constraint Teknis:**
  - Harus bisa digunakan offline
  - Harus gratis untuk user — tanpa iklan, tanpa subscription/paywall
- **Deadline / Timeline:** Fleksibel, tidak ada tenggat waktu ketat — prioritas pada kualitas, bukan kecepatan rilis
- **Sub-tipe Aplikasi:** Mobile
- **Target Platform:** Android saja (Android-only)
- **Minimum OS Version:** Android 10+ (API 29)

---

## 3. Fitur & Fungsi

### 3.0 Onboarding & Splash Screen
- **Splash Screen:** animasi 3D — visual pohon tumbuh (growing tree), selaras dengan tema growth/habit-building di Tazk. Durasi 2-4 detik, kemungkinan disertai logo/nama app "Tazk" muncul di akhir animasi (detail visual didalami lebih lanjut di tahap desain)
- **Onboarding nama:** saat pertama kali buka app, user diminta mengisi **nama** (bebas, tanpa validasi keunikan, tidak perlu koneksi internet). Nama dipakai untuk personalisasi tampilan app (misal sapaan "Halo, [Nama]!")
- **Tidak ada sistem akun/login** — data 100% lokal di device

### 3.1 Tasks (Manajemen Tugas Non-Recurring)
- **Field:** Judul (wajib), Tanggal (wajib), Jam+Menit (opsional — kosong = bebas kapan saja hari itu), Prioritas (Low/Medium/High), Checklist/subtask, Lokasi (opsional)
- **Status:** Selesai / Belum saja
- **Reminder:** saat jam+menit tiba, atau default 2 jam sebelum ganti hari jika kosong
- **Duplikasi:** ada fitur duplikat task cepat
- **Cara selesai:** cukup centang, tanpa syarat subtask harus selesai dulu (checklist/subtask bersifat opsional, tidak wajib diisi)
- **Auto-complete subtask:** saat task utama dicentang selesai (dari dalam app maupun dari widget), semua subtask/checklist di dalamnya otomatis ikut tercentang selesai juga — berlaku konsisten di semua entry point
- **Tampilan:** hanya task hari itu, urut prioritas → jam+menit terdekat
- **XP:** rata untuk semua task

### 3.2 Habits (Rutinitas Berulang)
- **Field:** Nama, Frekuensi (Harian/Mingguan/Bulanan/Custom), Waktu pelaksanaan (opsional)
- **Progress bertahap:** ada, diselesaikan via Pomodoro/Focus Timer
- **Cara selesai:** 1x checklist per hari
- **Reminder:** sama seperti Task
- **Streak (berlaku sama untuk Task & Habit, level harian umum):**
  - Naik jika ada ≥1 task/habit selesai hari itu
  - Kosong (tidak ada yang selesai) → potong streak, kecuali punya freeze (auto-pakai, streak lanjut)
  - Freeze baru didapat tiap 3 hari berturut-turut tanpa bolong
- **Hapus habit:** histori/streak tetap tersimpan, habit jadi tidak aktif (bukan hard delete)
- **Edit habit:** tidak mempengaruhi streak keseluruhan (streak = level harian umum, bukan per-habit)

### 3.3 Kalender
- **Fungsi:** menampilkan task & habit terjadwal (bukan bikin time-block manual)
- **Tampilan:** Bulanan
- **Sumber data:** otomatis dari Task & Habit
- **Interaksi:** drag & drop untuk reschedule
- **Konflik jadwal:** tidak ada indikator khusus

### 3.4 Pomodoro / Focus Timer
- **Durasi:** kustomisasi bebas
- **2 mode:** Terkait Habit (progress auto-tercatat) / Mode Bebas Mandiri (tanpa tracking apapun)
- **Progress:** harus 1 sesi penuh baru tercatat (tidak ada partial)
- **Interupsi:** timer tetap jalan di background
- **Selesai sesi:** ada suara/notifikasi
- **XP:** tidak langsung dari Pomodoro, hanya lewat progress habit yang ter-track

### 3.5 Reminder / Notifikasi
- **Sifat:** standar (bukan adaptive)
- **Streak warning:** notifikasi malam hari jika belum ada yang selesai hari itu
- **Kontrol:** bisa atur preferensi per kategori
- **Notifikasi tambahan:** saat freeze otomatis terpakai

### 3.6 Sistem Gamifikasi (MVP — versi simpel)
- **XP & Level:** 1 level/XP overall, formula `XP_needed = 100 * level`
- **Sumber XP:** streak habit aktif (makin banyak habit dijaga, makin besar XP), menyelesaikan task
- **Reward Level Up (Kosmetik):** tidak ada di level biasa; kelipatan 10 level → unlock kosmetik (avatar, ikon custom, dll)
- **Streak Rank/Title:** Perintis (1-6 hari), Petarung (7-29), Penakluk (30-59), Sang Ahli (60-89), Sang Master (90-119), Legenda (120+)
- **Badge:** sistem terpisah dari kosmetik — didapat otomatis saat pertama kali mencapai tiap milestone Streak Rank di atas (misal: Badge "Petarung" didapat saat pertama kali streak menyentuh 7 hari). Badge bersifat permanen sebagai koleksi/pencapaian (tidak hilang meski rank/streak berubah lagi nanti), ditampilkan terpisah dari Avatar Collection di halaman Profil

### 3.7 Widget
- Widget gabungan Today's Tasks & Today's Habits (2 kolom, bisa dikonfigurasi tampilkan salah satu saja)
- Widget Streak Counter — angka streak aktif di homescreen

### Animasi Khusus (semua masuk MVP)
- Checkbox "pop" + coret + micro-confetti saat task/habit selesai
- Full-screen celebration saat capai milestone streak/rank baru
- XP bar fill smooth + flash/glow + scale-bounce saat level up
- Efek "unlock" (card flip/shine sweep) saat dapat badge/kosmetik baru
- Widget streak dengan animasi flicker subtle pada ikon api

### Differentiator Utama
Kombinasi task management + habit tracking + sistem gamifikasi RPG-style (XP, level, streak rank, unlock kosmetik) yang jarang digabungkan dalam satu app produktivitas.

### Deferred ke Fase Berikutnya
- Sistem RPG multi-stat (misal: level otot, fokus, disiplin — berbasis kategori habit)
- Sistem Leaderboard (perlu akun & online)

---

## 4. Struktur Layar

### Navigasi
- **Pola navigasi:** Sidebar Nav (drawer) — diakses lewat ikon ☰ (hamburger) di kiri atas, berlaku di semua screen utama
- **Urutan menu sidebar:** Home → Tasks → Habits → Kalender → Pomodoro → Profil → Pengaturan
- **Pengaturan** berisi sub-bagian: Notifikasi, Tampilan/Tema, Bahasa, Tentang App (bukan entry sidebar terpisah)
- **Profil** berisi: edit nama & avatar (dipindah dari Pengaturan)

### Daftar Screen
1. Splash Screen
2. Onboarding — isi nama
3. Home / Dashboard
4. Tasks (list harian)
5. Tambah/Edit Task
6. Habits (list)
7. Tambah/Edit Habit
8. Detail Habit
9. Kalender (bulanan)
10. Pomodoro / Focus Timer
11. Profil
12. Pengaturan

### Wireframe

**Splash Screen**
```
+------------------------------------------+
| [SPLASH SCREEN]                          |
+------------------------------------------+
|                                            |
|                                            |
|         [Animasi 3D Pohon Tumbuh]         |
|              (2-4 detik)                  |
|                                            |
|              Tazk                         |
|         (logo/nama muncul di akhir)       |
|                                            |
+------------------------------------------+
```

**Onboarding (Isi Nama)**
```
+------------------------------------------+
| [ONBOARDING]                             |
+------------------------------------------+
|                                            |
|     Selamat datang di Tazk!               |
|     Siapa nama kamu?                      |
|                                            |
|     [Input: Nama]                         |
|                                            |
|            [Tombol: Mulai]                |
|                                            |
+------------------------------------------+
```

**Home / Dashboard**
```
+------------------------------------------+
| [☰]  Tazk               Halo, [Nama]!    |
+------------------------------------------+
| [Ringkasan Gamifikasi]                    |
|  Level 12 · XP Bar [====------] 620/1200  |
|  🔥 Streak 15 hari · Petarung              |
+------------------------------------------+
| [Tasks Hari Ini]                          |
|  [ ] Tugas Kuliah A       High  08:00     |
|  [ ] Rapat Organisasi     Med   13:00     |
|  [ ] Belanja bulanan      Low             |
+------------------------------------------+
| [Habits Hari Ini]                         |
|  [ ] Olahraga pagi                        |
|  [ ] Baca buku (progress 15/30 menit)     |
+------------------------------------------+
| [Tombol Cepat: ▶ Mulai Pomodoro]          |
+------------------------------------------+
```

**Sidebar Nav (saat ikon ☰ dipencet)**
```
+------------------+
| Tazk             |
+------------------+
|  🏠 Home          |
|  ✅ Tasks         |
|  🔁 Habits        |
|  📅 Kalender      |
|  ⏱  Pomodoro      |
|  👤 Profil        |
|  ⚙️  Pengaturan    |
+------------------+
```

**Tasks (List Harian)**
```
+------------------------------------------+
| [☰]  Tasks — Hari Ini            [+]      |
+------------------------------------------+
|  [ ] Tugas Kuliah A       High  08:00 [⧉] |
|  [ ] Rapat Organisasi     Med   13:00 [⧉] |
|  [ ] Belanja bulanan      Low         [⧉] |
|                                            |
|  (diurutkan: prioritas → jam terdekat)    |
|  [⧉] = tombol duplikat cepat              |
+------------------------------------------+
```

**Tambah/Edit Task**
```
+------------------------------------------+
| [< Kembali]  Tambah Task                 |
+------------------------------------------+
|  Judul: [___________________]            |
|  Tanggal: [___/___/____]                 |
|  Jam (opsional): [__:__]                 |
|  Prioritas: ( ) Low ( ) Med ( ) High     |
|  Lokasi (opsional): [___________]         |
|  Checklist/Subtask (opsional):            |
|   [+] Tambah item                         |
|                                            |
|            [Tombol: Simpan]               |
+------------------------------------------+
```

**Habits (List)**
```
+------------------------------------------+
| [☰]  Habits                       [+]     |
+------------------------------------------+
|  [ ] Olahraga pagi        Harian          |
|  [ ] Baca buku            15/30 menit ⏱   |
|  [ ] Meditasi              3x/minggu       |
+------------------------------------------+
|  (tap habit untuk lihat Detail)           |
+------------------------------------------+
```

**Tambah/Edit Habit**
```
+------------------------------------------+
| [< Kembali]  Tambah Habit                |
+------------------------------------------+
|  Nama: [___________________]              |
|  Frekuensi: ( ) Harian ( ) Mingguan       |
|             ( ) Bulanan ( ) Custom        |
|  Waktu (opsional): [__:__]                |
|  Progress bertahap? ( ) Ya ( ) Tidak      |
|   └─ Target waktu: [__ menit]             |
|                                            |
|            [Tombol: Simpan]               |
+------------------------------------------+
```

**Detail Habit**
```
+------------------------------------------+
| [< Kembali]  Olahraga Pagi     [Edit][🗑] |
+------------------------------------------+
| Frekuensi: Harian                         |
| Streak kontribusi: aktif                  |
+------------------------------------------+
| [Histori]                                 |
|  ✓ Sen  ✓ Sel  ✓ Rab  ✗ Kam  ✓ Jum        |
|  (kalender mini / grid histori)           |
+------------------------------------------+
```

**Kalender (Bulanan)**
```
+------------------------------------------+
| [☰]  Kalender — Juli 2026        [<] [>] |
+------------------------------------------+
|  Sen Sel Rab Kam Jum Sab Min              |
|   1   2   3   4   5   6   7               |
|           •       •                      |
|   8   9  10  11  12  13  14               |
|   •   •                                   |
|  ...                                      |
|  (• = ada task/habit di tanggal itu)      |
+------------------------------------------+
|  [Tap tanggal → lihat detail hari itu]    |
|  [Drag & drop item untuk reschedule]      |
+------------------------------------------+
```

**Pomodoro / Focus Timer**
```
+------------------------------------------+
| [☰]  Pomodoro                            |
+------------------------------------------+
|  Mode: ( ) Terkait Habit ( ) Bebas       |
|   └─ [Pilih Habit: Baca buku ▾]          |
|                                            |
|  Durasi: [__ menit]  (kustomisasi bebas) |
|                                            |
|            ⏱  00:00                      |
|         [Tombol: Mulai]                   |
+------------------------------------------+
```

**Profil**
```
+------------------------------------------+
| [☰]  Profil                      [Edit]  |
+------------------------------------------+
|         [Avatar]                          |
|         [Nama]                    [Edit]  |
|                                            |
|  Level 12 · XP [====------] 620/1200      |
|  🔥 Streak 15 hari · Petarung              |
+------------------------------------------+
| [Badge Collection]                        |
|  [🏅][🏅][🏅][🔒][🔒]                     |
+------------------------------------------+
| [Avatar Collection — unlock per 10 level] |
|  [👤][👤][🔒][🔒]                         |
+------------------------------------------+
```

**Pengaturan**
```
+------------------------------------------+
| [☰]  Pengaturan                          |
+------------------------------------------+
|  Notifikasi                          [>]  |
|   └─ Task, Habit, Streak Warning, Freeze  |
|  Tampilan: ( ) Light ( ) Dark             |
|  Bahasa: ( ) Indonesia ( ) English        |
|  Tentang App                         [>]  |
+------------------------------------------+
```

### Widget (Homescreen HP — di luar konteks in-app)

**Widget 1: Today's Tasks & Habits (gabungan, 2 kolom)**
```
+------------------------------------------+
| Tazk — Hari Ini                          |
+------------------+------------------------+
| TASKS            | HABITS                 |
|  [ ] Tugas A     |  [ ] Olahraga pagi     |
|  [ ] Rapat Org   |  [ ] Baca buku         |
|  [ ] Belanja     |  [ ] Meditasi          |
+------------------+------------------------+
```
*(Bisa dikonfigurasi user untuk cuma tampilkan salah satu kolom saja)*

**Widget 1 — Varian: Tasks Only**
```
+------------------------------------------+
| Tazk — Tasks Hari Ini                    |
+------------------------------------------+
|  [ ] Tugas Kuliah A            08:00     |
|  [ ] Rapat Organisasi          13:00     |
|  [ ] Belanja bulanan                     |
+------------------------------------------+
```

**Widget 1 — Varian: Habits Only**
```
+------------------------------------------+
| Tazk — Habits Hari Ini                   |
+------------------------------------------+
|  [ ] Olahraga pagi                       |
|  [ ] Baca buku (15/30 menit)             |
|  [ ] Meditasi                            |
+------------------------------------------+
```

**Widget 2: Streak Counter**
```
+------------------+
|                  |
|    🔥 15 hari    |
|   Streak aktif   |
|    Petarung      |
|                  |
+------------------+
```

Catatan:
- Checkbox di widget bisa langsung dicentang dari homescreen (auto-complete subtask berlaku juga dari widget)
- Widget Streak Counter punya animasi flicker subtle di ikon api

---

## 5. Alur User

### First-time Flow
```
Buka app → Splash Screen (animasi pohon, 2-4 detik) → Onboarding (isi nama)
→ Home Dashboard
```

### Daily Flow (returning user)
```
Buka app → Splash Screen → langsung Home Dashboard
→ Lihat ringkasan XP/streak, task & habit hari ini
→ Centang task/habit selesai, atau mulai Pomodoro
→ Buka menu lain via Sidebar (Tasks/Habits/Kalender) sesuai kebutuhan
```

### Edge Cases
- Tidak ada task/habit hari itu → tampilkan **empty state** di Home/Tasks/Habits
- Field wajib kosong saat submit form (misal judul task) → muncul **peringatan validasi**, form tidak bisa disimpan
- Mode offline total → **tidak ada masalah**, seluruh app berjalan penuh tanpa internet
- Centang dari widget → **wajib sinkron**, status tercentang juga reflect langsung di dalam app (bukan cuma di widget)

### Error States
- **Permission notifikasi ditolak:** banner/dialog muncul saat user buka app ("Notifikasi dimatikan, aktifkan supaya reminder berfungsi") dengan tombol langsung ke Pengaturan HP dan tombol **dismiss (✕)** kalau belum mau aktifkan; juga ada **indikator pasif** status notifikasi di halaman Pengaturan in-app untuk dicek manual kapan saja
- **Data corrupt/hilang:** graceful error handling — app **tidak crash total**, tampilkan pesan error jelas ke user, dan reset ke **state kosong yang aman** tanpa kehilangan seluruh app (bukan auto-backup/restore, cukup fallback aman)

---

## 6. Design & Tema

**Mood / Vibe Visual:**
Playful & colorful — warna cerah, ikon/ilustrasi yang terasa fun, selaras dengan tema gamifikasi RPG (XP, level, badge, streak rank). Namun tetap dijaga agar tidak childish berlebihan — terinspirasi kombinasi dari referensi Me+ yang terasa hangat & terstruktur. Konsistensi mood ini wajib terjaga baik di **light mode** maupun **dark mode**.

**Warna Utama — Tema "Warna Alam":**
- **Primary:** Hijau daun/forest green 🌿 — warna signature utama, selaras dengan tema pertumbuhan (splash screen pohon tumbuh, growth metaphor habit-building)
- **Secondary/Accent:** Kuning keemasan / oranye hangat 🌻 — dipakai untuk elemen gamifikasi (XP bar, badge, celebration/reward moments), kontras hangat dari hijau
- **Supporting:** Coklat tanah / terracotta 🌰 — untuk elemen sekunder, kartu, border, dan detail pendukung
- **Dark Mode:** Background dasar hijau tua/forest deep green (bukan hitam pekat generik), dengan aksen hijau muda & kuning tetap vibrant di atasnya, supaya tetap terasa "alam" dan konsisten dengan identitas light mode
- *(Catatan: hex code spesifik & shade lengkap ditentukan nanti di tahap desain visual/design system, bukan di level PRD)*

**Device Priority:**
Mobile-first, Android-only

**Motion Style Global:**
Smooth & slow — transisi antar halaman terasa halus dan tenang, bukan snappy/cepat. Konsisten dengan animasi-animasi spesifik yang sudah dibahas di section Fitur (checklist pop, streak celebration, XP bar fill, badge unlock)

**Referensi Visual:**
Me+ (Play Store) — app self-care/routine planner dengan kesan hangat, terstruktur, dan widget-driven; jadi acuan untuk keseimbangan antara "playful" dan "tidak berlebihan/tetap fungsional"

---

## 7. Platform Concerns (Mobile — Android)

- **Permission:**
  - **Notifikasi** — wajib, untuk reminder task/habit, streak warning, freeze terpakai
  - **Storage** — tidak perlu permission eksplisit (app-scoped storage otomatis dari OS, tanpa dialog izin)
  - Tidak ada permission lain (kamera, lokasi/GPS, kontak, mikrofon tidak dibutuhkan — field "Lokasi" di Task bersifat teks manual, bukan GPS)
- **Offline:** 100% offline, tidak ada fitur yang membutuhkan koneksi internet
- **Notifikasi:** local notification (dijadwalkan dari dalam app, tanpa server) — tampil di tray notifikasi HP seperti notifikasi umum lainnya
- **Deep Link:** tidak dibutuhkan
- **Background Task:**
  - Local notification scheduling (supaya reminder muncul tepat waktu meski app tidak dibuka)
  - Pomodoro timer tetap berjalan saat app di-minimize
  - Tidak ada background sync (karena tidak ada server/backend)

---

## 8. Spesifikasi Teknis

- **Framework Utama:** Flutter
  - Digunakan untuk target Android saja
  - Performa native yang baik untuk animasi smooth
  - Gratis & open-source
  - Mendukung pembuatan widget homescreen Android (via Home Widget plugin)
- **Database Lokal:** SQLite (via `sqflite` atau `drift`)
  - 100% offline, gratis, ringan, cocok untuk data terstruktur (task, habit, histori, XP)
- **Animasi Splash Screen (3D — pohon tumbuh):**
  - Animasi di-generate/di-render di luar aplikasi (Three.js, Blender, atau tool 3D/AI video generator lain), lalu di-export menjadi video, dan diputar di dalam app menggunakan package `video_player`
  - Spesifikasi video:
    - Format: MP4 (H.264)
    - Durasi: 2-4 detik
    - Resolusi: minimal 1080x1920 (portrait)
    - Ukuran file: idealnya di bawah 5MB
    - Background: sesuai tema warna Tazk (atau transparan jika ingin di-overlay)
- **Animasi UI Umum:** Flutter built-in animation (implicit/explicit) + Lottie untuk animasi yang lebih kompleks (confetti, celebration, badge unlock)
- **Local Notification:** `flutter_local_notifications` — untuk reminder task/habit, streak warning, notifikasi freeze terpakai (semua dijadwalkan dari dalam app, tanpa server)
- **State Management:** Riverpod
- **Backend / API Eksternal:** Tidak dibutuhkan — aplikasi 100% offline, tidak ada integrasi API/service eksternal
- **Biaya Development:** 100% gratis — seluruh tools & library yang digunakan open-source, tidak ada biaya lisensi atau subscription *(biaya submit ke Play Store dibahas terpisah di section Distribusi & Publikasi)*

---

## 9. Roadmap Pengembangan

Tidak ada roadmap versi/waktu formal — pengembangan berjalan fleksibel tanpa tenggat, dengan fokus MVP terlebih dahulu (semua fitur di section 3 di luar bagian "Deferred").

**Future Ideas** *(belum ditargetkan ke versi/waktu tertentu — dipertimbangkan lagi setelah MVP stabil)*:
- Sistem RPG multi-stat (misal: level otot, fokus, disiplin — berbasis kategori habit)
- Sistem Leaderboard (membutuhkan akun & koneksi online)

---

## 10. Struktur Proyek & Environment

- **Struktur Proyek:** Single repo/folder Flutter (bukan monorepo) — tidak ada backend terpisah karena aplikasi 100% offline
- **Environment:** 1 environment saja (langsung production/release build), tidak ada dev/staging terpisah

**Struktur Folder (garis besar):**

```
tazk/
├── android/                 # Konfigurasi native Android
├── assets/
│   ├── videos/               # Video splash screen (animasi pohon)
│   ├── animations/           # File Lottie (confetti, badge unlock, dll)
│   ├── icons/                 # Icon app & ilustrasi
│   └── fonts/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/                  # Konstanta, tema, util, extension
│   │   ├── theme/
│   │   ├── constants/
│   │   └── utils/
│   ├── data/
│   │   ├── database/           # Setup SQLite (sqflite/drift)
│   │   ├── models/              # Task, Habit, Streak, XP, dll
│   │   └── repositories/
│   ├── features/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── tasks/
│   │   ├── habits/
│   │   ├── calendar/
│   │   ├── pomodoro/
│   │   ├── gamification/        # XP, level, streak, badge
│   │   ├── profile/
│   │   └── settings/
│   ├── notifications/           # Setup flutter_local_notifications
│   ├── widgets/                  # Home widget Android
│   └── providers/                 # Riverpod providers
├── test/                    # Unit & widget test
├── pubspec.yaml
└── PRD.md
```

---

## 11. Distribusi & Publikasi

- **Target Store:** Google Play Store saja (sesuai Target Platform Android-only di section 2)
- **Akun Developer:** Sudah siap — user sudah punya budget untuk biaya registrasi Google Play Console (~$25, one-time)
- **Privacy Policy:** Dibutuhkan sebagai syarat submit ke Play Store, meskipun app 100% offline dan tidak mengumpulkan/mengirim data pengguna ke server manapun. Cukup 1 halaman statis yang menjelaskan bahwa seluruh data disimpan lokal di device dan tidak dibagikan ke pihak manapun. *(Akan dibantu draft-nya terpisah, di luar PRD ini)*
- **Kategori App:** Productivity (kategori utama), dengan nuansa Lifestyle pada positioning/marketing (habit-building, gamifikasi harian)
- **Target Rating Konten:** Everyone / semua umur (tidak ada konten sensitif)

---
