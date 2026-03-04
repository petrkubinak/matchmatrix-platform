param(
  [Parameter(Mandatory=$true)][int]$RunId
)

# SQL zdroje v repu (DB skripty)
$sqlBase = "C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\03_generation\030_upsert_api_football.sql"

$sql = @(
  Get-Content "$sqlBase\031_upsert_leagues_api_football.sql" -Raw
  Get-Content "$sqlBase\032_upsert_teams_api_football.sql" -Raw
  Get-Content "$sqlBase\033_upsert_league_teams_api_football.sql" -Raw
  Get-Content "$sqlBase\034_upsert_matches_api_football.sql" -Raw
) -join "`n`n"

Write-Host "=== MERGE-ONLY api_football run_id=$RunId ==="
$sql | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -v run_id=$RunId