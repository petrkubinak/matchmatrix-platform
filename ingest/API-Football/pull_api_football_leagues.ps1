param(
  [Parameter(Mandatory=$true)][long]$RunId
)

$ErrorActionPreference = "Stop"

$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) { throw ".env not found" }

$envContent = Get-Content $envFile
foreach ($line in $envContent) {
  if ($line -match "=") {
    $parts = $line.Split("=",2)
    [Environment]::SetEnvironmentVariable($parts[0], $parts[1])
  }
}

$API_KEY = $env:APISPORTS_KEY
if (-not $API_KEY) { throw "Missing APISPORTS_KEY in .env" }

$baseUrl = "https://v3.football.api-sports.io/leagues"

Write-Host "Pulling leagues from API-Football..."

$response = Invoke-RestMethod -Uri $baseUrl -Headers @{ "x-apisports-key" = $API_KEY }

if (-not $response.response) {
  throw "No leagues returned from API"
}

$PG_CONTAINER = "matchmatrix_postgres"
$PG_USER = "matchmatrix"
$PG_DB = "matchmatrix"
$PG_PASSWORD = "matchmatrix"

foreach ($item in $response.response) {

  $league = $item.league
  $country = $item.country

  $json = ($item | ConvertTo-Json -Depth 10).Replace("'", "''")

  $sql = @"
insert into staging.api_football_leagues
(run_id, league_id, season, name, type, country, country_code, is_cup, is_international, logo, raw)
values
($RunId,
 $($league.id),
 null,
 '$($league.name.Replace("'","''"))',
 '$($league.type)',
 '$($country.name)',
 '$($country.code)',
 false,
 false,
 '$($league.logo)',
 '$json'::jsonb)
on conflict (run_id, league_id) do update
set name = excluded.name,
    country = excluded.country,
    country_code = excluded.country_code,
    raw = excluded.raw;
"@

  $cmd = "export PGPASSWORD='$PG_PASSWORD'; psql -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1"
  $sql | docker exec -i $PG_CONTAINER bash -lc $cmd | Out-Null
}

Write-Host "Leagues inserted into staging."