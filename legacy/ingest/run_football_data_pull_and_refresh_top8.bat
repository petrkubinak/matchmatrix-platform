@echo off
setlocal

echo ==========================================
echo MATCHMATRIX - FOOTBALL_DATA + TOP8 REFRESH
echo ==========================================

REM --------------------------------------------------
REM 1) nastaveni tokenu football-data
REM --------------------------------------------------
set FOOTBALL_DATA_TOKEN=e70890f503314d7a8af4e5782074ea04

REM --------------------------------------------------
REM 2) spusteni football_data pull V6
REM --------------------------------------------------
echo.
echo [1/2] Spoustim football_data_pull_V6.py ...
C:\Python314\python.exe C:\MatchMatrix-platform\legacy\ingest\football_data_pull_V6.py

if errorlevel 1 (
    echo.
    echo CHYBA: football_data_pull_V6.py spadl.
    pause
    exit /b 1
)

REM --------------------------------------------------
REM 3) refresh TOP 8 standings
REM --------------------------------------------------
echo.
echo [2/2] Spoustim TOP8 standings refresh ...

type "C:\MatchMatrix-platform\db\fix\413_refresh_top8_league_standings_from_matches.sql" | docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix

if errorlevel 1 (
    echo.
    echo CHYBA: TOP8 standings refresh selhal.
    pause
    exit /b 1
)

echo.
echo HOTOVO: football_data ingest + TOP8 standings refresh probehl uspesne.
pause
endlocal