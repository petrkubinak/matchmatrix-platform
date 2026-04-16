# =====================================================================
# MatchMatrix
# FILE: run_fb_players_wave1_pro.ps1
# PATH: C:\MatchMatrix-platform\workers\run_fb_players_wave1_pro.ps1
#
# Cíl:
# Spustit WAVE 1 pro FB players po přechodu na PRO účet.
#
# WAVE 1 targety:
# - 39  Premier League      | season 2022 | planner_id 1698
# - 78  Bundesliga          | season 2022 | planner_id 1702
# - 140 La Liga             | season 2022 | planner_id 1694
# - 79  2. Bundesliga       | season 2022 | planner_id 1646
# - 62  Ligue 2             | season 2022 | planner_id 1634
# - 89  Eerste Divisie      | season 2022 | planner_id 1662
#
# Co dělá:
# 1) spustí single fetch pro každý target
# 2) po každém fetchi spustí transitional players pipeline
# 3) zapisuje průběh do logu
#
# Spuštění ve VS terminálu:
# powershell -ExecutionPolicy Bypass -File C:\MatchMatrix-platform\workers\run_fb_players_wave1_pro.ps1
# =====================================================================

$ErrorActionPreference = "Stop"

# -----------------------------------------------------
# KONFIG
# -----------------------------------------------------
$PROJECT_ROOT = "C:\MatchMatrix-platform"
$PYTHON_EXE   = "C:\Python314\python.exe"

$FETCH_SCRIPT    = "C:\MatchMatrix-platform\ingest\API-Football\pull_api_football_players_v5.py"
$PIPELINE_SCRIPT = "C:\MatchMatrix-platform\workers\run_players_pipeline_transitional_v1.py"

# Log složka
$LOG_DIR = "C:\MatchMatrix-platform\logs"
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
}

$RUN_TS = Get-Date -Format "yyyyMMdd_HHmmss"
$LOG_FILE = Join-Path $LOG_DIR ("fb_players_wave1_pro_" + $RUN_TS + ".log")

# -----------------------------------------------------
# WAVE 1 TARGETY
# -----------------------------------------------------
$TARGETS = @(
    @{ LeagueId = "39";  Season = "2022"; RunId = "1698"; JobId = "1698"; LeagueName = "Premier League"  },
    @{ LeagueId = "78";  Season = "2022"; RunId = "1702"; JobId = "1702"; LeagueName = "Bundesliga"      },
    @{ LeagueId = "140"; Season = "2022"; RunId = "1694"; JobId = "1694"; LeagueName = "La Liga"         },
    @{ LeagueId = "79";  Season = "2022"; RunId = "1646"; JobId = "1646"; LeagueName = "2. Bundesliga"   },
    @{ LeagueId = "62";  Season = "2022"; RunId = "1634"; JobId = "1634"; LeagueName = "Ligue 2"         },
    @{ LeagueId = "89";  Season = "2022"; RunId = "1662"; JobId = "1662"; LeagueName = "Eerste Divisie"  }
)

# -----------------------------------------------------
# HELPER - LOG
# -----------------------------------------------------
function Write-Log {
    param([string]$Message)

    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"

    Write-Host $line
    Add-Content -Path $LOG_FILE -Value $line
}

# -----------------------------------------------------
# HELPER - RUN CMD
# -----------------------------------------------------
function Run-Step {
    param(
        [string]$Title,
        [string]$FilePath,
        [string[]]$Arguments
    )

    Write-Log "=============================================================="
    Write-Log $Title
    Write-Log "CMD: $FilePath $($Arguments -join ' ')"
    Write-Log "=============================================================="

    & $FilePath @Arguments 2>&1 | Tee-Object -FilePath $LOG_FILE -Append

    if ($LASTEXITCODE -ne 0) {
        throw "Krok selhal. Title='$Title', ExitCode=$LASTEXITCODE"
    }

    Write-Log "HOTOVO OK: $Title"
}

# -----------------------------------------------------
# START
# -----------------------------------------------------
Write-Log "MATCHMATRIX FB PLAYERS WAVE 1 PRO - START"
Write-Log "PROJECT_ROOT   : $PROJECT_ROOT"
Write-Log "PYTHON_EXE     : $PYTHON_EXE"
Write-Log "FETCH_SCRIPT   : $FETCH_SCRIPT"
Write-Log "PIPELINE_SCRIPT: $PIPELINE_SCRIPT"
Write-Log "LOG_FILE       : $LOG_FILE"
Write-Log ""

$index = 0
$total = $TARGETS.Count

foreach ($t in $TARGETS) {
    $index++

    $leagueId   = $t.LeagueId
    $season     = $t.Season
    $runId      = $t.RunId
    $jobId      = $t.JobId
    $leagueName = $t.LeagueName

    Write-Log ""
    Write-Log "[$index/$total] TARGET: $leagueName | league=$leagueId | season=$season | run_id=$runId | job_id=$jobId"

    # 1) single fetch
    Run-Step `
        -Title "FETCH PLAYERS - $leagueName ($leagueId / $season)" `
        -FilePath $PYTHON_EXE `
        -Arguments @(
            $FETCH_SCRIPT,
            "--league-id", $leagueId,
            "--season",    $season,
            "--run-id",    $runId,
            "--job-id",    $jobId
        )

    # 2) transitional pipeline po každém fetchi
    Run-Step `
        -Title "PIPELINE MERGE - $leagueName ($leagueId / $season)" `
        -FilePath $PYTHON_EXE `
        -Arguments @(
            $PIPELINE_SCRIPT
        )

    Write-Log "TARGET HOTOV: $leagueName | league=$leagueId | season=$season"
    Write-Log ""
}

Write-Log "MATCHMATRIX FB PLAYERS WAVE 1 PRO - FINISHED SUCCESSFULLY"
Write-Log "Log uložen do: $LOG_FILE"