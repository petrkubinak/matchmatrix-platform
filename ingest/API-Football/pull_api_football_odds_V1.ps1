param(
  [Parameter(Mandatory=$true)][int]$RunId,
  [Parameter(Mandatory=$true)][int]$LeagueId,
  [Parameter(Mandatory=$true)][int]$Season,

  [Parameter(Mandatory=$true)][string]$From,
  [Parameter(Mandatory=$true)][string]$To,

  [Parameter(Mandatory=$true)][int]$FixtureId
)

$ErrorActionPreference = "Stop"

$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) { throw ".env not found" }

foreach ($line in Get-Content $envFile) {
  if ($line -match "=") {
    $parts = $line.Split("=",2)
    [Environment]::SetEnvironmentVariable($parts[0], $parts[1])
  }
}

$API_KEY = $env:APISPORTS_KEY
if (-not $API_KEY) { throw "Missing APISPORTS_KEY in .env" }

$uri = "https://v3.football.api-sports.io/odds?fixture=$FixtureId"
Write-Host "Pulling ODDS... league=$LeagueId season=$Season fixture=$FixtureId run_id=$RunId"

$response = Invoke-RestMethod -Uri $uri -Headers @{ "x-apisports-key" = $API_KEY }

Write-Host ("Odds API results={0}" -f $response.results)

if ($response.errors) {
  Write-Host ("Odds API errors: {0}" -f (($response.errors | ConvertTo-Json -Depth 10)))
}

if (-not $response.response) { Write-Host "No odds returned."; exit 0 }

$PG_CONTAINER = "matchmatrix_postgres"
$PG_USER      = "matchmatrix"
$PG_DB        = "matchmatrix"
$PG_PASSWORD  = "matchmatrix"

$inserted = 0

foreach ($item in $response.response) {
  $fixtureId = $item.fixture.id

  foreach ($bm in $item.bookmakers) {
    $bmId = $bm.id

    foreach ($bet in $bm.bets) {
      $market = ($bet.name -replace "'","''")

      foreach ($val in $bet.values) {
        $outcome = ($val.value -replace "'","''")
        $oddStr  = "" + $val.odd
        $oddSql  = if ($oddStr -and $oddStr -ne "") { "NULLIF('$oddStr','')::numeric" } else { "null" }

        $json = ($item | ConvertTo-Json -Depth 20).Replace("'", "''")

        $sql = @"
insert into staging.api_football_odds
(run_id, league_id, season, fixture_id, bookmaker_id, market, outcome, odd_value, raw)
values
($RunId, $LeagueId, $Season,
 $fixtureId,
 $bmId,
 '$market',
 '$outcome',
 $oddSql,
 '$json'::jsonb
)
on conflict (run_id, league_id, season, fixture_id, bookmaker_id, market, outcome) do update
set odd_value = excluded.odd_value,
    raw = excluded.raw,
    fetched_at = now();
"@

        $cmd = "export PGPASSWORD='$PG_PASSWORD'; psql -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1"
        $sql | docker exec -i $PG_CONTAINER bash -lc $cmd | Out-Null
        $inserted++
      }
    }
  }
}

Write-Host ("Odds rows inserted/updated into staging: {0}" -f $inserted)