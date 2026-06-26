/*
MATCHMATRIX SCRIPT

NÁZEV:
20_4_C_5_fix_pc2_command_python_path.sql

CO TO JE:
Oprava Python cesty v PC2 command queue.

K ČEMU TO JE:
Některé příkazy používají jen "python workers/..."
a na PC2 to způsobilo FileNotFoundError [WinError 2].

KDE TO UVIDÍME:
OPS Panel → PC2 Command Center / Denní práce.

JAK SE TO VYUŽIJE:
PC2 bude spouštět workery přes pevnou cestu:
C:\Python314\python.exe
*/

BEGIN;

UPDATE ops.pc2_run_command_queue
SET
    command_text = REPLACE(
        command_text,
        'python workers/',
        'C:\Python314\python.exe workers/'
    ),
    run_status = CASE
        WHEN run_status = 'FAILED' THEN 'READY_TO_RUN'
        ELSE run_status
    END,
    last_result = COALESCE(last_result, '') || E'\nPython path fixed by 20_4_C_5.',
    updated_at = now()
WHERE command_text LIKE 'python workers/%'
  AND run_status IN ('READY_TO_RUN', 'FAILED');

COMMIT;