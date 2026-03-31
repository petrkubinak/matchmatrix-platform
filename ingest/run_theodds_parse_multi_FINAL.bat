@echo off
echo ========================================
echo MATCHMATRIX - THEODDS PARSER
echo ========================================

REM === SPRAVNE DB PRIPOJENI (Docker DB) ===
set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=matchmatrix password=matchmatrix_pass

echo DB_DSN=%DB_DSN%
echo.

REM === PYTHON ===
set PYTHON_EXE=C:\Python314\python.exe

REM === SCRIPT ===
set SCRIPT=C:\MatchMatrix-platform\ingest\theodds_parse_multi_FINAL.py

echo Spoustim TheOdds parser...
echo.

%PYTHON_EXE% %SCRIPT%

echo.
echo HOTOVO
pause
