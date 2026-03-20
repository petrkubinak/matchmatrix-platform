param(
    [string]$ContainerName = "matchmatrix_postgres",
    [string]$PgUser = "matchmatrix",
    [string]$PgDatabase = "matchmatrix",
    [string]$BaseDir = "C:\MatchMatrix-platform"
)

$ErrorActionPreference = "Stop"

$sqlFile   = Join-Path $BaseDir "db\audit\079_audit_player_season_statistics_report_v1.sql"
$reportDir = Join-Path $BaseDir "reports\player_audit"

if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

$timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFile = Join-Path $reportDir ("player_season_statistics_audit_" + $timestamp + ".txt")

if (-not (Test-Path $sqlFile)) {
    throw "SQL soubor neexistuje: $sqlFile"
}

Write-Host "============================================================"
Write-Host "MATCHMATRIX - PLAYER SEASON STATISTICS AUDIT REPORT (DOCKER)"
Write-Host "============================================================"
Write-Host "SQL FILE   : $sqlFile"
Write-Host "REPORT FILE: $reportFile"
Write-Host "CONTAINER  : $ContainerName"
Write-Host "============================================================"

# Dulezite pro korektni UTF-8 vystup
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Spusteni auditu a zachyceni vystupu
$output = Get-Content $sqlFile -Raw | docker exec -i $ContainerName psql -U $PgUser -d $PgDatabase -v ON_ERROR_STOP=1 2>&1

# Ulozeni jako UTF-8 s BOM kompatibilni i pro starsi Windows PowerShell
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllLines($reportFile, [string[]]$output, $utf8Bom)

Write-Host "Hotovo."
Write-Host "Report ulozen do:"
Write-Host $reportFile