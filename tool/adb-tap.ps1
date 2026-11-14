# Tap aman untuk uji manual di perangkat.
#
# Dibuat karena tap `adb` dengan koordinat tebakan pernah membuka aplikasi
# pribadi owner dan memotret isinya (L-018, terulang 2026-11-14). Skrip ini
# menolak menebak: koordinat hanya boleh datang dari `uiautomator dump`.
#
# Contoh:
#   .\tool\adb-tap.ps1 -Package com.tazk.tazk -Text "Lower Day"
#   .\tool\adb-tap.ps1 -Package com.tazk.tazk -Text "Ekspor data" -Shot out.png
#   .\tool\adb-tap.ps1 -X 150 -Y 1818 -Package com.tazk.tazk

param(
  [string]$Package = 'com.tazk.tazk',
  [string]$Text,
  [int]$X = -1,
  [int]$Y = -1,
  [string]$Shot,
  [int]$SettleSeconds = 2,
  # Tap di kotak centang (kiri baris), bukan tengah baris yang membuka detail.
  [switch]$Checkbox
)

$ErrorActionPreference = 'Stop'
$adb = if ($env:ANDROID_HOME) { Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe' } else { 'adb' }
if (-not (Test-Path $adb)) { throw "adb tidak ditemukan di $adb" }

function Get-Focus {
  $out = & $adb shell dumpsys window 2>$null | Select-String 'mCurrentFocus'
  if (-not $out) { return '' }
  return ($out -join ' ')
}

function Assert-TargetFocus([string]$stage) {
  $focus = Get-Focus
  if ($focus -notmatch [regex]::Escape($Package)) {
    throw "Batal ($stage): fokus layar bukan $Package. Fokus: $focus. " +
          "Buka app target dulu; jangan menekan tombol saat app lain di depan."
  }
}

# Prasyarat: app target harus sudah di depan. Ini yang mencegah tap nyasar
# mendarat di aplikasi pribadi.
Assert-TargetFocus 'sebelum tap'

$tapX = $X
$tapY = $Y

if ($Text) {
  & $adb shell uiautomator dump /sdcard/_tap_dump.xml | Out-Null
  $xml = (& $adb shell cat /sdcard/_tap_dump.xml) -join ''

  # Label Flutter sering multi-baris ("Lower Day&#10;1 hari"), jadi cocokkan
  # persis dulu, lalu jatuh ke "mengandung" — masih dari bounds node, bukan tebakan.
  $escaped = [regex]::Escape($Text)
  $m = [regex]::Match($xml, 'content-desc="' + $escaped + '"[^>]*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
  if (-not $m.Success) {
    $m = [regex]::Match($xml, 'text="' + $escaped + '"[^>]*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
  }
  if (-not $m.Success) {
    $m = [regex]::Match($xml, 'content-desc="[^"]*' + $escaped + '[^"]*"[^>]*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
  }
  if (-not $m.Success) { throw "Node dengan teks '$Text' tidak ditemukan. Tidak menebak koordinat." }

  # Titik tengah kotak node, dihitung dari bounds asli perangkat (bukan screenshot).
  $left = [int]$m.Groups[1].Value
  $top = [int]$m.Groups[2].Value
  $right = [int]$m.Groups[3].Value
  $bottom = [int]$m.Groups[4].Value

  if ($Checkbox) {
    # Kotak centang berada di kiri baris; tap tengah baris justru membuka detail.
    $tapX = $left + [int](($right - $left) * 0.10)
    $tapY = $top + [int](($bottom - $top) / 2)
  } else {
    $tapX = $left + [int](($right - $left) / 2)
    $tapY = $top + [int](($bottom - $top) / 2)
  }
  Write-Host "target '$Text' -> ($tapX,$tapY)$(if ($Checkbox) { ' [checkbox]' })"
} elseif ($X -lt 0 -or $Y -lt 0) {
  throw 'Butuh -Text (disarankan) atau -X/-Y yang sudah dipastikan.'
}

& $adb shell input tap $tapX $tapY | Out-Null
Start-Sleep -Seconds $SettleSeconds

Assert-TargetFocus 'sesudah tap'

if ($Shot) {
  & $adb shell screencap -p /sdcard/_tap_shot.png 2>&1 | Out-Null
  # adb menulis progres ke stderr; PowerShell memperlakukannya sebagai error.
  $prev = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  & $adb pull /sdcard/_tap_shot.png $Shot 2>&1 | Out-Null
  $ErrorActionPreference = $prev
  & $adb shell rm -f /sdcard/_tap_shot.png /sdcard/_tap_dump.xml 2>&1 | Out-Null
  if (Test-Path $Shot) { Write-Host "screenshot: $Shot" } else { Write-Host "screenshot GAGAL: $Shot" }
}
