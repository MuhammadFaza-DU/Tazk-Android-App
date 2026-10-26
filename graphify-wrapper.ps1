# graphify-wrapper.ps1
param([Parameter(ValueFromRemainingArguments=$true)]$args)

# Load .env dari folder project
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^\s*([^#=][^=]*)=(.*)$") {
            Set-Item -Path "Env:$($matches[1].Trim())" -Value $matches[2].Trim()
        }
    }
}

# Call graphify via uv tool (path sudah di PATH)
uv tool run --from graphifyy graphify @args
