@echo off
echo === MATCHMATRIX: TRAIN GBM V2 ===

set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123

cd /d C:\MatchMatrix-platform\ingest

python train_gbm_v2.py

pause
