# ==========================================================
# MATCHMATRIX SCHEDULED INGEST RUNNER
# Spouští se automaticky přes Windows Task Scheduler
# ==========================================================

$BaseDir = "C:\MatchMatrix-platform"
$PythonExe = "C:\Python314\python.exe"
$LogDir = "$BaseDir\logs\scheduler"

# vytvoření log složky
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = "$LogDir\ingest_$Timestamp.log"

Write-Output "==================================================" | Tee-Object -FilePath $LogFile
Write-Output "MATCHMATRIX SCHEDULED INGEST START: $(Get-Date)" | Tee-Object -FilePath $LogFile -Append
Write-Output "BASE DIR: $BaseDir" | Tee-Object -FilePath $LogFile -Append
Write-Output "==================================================" | Tee-Object -FilePath $LogFile -Append

Set-Location $BaseDir

# stáhne poslední verzi z GitHubu
git pull 2>&1 | Tee-Object -FilePath $LogFile -Append

# spustí ingest planner
& $PythonExe "$BaseDir\workers\run_ingest_planner_jobs.py" 2>&1 | Tee-Object -FilePath $LogFile -Append

Write-Output "==================================================" | Tee-Object -FilePath $LogFile -Append
Write-Output "MATCHMATRIX SCHEDULED INGEST END: $(Get-Date)" | Tee-Object -FilePath $LogFile -Append
Write-Output "==================================================" | Tee-Object -FilePath $LogFile -Append