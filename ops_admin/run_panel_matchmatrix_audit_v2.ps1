# MatchMatrix Audit Panel V2 - spouštěč
# Doporučené umístění:
# C:\MatchMatrix-platform\ops_admin\run_panel_matchmatrix_audit_v2.ps1

$ErrorActionPreference = "Stop"

$pythonCandidates = @(
    "C:\Python314\python.exe",
    "python",
    "py"
)

$scriptPath = "C:\MatchMatrix-platform\ops_admin\panel_matchmatrix_audit_v2.py"

if (!(Test-Path $scriptPath)) {
    Write-Host "Soubor nebyl nalezen:" -ForegroundColor Red
    Write-Host $scriptPath -ForegroundColor Yellow
    pause
    exit 1
}

$pythonExe = $null
foreach ($candidate in $pythonCandidates) {
    try {
        & $candidate --version *> $null
        if ($LASTEXITCODE -eq 0) {
            $pythonExe = $candidate
            break
        }
    } catch {
    }
}

if ($null -eq $pythonExe) {
    Write-Host "Nebyl nalezen Python." -ForegroundColor Red
    Write-Host "Zkontroluj instalaci Pythonu nebo uprav run_panel_matchmatrix_audit_v2.ps1" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "Spouštím MatchMatrix Audit Panel V2..." -ForegroundColor Cyan
& $pythonExe $scriptPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "Panel skončil s chybou. Zkontroluj Python závislosti." -ForegroundColor Red
    Write-Host "Pro DB audit může být potřeba: pip install psycopg2-binary" -ForegroundColor Yellow
    pause
}
