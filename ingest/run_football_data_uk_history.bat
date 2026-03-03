@echo off
setlocal

set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123
set FD_SEASONS_BACK=8

python football_data_uk_history_pull.py

pause

