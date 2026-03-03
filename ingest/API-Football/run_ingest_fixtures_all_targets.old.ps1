# run_ingest_fixtures_all_targets.ps1
# CREATE RUN -> loop ingest_targets -> pull fixtures per league -> merge -> FINISH RUN
# DB v Dockeru: matchmatrix_postgres

param(
  [string]$RunGroup = ""
)

# Auto režim: když není RunGroup zadaný, vybereme A/B podle parity dne v roce
if ([string]::IsNullOrWhiteSpace($RunGroup)) {
    $isEven = ((Get-Date).DayOfYear % 2) -eq 0
    $major = if ($isEven) { "EU_major_v4_A" } else { "EU_major_v4_B" }
    $RunGroup = "EU_top,EU_exact_v1,$major"
    Write-Host "Auto RunGroup: $RunGroup"
}

$ErrorActionPreference = "Stop"

# ---- CONFIG ----
$container = "matchmatrix_postgres"
$dbUser    = "matchmatrix"
$dbName    = "matchmatrix"

# Free plan API-Football: dle hlášky 2022–2024, držíme 2024 jako fallback
$defaultSeason = 2024

# SQL merge soubor v containeru (kopie do /tmp)
$mergeSqlInContainer = "/tmp/034_upsert_matches_api_football.sql"

function ExecPsql([string]$sql) {
    return ($sql | docker exec -i $container psql -U $dbUser -d $dbName -t -A -q)
}

function FinishRun([string]$runId, [string]$status, [string]$msg, [string]$detailsJson) {
    $safeMsg = $msg.Replace("'", "''")
    $safeDetails = $detailsJson.Replace("'", "''")
    $sql = @"
UPDATE ops.job_runs
SET finished_at = NOW(),
    status = '$status',
    message = '$safeMsg',
    details = COALESCE(details, '{}'::jsonb) || '$safeDetails'::jsonb
WHERE id = $runId;
"@
    ExecPsql $sql | Out-Null
}

Write-Host "=== CLEANUP stale running runs (older than 6h) ==="

ExecPsql @"
UPDATE ops.job_runs
SET finished_at = NOW(),
    status = 'failed',
    message = COALESCE(message,'') || ' | auto-failed (stale running > 6h)'
WHERE job_code = 'ingest_fixtures'
  AND status = 'running'
  AND started_at < NOW() - INTERVAL '6 hours';
"@ | Out-Null

Write-Host "=== LOCK CHECK (no parallel runs) ==="

$runningCount = ExecPsql @"
SELECT COUNT(*)
FROM ops.job_runs
WHERE job_code = 'ingest_fixtures'
  AND status = 'running';
"@

$runningCount = ($runningCount | Select-Object -First 1).Trim()

if ([int]$runningCount -gt 0) {
    Write-Host "Another ingest_fixtures run is already running. Exiting."
    exit 0
}

Write-Host "=== CREATE RUN ==="
$runId = ExecPsql @"
INSERT INTO ops.job_runs (job_code, started_at, status, params, created_at)
VALUES ('ingest_fixtures', NOW(), 'running', '{}'::jsonb, NOW())
RETURNING id;
"@
$runId = ($runId | Select-Object -First 1).Trim()
if ([string]::IsNullOrWhiteSpace($runId)) { throw "Nepodařilo se získat run_id z DB." }
Write-Host "Run ID: $runId"

try {
  Write-Host "=== LOAD TARGETS (enabled) ==="

# podporuje 1 group nebo více: "EU_top,EU_exact_v1,EU_major_v4_A"
$rgList = @()
if (-not [string]::IsNullOrWhiteSpace($RunGroup)) {
    $rgList = $RunGroup.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
}

if ($rgList.Count -gt 0) {
    $rgSql = ($rgList | ForEach-Object { "'" + $_.Replace("'", "''") + "'" }) -join ","
    Write-Host "RunGroup filter: $($rgList -join ', ')"

    $targetsRaw = ExecPsql @"
SELECT
  id::text || '|' ||
  provider_league_id::text || '|' ||
  COALESCE(season::text, '$defaultSeason') || '|' ||
  COALESCE(fixtures_days_back, 2)::text || '|' ||
  COALESCE(fixtures_days_forward, 7)::text
FROM ops.ingest_targets
WHERE enabled = true
  AND run_group IN ($rgSql)
ORDER BY id;
"@
} else {
    $targetsRaw = ExecPsql @"
SELECT
  id::text || '|' ||
  provider_league_id::text || '|' ||
  COALESCE(season::text, '$defaultSeason') || '|' ||
  COALESCE(fixtures_days_back, 2)::text || '|' ||
  COALESCE(fixtures_days_forward, 7)::text
FROM ops.ingest_targets
WHERE enabled = true
ORDER BY id;
"@
}

    $targets = $targetsRaw -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

    if ($targets.Count -eq 0) {
        throw "Žádné enabled targets v ops.ingest_targets."
    }

    Write-Host ("Targets: " + $targets.Count)

    $ok = 0
    $fail = 0
    $errors = @()

    Write-Host "=== INGEST LOOP ==="
    foreach ($line in $targets) {
        $parts   = $line.Split('|')
        $targetId = [int]$parts[0]
        $leagueId = [int]$parts[1]
        $season   = [int]$parts[2]
        $back     = [int]$parts[3]
        $forward  = [int]$parts[4]

        # FREE plan guard: drž se 2022-2024
        if ($season -lt 2022 -or $season -gt 2024) { $season = $defaultSeason }

        # AUTOMATICKÉ OKNO
        $from = (Get-Date).AddDays(-$back).ToString('yyyy-MM-dd')
        $to   = (Get-Date).AddDays($forward).ToString('yyyy-MM-dd')

        Write-Host "-> target_id=$targetId league_id=$leagueId season=$season from=$from to=$to"

        # DŮLEŽITÉ: voláme pull script a předáme parametry, aby se NEPTAL
        powershell -ExecutionPolicy Bypass -File ".\pull_api_football_fixtures.ps1" `
            -RunId ([int64]$runId) -LeagueId $leagueId -Season $season -From $from -To $to

        if ($LASTEXITCODE -ne 0) {
            $fail++
            $errors += "target=$targetId league=$leagueId season=$season exit=$LASTEXITCODE"
            Write-Host "   FAIL (exit=$LASTEXITCODE)"
        } else {
            $ok++
        }
    }

    Write-Host "=== MERGE SQL ==="
    ExecPsql @"
\i $mergeSqlInContainer
"@ | Out-Null

    $details = @{
        targets_total = $targets.Count
        targets_ok    = $ok
        targets_fail  = $fail
        errors        = $errors
    } | ConvertTo-Json -Compress

    if ($fail -gt 0) {
        FinishRun $runId "partial" "Fixtures ingest done with some failures" $details
        exit 2
    } else {
        FinishRun $runId "success" "Fixtures ingest OK" $details
        Write-Host "=== DONE ==="
    }
}
catch {
    $msg = $_.Exception.Message
    $details = @{ error = $msg } | ConvertTo-Json -Compress
    FinishRun $runId "failed" ("FAILED: " + $msg) $details
    exit 1
}