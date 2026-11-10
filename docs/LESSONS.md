# LESSONS.md — Ledger Kesalahan & Pelajaran (Tazk)

> **Aturan:** setiap bug, kegagalan build, klaim yang salah, atau salah paham
> requirement **WAJIB** dicatat di sini **sebelum** lanjut kerja lain.
> Tanpa entri di sini, perbaikan dianggap belum selesai.
> Dibaca di awal sesi (lihat `AGENTS.md` §12).
>
> Format entri: **Apa yang kulakukan salah → Bukti → Dampak → Aturan baru → Verifikasi**.

---

## L-001 · Widget gagal inflate karena memakai `<View>` di layout RemoteViews
- **Tanggal:** 2026-11-09
- **Salah:** menambahkan divider kolom pakai tag `<View>` di
  `widget_tasks_habits.xml` dan `widget_calendar_tasks_habits.xml`.
- **Bukti:** `adb logcat` → `W/RemoteViews: inflate error, layoutId = 2131428547`
  dan `2131428541`; dipetakan via `aapt` ke kedua layout itu. Widget tidak tampil
  sama sekali di launcher.
- **Dampak:** build v2031 terpasang di HP owner dalam kondisi widget rusak total.
- **Kenapa lolos:** `flutter analyze` = 0 issue; APK ter-build sukses; resource
  terverifikasi ada di APK. **Tidak satu pun dari itu menyentuh validasi RemoteViews.**
- **Aturan baru:**
  1. Layout widget hanya boleh memakai view yang didukung RemoteViews:
     `FrameLayout, LinearLayout, RelativeLayout, GridLayout, TextView, ImageView,
     ImageButton, Button, Chronometer, ProgressBar, ListView, GridView, StackView,
     ViewFlipper, AdapterViewFlipper, AnalogClock, ViewStub, include`.
     **`<View>`, `<Space>`, `<SurfaceView>`, custom view = DILARANG.**
  2. Setiap perubahan layout widget wajib: (a) jalankan guard tag otomatis,
     (b) setelah install, cek `adb logcat | grep "inflate error"` **harus kosong**,
     (c) ambil screenshot home screen.
- **Pencegahan otomatis:** guard Python memeriksa semua `<tag>` di
  `res/layout/widget_*.xml` terhadap daftar di atas (dipakai saat patch divider:
  hasil `UNSUPPORTED_TAGS: none`).

---

## L-002 · Mengklaim "sync sudah beres" padahal baru diuji pada kondisi app baru dibuka
- **Tanggal:** 2026-11-09
- **Salah:** menyatakan fix sinkronisasi widget selesai setelah owner mengetuk
  centang **beberapa saat setelah app ditutup** — bukan setelah app didiamkan,
  bukan setelah HP reboot.
- **Bukti:** owner melaporkan: rusak **dalam hitungan menit**, dan setelah HP
  dimatikan-hidupkan widget **freeze walau diketuk**.
- **Dampak:** owner memakai build yang salah dan kehilangan waktu; kepercayaan turun.
- **Aturan baru:**
  1. Fitur yang melibatkan proses background **wajib diuji pada kondisi gagal yang
     sebenarnya**: app idle beberapa menit, app di-kill, HP reboot, layar mati.
     "Berfungsi saat app baru dibuka" bukan bukti.
  2. Klaim selesai harus menyebut kondisi uji secara eksplisit.
- **Verifikasi:** belum tuntas — lihat L-005 (masih terbuka).

---

## L-003 · Menganggap JobScheduler akan selalu menjalankan pekerjaan widget
- **Tanggal:** 2026-11-09
- **Salah:** jalur tap widget lewat `HomeWidgetBackgroundReceiver` →
  `HomeWidgetBackgroundService` (JobScheduler) dianggap setara dengan eksekusi langsung.
- **Bukti:** `adb shell dumpsys jobscheduler` → `com.tazk.tazk` punya
  `ACTIVE: jobCountLimit=75` tapi `WORKING_SET/FREQUENT/RARE: jobCountLimit=0,
  sessionCountLimit=0`. Artinya Android **mencabut kuota job** app yang didiamkan.
- **Dampak:** pekerjaan bisa ditunda/dibatalkan oleh sistem tanpa error yang terlihat.
- **Aturan baru:** setiap pekerjaan yang harus "pasti jalan" tidak boleh
  mengandalkan JobScheduler semata; sediakan jalur eksekusi langsung atau
  pengecualian baterai, dan buktikan dengan `dumpsys jobscheduler` +
  `dumpsys deviceidle whitelist`.

---

## L-004 · Tes lama dibiarkan bertentangan dengan perbaikan yang sudah terbukti
- **Tanggal:** 2026-11-09
- **Salah:** `test/widgets/widget_push_gate_test.dart` masih menegaskan perilaku
  lama (jawaban channel kosong = `{}` = jangan push), padahal perilaku itulah
  penyebab widget tidak refresh.
- **Bukti:** `flutter test` → 533 lolos, **1 gagal** tepat di tes itu.
- **Dampak:** suite merah; kalau ditekan agar hijau dengan mengembalikan kode lama,
  bug sync akan kembali.
- **Aturan baru:** kalau tes bertentangan dengan perilaku yang **sudah diverifikasi
  benar di perangkat**, perbaiki **tes**-nya agar mengunci kontrak baru — jangan
  melonggarkan asersi, dan jangan mengembalikan kode yang salah.
- **Verifikasi:** tes dipecah jadi dua kontrak eksplisit (tanpa cache; jawaban kosong
  = push semua) → `flutter test test/widgets/widget_push_gate_test.dart` → 3/3 lulus.

---

## L-005 · ROOT CAUSE DITEMUKAN — tap widget mati setelah proses app dimatikan
- **Tanggal:** 2026-11-09
- **Gejala (dari owner):** tap centang widget **diam total** setelah app didiamkan
  beberapa menit; setelah HP reboot widget **freeze walau diketuk**; harus buka app.
- **Reproduksi (deterministik, Galaxy A52):**
  1. `adb shell am kill com.tazk.tazk` -> proses mati. **JANGAN pakai `force-stop`**
     untuk tes ini: `force-stop` membuat app masuk "stopped state" sehingga
     broadcast tidak dikirim sama sekali -> tesnya cacat (sudah kena, lihat L-008).
  2. Tap tombol `>` di widget -> `updateAppWidget count = 0` (widget tidak berubah),
     tetapi `pidof` menunjukkan proses BARU hidup (receiver memang jalan).
  3. Tunggu 60 detik -> tetap **0** update. Tidak ada error di logcat.
- **Bukti akar masalah:**
  - `dumpsys jobscheduler` -> **tiga** job menumpuk untuk
    `HomeWidgetBackgroundService` (`-2135470339`, `-1847571183`, `-1240186475`),
    semuanya `WAITING`/`RUNNABLE`, `Tracking: QUOTA UID_RESTRICT`.
  - `dumpsys activity services com.tazk.tazk` -> `(nothing)` -> service **tidak
    pernah start**.
  - logcat: `libflutter.so` termuat lalu berhenti; **tidak ada** log
    `HomeWidgetService` maupun exception.
- **Akar masalah:** `home_widget` 0.7.0 menyalurkan tap lewat
  `HomeWidgetBackgroundReceiver` -> `HomeWidgetBackgroundService`
  (**`JobIntentService` = JobScheduler**). JobScheduler **menahan** eksekusi job
  untuk app yang prosesnya idle (kuota `UID_RESTRICT`), sehingga pekerjaan tidak
  pernah berjalan dan **gagal senyap**. Membuka app membuat app aktif kembali ->
  job akhirnya jalan -> seolah "diperbaiki dengan membuka app".
  Tambahan: `JOB_ID` dibuat **acak per proses** (`UUID.randomUUID()`), jadi job
  yang tertahan menumpuk dan tidak saling menggantikan.
- **Yang TERBUKTI BUKAN penyebab** (sudah diuji — jangan dituduh lagi):
  - Bukan `WidgetPushGate`/logika sync: broadcast langsung ke receiver saat proses
    hidup -> `updateAppWidget` muncul 2x, tiga kali berturut-turut.
  - Bukan PendingIntent/fill-in: tap nyata (`input tap`) pada tombol `>` widget
    saat proses hidup -> `updateAppWidget` muncul 2x.
  - Bukan `engine` static di plugin: tap ke-2 dan ke-3 tetap jalan.
  - Bukan layout: widget tampil benar (divider ada, header satu baris).
- **Keputusan perbaikan (dipilih owner):** **A + B** —
  (A) tap dieksekusi **tanpa JobScheduler** (langsung di `BroadcastReceiver` via
  `goAsync()`), (B) minta **pengecualian optimasi baterai** sekali agar pengingat
  dan alarm tidak ikut ditahan.
- **Perbaikan diterapkan (v2033, menunggu verifikasi di perangkat):**
  1. `TazkWidgetTapReceiver` (baru) mengeksekusi tap **langsung di
     `BroadcastReceiver`** memakai `goAsync()` + `FlutterEngine` sendiri
     (channel `com.tazk.tazk/widget_tap`). Tidak ada JobScheduler di jalur tap.
  2. `HomeWidgetBackgroundReceiver`/`HomeWidgetBackgroundService` **dihapus** dari
     `AndroidManifest.xml` (manifest plugin kosong, jadi tidak ada yang
     menggabungkannya kembali). Semua `PendingIntent` (template baris + tombol
     kalender) diarahkan ke receiver baru.
  3. Handle entry-point Dart (`widgetTapMain`) disimpan lewat channel
     `saveWidgetTapHandle` setiap app start.
  4. (B) Pengecualian optimasi baterai: izin
     `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` + dialog sekali
     (`maybePromptBatteryOptimization`) yang hanya muncul bila Android memang
     membatasi app.
- **Status:** kode selesai, `flutter analyze` = 0 issue. **BELUM terbukti** sampai
  diuji `am kill` + tap + reboot di perangkat.
- **Aturan:** **dilarang** "memperbaiki" dengan menyuruh user membuka app.

---

## L-006 · Jebakan alat (PowerShell/SSH) yang berulang
- **Tanggal:** 2026-11-09
- **Salah:** (a) `adb exec-out screencap -p > file` di PowerShell menghasilkan
  PNG rusak (UTF-16) → screenshot tak terbaca; (b) perintah SSH dengan tanda
  kurung/pipa/double-quote di-strip oleh PowerShell → `syntax error near unexpected token`.
- **Aturan baru:** (a) ambil biner lewat `cmd /c "adb ... > file"`;
  (b) selalu kirim skrip ke server via **base64**
  (`$b64=[Convert]::ToBase64String(...)` → `echo $b64 | base64 -d > /tmp/s.sh` → `bash /tmp/s.sh`).
- **Verifikasi:** keduanya terbukti pada sesi ini (screenshot 224 KB valid;
  semua skrip multi-baris berjalan).

---

## L-007 · Menunggu build lama tanpa memberi nilai tambah
- **Tanggal:** 2026-11-09
- **Salah:** build `assembleRelease` di server memakan 1903 s (31 menit) dan selama
  itu tidak ada pekerjaan lain yang disiapkan.
- **Aturan baru:** saat build berjalan, kerjakan hal yang tidak bergantung padanya
  (dokumentasi, guard otomatis, penulisan tes). Dan ukur dulu beban server
  (`uptime`) sebelum memilih jalur build.

---

## L-008 · `force-stop` membuat tes broadcast jadi palsu
- **Tanggal:** 2026-11-09
- **Salah:** memakai `adb shell am force-stop com.tazk.tazk` untuk menguji jalur tap
  widget "dari proses mati".
- **Bukti:** broadcast dikirim (`Broadcast completed: result=0`) tapi tidak ada satu
  pun `updateAppWidget`, bahkan untuk tap pertama — hasilnya menyesatkan dan sempat
  membuat hipotesis "engine static" terlihat benar.
- **Sebab:** `force-stop` menaruh app di **stopped state**; Android **tidak
  mengirimkan broadcast** ke app yang berhenti sampai user membukanya lagi.
- **Aturan baru:** untuk mensimulasikan "proses mati" pakai `adb shell am kill
  <pkg>` (tidak mengubah stopped state). Pakai `force-stop` hanya bila memang ingin
  mematikan app sepenuhnya, dan jangan menarik kesimpulan apa pun dari tes sesudahnya.
- **Verifikasi:** dengan `am kill`, tes jadi bermakna (bug L-005 langsung tereproduksi:
  `updateAppWidget count = 0` sementara `pidof` menunjukkan proses baru hidup).

---

## L-009 · `lookupCallbackInformation` sebelum loader Flutter diinisialisasi
- **Tanggal:** 2026-11-09
- **Salah (di `TazkWidgetTapReceiver`, v2033):** memanggil
  `FlutterCallbackInformation.lookupCallbackInformation(handle)` **sebelum**
  `FlutterLoader.startInitialization()` / `ensureInitializationComplete()`.
- **Bukti:** `adb logcat` -> `E/TazkWidgetTap: Widget tap crashed`
  `java.lang.UnsatisfiedLinkError: No implementation found for
  io.flutter.view.FlutterCallbackInformation ...
  FlutterJNI.nativeLookupCallbackInformation(long)`.
- **Dampak:** tap widget tetap tidak berubah (`updateAppWidget = 0`) pada v2033.
  Positifnya kali ini **gagal berisik**, bukan senyap seperti L-005, jadi akar
  masalahnya langsung terlihat.
- **Aturan baru:** di proses/isolate baru, **inisialisasi loader Flutter dulu**,
  baru panggil API native apa pun (`lookupCallbackInformation`, `FlutterEngine`,
  `DartExecutor`).
- **Verifikasi:** urutan dibalik; dibuktikan ulang pada build v2034
  (`am kill` -> tap -> `updateAppWidget` > 0, tanpa `UnsatisfiedLinkError`).
- **Pelajaran proses:** menaruh `Log.e` di jalur `catch` **membayar dirinya
  sendiri**. Tanpa itu kegagalan ini tampak seperti "masih diam" dan memancing
  tambalan buta. Jalur background **wajib** punya logging eksplisit.

---

## L-010 · API inisialisasi Flutter dipanggil dari background thread
- **Tanggal:** 2026-11-09
- **Salah (di `TazkWidgetTapReceiver`):** menjalankan seluruh setup Flutter di dalam
  `Thread { ... }` buatan sendiri — dua kali, dua error berbeda:
  - v2034: `java.lang.IllegalStateException: startInitialization must be called on the main thread`
  - v2035: `java.lang.IllegalStateException: ensureInitializationComplete must be called on the main thread`
- **Dampak:** tap widget tetap tidak berubah (`updateAppWidget = 0`) pada v2034 **dan** v2035.
- **Aturan baru:** `FlutterLoader.startInitialization()` **dan**
  `ensureInitializationComplete()` **wajib di main thread** (di
  `BroadcastReceiver.onReceive` sudah main thread). Setup engine + channel +
  `executeDartCallback` juga di main thread; **kerja berat (DB, push widget)
  berjalan di isolate Dart**, bukan di main thread. Jadi main thread hanya
  membayar ~100–300 ms untuk membuat engine.
- **Verifikasi:** dibuktikan ulang pada v2036 (`am kill` -> tap -> `updateAppWidget > 0`).
- **Pola yang terulang (penting):** ini kali **ketiga** bug urutan/thread inisialisasi
  Flutter di jalur yang sama (L-009, L-010 v2034, L-010 v2035). Aturan turunan:
  **baca kontrak thread API Flutter sebelum menulis jalur background**, dan jangan
  pernah menyimpulkan "cukup satu yang di main thread" tanpa bukti.

---

## L-011 · Build di server padahal laptop 6x lebih cepat
- **Tanggal:** 2026-11-09
- **Salah:** terus mem-build `assembleRelease` di `resserver` karena "kode terbaru ada
  di server", meski owner sudah mengeluh berulang soal lamanya.
- **Bukti (terukur, build yang sama, kode yang sama):**
  - server: **875,8 s** (dan pernah 1903,7 s saat mesin sedang berat)
  - laptop: **149,2 s** (8 core) — **5,9x lebih cepat**
  - Biaya sinkronisasi yang kubayangkan mahal ternyata **~1 menit** (tar 30 MB + scp
    + verifikasi SHA256).
- **Dampak:** waktu owner terbuang menunggu berjam-jam; iterasi jadi sangat lambat
  padahal bug yang sedang dikejar butuh banyak iterasi.
- **Aturan baru:**
  1. **Build/iterasi = laptop.** Server hanya arsip/backup & pekerjaan yang memang
     butuh Linux.
  2. Menyerahkan pekerjaan ke mesin lain **wajib** disertai alasan terukur
     (bandingkan `uptime`/core/jam build), bukan asumsi.
  3. Sinkronisasi kode bukan alasan menunda: `tar` + `scp` + cek SHA itu murah.

---

## L-012 · Teks privasi di app menjanjikan Google Drive padahal fiturnya tidak pernah dibangun
- **Tanggal:** 2026-11-10
- **Salah:** `aboutPrivacyBody` di l10n (id & en) menyatakan *"Cadangan hanya dibuat bila kamu sendiri mengaktifkan backup ke Google Drive milikmu…"*, padahal tidak ada satu baris pun kode Drive — keputusan T10 selalu "offline JSON dulu, Drive ditunda".
- **Bukti (2 sumber):** ① `pubspec.yaml` → 0 dep `google_sign_in`/Drive dan `grep drive` di `lib/` → 0 hasil; ② manifest tanpa izin `INTERNET` — app bahkan belum bisa bicara ke jaringan.
- **Dampak:** app membuat klaim ke pengguna yang tidak ada wujudnya; dokumen plan & ledger juga masih menulis "Drive ditunda/akan datang" sehingga sesi berikutnya bisa menghidupkannya tanpa sadar.
- **Aturan baru:**
  1. **Teks user-facing wajib mencerminkan kode nyata saat ini**, bukan rencana. Sebelum menulis janji fitur di UI/privasi/README, buktikan dep-nya terpasang (`pubspec` + grep kode + `flutter analyze`).
  2. **Meniadakan fitur = hapus jejak janjinya di teks produk**, bukan sekadar menandai "ditunda".
  3. Dokumen plan/ledger yang menyimpan status lama wajib diberi catatan *"status berubah tanggal X"*, bukan dihapus diam-diam.
- **Verifikasi:** `flutter gen-l10n` → `dart analyze` 0 issue; `grep "Google Drive"` di file user-facing (`lib/l10n/*.arb`) = 0 tersisa (kecuali catatan keputusan "tidak masuk v2.0" di dokumen).
- **Pencegahan otomatis (belum dipasang):** usul test l10n yang menolak string berisi nama layanan pihak ketiga (`Drive`, `Firebase`, dst.) bila dep-nya tidak ada di `pubspec.yaml`.

---

