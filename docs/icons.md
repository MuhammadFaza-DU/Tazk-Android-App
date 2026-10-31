# Ikon & Aset — Cara Memasang Ikon Final

Semua ikon Android dihasilkan dari **satu file master** oleh `tool/generate_icons.py`.
Jangan menimpa `ic_launcher.png` satu per satu — selalu regenerasi supaya semua
densitas + adaptive icon + ikon notifikasi tetap sinkron.

## 1. Siapkan master

- Ukuran: **1024×1024 PNG** (persegi, tanpa sudut membulat).
- Wajah/elemen penting di **66% area tengah** (pinggir ~18% bisa terpotong mask Android).
- Prompt resmi: `docs/design/ikon-logo-prompts.md` §2 (prompt **I-1** untuk light).
- Simpan ke: **`assets/icon/app_icon_master.png`**

> Catatan 2026-10-31: ikon saat ini dihasilkan dari `assets/mascot/otter-portrait.png`
> karena generator gambar belum tersedia (API key provider image tidak valid).
> Board `16 App Icon` sendiri menandai ini "pratinjau, belum ikon final".

## 2. Regenerasi

```powershell
python tool/generate_icons.py                     # pakai master default
python tool/generate_icons.py path/ke/lain.png    # atau file lain
```

Yang ditulis:

| Keluaran | Lokasi |
|---|---|
| Launcher legacy (48/72/96/144/192 px) | `android/app/src/main/res/mipmap-*/ic_launcher.png` |
| Adaptive foreground + monochrome (108/162/216/324/432 px) | `android/app/src/main/res/mipmap-*/ic_launcher_{foreground,monochrome}.png` |
| Adaptive XML | `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` |
| Warna latar adaptive (`#F4F1EA` = token `canvas`) | `android/app/src/main/res/values/ic_launcher_background.xml` |
| Ikon notifikasi monokrom (glyph tunas, 24/36/48/72/96 px) | `android/app/src/main/res/drawable-*/ic_notification.png` |

## 3. Pasang di perangkat

```powershell
flutter build apk --release --split-per-abi
adb install -r build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

Ikon launcher di-cache agresif oleh launcher. Kalau ikon lama masih tampil:
uninstall dulu (`adb uninstall com.tazk.tazk`), install ulang, atau restart launcher.

## 4. Kenapa bukan ikon notifikasi dari wajah maskot?

Status bar Android hanya mau **siluet putih transparan**; maskot PNG berlatar krem
opaque. Hasil uji coba (luminance pass) terlalu pudar di 24dp, jadi dipakai glyph
**tunas** — mark khas Tazk yang tetap tajam di semua DPI.

## 5. Aset yang masih perlu dibuat

| Aset | Status | Catatan |
|---|---|---|
| Ikon launcher final (wajah otter) | ⚠️ pratinjau | menunggu master 1024×1024 dari owner |
| Wordmark horizontal | ✅ `assets/logo/tazk-logo.png` | jangan dipakai di kotak persegi (terpotong) |
| Maskot: portrait / waving / with-sprout | ✅ `assets/mascot/` | PNG berlatar krem; di UI dipakai dalam `ClipOval` |
| Maskot latar transparan | ⬜ belum | dibutuhkan bila ingin maskot tanpa lingkaran |
| Ikon widget homescreen | 🟡 | menunggu T8 |
