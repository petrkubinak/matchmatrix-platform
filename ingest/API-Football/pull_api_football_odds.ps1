param(
  [Parameter(Mandatory=$true)][long]$RunId,
  [Parameter(Mandatory=$true)][int]$LeagueId,
  [Parameter(Mandatory=$true)][int]$Season,
  [Parameter(Mandatory=$true)][string]$From,
  [Parameter(Mandatory=$true)][string]$To
)

$ErrorActionPreference = "Stop"

# Load .env stejně jako teams/fixtures
$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) { throw ".env not found" }

foreach ($line in Get-Content $envFile) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  if ($line.Trim().StartsWith("#")) { continue }
  if ($line -match "=") {
    $parts = $line.Split("=", 2)
    $name  = $parts[0].Trim()
    $value = $parts[1].Trim()
    [Environment]::SetEnvironmentVariable($name, $value)
  }
}

$API_KEY = $env:APISPORTS_KEY
if (-not $API_KEY) { throw "Missing APISPORTS_KEY in .env" }

$headers = @{
  "x-apisports-key" = $API_KEY
}

$PG_CONTAINER = "matchmatrix_postgres"
$PG_USER      = "matchmatrix"
$PG_DB        = "matchmatrix"
$PG_PASSWORD  = "matchmatrix"

$uri = "https://v3.football.api-sports.io/odds?league=$LeagueId&season=$Season&from=$From&to=$To"
Write-Host "Pulling ODDS... league=$LeagueId season=$Season from=$From to=$To run_id=$RunId"

try {
  $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET -ErrorAction Stop
}
catch {
  Write-Host "API error for odds league=$LeagueId season=$Season"
  Write-Host $_.Exception.Message
  throw
}

Write-Host ("Odds API results={0}" -f $response.results)

if ($response.errors -and ($response.errors | ConvertTo-Json -Compress) -ne "{}") {
  Write-Host ("API errors: {0}" -f ($response.errors | ConvertTo-Json -Depth 10)) -ForegroundColor Red
}

if (-not $response.response) {
  Write-Host "No odds returned."
  exit 0
}

$inserted = 0

foreach ($item in $response.response) {
  $fixtureId = $item.fixture.id
  if ($null -eq $fixtureId) { continue }

  foreach ($bm in $item.bookmakers) {
    $bmId = $bm.id
    if ($null -eq $bmId) { continue }

    foreach ($bet in $bm.bets) {
      $market = (($bet.name) -replace "'","''")

      foreach ($val in $bet.values) {
        $outcome = (($val.value) -replace "'","''")
        $oddStr  = "" + $val.odd
        $oddSql  = if ($oddStr -and $oddStr -ne "") { "NULLIF('$oddStr','')::numeric" } else { "null" }

        $json = ($item | ConvertTo-Json -Depth 20).Replace("'", "''")

        $sql = @"
insert into staging.api_football_odds
(
    run_id,
    league_id,
    season,
    fixture_id,
    bookmaker_id,
    market,
    outcome,
    odd_value,
    raw
)
values
(
    $RunId,
    $LeagueId,
    $Season,
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