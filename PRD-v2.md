# PRD v2 — Tazk

> Upgrade v1 → v2.0. Dokumen requirement ini **sumber kebenaran scope** untuk build.
> Design system kanonik: [`DESIGN.md`](./DESIGN.md). Posisi kerja terkini: [`docs/STATUS.md`](./docs/STATUS.md).
> PRD v1 diarsipkan di `archive/v1/PRD-v1.md`.

Tanggal: 2026-10-30 · Status: **draft untuk review owner**

---

## 1. Executive Summary

### Problem Statement
Tazk v1 (1.1.5) sudah lengkap fiturnya, tapi empat hal membuatnya belum enak dipakai sehari-hari:
1. **Widget tidak sinkron** — centang dari widget baru jalan setelah app dibuka dulu; widget sering basi.
2. **Lag** — cold start, scroll, centang, kalender, dan pomodoro terasa berat (audit menemukan centang = ~300+ channel write + 5x rebuild; APK release 176 MB tanpa shrink/split).
3. **Centang satu arah** — baris yang tercentang tidak bisa dibatalkan langsung.
4. **Tampilan & animasi belum selesai** — masih font sistem, UI material default, dan momen reward belum hidup.

Ditambah sejumlah fitur yang "setengah jadi" (statistik, subtask/lokasi, kategori/pencarian, widget scroll, backup, cek update) dan aset yang belum lengkap (ikon app persegi, avatar, badge).

### Proposed Solution
Upgrade menyeluruh **v2.0**: design system baru (sudah selesai di `DESIGN.md` + 27 board kanvas) diimplementasikan ke kode, performa diperbaiki dulu (T1), widget dibuat benar-benar tersinkron dua arah tanpa perlu buka app, interaksi & animasi dihidupkan, aset dilengkapi, dan semua fitur setengah jadi diselesaikan. Satu rilis besar via landing page sendiri.

### Success Criteria (KPI — terukur)
Lihat §9 (KPI). Ringkas: semua angka performa T1 tercapai + widget centang instan tanpa buka app + semua acceptance criteria fitur lulus + `dart analyze` bersih + `flutter test` hijau + divertifikasi di HP.

---

## 2. User Experience & Functionality

### 2.1 User Personas
- **Mahasiswa / pekerja muda Gen Z** (primer): pakai sesi pendek harian — cek "apa yang penting hari ini", centang task/habit, mulai fokus, lihat progres. Android, offline, tanpa akun.
- **Pengguna offline-first** (sekunder): value = data 100% lokal, tetap berfungsi tanpa internet, backup manual berupa file JSON yang disimpan sendiri.

### 2.2 User Stories inti (dengan Acceptance Criteria)

**US-W1 — Sinkron widget tanpa buka app**
> Sebagai pengguna, saya ingin mencentang task/habit langsung dari widget homescreen **tanpa membuka app**, agar cepat dan tidak ribet.
- **AC:** Tap centang di widget langsung berubah tampilannya (ikon/teks/warna) dan menulis ke DB + menghitung XP/streak + menjadwalkan/membatalkan notifikasi, **tanpa app dibuka**.
- **AC:** Perubahan langsung reflect di app saat app dibuka berikutnya (tidak basi).
- **AC:** Berlaku dua arah (app ↔ widget) untuk semua varian yang memuat task/habit: Tasks&Habits, Tasks Only, Habits Only, Calendar+Tasks+Habits.
- **AC:** XP dari centang-widget dihitung; batal-centang (dari widget juga) **mengurangi XP balik** (anti XP ganda).
- **AC:** Idealnya tetap bekerja setelah HP reboot / app di-force-stop, dengan toleransi teknis yang didokumentasikan (§6.3).
- **AC:** Instan (tanpa delay buatan), tapi tidak menimbulkan polling/boros baterai (§9 pendekatan).

**US-W2 — Anti-basi**
> Sebagai pengguna, saya ingin data widget selalu akurat ketika task/habit/log berubah (termasuk pergantian hari), tanpa harus me-refresh manual.
- **AC:** Setelah pergantian hari (midnight rollover) atau resume app, widget ter-update.
- **AC:** Snapshot di-push ter-debounce & hanya ke widget yang benar-benar terpasang; 0 write bila tidak ada widget terpasang.

**US-P1 — Mulus (no lag)**
> Sebagai pengguna, saya ingin app terasa mulus di HP (≥2 GB RAM), agar tidak frustrasi.
- **AC:** Semua KPI §9 (cold start, centang, jank, resume, pomodoro, APK) terpenuhi dan terukur before/after.

**US-C1 — Centang toggle dua arah**
> Sebagai pengguna, saya bisa membatalkan centang (mis. salah pencet) dengan mengetuk baris yang sudah tercentang.
- **AC:** Klik baris tercentang → langsung kembali ke "belum" (task, habit, **dan subtask**), tanpa dialog konfirmasi.
- **AC:** XP yang didapat saat centang dikurangi balik saat dibatalkan.
- **AC:** Per-date tetap dibedakan (centang pada tanggal tertentu di Kalender ≠ centang "hari ini").

**US-A1 — Animasi interaktif**
> Sebagai pengguna, saya ingin momen menyelesaikan/rward terasa hidup tapi tetap kalem (tidak laggy).
- **AC:** Semua momen di §4.12 (centang pop+confetti, XP bar & level up, sheet & transisi, unlock badge/kosmetik, empty state & onboarding) hidup.
- **AC:** Ada swipe untuk selesai/hapus, dan drag reorder.
- **AC:** Hormati `MediaQuery.disableAnimations` (reduced motion) → celebration jadi instan.

**US-G1 — Gamifikasi (polish, konsisten)**
> Sebagai pengguna, saya merasa angka XP/streak/badge konsisten dan tidak "aneh".
- **AC:** XP = **High 15 / Medium 10 / Low 5** (task). Habit tanpa prioritas → flat **15** *(keputusan builder — koreksi bila perlu)*.
- **AC:** Tidak ada XP ganda; refund benar saat batal (sudah ada test, dipertahankan).
- **AC:** Aturan streak/freeze dipertahankan seperti v1 (hanya diperjelas): streak naik bila ≥1 task/habit selesai hari itu; kosong → potong kecuali freeze (auto-pakai); freeze didapat tiap 3 hari berturut-turut tanpa bolong.

**US-S1 — Statistik & insight**
> Sebagai pengguna, saya ingin melihat progres saya lewat statistik, agar termotivasi.
- **AC:** Heatmap kontribusi habit (per habit & keseluruhan, bisa tap hari).
- **AC:** Grafik XP & level per minggu/bulan; completion rate task; waktu fokus Pomodoro per hari/minggu.
- **AC:** Insight otomatis 2–3 kalimat dari data lokal; semua dihitung offline; chart custom ringan; ada test untuk perhitungannya.

**US-T1 — Subtask & lokasi**
> Sebagai pengguna, saya ingin subtask yang lebih berguna dan lokasi yang fleksibel.
- **AC:** Subtask punya progress (mis. 2/4), bisa dicentang sebagian tanpa menutup task, bisa reorder (drag).
- **AC:** **Default: semua subtask selesai → task otomatis selesai**, dan ini **bisa dimatikan per task**.
- **AC:** Lokasi = teks manual **atau** tap buka Google Maps (opsional), **tanpa izin GPS**.

**US-F1 — Kategori/tag & pencarian**
> Sebagai pengguna, saya ingin mengelompokkan dan mencari task/habit (termasuk yang selesai).
- **AC:** Kategori/tag untuk task & habit, bisa difilter & diwarnai dari token.
- **AC:** Pencarian lintas task & habit (judul, tag, lokasi; termasuk selesai); filter (hari ini / semua / per kategori / status) responsif pada ratusan item.

**US-B1 — Backup/restore**
> Sebagai pengguna, saya tidak takut kehilangan data.
- **AC:** Export/import JSON ter-versi + checksum, 100% offline (share sheet + file picker).
- **AC:** Pengingat berkala bila sudah lama tidak mengekspor backup (offline, tanpa akun).
- **Bukan AC v2.0:** backup cloud/Google Drive `drive.appdata` — **tidak masuk v2.0** (keputusan owner 2026-11-10); boleh dievaluasi ulang di versi berikutnya.
- **AC:** Data user tidak hilang/reset saat upgrade (migrasi Drift terkontrol + test migrasi).

**US-U1 — Onboarding baru**
> Sebagai pengguna baru, saya memilih nama, tema, dan bahasa di awal.
- **AC:** Onboarding = input nama + pilih tema (light/dark/sistem) + pilih bahasa (id/en).

**US-U2 — Cek update**
> Sebagai pengguna, saya tahu kalau ada versi baru, tanpa dipaksa.
- **AC:** Cek `version.json` statis; banner halus "v2.x tersedia" + tombol unduh; bisa dimatikan; selalu render sebagai data (anti prompt-injection); tidak crash saat manifest rusak/tanpa jaringan.

### 2.3 Non-Goals (anti-gagal)
- **Tanpa akun/login** wajib; tanpa leaderboard; tanpa server yang dioperasikan owner.
- **Bukan Play Store** (distribusi via landing page sendiri).
- **Tanpa izin kamera, mikrofon, lokasi/GPS, storage eksplisit.**
- **Tidak** menambah RPG multi-stat (level otot/fokus/disiplin) → deferred.
- **Tidak** menambah fitur sosial/kolaborasi.
- **Offline-first tidak dikompromikan** diam-diam.
- **Anti-pattern visual** ditolak: gradient ungu-biru generik, glassmorphism berlebihan, ikon bootstrap, UI enterprise dingin, daftar monokrom, "dopamine-heavy game UI", childish cartoon (anti-references di `PRODUCT.md`).
- **Animasi tidak boleh menambah lag** (T1 dieksekusi lebih dulu; profil ulang setelah T3/T4).

---

## 3. Fitur & Fungsi (v2)

> Fitur v1 dipertahankan kecuali disebut berubah. Perubahan v2 ditandai **→**.

### 3.0 Onboarding & Splash
- **→ Onboarding:** nama + **pilih tema** (Light/Dark/Sistem) + **pilih bahasa** (Indonesia/English).
- **Splash:** maskot otter (`otter-with-sprout`); tidak mengikat navigasi ke panjang video penuh (frame statis + init terlepas).
- Tanpa akun/login; data 100% lokal.

### 3.1 Tasks
- Field: Judul (wajib), Tanggal (wajib), Jam+Menit (opsional), Prioritas (Low/Medium/High), Checklist/subtask, Lokasi (opsional).
- **→ XP dibobot prioritas:** High 15 / Medium 10 / Low 5.
- **→ Toggle:** centang ↔ batal centang langsung (tanpa dialog); batal mengurangi XP.
- **→ Subtask:** default auto-selesai task saat semua subtask selesai (bisa dimatikan per task); progres; reorder; centang sebagian.
- Duplikasi cepat tetap ada; auto-complete subtask saat task dicentang tetap ada (konsisten app + widget).
- Tampilan: task hari itu, urut prioritas → jam terdekat.

### 3.2 Habits
- Field: Nama, Frekuensi (Harian/Mingguan/Bulanan/Custom), Waktu (opsional).
- Progress bertahap via Pomodoro; selesai 1x checklist per hari; **→ toggle** batal-centang.
- Streak & freeze: **dipertahankan** (polish saja) — lihat US-G1.

### 3.3 Kalender
- Menampilkan task & habit terjadwal; view bulanan; drag & drop reschedule; **per-date distinction** dipertahankan.

### 3.4 Pomodoro / Focus Timer
- Durasi kustom; 2 mode (Terkait Habit / Bebas); 1 sesi penuh baru tercatat; timer jalan di background; suara/notifikasi selesai.
- **→ Performa:** hanya label timer yang rebuild per detik (bukan seluruh layar).

### 3.5 Reminder / Notifikasi
- **5 channel:** `task_reminders`, `habit_reminders`, `streak_warning`, `freeze_used`, `focus_session`.
- **3 banner in-app:** notifikasi dimatikan, izin exact alarm, level up.
- **Layar pengaturan notifikasi:** 5 toggle per channel + deskripsi.
- Reschedule **inkremental** (bukan semua setiap kali); reminder konsisten tepat waktu (termasuk reboot).

### 3.6 Gamifikasi
- **→ XP:** 15/10/5 (prioritas) untuk task; habit flat 15 *(keputusan builder — koreksi bila perlu)*. Streak habit aktif memberi XP (aturan v1).
- Level: `XP_needed = 100 * level`; unlock kosmetik kelipatan 10 level.
- Streak Rank: Perintis → Petarung → Penakluk → Sang Ahli → Sang Master → Legenda (permanen sebagai badge koleksi).
- **→ Polish konsistensi:** tidak ada XP ganda; refund benar saat batal; pesan streak/freeze jelas; koleksi badge & kosmetik tampil locked/unlocked jelas + animasi unlock.

### 3.7 Widget (homescreen)
- **5 varian (solid ikut tema):** Tasks&Habits (4×2) · Tasks Only (4×2) · Habits Only (4×2) · Streak (2×2) · Calendar+Tasks+Habits (4×2). + 2 empty state.
- **→ Sinkron dua arah & centang tanpa buka app** (US-W1), termasuk Calendar+Tasks+Habits.
- **→ Scroll** widget butuh `RemoteViewsService` + `RemoteViewsFactory` (Kotlin) — implementasi di T8.
- **→ Feedback visual** widget = ganti ikon/teks/warna (RemoteViews tidak bisa animasi Flutter); gaya "mirip, bukan identik" dengan app; satu font ter-bundle bila aman.
- Maskot muncul di semua widget kecuali Calendar; teks mini wajib dites keterbacaan di HP (risiko ≤8.5px).

### 3.8 Statistik & Insight
- Lihat US-S1 (heatmap, grafik XP/level, completion rate, waktu fokus, insight otomatis). Board 07 sudah digambar; desain tidak diubah.

### 3.9 Kategori/tag & Pencarian
- Lihat US-F1.

### 3.10 Backup/restore
- Lihat US-B1 (export/import JSON offline + pengingat backup + migrasi terkontrol). Google Drive tidak masuk v2.0.

### 3.11 Cek update
- Lihat US-U2 (`version.json` di landing page).

### 3.12 Animasi & motion
- Motion token (di `DESIGN.md`): fast 150ms · base 220ms · slow 320ms · celebration 600–900ms · `easeStandard` · `easeGentle` · `springPop`.
- Momen: centang pop + coret + micro-confetti · full-screen celebration milestone · XP bar fill smooth + glow + scale-bounce level up · unlock (card flip/shine sweep) · empty state & onboarding.
- **→ Gesture:** swipe selesai/hapus + drag reorder.
- **→ Reduced motion:** hormati `MediaQuery.disableAnimations`.
- Animasi **hanya transform/opacity** di dalam list (hindari blur/shadow/clip besar); semua controller di-dispose; tidak ada ticker idle.

### 3.13 Aset yang dibutuhkan (di-generate owner atau builder bila lolos standar)
- **→ Avatar profil** (beragam varian, gaya otter 3D clay).
- **→ Badge & ikon kosmetik** (locked/unlocked).
- **→ Ikon app persegi + adaptive icon** (untuk launcher; wordmark horizontal saat ini terpotong).
- Gaya wajib **sama: otter 3D clay glossy**. Standar builder: hanya boleh generate bila kualitas ≥ aset milik owner; jika tidak, builder cukup menyediakan **prompt** dari `docs/design/ikon-logo-prompts.md`.

---

## 4. Design & Tema (v2)

Sumber kanonik: [`DESIGN.md`](./DESIGN.md). Ringkas:
- **Palet:** Sage & Sand (light) / Dusk Forest (dark) — 19 token warna.
- **Font:** Fredoka (display/title/headline) + Plus Jakarta Sans (body/label/caption/angka).
- **Maskot:** otter 3D clay dengan tunas; muncul di empty state, celebration, onboarding, profil, banner, dan widget (kecuali Calendar).
- **Navigasi:** tab bar 5 (Home · Tasks · Habits · Kalender · Lainnya) + sheet "Lainnya" (Statistik · Profil · Pengaturan · Tentang). **Tanpa ☰.**
- **Bentuk/jarak:** radius sm10/md14/lg18/xl24/pill; spacing 4/8/12/16/24/32/40; elevasi dari border & warna permukaan (bukan shadow berat); tap target ≥48dp.
- **Aksesibilitas:** kontras AA (4.5:1 body / 3:1 large) light+dark, `Semantics` label, dukung text scale 130%, status selesai tidak hanya dibedakan warna.

---

## 5. Platform Concerns (Android)

- **Permission:** Notifikasi (wajib) + izin exact alarm (android 12+, ditangani jujur + fallback inexact) + reboot broadcast + **INTERNET** (khusus cek update T11; bukan untuk mengunggah data). **Tanpa** kamera/mic/lokasi/storage eksplisit.
- **Offline:** 100%; satu-satunya fitur online = cek update (opsional, tidak memblokir fungsi inti). Backup tetap offline (file JSON).
- **Background:**
  - Local notification scheduling (reminder tepat waktu).
  - Pomodoro timer jalan saat minimize.
  - **→ Widget write** lewat `homeWidgetBackgroundCallback` (isolate terpisah, satu instance DB/notifikasi), sinkron dua arah, reschedule inkremental, invalidasi saat resume + setelah midnight rollover.

---

## 6. Spesifikasi Teknis

### 6.1 Stack (tetap, tidak naik mayor)
- Flutter 3.44.6 / Dart 3.12.2 · Riverpod 2.6 · Drift + SQLite (migrasi terkontrol + index baru) · flutter_local_notifications + timezone · home_widget · table_calendar · android_alarm_manager_plus · video_player.
- **→ Keputusan teknis (dari spec §5):** tetap Riverpod 2.6 (tidak naik 3); tetap Drift (tambah index, bukan ganti ORM); tidak pakai freezed/json_serializable; animasi pakai API Flutter (bukan Lottie default; Lottie opsional untuk momen langka); chart custom `CustomPainter`; widget pisahkan "hitung snapshot" dari "dorong ke widget"; cek update via manifest JSON statis; backup = file JSON lokal (share/pick), tanpa cloud.

### 6.2 Perbaikan performa (T1 — diurut dampak)
1. Debounce/koalesensi `refreshAll()`; hapus yang redundan.
2. Hanya dorong ke widget terpasang (0 write bila tidak terpasang).
3. Jangan `await` sebelum `runApp`; timezone init malas.
4. `runDailyRollover` dibatasi sekali per ganti hari; reschedule inkremental.
5. Pomodoro: hanya label timer rebuild per detik.
6. Home lazy (`CustomScrollView` + `SliverList`; satu query untuk log habit hari ini).
7. Index DB: `Tasks(date)`, `Tasks(isCompleted)`, `Habits(isActive)`, `Subtasks(taskId)` (migrasi Drift + test).
8. Checkbox tulis DB langsung, animasi paralel (buang delay 380ms).
9. Granularitas provider: `select()`, cache peta turunan, kurangi invalidasi buta.
10. Release build: `isMinifyEnabled` + `isShrinkResources` + `--split-per-abi` (APK turun dari 176 MB).
11. Splash: tidak mengikat navigasi ke durasi video; frame statis + init terlepas; kompres video bila perlu.

### 6.3 Widget sincronization (pendekatan "instan tanpa boros")
- **→** Isolate background untuk tulis DB/notifikasi; snapshot **ter-debounce**; **hanya** widget terpasang yang dipush; **tanpa polling** berulang.
- Tap dari widget → BroadcastReceiver/PendingIntent unik per baris → background callback → tulis DB + hitung gamifikasi → push snapshot balik ke widget (feedback instan).
- **Toleransi reboot (dokumentasi jujur):** tap widget tetap berfungsi tanpa app dibuka; setelah reboot/force-stop, broadcast harus terdaftar ulang (BOOT_COMPLETED). Batas Android: background WorkManager/AlarmManager menghormati Doze/battery protection → perilaku "instan penuh" tidak dijamin 100% oleh OS pada semua vendor; solusi = coverage maksimal + dokumentasi.

### 6.4 Security & Privacy
- Data lokal di device; backup = file JSON yang diekspor user sendiri ke tempat pilihannya (`share_plus` + `file_selector`). Tidak ada unggahan otomatis; Google Drive tidak masuk v2.0.
- Tidak ada telemetry; referral di-hormati; `version.json` diperlakukan sebagai data (validasi skema, tanpa eksekusi).
- Privacy policy jujur: data tetap lokal; cek update adalah satu-satunya request keluar (tanpa mengirim data pengguna).

---

## 7. Arsitektur (v2 — tetap modular)

```
lib/
├── core/ (theme, constants, widgets, utils)   → token v2 (app_colors/app_typography baru)
├── data/ (database, models, repositories)     → index baru + migrasi
├── features/ (home, tasks, habits, calendar, pomodoro, gamification, profile, settings, onboarding, splash)
├── notifications/ · background/ · l10n/ · widgets/ · providers/
```
Perubahan besar: `core/theme/*` diganti ke token `DESIGN.md`; widget kit baru; granularitas provider diperbaiki; index DB + migrasi.

---

## 8. Risiko & Roadmap

### 8.1 Roadmap (16 tahap — satu rilis besar v2.0)
| Tahap | Isi | Status |
|---|---|---|
| T0 | Fondasi & jaring aman (test, .gitignore, docs) | 🟡 sebagian |
| T1 | **Performa (lag)** | ⬜ belum |
| T2 | Design system ke kode (token, tema, widget kit) | 🟡 desain selesai |
| T3 | Redesign layar + navigasi | 🟡 desain selesai |
| T4 | Animasi & micro-interaction | ⬜ belum |
| T5 | Statistik & insight | 🟡 desain selesai |
| T6 | Subtask & lokasi | ⬜ belum |
| T7 | Kategori/tag & pencarian | 🟡 desain selesai |
| T8 | Widget (scroll + sinkron + tampilan) | 🟡 desain selesai |
| T9 | Notifikasi (keandalan) | 🟡 desain selesai |
| T10 | Backup/restore + export/import | 🟡 desain selesai |
| T11 | Cek update | ⬜ belum |
| T12 | Gamifikasi polish | ⬜ belum |
| T13 | Bug audit & hardening | ⬜ belum |
| T14 | Ikon & logo + aset | 🟡 sebagian |
| T15 | Landing page (Astro) + distribusi | ⬜ belum |
| T16 | Docs final + rilis v2.0 | ⬜ belum |

**Urutan eksekusi:** **T1 → T2 → T3 → T4** dulu (fondasi performa sebelum animasi), lalu T5–T16 bertahap. Setiap tahap berakhir: `dart analyze` bersih → `flutter test` hijau → verifikasi HP → ringkasan → tawaran checkpoint git (`stable-YYYY-MM-DD-vN`).

### 8.2 Risiko & mitigasi
| Risiko | Mitigasi |
|---|---|
| Upgrade merusak data user | Migrasi Drift terkontrol + test; backup sebelum migrasi; uji restore |
| Redesign+animasi malah menambah lag | T1 dulu; profil ulang akhir T3/T4; batas 60fps |
| Identitas playful vs "kalem premium" | Playful dipindah ke momen reward & judul; diuji di mockup |
| Font baru membengkakkan APK | Bundle instance saja; hapus font lama |
| User lupa backup → data hilang saat HP rusak | Backup manual JSON + pengingat berkala (T13); Drive tidak masuk v2.0 |
| Cek update disalahgunakan (prompt injection) | Manifest = data + validasi skema |
| Widget Kotlin sulit diverifikasi tanpa HP | Verifikasi manual via USB + test unit logika murni |
| Batas OS untuk "instan penuh" widget (Doze/reboot) | Coverage maksimal + dokumentasi jujur (§6.3) |

---

## 9. KPI (Success Criteria terukur)

**Performa (diukur `--release`/`--profile`, HP ≥2 GB RAM, before→after):**
| Metrik | Target |
|---|---|
| Cold start → Home pertama | ≥30% lebih cepat & ≤1.5 s |
| Centang → status berubah (P95) | ≤100 ms (tanpa penundaan buatan) |
| `refreshAll`/channel write per aksi | ≤1× · ≤60 write · **0** bila widget tidak terpasang |
| Jank scroll Home & Kalender | ≤1% frame; tidak ada frame >16 ms terlihat |
| Resume (tidak ganti hari) | tanpa reschedule penuh, tanpa refreshAll beruntun |
| Pomodoro | hanya label timer rebuild/tick; ticker mati saat idle |
| APK release (per ABI) | turun signifikan dari 176 MB |

**Widget:** centang tanpa buka app · instan (tanpa delay buatan) · reflect di app saat dibuka · tidak basi · tahan reboot (sejauh OS mengizinkan) · 0 polling.

**Kualitas:** `dart analyze` 0 issue · `flutter test` 100% hijau · `npx @google/design.md lint` 0 error · kontras AA (light+dark) · verifikasi HP untuk tiap perubahan terlihat.

---

## 10. Keputusan final (jangan ditanya ulang saat build)

Palet Sage&Sand/Dusk Forest · font Fredoka+Plus Jakarta Sans · maskot otter · tab bar 5 + sheet "Lainnya" (tanpa ☰) · widget solid ikut tema (maskot di semua kecuali Calendar) · backup JSON manual tanpa cloud (Drive tidak masuk v2.0) · distribusi APK landing page (bukan Play Store) · satu rilis v2.0 · verifikasi HP via USB · anti-slop DURING · push hanya izin eksplisit · XP 15/10/5 (task) & 15 (habit, builder) · subtask auto-selesai default ON (bisa dimatikan) · lokasi teks/maps tanpa GPS · onboarding nama+tema+bahasa · bahasa id&en · statistik TETAP masuk · reduced-motion dihormati · toggle centang dua arah tanpa dialog.

---

## 11. Inovasi tanpa perubahan design.pen (opsional, diusulkan saat plan)

Diarahkan, boleh dieksplorasi bila tidak butuh papan/board baru:
- Micro-interaction & validasi feedback yang lebih halus di layar yang sudah ada.
- Sinkron widget yang lebih cerdas (invalidasi tepat waktu, hemat baterai).
- Gamifikasi polish (pesan streak/freeze yang lebih jelas, koleksi lebih rapi).
- Perbaikan performa yang terasa (index, lazy, granularity) tanpa ubah tampilan.

*Detail final diputuskan di dokumen plan implementasi (langkah berikutnya setelah PRD ini disetujui).*