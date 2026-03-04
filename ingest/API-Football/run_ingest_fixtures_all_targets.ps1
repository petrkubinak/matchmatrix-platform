# run_ingest_fixtures_all_targets.ps1
# CREATE RUN -> loop ingest_targets -> pull fixtures per league -> merge -> FINISH RUN
# DB v Dockeru: matchmatrix_postgres

param(
  [string]$RunGroup = ""
)

# Auto režim: když není RunGroup zadaný, jedeme jen EU_top + EU_exact_v1
if ([string]::IsNullOrWhiteSpace($RunGroup)) {
    $RunGroup = "EU_top,EU_exact_v1"
    Write-Host "Auto RunGroup: $RunGroup"
}

$ErrorActionPreference = "Stop"

# --- paths (important for Task Scheduler) ---
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$pullFixturesScript = Join-Path $scriptDir "pull_api_football_fixtures.ps1"
if (-not (Test-Path $pullFixturesScript)) {
    throw "pull_api_football_fixtures.ps1 not found at: $pullFixturesScript (Task Scheduler often runs with a different working directory)."
}

function GetCurrentSeasonYear() {
    $now = Get-Date
    # fotbalová sezóna (Evropa) typicky startuje v létě; Feb 2026 => season 2025
    if ($now.Month -ge 7) { return $now.Year } else { return ($now.Year - 1) }
}

function GetSeasonBounds([int]$season) {
    # API-Football season je startovací rok (např. 2024 = sezóna 2024/25)
    $start = Get-Date -Date ("$season-07-01")
    $end   = Get-Date -Date ((($season + 1).ToString()) + "-06-30")
    return @($start, $end)
}

# ---- CONFIG ----
$container = "matchmatrix_postgres"
$dbUser    = "matchmatrix"
$dbName    = "matchmatrix"

# --- PLAN LIMIT (API-Football FREE) ---
# Free plan dle hlášky API povoluje jen sezóny 2022-2024. Jakmile budeš mít paid, stačí zvednout.
$maxSeasonAllowed = 2024

# Default season: odvozeno od aktuálního data, ale oříznuto na max povolenou sezónu (free plan)
$defaultSeason = [Math]::Min((GetCurrentSeasonYear), $maxSeasonAllowed)

# Pro seed databáze na free plánu je nejlepší stáhnout celou povolenou sezónu (1 request / liga)
$useFullSeasonWindow = $true

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

# Var 2: RunGroup je vždy naplněný (buď parametrem, nebo auto režimem nahoře)
$rgList = $RunGroup.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
if ($rgList.Count -eq 0) { throw "RunGroup is empty after parsing. This should not happen." }

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

        # FREE plan: sezóny nad $maxSeasonAllowed nejsou dostupné
        if ($season -gt $maxSeasonAllowed) { $season = $maxSeasonAllowed }

        if ($useFullSeasonWindow) {
            $bounds = GetSeasonBounds $season
            $from = ($bounds[0]).ToString('yyyy-MM-dd')
            $to   = ($bounds[1]).ToString('yyyy-MM-dd')
        } else {
            # Rolling okno, ale vždy oříznuté do hranic sezóny
            $bounds = GetSeasonBounds $season
            $fromDt = (Get-Date).AddDays(-$back)
            $toDt   = (Get-Date).AddDays($forward)
            if ($fromDt -lt $bounds[0]) { $fromDt = $bounds[0] }
            if ($toDt   -gt $bounds[1]) { $toDt   = $bounds[1] }
            $from = $fromDt.ToString('yyyy-MM-dd')
            $to   = $toDt.ToString('yyyy-MM-dd')
        }

        Write-Host "-> target_id=$targetId league_id=$leagueId season=$season from=$from to=$to"

        # DŮLEŽITÉ: voláme pull script a předáme parametry, aby se NEPTAL
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File $pullFixturesScript `
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