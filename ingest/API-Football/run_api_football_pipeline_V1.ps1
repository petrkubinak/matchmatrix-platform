# C:\MATCHMATRIX-PLATFORM\ingest\API-Football\run_api_football_pipeline.ps1
# Example:
#   powershell -ExecutionPolicy Bypass -File .\run_api_football_pipeline.ps1 `
#     -LeagueId 39 -Season 2025 `
#     -FixturesFrom 2026-02-22 -FixturesTo 2026-03-02 `
#     -OddsFrom 2026-02-24 -OddsTo 2026-02-27

param(
  [Parameter(Mandatory=$true)][int]$LeagueId,
  [Parameter(Mandatory=$true)][int]$Season,

  [Parameter(Mandatory=$false)][string]$FixturesFrom,
  [Parameter(Mandatory=$false)][string]$FixturesTo,

  [Parameter(Mandatory=$false)][string]$OddsFrom,
  [Parameter(Mandatory=$false)][string]$OddsTo,

  [switch]$DoTeams,
  [switch]$DoFixtures,
  [switch]$DoOdds
)

Write-Host "=== USING V1 PIPELINE ===" -ForegroundColor Yellow

Set-Location $PSScriptRoot
$ErrorActionPreference = "Stop"

# DB (align with docker defaults)
$PG_CONTAINER = "matchmatrix_postgres"
$PG_USER      = "matchmatrix"
$PG_DB        = "matchmatrix"
$PG_PASSWORD  = "matchmatrix"

function Get-RunIdFromPython([string]$output) {
  $rid = ($output | Out-String).Trim()
  if (-not $rid -or -not ($rid -match '^\d+$')) {
    throw ("Python did not return numeric run_id. Got: [{0}]" -f $rid)
  }
  return $rid
}

function Psql-FileWithVars([string]$sqlFile, [hashtable]$vars) {
  if (-not (Test-Path $sqlFile)) { throw ("SQL file not found: {0}" -f $sqlFile) }

  $varArgs = ""
  foreach ($k in $vars.Keys) {
    $v = $vars[$k]
    $varArgs += " -v $k=$v"
  }

  $cmd = "docker exec -e PGPASSWORD=$PG_PASSWORD -i $PG_CONTAINER psql -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1$varArgs -f -"
  Get-Content -Raw $sqlFile | cmd /c $cmd
}

# Default windows if not provided
if (-not $FixturesFrom) { $FixturesFrom = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd") }
if (-not $FixturesTo)   { $FixturesTo   = (Get-Date).AddDays(14).ToString("yyyy-MM-dd") }

if (-not $OddsFrom) { $OddsFrom = (Get-Date).ToString("yyyy-MM-dd") }
if (-not $OddsTo)   { $OddsTo   = (Get-Date).AddDays(3).ToString("yyyy-MM-dd") }

Write-Host "== API-Football pipeline =="
Write-Host ("LeagueId={0} Season={1}" -f $LeagueId, $Season)
Write-Host ("Fixtures window: {0} -> {1} (DoFixtures={2})" -f $FixturesFrom, $FixturesTo, [bool]$DoFixtures)
Write-Host ("Odds window    : {0} -> {1} (DoOdds={2})" -f $OddsFrom, $OddsTo, [bool]$DoOdds)

function New-ApiImportRun([int]$leagueId, [int]$season) {

  $sql = "insert into public.api_import_runs(source, details) values ('api-football', jsonb_build_object('league_id',$leagueId,'season',$season)) returning id;"

  $cmd = "export PGPASSWORD='$PG_PASSWORD'; psql -q -t -A -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1"

  # Pošli SQL do psql přes stdin (žádné quoting peklo)
  $rid = $sql | docker exec -i $PG_CONTAINER bash -lc $cmd
  $rid = ($rid | Out-String).Split([Environment]::NewLine) | Where-Object { $_ -match '^\s*\d+\s*$' } | Select-Object -Last 1
  $rid = ($rid -as [string]).Trim()

  if (-not $rid -or -not ($rid -match '^\d+$')) {
    throw "Could not create api_import_run id. Got: [$rid]"
  }

  return [long]$rid
}

$runId = New-ApiImportRun -leagueId $LeagueId -season $Season
Write-Host ("run_id={0}" -f $runId)

Write-Host "==[0/4] Pull leagues -> staging =="
& powershell -ExecutionPolicy Bypass -File ".\pull_api_football_leagues.ps1" -RunId $runId

if ($DoTeams) {
  Write-Host "==[1/4] Pull teams -> staging =="
  & powershell -ExecutionPolicy Bypass -File ".\pull_api_football_teams.ps1" -RunId $runId -LeagueId $LeagueId -Season $Season
} else {
  Write-Host "==[1/4] Pull teams -> SKIP =="
}

if ($DoFixtures) {
  Write-Host "==[2/4] Pull fixtures -> staging =="
  & powershell -ExecutionPolicy Bypass -File ".\pull_api_football_fixtures.ps1" -RunId $runId -LeagueId $LeagueId -Season $Season -From $FixturesFrom -To $FixturesTo
}

if ($DoOdds) {
  Write-Host "==[3/4] Pull odds -> staging =="
  & powershell -ExecutionPolicy Bypass -File ".\pull_api_football_odds_V1.ps1" -RunId $runId -LeagueId $LeagueId -Season $Season -From $OddsFrom -To $OddsTo
}

# mergeRunId = $runId
$mergeRunId = $runId

# 3) Merge staging -> public
# NOTE: Today merge script supports run_id. We merge using fixtures run_id if available.
# If you later add odds merge scripts, we can run a second merge for odds_run_id.
Write-Host "==[3/3] Merge staging -> public =="

# --- MERGE: stream 031-034 directly (no \i) ---
$Repo   = "C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform"
$GenDir = Join-Path $Repo "Scripts\03_generation"

$sqlFiles = @(
  "031_upsert_leagues_api_football.sql",
  "032_upsert_teams_api_football.sql",
  "033_upsert_league_teams_api_football.sql",
  "034_upsert_matches_api_football.sql"
) | ForEach-Object { Join-Path $GenDir $_ }

foreach ($f in $sqlFiles) {
  if (-not (Test-Path $f)) { throw ("Missing SQL file: {0}" -f $f) }
}

$nl = "`n"
$sqlStream = "\set ON_ERROR_STOP on$nl"
$sqlStream += "-- run_id injected by pipeline$nl"
$sqlStream += "BEGIN;$nl"

foreach ($f in $sqlFiles) {
  $sqlStream += "$nl-- ===== FILE: $f =====$nl"
  $content = Get-Content -Raw -Encoding UTF8 $f
  $content = $content -replace ":'run_id'", $mergeRunId
  $content = $content -replace ":run_id", $mergeRunId
  $sqlStream += $content + $nl
}

$sqlStream += "COMMIT;$nl"

$cmd = "export PGPASSWORD='$PG_PASSWORD'; psql -v ON_ERROR_STOP=1 -U $PG_USER -d $PG_DB"
$sqlStream | docker exec -i $PG_CONTAINER bash -lc $cmd

Write-Host "DONE."