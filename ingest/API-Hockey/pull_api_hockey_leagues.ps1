param(
  [Parameter(Mandatory=$true)][string]$RunId
)

$ErrorActionPreference = "Stop"

function Load-EnvFile($path) {
  if (-not (Test-Path $path)) { throw ".env not found at $path" }
  foreach ($line in Get-Content $path) {
    if ($line -match "^\s*([^#][^=]+?)\s*=\s*(.*)\s*$") {
      $name  = $matches[1].Trim()
      $value = $matches[2].Trim()
      [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
  }
}

$envFile = Join-Path $PSScriptRoot ".env"
Load-EnvFile $envFile

# Prefer dedicated hockey base, fallback to APISPORTS_BASE
$base = $env:APISPORTS_HOCKEY_BASE
if ([string]::IsNullOrWhiteSpace($base)) { $base = $env:APISPORTS_BASE }
$key  = $env:APISPORTS_KEY

if ([string]::IsNullOrWhiteSpace($base)) { throw "Missing base URL. Set APISPORTS_HOCKEY_BASE=https://v1.hockey.api-sports.io in API-Hockey/.env" }
if ([string]::IsNullOrWhiteSpace($key))  { throw "APISPORTS_KEY missing" }

$pgContainer = "matchmatrix_postgres"

# 1) ensure raw table exists
$sqlDDL = @'
CREATE SCHEMA IF NOT EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.api_hockey_leagues_raw (
  run_id     int8,
  fetched_at timestamptz NOT NULL DEFAULT now(),
  payload    jsonb       NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_api_hockey_leagues_raw_run_id
  ON staging.api_hockey_leagues_raw(run_id);

CREATE INDEX IF NOT EXISTS ix_api_hockey_leagues_raw_fetched_at
  ON staging.api_hockey_leagues_raw(fetched_at);
'@

$sqlDDL | docker exec -i $pgContainer psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 | Out-Null

# 2) call API
$uri = "$base/leagues"
Write-Host "Pulling HOCKEY LEAGUES RAW... $uri run_id=$RunId"
$resp = Invoke-RestMethod -Uri $uri -Headers @{ "x-apisports-key" = $key } -Method GET

# 3) store whole response as payload
$json = ($resp | ConvertTo-Json -Depth 80 -Compress)
$json = $json.Replace("'", "''")

$sqlInsert = "INSERT INTO staging.api_hockey_leagues_raw(run_id, payload) VALUES ($RunId, '$json'::jsonb);"

$sqlInsert | docker exec -i $pgContainer psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 | Out-Null

# 4) quick check
$sqlCheck = "SELECT COUNT(*) AS cnt, MIN(fetched_at) AS min_ts, MAX(fetched_at) AS max_ts FROM staging.api_hockey_leagues_raw WHERE run_id = $RunId;"
$checkOut = $sqlCheck | docker exec -i $pgContainer psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -At
Write-Host "OK: $checkOut"
