# MatchMatrix report runner
# API Football Backfill Status

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

$sqlFile = "C:\MATCHMATRIX-PLATFORM\MatchMatrix-platform\Scripts\99_reports\mm_api_football_backfill_status.sql"

$logDir = "C:\MatchMatrix-platform\logs"

$logFile = "$logDir\api_football_backfill_status_$timestamp.txt"

Write-Host ""
Write-Host "Running MatchMatrix backfill report..."
Write-Host "Log file:"
Write-Host $logFile
Write-Host ""

Get-Content $sqlFile -Raw |
docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -P pager=off `
| Tee-Object $logFile

Write-Host ""
Write-Host "Report finished."
Write-Host ""