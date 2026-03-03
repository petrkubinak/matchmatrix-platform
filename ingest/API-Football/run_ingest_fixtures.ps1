# run_ingest_fixtures.ps1
# MatchMatrix wrapper: CREATE RUN -> ingest fixtures -> merge -> FINISH RUN
# Pozn.: běží proti DB v Dockeru (matchmatrix_postgres)

$ErrorActionPreference = "Stop"

# ---- CONFIG ----
$container = "matchmatrix_postgres"
$dbUser    = "matchmatrix"
$dbName    = "matchmatrix"

# ingest_target pro pilot (u tebe 1 řádek)
$targetId = 1

# Free plan API-Football: držíme season v rozmezí 2022-2024
$season = 2024

# SQL merge soubor (už máš kopírovaný do /tmp)
$mergeSqlInContainer = "/tmp/034_upsert_matches_api_football.sql"

function ExecPsql([string]$sql) {
    # -t -A -q = jen data, bez hlášek/hlaviček
    return ($sql | docker exec -i $container psql -U $dbUser -d $dbName -t -A -q)
}

function FailRun([string]$runId, [string]$msg) {
    $safeMsg = $msg.Replace("'", "''")
    $sql = @"
UPDATE ops.job_runs
SET finished_at = NOW(),
    status = 'failed',
    message = '$safeMsg'
WHERE id = $runId;
"@
    ExecPsql $sql | Out-Null
}

Write-Host "=== SETUP: enforce season=$season for ingest_target id=$targetId ==="
ExecPsql @"
UPDATE ops.ingest_targets
SET season = $season,
    updated_at = NOW()
WHERE id = $targetId;
"@ | Out-Null

Write-Host "=== CREATE RUN ==="
$runId = ExecPsql @"
INSERT INTO ops.job_runs (job_code, started_at, status, params, created_at)
VALUES ('ingest_fixtures', NOW(), 'running', jsonb_build_object('target_id',$targetId,'season',$season), NOW())
RETURNING id;
"@

$runId = ($runId | Select-Object -First 1).Trim()

if ([string]::IsNullOrWhiteSpace($runId)) {
    throw "Nepodařilo se získat run_id z DB."
}

Write-Host "Run ID: $runId"

try {
    Write-Host "=== INGEST (pull_api_football_fixtures.ps1) ==="
    # předáme RunId, aby se script neptal
    powershell -ExecutionPolicy Bypass -File ".\pull_api_football_fixtures.ps1" -RunId ([int64]$runId)

    if ($LASTEXITCODE -ne 0) {
        throw "Ingest skript skončil s chybou (exit code $LASTEXITCODE)."
    }

    Write-Host "=== MERGE SQL ==="
    # spustíme merge SQL, které je v containeru
    ExecPsql @"
\i $mergeSqlInContainer
"@ | Out-Null

    Write-Host "=== FINISH RUN (success) ==="
    ExecPsql @"
UPDATE ops.job_runs
SET finished_at = NOW(),
    status = 'success',
    message = 'Ingest fixtures OK (season=$season, target_id=$targetId)'
WHERE id = $runId;
"@ | Out-Null

    Write-Host "=== DONE ==="
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)"
    FailRun $runId "FAILED: $($_.Exception.Message)"
    exit 1
}