param(
    [Parameter(Mandatory = $true)][string]$RunId,
    [Parameter(Mandatory = $false)][string]$LeagueId,
    [Parameter(Mandatory = $false)][string]$Season,
    [Parameter(Mandatory = $false)][string]$From,
    [Parameter(Mandatory = $false)][string]$To,
    [Parameter(Mandatory = $false)][string]$SportCode = "hockey"
)

$ErrorActionPreference = "Stop"

# ==========================================================
# MATCHMATRIX
# API-HOCKEY FIXTURES / GAMES RAW PULL
#
# Kam uložit:
# C:\MatchMatrix-platform\ingest\API-Hockey\pull_api_hockey_fixtures.ps1
#
# Co dělá:
# - stáhne RAW fixtures/games payload z API-Hockey
# - uloží payload do staging.stg_api_payloads
#
# DŮLEŽITÉ:
# - pokud Season není zadána, použije fallback 2024
# - pro league běh používá URL:
#     /games?league=<LeagueId>&season=<Season>
# - external_id ukládá jako league_season
# ==========================================================

function Write-Log {
    param([string]$Message)
    Write-Host "[pull_api_hockey_fixtures] $Message"
}

# ----------------------------------------------------------
# .env loader
# ----------------------------------------------------------
function Import-DotEnvFile {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return
    }

    Write-Log "Načítám ENV z: $Path"

    foreach ($line in Get-Content $Path) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line.Trim().StartsWith("#")) { continue }

        if ($line -match "^\s*([^=]+?)\s*=\s*(.*)\s*$") {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()

            if (
                ($value.StartsWith('"') -and $value.EndsWith('"')) -or
                ($value.StartsWith("'") -and $value.EndsWith("'"))
            ) {
                $value = $value.Substring(1, $value.Length - 2)
            }

            [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

Import-DotEnvFile ".env"
Import-DotEnvFile "C:/MatchMatrix-platform/.env"
Import-DotEnvFile "C:/MatchMatrix-platform/ingest/.env"

# ----------------------------------------------------------
# API config
# ----------------------------------------------------------
$ApiBase = $env:APISPORTS_HOCKEY_BASE
if ([string]::IsNullOrWhiteSpace($ApiBase)) {
    $ApiBase = "https://v1.hockey.api-sports.io"
}

$ApiKey = $env:API_SPORTS_KEY
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:APISPORTS_KEY
}

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw "Chybí API klíč v ENV (API_SPORTS_KEY nebo APISPORTS_KEY)."
}

if ($env:API_SPORTS_KEY) {
    Write-Log "Použit API klíč z ENV: API_SPORTS_KEY"
}
elseif ($env:APISPORTS_KEY) {
    Write-Log "Použit API klíč z ENV: APISPORTS_KEY"
}

$Headers = @{
    "x-apisports-key" = $ApiKey
}

# ----------------------------------------------------------
# SAFE SEASON
# ----------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($Season) -or $Season -eq "0") {
    Write-Log "Season not set or 0 -> using fallback 2024"
    $Season = "2024"
}

# ----------------------------------------------------------
# Metadata
# ----------------------------------------------------------
$Provider = "api_hockey"
$EndpointName = "games"

if ([string]::IsNullOrWhiteSpace($LeagueId)) {
    throw "LeagueId je povinný pro hockey fixtures pull."
}

$ExternalId = "$LeagueId" + "_" + "$Season"

Write-Log "Sport      : $SportCode"
Write-Log "LeagueId   : $LeagueId"
Write-Log "Season     : $Season"
Write-Log "From       : $From"
Write-Log "To         : $To"
Write-Log "RunId      : $RunId"
Write-Log "Provider   : $Provider"
Write-Log "Endpoint   : $EndpointName"
Write-Log "ExternalId : $ExternalId"
Write-Log "API Base   : $ApiBase"

# ----------------------------------------------------------
# URL build
# ----------------------------------------------------------
if (-not [string]::IsNullOrWhiteSpace($From) -and -not [string]::IsNullOrWhiteSpace($To)) {
    $Url = "$ApiBase/games?league=$LeagueId&season=$Season&from=$From&to=$To"
}
elseif (-not [string]::IsNullOrWhiteSpace($From)) {
    $Url = "$ApiBase/games?league=$LeagueId&season=$Season&from=$From"
}
elseif (-not [string]::IsNullOrWhiteSpace($To)) {
    $Url = "$ApiBase/games?league=$LeagueId&season=$Season&to=$To"
}
else {
    $Url = "$ApiBase/games?league=$LeagueId&season=$Season"
}

Write-Log "URL        : $Url"

# ----------------------------------------------------------
# API call
# ----------------------------------------------------------
Write-Log "Volám API-Hockey fixtures endpoint..."

try {
    $Response = Invoke-RestMethod -Uri $Url -Headers $Headers -Method GET
}
catch {
    throw "API call failed: $($_.Exception.Message)"
}

$Results = 0
if ($null -ne $Response -and $Response.PSObject.Properties.Name -contains "results") {
    $Results = [int]$Response.results
}

Write-Log "API call OK. Results: $Results"

# ----------------------------------------------------------
# JSON + hash
# ----------------------------------------------------------
$PayloadJson = ($Response | ConvertTo-Json -Depth 100 -Compress)
$PayloadJsonSql = $PayloadJson.Replace("'", "''")

$Sha256 = [System.Security.Cryptography.SHA256]::Create()
$HashBytes = $Sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($PayloadJson))
$PayloadHash = ([System.BitConverter]::ToString($HashBytes)).Replace("-", "").ToLower()

Write-Log "Payload SHA256: $PayloadHash"

# ----------------------------------------------------------
# DB insert přes docker exec
# ----------------------------------------------------------
$PgContainer = "matchmatrix_postgres"

$Sql = @"
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
    '$Provider',
    '$SportCode',
    'fixtures',
    '$EndpointName',
    '$ExternalId',
    '$Season',
    now(),
    '$PayloadJsonSql'::jsonb,
    'pending',
    now()
);
"@

Write-Log "DB insert přes docker exec do kontejneru: $PgContainer"

$Sql | docker exec -i $PgContainer psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1

Write-Log "Payload uložen do staging.stg_api_payloads"
Write-Log "Hotovo."