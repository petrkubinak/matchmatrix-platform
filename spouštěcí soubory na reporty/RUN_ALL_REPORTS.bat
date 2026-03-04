@echo off
cd /d C:\MATCHMATRIX-PLATFORM\system
echo ==============================
echo   MATCHMATRIX FULL REPORT
echo ==============================
powershell -ExecutionPolicy Bypass -File run_reports.ps1 -Mode all
echo.
pause