param(
    [string]$TeamId = "",
    [string]$LeagueId = "",
    [string]$Season = "",
    [string]$RunId = ""
)

$pythonExe = if ($env:PYTHON_EXE) { $env:PYTHON_EXE } else { "C:\Python314\python.exe" }
$scriptPath = "C:\MatchMatrix-platform\workers\run_players_fetch_hk_only_v1.py"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: script not found -> $scriptPath"
    exit 1
}

$arguments = @($scriptPath)
if ($TeamId -ne "") { $arguments += @("--team-id", $TeamId) }
if ($LeagueId -ne "") { $arguments += @("--league-id", $LeagueId) }
if ($Season -ne "") { $arguments += @("--season", $Season) }
if ($RunId -ne "") { $arguments += @("--run-id", $RunId) }

Write-Host "=== MATCHMATRIX: API-HOCKEY PLAYERS PULL ==="
Write-Host "RUN: $pythonExe $($arguments -join ' ')"

& $pythonExe @arguments
exit $LASTEXITCODE
