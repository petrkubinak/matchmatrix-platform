param(
    [string]$RunGroup = "VB_CORE",
    [int]$Limit = 1,
    [int]$MaxWorkers = 1,
    [int]$TimeoutSec = 300
)

$BaseDir = "C:\MatchMatrix-platform"
$PythonExe = "C:\Python314\python.exe"
$Runner = Join-Path $BaseDir "ingest\run_unified_ingest_batch_v1.py"

Write-Host "MATCHMATRIX VB FIXTURES PULL"
& $PythonExe $Runner --provider api_volleyball --sport VB --entity fixtures --run-group $RunGroup --limit $Limit --max-workers $MaxWorkers --timeout-sec $TimeoutSec

exit $LASTEXITCODE