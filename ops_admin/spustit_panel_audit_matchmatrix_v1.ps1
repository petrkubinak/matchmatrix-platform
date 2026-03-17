# ============================================
# MatchMatrix Audit Panel V1 - launcher
# ============================================

$ErrorActionPreference = "Stop"

# UPRAV podle umístění Python skriptu na tvém PC
$ScriptPath = "C:\Users\$env:USERNAME\Desktop\panel_audit_matchmatrix_v1.py"

if (-not (Test-Path $ScriptPath)) {
    Write-Host "Soubor nebyl nalezen:" -ForegroundColor Red
    Write-Host $ScriptPath -ForegroundColor Yellow
    pause
    exit 1
}

# Preferovaný Python launcher
if (Get-Command py -ErrorAction SilentlyContinue) {
    py "$ScriptPath"
}
elseif (Get-Command python -ErrorAction SilentlyContinue) {
    python "$ScriptPath"
}
else {
    Write-Host "Python nebyl nalezen v PATH." -ForegroundColor Red
    pause
    exit 1
}
