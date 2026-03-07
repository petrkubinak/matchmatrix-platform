@echo off
cd /d C:\MATCHMATRIX-PLATFORM

echo ===============================
echo   INITIALIZACE GIT REPO
echo ===============================
echo.

REM 1) Inicializace repozitáře
git init

REM 2) Nastavení hlavní větve
git branch -M main

REM 3) Vytvoření .gitignore
echo Creating .gitignore ...

(
echo # ==========================
echo # MATCHMATRIX GIT IGNORE
echo # ==========================
echo.
echo # Python
echo __pycache__/
echo *.pyc
echo *.pyo
echo.
echo # Logs
echo *.log
echo.
echo # Reports
echo reports/*.txt
echo reports/*.csv
echo.
echo # Docker volumes
echo postgres-data/
echo redis-data/
echo.
echo # Local env
echo .env
echo .env.*
echo.
echo # VSCode
echo .vscode/
echo.
echo # OS
echo Thumbs.db
echo .DS_Store
echo.
echo # Temporary
echo _tmp_*
) > .gitignore

REM 4) Přidání souborů do Gitu
git add .

REM 5) Commit
git commit -m "Initial MatchMatrix setup (Docker + ingest + reports)"

echo.
echo ==================================
echo   GIT REPO JE INICIALIZOVANO
echo ==================================
pause