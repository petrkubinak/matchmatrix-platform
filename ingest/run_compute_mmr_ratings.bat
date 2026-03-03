@echo off
echo === MATCHMATRIX: COMPUTE MMR RATINGS ===

REM Přepni se do složky, kde je tento .bat (tj. ingest)
cd /d "%~dp0"

REM DB připojení
set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123

REM Spusť skript (je ve stejné složce jako .bat)
python compute_mmr_ratings.py

echo.
echo Done.
pause


