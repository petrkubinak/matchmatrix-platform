@echo off
setlocal

set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123

cd /d "%~dp0"
python "%~dp0theodds_parse.py"

pause
