# =====================================================================
# MatchMatrix
# FILE: run_players_pipeline_merge_only_v1.ps1
# PATH: C:\MatchMatrix-platform\workers\run_players_pipeline_merge_only_v1.ps1
#
# Cíl:
# Spustit players pipeline BEZ fetch fáze
# (používá se po single-target fetchi nebo řízeném batchi)
#
# Spouští:
# 1) BRIDGE
# 2) PUBLIC MERGE
# 3) PARSE (season stats)
# 4) STATS PUBLIC MERGE
#
# =====================================================================

$ErrorActionPreference = "Stop"

# -----------------------------------------------------
# KONFIG
# -----------------------------------------------------
$PYTHON_EXE = "C:\Python314\python.exe"

$BRIDGE_SCRIPT       = "C:\MatchMatrix-platform\workers\run_players_bridge_v4.py"
$PUBLIC_MERGE_SCRIPT = "C:\MatchMatrix-platform\workers\run_players_public_merge_v2.py"
$PARSE_SCRIPT        = "C:\MatchMatrix-platform\workers\run_players_parse_only_v1.py"
$STATS_MERGE_SCRIPT  = "C:\MatchMatrix-platform\workers\run_player_season_statistics_public_merge_v1.py"

# Log
$LOG_DIR = "C:\MatchMatrix-platform\logs"
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
}

$RUN_TS = Get-Date -Format "yyyyMMdd_HHmmss"
$LOG_FILE = Join-Path $LOG_DIR ("players_merge_only_" + $RUN_TS + ".log")

# -----------------------------------------------------
# HELPER
# -----------------------------------------------------
function Write-Log {
    param([string]$Message)

    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"

    Write-Host $line
    Add-Content -Path $LOG_FILE -Value $line
}

function Run-Step {
    param(
        [string]$Title,
        [string]$ScriptPath
    )

    Write-Log "=============================================================="
    Write-Log $Title
    Write-Log "CMD: $PYTHON_EXE $ScriptPath"
    Write-Log "=============================================================="

    & $PYTHON_EXE $ScriptPath 2>&1 | Tee-Object -FilePath $LOG_FILE -Append

    if ($LASTEXITCODE -ne 0) {
        throw "Krok selhal: $Title"
    }

    Write-Log "HOTOVO OK: $Title"
}

# -----------------------------------------------------
# START
# -----------------------------------------------------
Write-Log "MATCHMATRIX PLAYERS PIPELINE MERGE-ONLY - START"
Write-Log ""

# 1) BRIDGE
Run-Step -Title "STEP 1 - BRIDGE PLAYERS" -ScriptPath $BRIDGE_SCRIPT

# 2) PUBLIC MERGE
Run-Step -Title "STEP 2 - PUBLIC PLAYERS MERGE" -ScriptPath $PUBLIC_MERGE_SCRIPT

# 3) PARSE
Run-Step -Title "STEP 3 - PARSE PLAYER SEASON STATS" -ScriptPath $PARSE_SCRIPT

# 4) STATS MERGE
Run-Step -Title "STEP 4 - PUBLIC PLAYER SEASON STATS MERGE" -ScriptPath $STATS_MERGE_SCRIPT

Write-Log ""
Write-Log "MATCHMATRIX PLAYERS PIPELINE MERGE-ONLY - FINISHED SUCCESSFULLY"
Write-Log "LOG: $LOG_FILE"