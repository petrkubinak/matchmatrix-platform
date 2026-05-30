/*
MATCHMATRIX BK JOB RUNS AUDIT V1

Co to je:
- Kontrola posledních BK job runů.

K čemu to je:
- Zjistíme, jaký worker BK fixtures skutečně běžel
  a jestli skončil úspěšně, nebo jen označil planner jako done.

Kde výsledek uvidíme:
- V DBeaveru jako poslední běhy jobů.

Jak se využije na webu:
- Pomůže opravit BK ingest tak, aby výsledky šly do RAW -> staging -> public.
*/

SELECT
    id,
    job_code,
    started_at,
    finished_at,
    status,
    rows_affected,
    message,
    params
FROM ops.job_runs
WHERE params::text ILIKE '%BK%'
   OR params::text ILIKE '%BK_TOP%'
   OR job_code ILIKE '%BK%'
ORDER BY started_at DESC
LIMIT 50;