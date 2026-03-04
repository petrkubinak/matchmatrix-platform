@echo off
cd /d C:\MATCHMATRIX-PLATFORM\system
echo ==============================
echo   MATCHMATRIX WEEKLY REPORT
echo ==============================
powershell -ExecutionPolicy Bypass -File run_reports.ps1 -Mode weekly
echo.
pause