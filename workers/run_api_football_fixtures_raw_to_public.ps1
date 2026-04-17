param(
  [Parameter(Mandatory=$true)]
  [long[]]$RunIds
)

$ErrorActionPreference = "Stop"

# Přesná cesta k SQL skriptům
$sqlBase = "C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\03_generation\030_upsert_api_football.sql"

if (-not (Test-Path $sqlBase)) {
    throw "SQL base folder not found: $sqlBase"
}

# Načtení merge SQL kroků
$sql31 = Get-Content (Join-Path $sqlBase "031_upsert_leagues_api_football.sql") -Raw
$sql32 = Get-Content (Join-Path $sqlBase "032_upsert_teams_api_football.sql") -Raw
$sql33 = Get-Content (Join-Path $sqlBase "033_upsert_league_teams_api_football.sql") -Raw
$sql34 = Get-Content (Join-Path $sqlBase "034_upsert_matches_api_football.sql") -Raw

foreach ($runId in $RunIds) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "API-FOOTBALL FIXTURES RAW -> PUBLIC | run_id=$runId" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan

    # 1) Ligy
    Write-Host "[1/4] Upsert leagues..." -ForegroundColor Yellow
    $sql31 | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -v run_id=$runId

    # 2) Týmy
    Write-Host "[2/4] Upsert teams..." -ForegroundColor Yellow
    $sql32 | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -v run_id=$runId

    # 3) League teams
    Write-Host "[3/4] Upsert league_teams..." -ForegroundColor Yellow
    $sql33 | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -v run_id=$runId

    # 4) Matches
    Write-Host "[4/4] Upsert matches..." -ForegroundColor Yellow
    $sql34 | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -v run_id=$runId

    Write-Host ""
    Write-Host "Kontrola výsledku pro run_id=$runId" -ForegroundColor Green

    docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -c "
    SELECT
        $runId AS run_id,
        COUNT(DISTINCT f.fixture_id) AS raw_distinct,
        COUNT(DISTINCT m.ext_match_id) AS present_in_public,
        COUNT(DISTINCT f.fixture_id) - COUNT(DISTINCT m.ext_match_id) AS missing_after_merge
    FROM staging.api_football_fixtures f
    LEFT JOIN public.matches m
      ON m.ext_source = 'api_football'
     AND m.ext_match_id = f.fixture_id::text
    WHERE f.run_id = $runId;
    "
}

Write-Host ""
Write-Host "HOTOVO: API-Football fixtures raw -> public merge dokončen." -ForegroundColor Green