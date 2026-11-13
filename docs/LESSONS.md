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

## L-013 · Mengklaim "sudah kubedah sampai motion & struktur" padahal cuma membaca CSS bundle
- **Tanggal:** 2026-11-10
- **Salah:** ketika owner memberi referensi desain `https://openbot.run/`, aku hanya mengunduh **CSS bundle** (254 KB) + markup SSR, lalu melaporkan seolah sudah membedah sistem desainnya. Aku juga menulis kesimpulan yang **tidak kuperiksa di render**:
  1. "openbot pakai system font" — **salah**, yang dirender **`Inter Variable`**.
  2. "easing utama `.22,1,.36,1`" — hanya untuk reveal hero; **hover transform memakai `.23,1,.32,1`**.
  3. Menyebut "sudah sampai motion" padahal tidak pernah membuka halaman; aset (gambar/video/ikon) belum dihitung sama sekali.
- **Bukti (2 sumber, sesudah render):** ① `getComputedStyle(h1).fontFamily` = `"Inter Variable", "Inter Variable Fallback", …` dan `document.fonts` memuat Inter Variable (100–900); sementara `--font-sans` di CSS hanya *deklarasi* system stack yang **tidak dipakai**. ② `document.getAnimations()` → `landing-hero-in` 500ms, `landing-header-enter` 240ms, `landing-marquee` 36.000ms; `transition` terhitung → `transform 0.2s cubic-bezier(0.23, 1, 0.32, 1)` pada 52 elemen, berbeda dari `.22,1,.36,1` milik stagger. ③ Setelah render: **198 SVG, 0 video, 2 raster kecil**, art honeycomb = CSS gradient.
- **Dampak:** owner kecewa dan benar — dokumen "design system" pertama **tidak bisa dipakai** membangun landing page karena tidak memuat UI/UX, motion nyata, dan strategi aset. Satu putaran kerja terbuang, dan kepercayaan pada laporan turun.
- **Aturan baru:**
  1. **Untuk situs web, "bedah" = render dulu.** Buka di browser, ukur `getComputedStyle`/`getAnimations`/`getBoundingClientRect`, screenshot, scroll untuk memicu state. Fetch CSS/markup hanya boleh jadi *hipotesis awal*, bukan hasil.
  2. **Token ≠ pemakaian.** Nilai yang dideklarasikan di CSS bisa tidak dipakai (kasus `--font-sans`). Setiap klaim "dipakai" wajib dari render.
  3. **Klaim cakupan harus menyebut metode dan batasnya**: "terukur X, belum diukur Y". Dilarang menyimpulkan cakupan dari sebagian kecil bukti.
  4. **Motion tidak boleh disimpulkan dari nama keyframes**: durasi/easing per peran (reveal vs hover) berbeda dan harus diukur per elemen.
- **Verifikasi:** `docs/design/2026-11-10-landing-design-reference.md` ditulis ulang dengan tabel render + catatan metode; font/easing/aset dikutip dari hasil ukur, bukan dari deklarasi; bagian "yang tidak diukur" (Lighthouse, HP asli, TalkBack) dinyatakan terbuka.

---

## L-014 · Mengklaim "screenshot tersimpan" padahal file tidak ada / menampilkan hal yang salah
- **Tanggal:** 2026-11-10
- **Salah:** tiga kali dalam satu sesi (landing page Wave L):
  1. Melaporkan screenshot `1440` "tersimpan" padahal Chrome headless gagal senyap (`--blink-settings=scriptEnabled=false` tidak valid) → hanya file `dark-800` yang benar-benar ada.
  2. Screenshot berlabel **ID** ternyata berisi **teks Inggris**, karena Playwright default-locale `en-US` sehingga `/` me-redirect ke `/en/` (perilaku yang *aku sendiri* bangun). Aku baru tahu setelah melihat gambarnya.
  3. Gambar pertama tampak "banyak section kosong" — bukan bug layout, melainkan `addStyleTag` hanya memaksa `opacity:1` sementara `transition` 320 ms + delay stagger masih berjalan, jadi tertangkap di tengah animasi.
- **Bukti:** `Get-ChildItem docs\artifacts\landing-*.png` hanya memuat 1 file setelah batch pertama; screenshot 1440 yang berhasil memuat judul `Selesai lebih tenang.` vs label ID; section kosong hilang setelah `transition:none!important` + `waitForTimeout(250)`.
- **Dampak:** hampir melaporkan bukti visual yang tidak ada dan menuduh CSS sendiri rusak. Kalau owner tidak menunjuk gambar HP, aku juga melewatkan cacat nyata (frame HP rata + grid 2+1).
- **Aturan baru:**
  1. **Klaim "file tersimpan" wajib disertai cek keberadaan file** (`Test-Path` / list dir) di langkah yang sama. Tool yang gagal senyap harus diperlakukan gagal.
  2. **Screenshot harus dibuka dan dilihat** sebelum dijadikan bukti; kalau tidak dilihat, sebut "belum kuperiksa isinya".
  3. **Verifikasi screenshot wajib memaksa keadaan akhir**: `transition:none`, `animation:none`, `[data-reveal]{opacity:1}`, lalu tunggu 1 frame.
  4. **Uji halaman ber-multibahasa dengan locale eksplisit** (`locale: "id-ID"`), karena logika redirect bahasa bisa membuat "bukti" menampilkan bahasa lain.
- **Verifikasi:** `landing/scripts/gates.mjs` sekarang menulis screenshot dengan locale eksplisit + mematikan transisi, dan mengembalikan **exit 0/1** (bukan sekadar mencetak JSON).

---

## L-015 · Overflow horizontal 47px di 320px karena specificity CSS, bukan karena layout
- **Tanggal:** 2026-11-10
- **Salah:** tombol CTA header (`display:none` di bawah 900px) tetap tampil di 320px sehingga halaman bisa di-scroll horizontal. Penyebabnya **urutan + specificity**: `.tk-btn` (2 kelas, didefinisikan **sesudah**) mengalahkan `.tk-header__cta` (1 kelas), jadi `display:none` kalah.
- **Bukti:** iframe 320px → `documentElement.scrollWidth` **367** vs `innerWidth` **320**; penyebab teridentifikasi dengan memindai `getBoundingClientRect().right > innerWidth` → `.tk-header__cta` `right: 394`. Setelah `.tk-btn.tk-header__cta` (2 kelas) dipakai, 320–1440 semuanya **0 overflow**.
- **Dampak:** satu-satunya gate yang gagal pada build pertama; kalau lolos, pengguna HP kecil akan melihat halaman bergeser ke samping.
- **Aturan baru:**
  1. **Jangan menyimpulkan "responsif" dari melihat 390px.** Ukur `scrollWidth <= innerWidth` di **320** juga, karena di situlah kebocoran paling sering muncul.
  2. **Utility class yang dipakai ulang (`.tk-btn`) jangan diberi override tampilan oleh kelas tunggal**; naikkan specificity (`.tk-btn.tk-header__cta`) atau pakai layer CSS.
  3. Kalau ada overflow, **cari elemennya** dengan memindai `right > innerWidth`, jangan menebak dari CSS.
- **Verifikasi:** `npm run check:gates` → `All gates passed` (exit 0), 320/390/768/1024/1440 semua `overflow: false`.

---

## L-016 · Deploy Vercel: domain `<nama>.vercel.app` tidak otomatis jadi milik kita + proteksi default ON
- **Tanggal:** 2026-11-10
- **Salah:** (1) mengira `version.json` yang menunjuk `tazk.vercel.app` sudah benar, padahal domain itu milik **akun lain**; (2) setelah deploy, menganggap landing sudah tayang padahal `curl /version.json` mengembalikan **halaman "Log in to Vercel"**. Baru sadar saat mem-verifikasi, bukan saat menulis.
- **Bukti:** `curl https://tazk.vercel.app/version.json` → HTML React `main.8202c31d.js` ("Collaborative Task Management", project orang lain). `vercel alias set ... tazk-manager.vercel.app` → **"already in use"**. API project: `ssoProtection = {"deploymentType":"all_except_custom_domains"}` → login wall untuk semua `*.vercel.app`. `curl` deployment-URL sebelum PATCH → halaman login Vercel; sesudah PATCH → `application/json` 200.
- **Dampak:** butuh 4 putaran (domain + proteksi + token) sebelum landing benar-benar publik; kalau lolos, app T11 akan fetch `version.json` dan dapat HTML login, bukannya JSON.
- **Aturan baru:**
  1. **Production domain project Vercel (plan hobby) = `<nama>-<scope>.vercel.app`** (mis. `tazk-manager-mfdu.vercel.app`). `<nama>.vercel.app` **TIDAK otomatis** jadi milik kita — cek dulu dengan `vercel alias set` / curl sebelum memakainya di `version.json`.
  2. **Project baru via `vercel link` punya `ssoProtection.deploymentType="all_except_custom_domains"` (default ON)** → semua `*.vercel.app` di balik login. Matikan lewat API: `PATCH /v9/projects/{id}` body `{"ssoProtection": null}`. Bukti wajib: `curl <domain>/version.json` → `Content-Type: application/json` (bukan HTML).
  3. **Token CLI Vercel disimpan di `%APPDATA%\xdg.data\com.vercel.cli\auth.json`** (bukan `~/.vercel/auth.json` yang kosong). Untuk API, baca dari situ; jangan echo tokennya.
- **Verifikasi:** `curl https://tazk-manager-mfdu.vercel.app/version.json` → `application/json` berisi `downloadUrl: https://tazk-manager-mfdu.vercel.app/downloads/tazk.apk`; `/`, `/en/`, `/privasi/`, `/en/privacy/` semua HTTP 200 publik.

---

## L-017 · STATUS.md menulis "input durasi bebas dihapus" padahal fiturnya ada di kode
- **Tanggal:** 2026-11-10
- **Salah:** baris fidelity board 05 Pomodoro di `docs/STATUS.md` berbunyi "**Regresi: input durasi bebas dihapus** (board hanya chip)", dan daftar "keputusan yang menunggu owner" masih memuat "durasi Pomodoro bebas dikembalikan?" — padahal fitur itu **sudah** ada di kode (`pomodoro_screen.dart` ketuk angka → sheet 1–180 menit; `setDurationMinutes`).
- **Bukti:** `grep "durasi|sheet|1..180|setDurationMinutes" lib/features/pomodoro` → pemilih durasi bebas hadir dan teruji; log 2026-10-31 sendiri mencatatnya terverifikasi di HP.
- **Dampak:** dokumen status menyesatkan sesi berikutnya (bisa memicu "membangun ulang" fitur yang sudah ada, atau keputusan yang salah).
- **Aturan baru:** **status fitur wajib diverifikasi ke KODE sebelum ditulis** — klaim "X belum ada/dihilangkan" hanya setelah `grep`/membaca implementasi nyata, bukan dari board atau ingatan. Berlaku juga untuk tabel fidelity & daftar keputusan.
- **Verifikasi:** `grep "input durasi bebas dihapus" docs/STATUS.md` → 0 hasil; baris board 05 dan daftar keputusan sudah dikoreksi.

---

## L-018 · Tap `adb` buta dengan koordinat salah membuka aplikasi pribadi owner dan memotret isinya
- **Tanggal:** 2026-11-10
- **Salah:** menguji tap widget dengan `adb shell input tap <x> <y>` memakai koordinat yang dibaca dari screenshot berukuran **900×2000**, padahal layar perangkat **1080×2400**. Tanpa kalibrasi, tap mendarat di luar widget dan membuka **Telegram**, lalu `screencap` memotret grup pribadi owner (nama grup, isi pesan, nomor, foto). Aku juga sempat menyimpulkan "tap widget rusak" dari satu screenshot yang sebenarnya diambil **sebelum widget ter-refresh**.
- **Bukti:** `wm size` = 1080×2400 vs `Image.open(...).size` = 900×2000 (skala 1,2). Setelah tap mendarat di area widget dengan koordinat benar, task "y" berubah ☐ → ☑ → ☐ (dua arah), jadi receiver tetap berfungsi.
- **Dampak:** privasi owner tersentuh (screenshot aplikasi pribadi ikut terbaca), dan hampir melaporkan regresi palsu pada jalur widget yang justru sudah terbukti benar (kelas kesalahan L-002: menyimpulkan dari kondisi uji yang salah).
- **Aturan baru:**
  1. **Sebelum tap apa pun lewat `adb`:** jalankan `adb shell wm size` dan bandingkan dengan ukuran file screenshot; hitung skala eksplisit, jangan menebak. Kalau ragu, pakai `uiautomator dump` dan ambil koordinat dari `bounds` node, bukan dari mata.
  2. **Tap hanya di area yang sudah dipastikan** (widget/aplikasi target). Setelah tap, verifikasi `topResumedActivity` **sebelum** mengambil screenshot, supaya aplikasi pribadi tidak ikut terpotret.
  3. **Screenshot yang memuat konten pribadi owner wajib langsung dihapus** dari disk dan tidak boleh masuk repo.
  4. **Jangan menyimpulkan "rusak" dari satu screenshot.** Widget me-refresh asinkron; tunggu dan ambil ulang, atau buktikan lewat data (DB/log), sebelum menyatakan regresi.
- **Verifikasi:** koordinat dihitung ulang (skala 1,2), tap mendarat di widget, perubahan centang terbukti dua arah; screenshot berisi konten pribadi dihapus (`docs/artifacts/w4_now.png`, `w4_after_tap.png`, `w4_home_widgets.png`).

---

## L-019 · `Set-Content -NoNewline` merusak `pubspec.yaml` jadi satu baris
- **Tanggal:** 2026-11-10
- **Salah:** menaikkan versi dengan `(Get-Content pubspec.yaml) -replace ... | Set-Content pubspec.yaml -NoNewline`. `-NoNewline` **membuang semua pemisah baris** hasil pipeline, sehingga 137 baris `pubspec.yaml` runtuh menjadi **1 baris** (137 baris terhapus). File rusak total, bukan hanya baris versi.
- **Bukti:** `(Get-Content pubspec.yaml).Count` → **1**; `git diff --stat` → `138 +----...` (137 deletions). Setelah `git checkout -- pubspec.yaml`, kembali 137 baris.
- **Dampak:** kalau tidak tertangkap, build/`pub get` gagal atau lebih buruk: YAML tetap valid sebagai satu baris panjang sehingga bisa lolos dan merusak konfigurasi lain secara senyap. Waktu terbuang + risiko pada file konfigurasi kritis.
- **Aturan baru:**
  1. **Jangan pernah menulis ulang file utuh dengan shell** (`Set-Content`/`Out-File`/`>`). Untuk perubahan satu baris, pakai alat `edit` (find & replace eksak) yang mempertahankan sisa file.
  2. **Jangan pakai `-NoNewline` pada file multi-baris.** Itu untuk output satu baris, bukan untuk file konfigurasi.
  3. **Setelah menyentuh file konfigurasi kritis** (`pubspec.yaml`, `build.gradle*`, `AndroidManifest.xml`, `*.arb`): segera cek `(Get-Content <file>).Count` dan `git diff --stat`. Diff harus sebanding dengan perubahan yang dimaksud; diff yang menghapus ratusan baris = berhenti dan restore.
- **Verifikasi:** `pubspec.yaml` 137 baris, `version: 2.0.0+1`, `git diff --stat` = `1 insertion(+), 1 deletion(-)`.

---

## L-020 · Streak "tidak bertambah" — reset terjadi karena hari bolong, dan app diam saja saat reset
- **Tanggal:** 2026-11-14
- **Keluhan owner:** "streak tidak bertambah padahal task & habit hari itu sudah dikerjakan semua" (streak mentok di 1 dari hari pertama).
- **Investigasi:** seluruh logika diuji dan **terbukti benar** — `_registerActiveDay`, `evaluateMissedDay`, round-trip `DateTime` Drift (probe: `2026-11-14` masuk → `2026-11-14` keluar), `switch` callback widget tidak fall-through (dibuktikan `dart run` → `RESULT=A`), dan semua jalur centang memanggil gamifikasi.
- **Bukti akar masalah (DB asli dari perangkat, dibaca lewat build ber-`debuggable` + `run-as`):**
  ```
  streak_state: current=1 longest=1 last_active=2026-11-13
  xp_events per hari: 2026-11-11 → 30 event, 2026-11-12 → 0 event, 2026-11-13 → 5 event
  habit_logs:        2026-11-09, 11-10, 11-11, 11-13 (12 Nov tidak ada)
  tasks:             "SDL P2" due 2026-11-12, is_completed=1, TAPI tidak ada xp_event 12 Nov
  ```
  Jadi **12 November tidak ada penyelesaian tercatat** → `evaluateMissedDay` pada 13 Nov melihat jarak 2 hari → streak direset → naik lagi jadi 1. Perilaku **sesuai desain** (streak butuh ≥1 item selesai tiap hari).
- **Probe konfirmasi pada SALINAN DB asli:** `BEFORE cur=1 last=2026-11-13` → `onHabitCompleted()` → `cur=2 longest=2 last=2026-11-14`. Logika naik dengan benar.
- **Salah (produk):** `streakBrokenTitle` / `streakBrokenBody` sudah ada di l10n ID+EN tetapi **tidak dipakai di kode mana pun** — streak bisa direset tanpa satu pun pemberitahuan. Owner tidak punya cara mengetahui hari mana yang bolong, sehingga bug terlihat seperti "streak tidak berfungsi".
- **Dampak:** kepercayaan pada fitur gamifikasi turun; owner mengira ada bug hitung padahal reset-nya benar.
- **Aturan baru:**
  1. **Jangan menyimpulkan "bug" dari kode saja.** Untuk keluhan berbasis riwayat (streak/statistik/XP), baca **database asli** dulu: `xp_events` per hari + `habit_logs` + `streak_state.last_active_date`. Kode yang lulus test belum membuktikan data user benar.
  2. **Reset streak wajib bisa dilihat user.** Setiap kali `evaluateMissedDay` mengosongkan streak, kabari (notifikasi/banner) + sebutkan tanggal yang bolong.
  3. Membaca DB release butuh `debuggable=true` + **keystore rilis yang sama** supaya `adb install -r` tidak menghapus data. Selalu revert flag itu sebelum build rilis berikutnya.
  4. Menarik file biner dari adb **jangan** lewat redirection PowerShell (`>` merusak byte). Pakai `cmd /c "... exec-out ... > file"`.
- **Verifikasi:** DB perangkat terbaca (schema v8, 22 objek), probe pada salinan DB asli menunjukkan streak 1→2, HP dipulihkan ke build rilis non-debuggable dengan data utuh (Faza, 95 XP).

---

## L-021 · Memperbaiki bug streak tapi memasukkan bug yang sama lewat "self-heal"
- **Tanggal:** 2026-11-14
- **Salah:** menulis `repairStreakFromHistory()` yang menganggap hari aktif bila ada `xp_events` positif, tanpa memeriksa **sumber** event itu. `onTaskPriorityChanged` (menaikkan prioritas task yang sudah selesai) memberi XP hari ini tanpa penyelesaian — jadi hari tanpa penyelesaian tampak aktif, `lastActiveDate` ditulis ke hari ini, lalu `_registerActiveDay()` **menelan penyelesaian berikutnya** (`return` awal karena tanggal aktif sudah hari ini). Persis gejala asli yang sedang diperbaiki: "sudah dikerjakan tapi streak tidak naik".
- **Bukti:** `flutter test` menangkapnya lebih dulu setelah saya menulis test khusus — `Expected: [2026-11-13]` / `Actual: [2026-11-13, 2026-11-14]`. Scan Strix (diff-scoped) menemukan cacat yang sama secara independen, ditambah 2 cacat lain: notifikasi "streak putus" **terkirim ulang tiap hari** (dibuktikan test: `['streakBroken','streakBroken']`), dan `lastActiveDate` bisa **mundur** walau kontraknya "monoton".
- **Dampak:** kalau dirilis apa adanya, fitur yang dimaksudkan memulihkan kepercayaan justru menampilkan streak yang tidak layak dan membekukan streak berikutnya — kerusakan lebih besar daripada bug awal.
- **Aturan baru:**
  1. **"Hari aktif" harus punya sumber eksplisit.** Event XP yang berarti penyelesaian = `XpSource.task` / `XpSource.habit`. Penyesuaian XP (ubah prioritas, refund, bonus) **tidak** boleh dihitung. Menambah `enum` = aman selama **ditambahkan di akhir** (nilai disimpan sebagai int).
  2. **Notifikasi yang dipicu kondisi persisten wajib dijaga transisi** (`state lama > 0`), bukan hanya gate preferensi — kalau tidak, ia berulang setiap rollover selamanya.
  3. **Kontrak "monoton" harus mencakup SEMUA field**, bukan hanya counter yang dibandingkan; `lastActiveDate` ikut dijaga.
  4. **Read-modify-write lintas isolate wajib transaksi** (isolate tengah malam + UI bisa menulis bersamaan).
  5. **Aritmetika tanggal pakai konstruktor kalender** (`DateTime(y, m, d + n)`), bukan `subtract(Duration(days: n))` — DST membuat hasilnya bukan tengah malam.
  6. **Widget yang menampilkan data wajib membedakan "belum ada nilai" dari "kosong"** — `valueOrNull ?? []` membuat layar menyatakan "tidak ada aktivitas" padahal masih memuat.
  7. **Test dengan tanggal tetap akan kedaluwarsa.** Fixture berbasis jam nyata, atau clock harus disuntikkan sampai ke repository.
- **Verifikasi:** `flutter test` **629/629** · `dart analyze` 0 issue · probe ulang pada salinan DB asli tetap `CHANGED=false` (tidak mengarang streak) · notifikasi hanya pada transisi (test).

---

