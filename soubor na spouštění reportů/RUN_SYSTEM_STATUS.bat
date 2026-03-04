@echo off
setlocal enabledelayedexpansion
cd /d C:\MATCHMATRIX-PLATFORM\system

set OUTDIR=C:\MATCHMATRIX-PLATFORM\reports
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%i
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set TS=%%i

set OUTFILE=%OUTDIR%\%TODAY%_SYSTEM_CHECK_%TS%.txt
set TMPFILE=%OUTDIR%\_tmp_SYSTEM_CHECK_%TS%.txt

echo Writing (temp): %TMPFILE%
if exist "%TMPFILE%" del /f /q "%TMPFILE%" >nul 2>&1

(
  echo ==============================
  echo MATCHMATRIX SYSTEM CHECK
  echo ==============================
  echo.

  echo [1] Docker containers
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
  echo.

  echo [2] Docker compose status (optional)
  docker compose ps 2^>^&1
  echo.

  echo [3] Postgres quick check (inside container)
  docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -c "SELECT now() as db_time, version() as pg_version;" 2^>^&1
  echo.

  echo [4] Ops health (job_runs + targets)
  docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -c "SELECT id, job_code, status, started_at, finished_at FROM ops.job_runs ORDER BY id DESC LIMIT 15;" 2^>^&1
  echo.
  docker exec -i matchmatrix_postgres psql -U matchmatrix -d matchmatrix -v ON_ERROR_STOP=1 -c "SELECT provider, run_group, COUNT(*) cnt FROM ops.ingest_targets WHERE enabled=true GROUP BY provider, run_group ORDER BY provider, run_group;" 2^>^&1
  echo.

  echo [5] Redis ping
  docker exec -i matchmatrix_redis redis-cli PING 2^>^&1
  echo.
) > "%TMPFILE%"

REM Rename temp to final (atomic-ish)
move /y "%TMPFILE%" "%OUTFILE%" >nul

echo Done. Open file: %OUTFILE%
pause