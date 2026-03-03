# run_ingest_teams_all_targets.ps1
# Pull TEAMS for enabled targets (filtered by RunGroup) -> merge via /tmp/035_merge_teams_api_football.sql

param(
  [string]$RunGroup = ""
)

$ErrorActionPreference = "Stop"

# --- defaults (auto) ---
if ([string]::IsNullOrWhiteSpace($RunGroup)) {
    $isEven = ((Get-Date).DayOfYear % 2) -eq 0
    $major = if ($isEven) { "EU_major_v4_A" } else { "EU_major_v4_B" }

    # PŘESNÉ názvy run_group z ops.ingest_targets
    $RunGroup = "EU_top_A,EU_top_B,EU_exact_v1_0,EU_exact_v1_1,EU_exact_v1_2,EU_exact_v1_3,$major"
    Write-Host "Auto RunGroup: $RunGroup"
}

# --- paths ---
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$pullTeamsScript = Join-Path $scriptDir "pull_api_football_teams.ps1"
if (-not (Test-Path $pullTeamsScript)) {
    throw "pull_api_football_teams.ps1 not found at: $pullTeamsScript"
}

# --- docker / db ---
$container = "matchmatrix_postgres"
$dbUser    = "matchmatrix"
$dbName    = "matchmatrix"

# Merge script already copied to container:/tmp
$mergeSqlInContainer = "/tmp/035_merge_teams_api_football.sql"

function ExecPsql([string]$sql) {
    return ($sql | docker exec -i $container psql -U $dbUser -d $dbName -v ON_ERROR_STOP=1 -t -A -q)
}

function GetCurrentSeasonYear() {
    $now = Get-Date
    if ($now.Month -ge 7) { return $now.Year } else { return ($now.Year - 1) }
}

# API-Football free plan limit (as per your notes)
$maxSeasonAllowed = 2024
$defaultSeason = [Math]::Min((GetCurrentSeasonYear), $maxSeasonAllowed)

Write-Host "=== CLEANUP stale running runs (older than 6h) ==="
ExecPsql @"
UPDATE ops.job_runs
SET finished_at = NOW(),
    status = 'failed',
    message = COALESCE(message,'') || ' | auto-failed (stale running > 6h)'
WHERE job_code = 'ingest_teams'
  AND status = 'running'
  AND started_at < NOW() - INTERVAL '6 hours';
"@ | Out-Null

Write-Host "=== LOCK CHECK (no parallel runs) ==="
$runningCount = ExecPsql @"
SELECT COUNT(*)
FROM ops.job_runs
WHERE job_code = 'ingest_teams'
  AND status = 'running';
"@
$runningCount = ($runningCount | Select-Object -First 1).Trim()
if ([int]$runningCount -gt 0) {
    Write-Host "Another ingest_teams run is already running. Exiting."
    exit 0
}

Write-Host "=== CREATE RUN ==="
$runId = ExecPsql @"
INSERT INTO ops.job_runs (job_code, started_at, status, params, created_at)
VALUES ('ingest_teams', NOW(), 'running', '{}'::jsonb, NOW())
RETURNING id;
"@
$runId = ($runId | Select-Object -First 1).Trim()
if ([string]::IsNullOrWhiteSpace($runId)) { throw "Nepodařilo se získat run_id z DB." }
Write-Host "Run ID: $runId"

try {
    Write-Host "=== LOAD TARGETS (enabled) ==="
    $rgList = $RunGroup.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    if ($rgList.Count -eq 0) { throw "RunGroup is empty after parsing." }

    $rgSql = ($rgList | ForEach-Object { "'" + $_.Replace("'", "''") + "'" }) -join ","
    Write-Host "RunGroup filter: $($rgList -join ', ')"

    $targetsRaw = ExecPsql @"
SELECT
  id::text || '|' ||
  provider_league_id::text || '|' ||
  COALESCE(season::text, '$defaultSeason')
FROM ops.ingest_targets
WHERE enabled = true
  AND provider = 'api_football'
  AND run_group IN ($rgSql)
ORDER BY id;
"@

    $targets = $targetsRaw -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    if ($targets.Count -eq 0) { throw "Žádné enabled targets pro zadaný RunGroup." }

    Write-Host ("Targets: " + $targets.Count)

    $ok = 0
    $fail = 0
    $errors = New-Object System.Collections.Generic.List[string]

    Write-Host "=== INGEST LOOP (TEAMS) ==="
    foreach ($line in $targets) {
        $parts    = $line.Split('|')
        $targetId = [int]$parts[0]
        $leagueId = [int]$parts[1]
        $season   = [int]$parts[2]
        if ($season -gt $maxSeasonAllowed) { $season = $maxSeasonAllowed }

        Write-Host "-> target_id=$targetId league_id=$leagueId season=$season"

        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $pullTeamsScript `
            -RunId ([int64]$runId) -LeagueId $leagueId -Season $season

        if ($LASTEXITCODE -ne 0) {
            $fail++
            $errors.Add("target=$targetId league=$leagueId season=$season exit=$LASTEXITCODE")
            Write-Host "   FAIL (exit=$LASTEXITCODE)"
        } else {
            $ok++
        }
    }

    Write-Host "=== MERGE (single script) ==="
    ExecPsql "\i $mergeSqlInContainer" | Out-Null

    $details = @{
        targets_total = $targets.Count
        targets_ok    = $ok
        targets_fail  = $fail
        errors        = $errors
        merge_sql      = $mergeSqlInContainer
    } | ConvertTo-Json -Compress

    $safeDetails = $details.Replace("'", "''")

    ExecPsql @"
UPDATE ops.job_runs
SET finished_at = NOW(),
    status = 'success',
    message = 'Teams ingest finished',
    details = COALESCE(details, '{}'::jsonb) || '$safeDetails'::jsonb
WHERE id = $runId;
"@ | Out-Null

    Write-Host "=== DONE ==="
}
catch {
    $err = $_.Exception.Message
    Write-Host "ERROR: $err"
    $details = @{ error = $err } | ConvertTo-Json -Compress
    $safeDetails = $details.Replace("'", "''")

    ExecPsql @"
UPDATE ops.job_runs
SET finished_at = NOW(),
    status = 'failed',
    message = '$($err.Replace("'", "''"))',
    details = COALESCE(details, '{}'::jsonb) || '$safeDetails'::jsonb
WHERE id = $runId;
"@ | Out-Null
    exit 1
}