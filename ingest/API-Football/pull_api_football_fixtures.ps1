param(
  [Parameter(Mandatory=$true)][long]$RunId,
  [Parameter(Mandatory=$true)][int]$LeagueId,
  [Parameter(Mandatory=$true)][int]$Season,
  [Parameter(Mandatory=$true)][string]$From,
  [Parameter(Mandatory=$true)][string]$To
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

function Invoke-ApiFootballGet {
  param(
    [Parameter(Mandatory=$true)][string]$Uri,
    [Parameter(Mandatory=$true)][string]$ApiKey,
    [int]$TimeoutSec = 40,
    [int]$MaxRetry = 3
  )

  for ($i = 1; $i -le $MaxRetry; $i++) {
    try {
      return Invoke-RestMethod -Method Get -Uri $Uri -Headers @{ "x-apisports-key" = $ApiKey } -TimeoutSec $TimeoutSec -ErrorAction Stop
    }
    catch {
      Write-Warning "API call failed (attempt $i/$MaxRetry) uri=$Uri :: $($_.Exception.Message)"
      if ($i -lt $MaxRetry) { Start-Sleep -Seconds (5 * $i) } else { throw }
    }
  }
}

$uri = "https://v3.football.api-sports.io/fixtures?league=$LeagueId&season=$Season&from=$From&to=$To"
Write-Host "Pulling FIXTURES... league=$LeagueId season=$Season from=$From to=$To run_id=$RunId"

$response = Invoke-ApiFootballGet -Uri $uri -ApiKey $API_KEY -TimeoutSec 40 -MaxRetry 3
if ($response.errors -and ($response.errors | ConvertTo-Json -Compress) -ne "{}") {
  Write-Host ("API errors: {0}" -f ($response.errors | ConvertTo-Json -Depth 10)) -ForegroundColor Red
}
if (-not $response.response) { Write-Host "No fixtures returned."; exit 0 }

$PG_CONTAINER = "matchmatrix_postgres"
$PG_USER      = "matchmatrix"
$PG_DB        = "matchmatrix"
$PG_PASSWORD  = "matchmatrix"

foreach ($item in $response.response) {
  $fixture = $item.fixture
  $teams   = $item.teams
  $goals   = $item.goals

  $json = ($item | ConvertTo-Json -Depth 15).Replace("'", "''")

  $kickoff = ($fixture.date -replace "'","''")
  $status  = (($fixture.status.short) -replace "'","''")

  $homeGoals = if ($null -ne $goals.home) { [int]$goals.home } else { "null" }
  $awayGoals = if ($null -ne $goals.away) { [int]$goals.away } else { "null" }

  $sql = @"
insert into staging.api_football_fixtures
(run_id, league_id, season, fixture_id, kickoff, status, home_team_id, away_team_id, home_goals, away_goals, raw)
values
($RunId, $LeagueId, $Season,
 $($fixture.id),
 '$kickoff'::timestamptz,
 '$status',
 $($teams.home.id),
 $($teams.away.id),
 $homeGoals,
 $awayGoals,
 '$json'::jsonb
)
on conflict (run_id, league_id, season, fixture_id) do update
set kickoff = excluded.kickoff,
    status = excluded.status,
    home_team_id = excluded.home_team_id,
    away_team_id = excluded.away_team_id,
    home_goals = excluded.home_goals,
    away_goals = excluded.away_goals,
    raw = excluded.raw,
    fetched_at = now();
"@

  $cmd = "export PGPASSWORD='$PG_PASSWORD'; psql -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1"
  $sql | docker exec -i $PG_CONTAINER bash -lc $cmd | Out-Null
}

Write-Host ("Fixtures inserted into staging: {0}" -f $response.response.Count)