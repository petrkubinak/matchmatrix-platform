param(
    [string]$RunGroup = "HB_CORE",
    [string]$SportCode = "HB",
    [string]$Entity = "teams",
    [string]$Provider = "api_handball",
    [int]$Limit = 1,
    [int]$MaxWorkers = 1,
    [int]$TimeoutSec = 300
)

$ProjectRoot = "C:\MatchMatrix-platform"
$PythonExe   = "C:\Python314\python.exe"
$UnifiedRun  = Join-Path $ProjectRoot "ingest\run_unified_ingest_batch_v1.py"

Write-Host "======================================================================"
Write-Host "MATCHMATRIX HB TEAMS PULL"
Write-Host "======================================================================"
Write-Host "Provider   : $Provider"
Write-Host "Sport      : $SportCode"
Write-Host "Entity     : $Entity"
Write-Host "RunGroup   : $RunGroup"
Write-Host "Limit      : $Limit"
Write-Host "MaxWorkers : $MaxWorkers"
Write-Host "TimeoutSec : $TimeoutSec"
Write-Host "======================================================================"

& $PythonExe $UnifiedRun `
    --provider $Provider `
    --sport $SportCode `
    --entity $Entity `
    --limit $Limit `
    --max-workers $MaxWorkers `
    --timeout-sec $TimeoutSec `
    --run-group $RunGroup

exit $LASTEXITCODE