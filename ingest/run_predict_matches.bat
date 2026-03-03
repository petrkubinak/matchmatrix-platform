@echo off
setlocal
cd /d %~dp0

echo === MATCHMATRIX: PREDICT MATCHES ===

REM DB connection (uprav podle sebe, nebo smaž pokud to už máš v systému)
set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123

REM Najdi predict_matches.py buď ve stejné složce, nebo v podsložce ingest
if exist "%~dp0predict_matches.py" (
  python "%~dp0predict_matches.py"
) else if exist "%~dp0ingest\predict_matches.py" (
  python "%~dp0ingest\predict_matches.py"
) else (
  echo ERROR: Nenalezen predict_matches.py ani v %~dp0 ani v %~dp0ingest\
  exit /b 1
)

echo.
echo Done.
pause


