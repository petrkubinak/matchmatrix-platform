param(
  [Parameter(Mandatory=$true)][long]$RunId,
  [Parameter(Mandatory=$true)][int]$LeagueId,
  [Parameter(Mandatory=$true)][int]$Season
)

$ErrorActionPreference = "Stop"

# Load .env
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

$uri = "https://v3.football.api-sports.io/teams?league=$LeagueId&season=$Season"
Write-Host "Pulling TEAMS... league=$LeagueId season=$Season run_id=$RunId"

$response = Invoke-RestMethod -Uri $uri -Headers @{ "x-apisports-key" = $API_KEY }

if (-not $response.response) { Write-Host "No teams returned."; exit 0 }

$PG_CONTAINER = "matchmatrix_postgres"
$PG_USER      = "matchmatrix"
$PG_DB        = "matchmatrix"
$PG_PASSWORD  = "matchmatrix"

foreach ($item in $response.response) {
  $team  = $item.team
  $venue = $item.venue

  $json = ($item | ConvertTo-Json -Depth 15).Replace("'", "''")

  $name  = ($team.name    -replace "'","''")
  $code  = ($team.code    -replace "'","''")
  $ctry  = ($team.country -replace "'","''")
  $logo  = ($team.logo    -replace "'","''")
  $vname = (($venue.name) -replace "'","''")
  $vcity = (($venue.city) -replace "'","''")

  $national = if ($team.national -eq $true) { "true" } else { "false" }
  $founded  = if ($team.founded) { [int]$team.founded } else { "null" }

  $sql = @"
insert into staging.api_football_teams
(run_id, league_id, season, team_id, name, code, country, founded, "national", logo, venue_name, venue_city, raw)
values
($RunId, $LeagueId, $Season,
 $($team.id),
 '$name',
 $(if($code){ "'$code'" } else { "null" }),
 $(if($ctry){ "'$ctry'" } else { "null" }),
 $founded,
 $national,
 $(if($logo){ "'$logo'" } else { "null" }),
 $(if($vname){ "'$vname'" } else { "null" }),
 $(if($vcity){ "'$vcity'" } else { "null" }),
 '$json'::jsonb
)
on conflict (run_id, league_id, season, team_id) do update
set name = excluded.name,
    code = excluded.code,
    country = excluded.country,
    founded = excluded.founded,
    "national" = excluded."national",
    logo = excluded.logo,
    venue_name = excluded.venue_name,
    venue_city = excluded.venue_city,
    raw = excluded.raw,
    fetched_at = now();
"@

  $cmd = "export PGPASSWORD='$PG_PASSWORD'; psql -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1"
  $sql | docker exec -i $PG_CONTAINER bash -lc $cmd | Out-Null
}

Write-Host ("Teams inserted into staging: {0}" -f $response.response.Count)