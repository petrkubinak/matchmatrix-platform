param(
    [string]$PgHost = "localhost",
    [int]$PgPort = 5432,
    [string]$PgDatabase = "matchmatrix",
    [string]$PgUser = "postgres",
    [string]$PgPassword = "postgres",
    [string]$BaseDir = "C:\MatchMatrix-platform"
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Cesty
# ------------------------------------------------------------
$sqlFile = Join-Path $BaseDir "db\audit\079_audit_player_season_statistics_report_v1.sql"
$reportDir = Join-Path $BaseDir "reports\player_audit"

# PostgreSQL client - uprav podle své instalace
$psqlExe = "C:\Program Files\PostgreSQL\17\bin\psql.exe"

# ------------------------------------------------------------
# Příprava složky
# ------------------------------------------------------------
if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

# ------------------------------------------------------------
# Název výstupního reportu
# ------------------------------------------------------------
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = Join-Path $reportDir ("player_season_statistics_audit_" + $timestamp + ".txt")

# ------------------------------------------------------------
# Kontroly
# ------------------------------------------------------------
if (-not (Test-Path $sqlFile)) {
    throw "SQL soubor neexistuje: $sqlFile"
}

if (-not (Test-Path $psqlExe)) {
    throw "psql.exe neexistuje: $psqlExe"
}

# ------------------------------------------------------------
# Spuštění
# ------------------------------------------------------------
$env:PGPASSWORD = $PgPassword

Write-Host "============================================================"
Write-Host "MATCHMATRIX - PLAYER SEASON STATISTICS AUDIT REPORT"
Write-Host "============================================================"
Write-Host "SQL FILE   : $sqlFile"
Write-Host "REPORT FILE: $reportFile"
Write-Host "DB         : $PgDatabase@$PgHost:$PgPort"
Write-Host "============================================================"

# Výstup stdout i stderr uložíme do souboru
& $psqlExe `
    -h $PgHost `
    -p $PgPort `
    -U $PgUser `
    -d $PgDatabase `
    -v ON_ERROR_STOP=1 `
    -f $sqlFile 2>&1 | Out-File -FilePath $reportFile -Encoding utf8

Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue

Write-Host "Hotovo."
Write-Host "Report ulozen do:"
Write-Host $reportFile