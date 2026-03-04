@echo off
cd /d C:\MATCHMATRIX-PLATFORM\system
echo ==============================
echo   MATCHMATRIX DAILY REPORT
echo ==============================
powershell -ExecutionPolicy Bypass -File run_reports.ps1 -Mode daily
echo.
pause