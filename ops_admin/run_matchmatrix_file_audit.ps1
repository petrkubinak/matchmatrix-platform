# MatchMatrix - spuštění auditu souborů
# Ulož tento soubor do: C:\MatchMatrix-platform\ops_admin\run_matchmatrix_file_audit.ps1

$PythonExe = "C:\Python314\python.exe"
$ScriptPath = "C:\MatchMatrix-platform\ops_admin\matchmatrix_file_audit.py"
$OutputDir = "C:\MatchMatrix-platform\reports\file_audit"

Write-Host "============================================================"
Write-Host "MATCHMATRIX FILE AUDIT"
Write-Host "============================================================"
Write-Host "Python : $PythonExe"
Write-Host "Script : $ScriptPath"
Write-Host "Output : $OutputDir"
Write-Host "============================================================"

& $PythonExe $ScriptPath --output-dir $OutputDir

Write-Host ""
Write-Host "Hotovo. Otevři report:" -ForegroundColor Green
Write-Host "$OutputDir\latest_report.md"
