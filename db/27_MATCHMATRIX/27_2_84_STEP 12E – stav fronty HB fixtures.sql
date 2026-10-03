-- CO: STEP 12E – stav fronty HB fixtures
-- K ČEMU: Rozhodnout, zda stačí spustit worker, nebo je nutné nejdřív vytvořit joby.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

SELECT
    season,
    count(*) AS celkem_jobu,
    count(*) FILTER (
        WHERE status = 'pending'
          AND coalesce(attempts, 0) < 3
          AND (next_run IS NULL OR next_run <= now())
    ) AS spustitelne_ted,
    count(*) FILTER (WHERE status = 'done') AS hotove,
    count(*) FILTER (WHERE status = 'error') AS chyby,
    max(last_attempt) AS posledni_pokus
FROM ops.ingest_planner
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures'
GROUP BY season
ORDER BY season DESC NULLS LAST;