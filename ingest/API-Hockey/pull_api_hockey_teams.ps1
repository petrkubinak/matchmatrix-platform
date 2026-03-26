param(
  [Parameter(Mandatory=$true)][string]$RunId,
  [Parameter(Mandatory=$false)][int]$Season,
  [Parameter(Mandatory=$false)][int]$LeagueId
)

$ErrorActionPreference = "Stop"

# ==========================================================
# MATCHMATRIX
# API-HOCKEY TEAMS RAW PULL
#
# Kam uložit:
# C:\MatchMatrix-platform\ingest\API-Hockey\pull_api_hockey_teams.ps1
#
# Co dělá:
# - stáhne RAW teams payload z API-Hockey
# - uloží payload do:
#     1) staging.api_hockey_teams_raw   (legacy větev)
#     2) staging.stg_api_payloads       (nový unified flow pro parser)
# - pokud přijde LeagueId ze scheduleru, jede jen tuto ligu
# - jinak načte ligy z public.league_provider_map
#
# DŮLEŽITÉ:
# - season nikdy nesmí být 0
# - pokud season není zadán, použije se fallback 2024
# ==========================================================

# ----------------------------------------------------------
# načti .env
# ----------------------------------------------------------
$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) {
  throw ".env not found at $envFile"
}

foreach ($line in Get-Content $envFile) {
  if ($line -match "^\s*([^#][^=]+?)\s*=\s*(.*)\s*$") {
    $name  = $matches[1].Trim()
    $value = $matches[2].Trim()
    [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
  }
}

# ----------------------------------------------------------
# API config
# ----------------------------------------------------------
$base = $env:APISPORTS_HOCKEY_BASE
if ([string]::IsNullOrWhiteSpace($base)) {
  $base = "https://v1.hockey.api-sports.io"
}

$key = $env:APISPORTS_KEY
if ([string]::IsNullOrWhiteSpace($key)) {
  throw "APISPORTS_KEY missing"
}

$headers = @{
  "x-apisports-key" = $key
}

# ----------------------------------------------------------
# SAFE SEASON
# ----------------------------------------------------------
if (-not $PSBoundParameters.ContainsKey('Season') -or $null -eq $Season -or $Season -eq 0) {
  Write-Host "Season not set or 0 -> using fallback 2024"
  $Season = 2024
}

# ----------------------------------------------------------
# Postgres container
# ----------------------------------------------------------
$pgContainer = "matchmatrix_postgres"

function Exec-Psql {
  param(
    [Parameter(Mandatory=$true)][string]$Sql
  )

  $Sql | docker exec -i $pgContainer psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -At
}

# ----------------------------------------------------------
# league list
# ----------------------------------------------------------
$leagues = @()

if ($PSBoundParameters.ContainsKey('LeagueId') -and $null -ne $LeagueId -and $LeagueId -ne 0) {
  Write-Host "LeagueId provided by scheduler -> using single target league=$LeagueId"
  $leagues = @("$LeagueId")
}
else {
  $leaguesText = Exec-Psql @"
select provider_league_id
from (
    select distinct provider_league_id
    from public.league_provider_map
    where provider = 'api_hockey'
      and provider_league_id is not null
      and btrim(provider_league_id) <> ''
) q
order by provider_league_id::int;
"@

  if ([string]::IsNullOrWhiteSpace($leaguesText)) {
    Write-Host "No leagues found for provider=api_hockey in public.league_provider_map"
    $leagues = @()
  }
  else {
    $leagues = $leaguesText -split "`n"
  }
}

# ----------------------------------------------------------
# main loop
# ----------------------------------------------------------
foreach ($league in $leagues) {
  $league = "$league".Trim()

  if ([string]::IsNullOrWhiteSpace($league)) {
    continue
  }

  $url = "$base/teams?league=$league&season=$Season"
  Write-Host "Pulling HOCKEY TEAMS RAW... $url run_id=$RunId"

  try {
    $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
  }
  catch {
    Write-Host "ERROR API CALL league=$league season=$Season : $($_.Exception.Message)"
    continue
  }

  if ($null -eq $resp) {
    Write-Host "WARNING: Empty API response for league=$league season=$Season"
    continue
  }

  $results = $null
  if ($resp.PSObject.Properties.Name -contains "results") {
    $results = $resp.results
  }

  Write-Host "API response OK | league=$league | season=$Season | results=$results"

  # JSON do jedné řádky + escapování apostrofů pro SQL
  $json = ($resp | ConvertTo-Json -Depth 100 -Compress).Replace("'", "''")

  # external_id musí sedět na parser:
  # league_season -> např. 224_2024
  $externalId = "$league" + "_" + "$Season"

  # --------------------------------------------------------
  # 1) legacy raw insert
  # --------------------------------------------------------
  $legacySql = @"
insert into staging.api_hockey_teams_raw
(
  run_id,
  fetched_at,
  payload
)
values
(
  $RunId,
  now(),
  '$json'::jsonb
);
"@

  try {
    Exec-Psql -Sql $legacySql | Out-Null
    Write-Host "LEGACY RAW saved | league=$league | season=$Season"
  }
  catch {
    Write-Host "ERROR LEGACY RAW INSERT league=$league season=$Season : $($_.Exception.Message)"
    continue
  }

  # --------------------------------------------------------
  # 2) unified raw insert pro STEP 1C parser
  # --------------------------------------------------------
  $unifiedSql = @"
insert into staging.stg_api_payloads
(
  provider,
  sport_code,
  entity_type,
  endpoint_name,
  external_id,
  season,
  fetched_at,
  payload_json,
  parse_status,
  created_at
)
values
(
  'api_hockey',
  'hockey',
  'teams',
  'teams',
  '$externalId',
  '$Season',
  now(),
  '$json'::jsonb,
  'pending',
  now()
);
"@

  try {
    Exec-Psql -Sql $unifiedSql | Out-Null
    Write-Host "UNIFIED RAW saved | external_id=$externalId | parse_status=pending"
  }
  catch {
    Write-Host "ERROR UNIFIED RAW INSERT league=$league season=$Season : $($_.Exception.Message)"
    continue
  }
}

Write-Host "DONE"