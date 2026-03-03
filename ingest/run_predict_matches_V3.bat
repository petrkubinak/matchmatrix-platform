@echo off
setlocal
cd /d %~dp0

echo === MATCHMATRIX :: PREDICT MATCHES ===

REM DB pripojeni
set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123

REM Model
set MM_MODEL_PATH=%~dp0artifacts\baseline_logreg_v3.joblib
set MM_MODEL_CODE=baseline_logreg_v3

REM Kolik dni dopredu predikovat
set MM_PRED_DAYS_AHEAD=14

python "%~dp0predict_matches_V3.py"

echo.
echo Done.
pause


