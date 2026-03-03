@echo off
echo === MATCHMATRIX: TRAIN GBM V3 (weighted + calibrated) ===

REM SQLAlchemy URL (ne psycopg2 DSN!)
set DB_DSN=postgresql+psycopg2://mm_ingest:mm_ingest_123@localhost:5432/matchmatrix

cd /d C:\MatchMatrix-platform\ingest

python train_gbm_v3.py

pause
