@echo off
setlocal

REM ====== UPRAV SI JEN TYHLE 2 ŘÁDKY ======
set FOOTBALL_DATA_TOKEN=SEM_DEJ_TOKEN_Z_FOOTBALL_DATA
set DB_DSN=host=localhost dbname=matchmatrix user=postgres password=SEM_DEJ_HESLO
REM =======================================

python --version >nul 2>&1
if errorlevel 1 (
  echo Python neni nainstalovany nebo neni v PATH.
  echo Nainstaluj Python a zaskrtni "Add python.exe to PATH".
  pause
  exit /b 1
)

python -m pip show requests >nul 2>&1
if errorlevel 1 (
  echo Instalujem knihovny requests a psycopg2-binary...
  python -m pip install requests psycopg2-binary
)

set FOOTBALL_DATA_TOKEN=%FOOTBALL_DATA_TOKEN%
set DB_DSN=%DB_DSN%

echo Spoustim import z football-data.org...
python "%~dp0football_data_pull.py"

echo Hotovo.
pause
