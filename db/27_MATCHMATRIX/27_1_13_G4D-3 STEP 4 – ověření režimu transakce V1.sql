/*
CO: G4D-3 STEP 4 – ověření režimu transakce V1
K ČEMU: Diagnostika READ ONLY při spuštění v DBeaveru.
KDE: Stejné připojení k databázi matchmatrix.
JAK: Spustit celý skript; výsledek poslat jako screenshot.
*/

BEGIN TRANSACTION READ ONLY;

SELECT
    clock_timestamp() AS checked_at,
    current_database() AS database_name,
    pg_backend_pid() AS connection_pid,
    current_setting('transaction_read_only') AS read_only,
    CASE
        WHEN current_setting('transaction_read_only') = 'on'
        THEN 'PASS'
        ELSE 'BLOCKER'
    END AS result;

ROLLBACK;