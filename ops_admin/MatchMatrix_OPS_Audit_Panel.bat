@echo off
title MatchMatrix OPS Audit Panel

echo =========================================
echo   MATCHMATRIX OPS AUDIT PANEL START
echo =========================================
echo.

set "BASE_DIR=C:\MatchMatrix-platform\ops_admin"
set "PYTHON_EXE=C:\Python314\python.exe"
set "PANEL_FILE=panel_matchmatrix_audit_v2.py"

if not exist "%BASE_DIR%\%PANEL_FILE%" (
    echo CHYBA: Soubor panelu nebyl nalezen:
    echo %BASE_DIR%\%PANEL_FILE%
    echo.
    echo Zkontroluj, ze jsi ulozil panel sem:
    echo C:\MatchMatrix-platform\ops_admin\panel_matchmatrix_audit_v2.py
    echo.
    pause
    exit /b 1
)

if not exist "%PYTHON_EXE%" (
    echo CHYBA: Python nebyl nalezen:
    echo %PYTHON_EXE%
    echo.
    echo Uprav v BAT souboru cestu k Pythonu.
    echo.
    pause
    exit /b 1
)

cd /d "%BASE_DIR%"

echo Spoustim panel...
echo.

"%PYTHON_EXE%" "%BASE_DIR%\%PANEL_FILE%"

echo.
echo Panel byl ukoncen.
pause
