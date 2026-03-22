@echo off
setlocal

REM ====== UPRAV SI JEN TYHLE 2 ŘÁDKY ======
set THEODDS_API_KEY=20d0a6ee8e376e26af007e0f069d7933
set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123
REM ========================================

REM volitelné nastavení (můžeš nechat jak je)
set ODDS_REGIONS=uk
set ODDS_MARKETS=h2h
set ODDS_DAYS_AHEAD=3

cd /d "%~dp0"

python -m pip show requests >nul 2>&1
if errorlevel 1 (
  echo Instalujem knihovny requests a psycopg2-binary...
  python -m pip install requests psycopg2-binary
)

echo Spoustim RAW import z TheOddsAPI...
python "%~dp0theodds_pull.py"

echo Hotovo.
pause
