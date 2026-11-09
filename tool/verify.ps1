# Local gate — same checks as .github/workflows/ci.yml.
# Run before a checkpoint/tag:  powershell -ExecutionPolicy Bypass -File tool\verify.ps1
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "== flutter pub get =="
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== dart analyze =="
dart analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== flutter test =="
flutter test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "GATE OK"