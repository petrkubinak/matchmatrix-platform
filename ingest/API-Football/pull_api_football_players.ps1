param(
  [Parameter(Mandatory=$true)][long]$RunId,
  [Parameter(Mandatory=$true)][int]$LeagueId,
  [Parameter(Mandatory=$true)][int]$Season
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

Write-Host "Pulling PLAYERS... league=$LeagueId season=$Season run_id=$RunId"

$page = 1
$inserted = 0

while ($true) {
  $uri = "https://v3.football.api-sports.io/players?league=$LeagueId&season=$Season&page=$page"
  Write-Host "URL: $uri"

  try {
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET -ErrorAction Stop
  }
  catch {
    Write-Host "API error for league=$LeagueId season=$Season page=$page"
    Write-Host $_.Exception.Message
    throw
  }

  if ($response.errors -and ($response.errors | ConvertTo-Json -Compress) -ne "{}") {
    Write-Host ("API errors: {0}" -f ($response.errors | ConvertTo-Json -Depth 10)) -ForegroundColor Red
  }

  if (-not $response.response -or $response.response.Count -eq 0) {
    if ($page -eq 1) {
      Write-Host "No players returned."
    } else {
      Write-Host "No more players returned."
    }
    break
  }

  foreach ($item in $response.response) {
    $player = $item.player
    if ($null -eq $player -or $null -eq $player.id) { continue }

    $json = ($item | ConvertTo-Json -Depth 20).Replace("'", "''")

    $playerId    = $player.id
    $playerName  = (($player.name) -replace "'","''")
    $firstName   = (($player.firstname) -replace "'","''")
    $lastName    = (($player.lastname) -replace "'","''")
    $birthDate   = $player.birth.date
    $nationality = (($player.nationality) -replace "'","''")
    $photo       = (($player.photo) -replace "'","''")

    $sql = @"
insert into staging.players_import
(
    provider_code,
    provider_player_id,
    player_name,
    first_name,
    last_name,
    birth_date,
    nationality,
    photo_url,
    raw,
    run_id,
    provider_league_id,
    season
    source_endpoint
)
values
(
    'api_football',
    '$playerId',
    $(if($playerName){ "'$playerName'" } else { "null" }),
    $(if($firstName){ "'$firstName'" } else { "null" }),
    $(if($lastName){ "'$lastName'" } else { "null" }),
    $(if($birthDate){ "'$birthDate'" } else { "null" }),
    $(if($nationality){ "'$nationality'" } else { "null" }),
    $(if($photo){ "'$photo'" } else { "null" }),
    '$json'::jsonb,
    $RunId,
    '$LeagueId',
    '$Season',
    '/players'
    )

on conflict (provider_code, provider_player_id) do update
set player_name = excluded.player_name,
    first_name = excluded.first_name,
    last_name = excluded.last_name,
    birth_date = excluded.birth_date,
    nationality = excluded.nationality,
    photo_url = excluded.photo_url,
    raw = excluded.raw,
    fetched_at = now();
"@

    $cmd = "export PGPASSWORD='$PG_PASSWORD'; psql -U $PG_USER -d $PG_DB -v ON_ERROR_STOP=1"
    $sql | docker exec -i $PG_CONTAINER bash -lc $cmd | Out-Null
    $inserted++
  }

  Write-Host "Page $page done"
  $page++

  Start-Sleep -Seconds 1
}

Write-Host ("Players inserted/updated into staging: {0}" -f $inserted)