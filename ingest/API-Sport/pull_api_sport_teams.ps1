param(
    [Parameter(Mandatory = $true)][string]$RunId,
    [Parameter(Mandatory = $true)][string]$Provider,
    [Parameter(Mandatory = $true)][string]$SportCode,
    [Parameter(Mandatory = $true)][string]$LeagueId,
    [Parameter(Mandatory = $true)][string]$Season
)

$ErrorActionPreference = "Stop"

# =========================================================
# MATCHMATRIX - GENERIC API-SPORT TEAMS PULL
# File: C:\MatchMatrix-platform\ingest\API-Sport\pull_api_sport_teams.ps1
# Účel:
#   Společný teams pull pro sporty typu api_volleyball / api_handball / api_baseball ...
#   Ukládá RAW payload do staging.stg_api_payloads
# =========================================================

# --- cesty ---
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

# FIX: jistá cesta na ingest\.env
$EnvPath = "C:\MatchMatrix-platform\ingest\.env"

# --- načtení .env ---
if (Test-Path $EnvPath) {
    Get-Content $EnvPath | ForEach-Object {
        if ($_ -match '^\s*#') { return }
        if ($_ -match '^\s*$') { return }
        $parts = $_ -split '=', 2
        if ($parts.Count -eq 2) {
            $name  = $parts[0].Trim()
            $value = $parts[1].Trim().Trim('"')
            [System.Environment]::SetEnvironmentVariable($name, $value)
        }
    }
}

# --- DB config ---
$PgHost = $env:PGHOST
$PgPort = if ($env:PGPORT) { $env:PGPORT } else { "5432" }
$PgDb   = $env:PGDATABASE
$PgUser = $env:PGUSER
$PgPass = $env:PGPASSWORD

if (-not $PgHost -or -not $PgDb -or -not $PgUser -or -not $PgPass) {
    throw "Chybí PGHOST / PGPORT / PGDATABASE / PGUSER / PGPASSWORD v ingest\.env"
}

# --- API key ---
$ApiKey = $env:API_SPORTS_KEY
if (-not $ApiKey) {
    $ApiKey = $env:API_VOLLEYBALL_KEY
}
if (-not $ApiKey) {
    throw "Chybí API_SPORTS_KEY (nebo API_VOLLEYBALL_KEY) v ingest\.env"
}

# --- sport host mapping ---
# DŮLEŽITÉ:
# Host se musí skládat ze sportu, NE z provideru.
# Např.:
#   basketball -> v1.basketball.api-sports.io
#   volleyball -> v1.volleyball.api-sports.io
#   handball   -> v1.handball.api-sports.io
# Provider api_sport by jinak chybně vytvořil v1.sport.api-sports.io

$SportHost = $SportCode.Trim().ToLower()

switch ($SportHost) {
    "bk"         { $SportHost = "basketball" }
    "basketball" { $SportHost = "basketball" }

    "vb"         { $SportHost = "volleyball" }
    "volleyball" { $SportHost = "volleyball" }

    "hb"         { $SportHost = "handball" }
    "handball"   { $SportHost = "handball" }

    "bsb"        { $SportHost = "baseball" }
    "baseball"   { $SportHost = "baseball" }

    "ck"         { $SportHost = "cricket" }
    "cricket"    { $SportHost = "cricket" }

    "fh"           { $SportHost = "fieldhockey" }
    "field_hockey" { $SportHost = "fieldhockey" }
    "fieldhockey"  { $SportHost = "fieldhockey" }

    "rgb"       { $SportHost = "rugby" }
    "rugby"     { $SportHost = "rugby" }

    "afb"                { $SportHost = "american-football" }
    "american_football"  { $SportHost = "american-football" }
    "american-football"  { $SportHost = "american-football" }

    "esp"       { $SportHost = "esports" }
    "esports"   { $SportHost = "esports" }

    default {
        # fallback pro případy, kdy do runneru jde už plný sport název
        $SportHost = $SportHost.Replace("_", "-")
    }
}

$ApiBase = "https://v1.$SportHost.api-sports.io"

# --- endpoint ---
$Url = "$ApiBase/teams?league=$LeagueId&season=$Season"

Write-Host "Pulling API-SPORT TEAMS RAW... $Url run_id=$RunId"

# --- headers ---
$Headers = @{
    "x-apisports-key" = $ApiKey
}

# --- request ---
$Response = Invoke-RestMethod -Method Get -Uri $Url -Headers $Headers -TimeoutSec 120
$PayloadJson = $Response | ConvertTo-Json -Depth 20 -Compress

# --- row count ---
$ResultsCount = 0
if ($null -ne $Response.response) {
    try {
        $ResultsCount = @($Response.response).Count
    } catch {
        $ResultsCount = 0
    }
}

# --- temp sql file ---
$TempSql = Join-Path $env:TEMP ("mm_api_sport_teams_{0}.sql" -f $RunId)

# escapování JSON pro SQL
$PayloadSql = $PayloadJson -replace "'", "''"
$MessageSql = ("teams pull OK | league={0} | season={1} | results={2} | run_id={3}" -f $LeagueId, $Season, $ResultsCount, $RunId) -replace "'", "''"

$sql = @"
INSERT INTO staging.stg_api_payloads
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
    parse_message,
    created_at
)
VALUES
(
    '$Provider',
    '$SportCode',
    'teams',
    'teams',
    '${LeagueId}_${Season}',
    '$Season',
    NOW(),
    '$PayloadSql'::jsonb,
    'pending',
    '$MessageSql',
    NOW()
);
"@

Set-Content -Path $TempSql -Value $sql -Encoding UTF8

# --- DOCKER psql call ---
$dockerCmd = "docker exec -i matchmatrix_postgres psql -U $PgUser -d $PgDb -f - < `"$TempSql`""
cmd /c $dockerCmd

if ($LASTEXITCODE -ne 0) {
    throw "psql insert selhal."
}

Remove-Item $TempSql -ErrorAction SilentlyContinue

Write-Host "DONE | provider=$Provider | sport=$SportCode | entity=teams | league=$LeagueId | season=$Season | results=$ResultsCount"