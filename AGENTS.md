# Aturan Project — Tazk

> **Wajib dibaca & dipatuhi** oleh semua sesi, agent, dan subagent yang bekerja di folder ini (`D:\Progamming\Project-SourceCode\Aplikasi\Tazk`).
> File ini = **delta project DI ATAS aturan global** `C:\Users\LENOVO\.config\opencode\AGENTS.md`. **Aturan global tetap berlaku penuh.** Bila konflik: **instruksi user > AGENTS.md global > file ini > skill lainnya**.

---

## 1. Pegang teguh aturan global

Aturan global WAJIB dipatuhi tanpa kecuali. Yang paling sering relevan di project ini:

- **Kejujuran** — laporkan status nyata; yang belum di-verifikasi bilang "belum di-verifikasi" + cara mengetesnya. Jangan mengarang hasil.
- **Verifikasi 2 bukti** — keputusan penting (jalan/tidak, aman/tidak) butuh ≥2 bukti yang saling mendukung; kalau cuma 1 → sebut "indikasi sementara".
- **Tidak merusak yang sudah berjalan** — cek dampak perubahan ke bagian lain sebelum jalan.
- **Checkpoint (commit + tag)** — di tiap titik stabil, tawarkan `commit + tag stable-YYYY-MM-DD-vN`. **Push hanya dengan izin eksplisit owner.**
- **Pre-deploy** — di titik stabil, tanyakan apakah akan rilis/deploy; kalau ya, tawarkan scan Strix (konfirmasi dulu). Setelah scan lokal Strix: `docker system prune -f` (tanpa `-a`).
- **Tidak ada LSP di OpenCode V2** — verifikasi kode pakai perintah nyata (`dart analyze`, `flutter test`), bukan klaim "sudah benar".

---

## 2. Selalu gunakan skill yang menunjang

- Jalankan **context matching** (Step 0 cek `graphify-out` → Step 1 baca konteks → Step 2 load parent skill → Step 3 load sub-skill → Step 4 kerja). Project ini **sudah punya graph** (`graphify-out/`) — **jangan setup ulang**.
- Load skill yang relevan via skill tool **sebelum** eksekusi. Contoh: UI → `software-engineering/frontend`; planning → `writing-plans`; debug → `systematic-debugging`; PRD → `prd`; riset/analisis → `knowledge-graph` + sub-skill.
- **LAPOR pemakaian skill** di akhir kerja (apa yang di-load + keputusan kunci + hasil verifikasi + yang belum ter-verifikasi).

---

## 3. Baca context dulu (urutan wajib sebelum kerja)

1. `docs/STATUS.md` — **posisi kerja terkini** (selalu pertama).
2. `graphify-out/GRAPH_REPORT.md` — memory project (graph). Baca sebelum menyelami source detail.
3. `PRD-v2.md` — scope & requirement v2.
4. `DESIGN.md` — design system kanonik (WAJIB bila task menyentuh UI).
5. `PRODUCT.md` — brand/audiens (bila perlu).
6. Plan eksekusi: `docs/superpowers/plans/` (bila eksekusi tahap).

---

## 4. Selalu perbarui `docs/STATUS.md` di SETIAP perubahan

- Tambahkan satu baris di section **"Log Perubahan (terbaru duluan)"** di `docs/STATUS.md`.
- Format baku: `- YYYY-MM-DD — <apa yang berubah/selesai> — <hash commit atau '(belum commit)'>`.
- Bila bagian yang relevan ikut berubah (Posisi git, status tahap, isu terbuka), **update juga bagian itu**.
- Berlaku untuk **SEMUA**: PM, subagent, dan kerja manual. Tujuan: siapa pun yang masuk folder ini tahu kondisi terkini **tanpa menebak**.

---

## 5. Keputusan project (final — jangan ditanya ulang)

| Topik | Keputusan |
|---|---|
| Palet | Sage & Sand (light) / Dusk Forest (dark) |
| Font | Fredoka (judul) + Plus Jakarta Sans (body/angka) |
| Maskot | Otter 3D clay dengan tunas |
| Navigasi | Tab bar 5 (Home·Tasks·Habits·Kalender·Lainnya) + sheet "Lainnya", **tanpa ☰** |
| XP | Task 15/10/5 (prioritas); habit flat 15; anti XP ganda (batal centang → kurangi) |
| Centang | Toggle dua arah tanpa dialog (task/habit/subtask); per-date dibedakan |
| Subtask | Auto-selesai default ON (bisa dimatikan per task); lokasi teks/maps (tanpa GPS) |
| Bahasa | Indonesia + Inggris; onboarding = nama + tema + bahasa |
| Widget | Solid ikut tema; RemoteViews = feedback ikon/teks/warna (bukan animasi); maskot di semua kecuali Calendar |
| Backup | Google Drive milik user (`drive.appdata`), tanpa server sendiri |
| Distribusi | APK dari landing page Astro+Vercel (bukan Play Store); **T15** |
| Rilis | Satu rilis besar v2.0 (versi akhir 2.0.0+1) |
| Privasi | Offline-first; tanpa akun; tanpa izin kamera/mic/lokasi/storage |
| Anti-slop | Mode **DURING** |
| Git | Commit lokal boleh; **push hanya izin eksplisit owner** |
| Urutan kerja | Performa (T1) sebelum redesign UI (biar animasi baru tidak menambah lag) |

---

## 6. Workflow PM + subagent (eksekusi paralel)

- **PM** = sesi utama (model Pro). Menyusun plan → dispatch subagent → review → integrasi → **satu-satunya yang commit+tag**.
- **Model subagent** = **MIMO V2.6 Flash** (default); fallback **DeepSeek V4.1 Flash 1017**. (ID model exact di-resolve saat dispatch.)
- **Effort** subagent di-setel per task (tinggi untuk logika rumit, rendah/medium untuk mekanik).
- **Isolasi kerja** = working dir yang SAMA; paralel hanya antar-file yang **tidak tumpang-tindih**; file bersama (`theme`, `main.dart`, provider inti, DB, `pubspec`, `build.gradle`) dikerjakan lebih dulu.
- **Review** = maks **2 ronde** per subagent; kalau masih gagal → **PM ambil alih**. Prompt+konteks ke subagent **wajib detail & jelas**.
- **TDD hybrid** = ketat untuk logika/DB/provider; test untuk tiap perubahan perilaku; visual diverifikasi manual + `dart analyze`.
- **Approval UI** = design.pen sudah final → **PM jaga fidelity ke `DESIGN.md`**, owner approve satu kali di akhir tiap tahap (bukan per layar).
- **Batch paralel** = maks 3–5 subagent bersamaan.

**Aturan wajib ke subagent:** (1) task + path exact; (2) nilai/interface exact; (3) test yang harus ditulis + command verifikasi; (4) konstrain §5; (5) larangan: jangan commit, jangan ubah file di luar daftar, jangan geser scope.

---

## 7. Gerbang verifikasi (Definition of Done — tiap task & tahap)

1. `dart analyze` → **0 issue**.
2. `flutter test` → **semua hijau** (+ test baru untuk perilaku baru).
3. Diverifikasi **di HP via USB** untuk perubahan yang terlihat/dirasakan.
4. Ringkasan tertulis: apa berubah, apa **belum** terverifikasi, risikonya.
5. Update `docs/STATUS.md` (log + bagian relevan).
6. Tawarkan checkpoint (commit+tag) + tanya apakah akan rilis (→ tawarkan Strix).

Tambahan kualitas: kontras AA (4.5:1 body / 3:1 large) light+dark; tap target ≥48dp; `reduced-motion` dihormati; status selesai tidak hanya dibedakan warna.

---

## 8. Konvensi teknis

- Flutter 3.44.6 / Dart 3.12.2 · minSdk 29 · package `com.tazk.tazk`.
- Riverpod 2.6 (jangan naik ke 3) · Drift + SQLite (migrasi terkontrol, jangan ganti ORM) · tanpa `freezed`/`json_serializable`.
- Struktur modular `lib/` → `core/`, `data/`, `features/`, `providers/`, `notifications/`, `background/`, `widgets/`, `l10n/`.
- Verifikasi Dart/Flutter pakai `dart analyze` + `flutter test` (LSP tidak jalan di V2).
- Release build: `isMinifyEnabled` + `isShrinkResources` + `--split-per-abi` (APK turun dari 176 MB).
- Commit message konvensional (`feat:`, `fix:`, `docs:`, `refactor:`); tag `stable-YYYY-MM-DD-vN`.

---

## 9. Alur kerja standar (step-by-step)

1. Baca `docs/STATUS.md` + `git status`.
2. Baca `PRD-v2.md` / `DESIGN.md` sesuai jenis task.
3. Context matching → load skill yang relevan.
4. Kerjakan (TDD hybrid; bila paralel, ikuti workflow §6).
5. Verifikasi: `dart analyze` + `flutter test` hijau.
6. Update `docs/STATUS.md` (log perubahan).
7. Tawarkan checkpoint (commit+tag) + tanya kebutuhan rilis (Strix).
8. Lapor: skill yang dipakai + hasil verifikasi + yang belum terverifikasi.

---

## 10. Peta tahap (16) + status

| Tahap | Isi | Status |
|---|---|---|
| T0 | Fondasi & jaring aman | 🟡 sebagian |
| T1 | Performa (lag) | ⬜ belum |
| T2 | Design system ke kode | 🟡 desain selesai |
| T3 | Redesign layar + navigasi | 🟡 desain selesai |
| T4 | Animasi & micro-interaction | ⬜ belum |
| T5 | Statistik & insight | 🟡 desain selesai |
| T6 | Subtask & lokasi | ⬜ belum |
| T7 | Kategori/tag & pencarian | 🟡 desain selesai |
| T8 | Widget (scroll + sinkron + tampilan) | 🟡 desain selesai |
| T9 | Notifikasi | 🟡 desain selesai |
| T10 | Backup/restore | 🟡 desain selesai |
| T11 | Cek update | ⬜ belum |
| T12 | Gamifikasi polish | ⬜ belum |
| T13 | Bug audit & hardening | ⬜ belum |
| T14 | Ikon/logo + aset | 🟡 sebagian |
| **T15** | **Landing page Astro + distribusi** | ⬜ belum |
| T16 | Docs final + rilis v2.0 | ⬜ belum |

> Sumber kebenaran status terkini: `docs/STATUS.md` (bukan tabel di atas — tabel ini ringkasan).