@echo off
setlocal

REM ====== UPRAV SI JEN Tohle ======
set DB_DSN=host=localhost port=5432 dbname=matchmatrix user=mm_ingest password=mm_ingest_123

REM test = posledních 365 dní
set MM_TEST_DAYS=365

REM volitelně omez nejstarší datum (prázdné = vše)
set MM_MIN_KICKOFF=

python train_baseline_logreg.py

pause
