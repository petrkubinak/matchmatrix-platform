# =========================================================
# MatchMatrix
# API-FOOTBALL PLAYER MATCH STATS WORKER V3
#
# Účel:
# - vezme ready joby z ops.ingest_planner
# - zavolá API endpoint /fixtures/players?fixture={fixture_id}
# - uloží RAW payload do staging.stg_api_payloads
#
# Poznámka:
# - používá docker exec do postgres kontejneru
# - DB a API nastavení bere z .env
# - toto je INGEST worker; parser do EAV uděláme v dalším kroku
# =========================================================

param(
    [string]$RunId = ""
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------
# Načtení .env
# ---------------------------------------------------------
$EnvFile = "C:\MatchMatrix-platform\.env"

if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*#') { return }
        if ($_ -match '^\s*$') { return }

        $parts = $_ -split '=', 2
        if ($parts.Count -eq 2) {
            $name = $parts[0].Trim()
            $value = $parts[1].Trim().Trim('"')
            [System.Environment]::SetEnvironmentVariable($name, $value)
        }
    }
}

# ---------------------------------------------------------
# Nastavení
# ---------------------------------------------------------
$BASE_URL = if ($env:APISPORTS_BASE) { $env:APISPORTS_BASE } else { "https://v3.football.api-sports.io" }
$API_KEY  = $env:APISPORTS_KEY

$PG_CONTAINER = if ($env:PG_CONTAINER) { $env:PG_CONTAINER } else { "matchmatrix_postgres" }
$PG_USER      = if ($env:PGUSER) { $env:PGUSER } else { "matchmatrix" }
$PG_DB        = if ($env:PGDATABASE) { $env:PGDATABASE } else { "matchmatrix" }

$JOB_LIMIT = 5

if (-not $API_KEY) {
    Write-Host "ERROR: Missing APISPORTS_KEY in environment."
    exit 1
}

$HEADERS = @{
    "x-apisports-key" = $API_KEY
    "Accept"          = "application/json"
    "User-Agent"      = "MatchMatrix/player-stats-v3"
}

# ---------------------------------------------------------
# Helper: escape string pro SQL literal
# ---------------------------------------------------------
function Escape-SqlLiteral {
    param([string]$Value)

    if ($null -eq $Value) {
        return "NULL"
    }

    return "'" + ($Value -replace "'", "''") + "'"
}

# ---------------------------------------------------------
# Helper: spusť SQL přes docker exec
# ---------------------------------------------------------
function Invoke-PgQueryRaw {
    param(
        [string]$Sql
    )

    $cmd = @(
        "exec", "-i", $PG_CONTAINER,
        "psql",
        "-U", $PG_USER,
        "-d", $PG_DB,
        "-At",
        "-c", $Sql
    )

    $output = & docker @cmd
    return $output
}

function Invoke-PgNonQuery {
    param(
        [string]$Sql
    )

    $cmd = @(
        "exec", "-i", $PG_CONTAINER,
        "psql",
        "-U", $PG_USER,
        "-d", $PG_DB,
        "-c", $Sql
    )

    & docker @cmd | Out-Host
}

# ---------------------------------------------------------
# 1) Najdi ready joby
# ---------------------------------------------------------
# Bereme fixture_id z planneru.
# Tady používám fixture_id, protože external_fixture_id v planneru pravděpodobně není.
$SQL_JOBS = @"
SELECT id, fixture_id
FROM ops.ingest_planner
WHERE provider = 'api_football'
  AND sport_code = 'FB'
  AND entity = 'player_stats'
  AND status IN ('pending', 'error')
  AND fixture_id IS NOT NULL
ORDER BY id
LIMIT $JOB_LIMIT;
"@

Write-Host "=== MATCHMATRIX: API-FOOTBALL PLAYER MATCH STATS WORKER V3 ==="
Write-Host "Container   : $PG_CONTAINER"
Write-Host "Database    : $PG_DB"
Write-Host "DB User     : $PG_USER"
Write-Host "Job limit   : $JOB_LIMIT"
Write-Host ""

$jobs = Invoke-PgQueryRaw -Sql $SQL_JOBS

if (-not $jobs) {
    Write-Host "No jobs found."
    exit 0
}

# ---------------------------------------------------------
# 2) Zpracování jobů
# ---------------------------------------------------------
foreach ($line in $jobs) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    $parts = $line.Split("|")
    if ($parts.Count -lt 2) {
        Write-Host "SKIP malformed line: $line"
        continue
    }

    $job_id = $parts[0].Trim()
    $fixture_id = $parts[1].Trim()

    Write-Host "Processing job_id=$job_id fixture_id=$fixture_id"

    $sqlRunning = @"
UPDATE ops.ingest_planner
SET status = 'running',
    updated_at = NOW()
WHERE id = $job_id;
"@
    Invoke-PgNonQuery -Sql $sqlRunning

    try {
        $url = "$BASE_URL/fixtures/players?fixture=$fixture_id"
        $response = Invoke-RestMethod -Uri $url -Headers $HEADERS -Method Get -TimeoutSec 60

        $payloadJson = $response | ConvertTo-Json -Depth 100 -Compress
        $payloadSql = Escape-SqlLiteral $payloadJson
        $requestUrlSql = Escape-SqlLiteral $url
        $requestParamsSql = Escape-SqlLiteral ('{"fixture":"' + $fixture_id + '"}')

        # smažeme starý RAW payload pro stejný fixture/source
        $sqlDelete = @"
DELETE FROM staging.stg_api_payloads
WHERE provider = 'api_football'
  AND sport_code = 'football'
  AND entity_type = 'player_stats'
  AND endpoint_name = 'fixtures/players'
  AND external_id = '$fixture_id';
"@
        Invoke-PgNonQuery -Sql $sqlDelete

        # uložíme RAW payload do obecné payload tabulky
        $sqlInsert = @"
INSERT INTO staging.stg_api_payloads (
    provider,
    sport_code,
    entity_type,
    endpoint_name,
    external_id,
    season,
    request_url,
    request_params,
    payload_json,
    created_at,
    updated_at
)
VALUES (
    'api_football',
    'football',
    'player_stats',
    'fixtures/players',
    '$fixture_id',
    NULL,
    $requestUrlSql,
    $requestParamsSql::jsonb,
    $payloadSql::jsonb,
    NOW(),
    NOW()
);
"@
        Invoke-PgNonQuery -Sql $sqlInsert

        $sqlDone = @"
UPDATE ops.ingest_planner
SET status = 'done',
    updated_at = NOW(),
    last_error = NULL
WHERE id = $job_id;
"@
        Invoke-PgNonQuery -Sql $sqlDone

        Write-Host "OK fixture_id=$fixture_id"
    }
    catch {
        $err = $_.Exception.Message
        $errEsc = Escape-SqlLiteral $err

        Write-Host "ERROR fixture_id=$fixture_id :: $err"

        $sqlError = @"
UPDATE ops.ingest_planner
SET status = 'error',
    updated_at = NOW(),
    last_error = $errEsc
WHERE id = $job_id;
"@
        Invoke-PgNonQuery -Sql $sqlError
    }

    Write-Host ""
}

Write-Host "Hotovo."