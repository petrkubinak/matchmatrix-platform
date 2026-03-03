@echo off
setlocal

REM --- DB (tvuj docker postgres)
set "DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123"

REM --- football-data.org token (dopln si)
REM set "FOOTBALL_DATA_TOKEN=e70890f503314d7a8af4e5782074ea04"

cd /d C:\MatchMatrix-platform\ingest

python football_data_pull_V5.py

pause
