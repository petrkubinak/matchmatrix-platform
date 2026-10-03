-- CO: STEP 12D – poslední běhy sběru api_handball
-- K ČEMU: Rozlišit chybějící spuštění od běhu bez uložených zápasů.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

SELECT
    id,
    job_code,
    started_at,
    finished_at,
    status,
    params->>'sport' AS sport,
    params->>'entity' AS entity,
    message
FROM ops.job_runs
WHERE params->>'provider' = 'api_handball'
ORDER BY started_at DESC
LIMIT 20;