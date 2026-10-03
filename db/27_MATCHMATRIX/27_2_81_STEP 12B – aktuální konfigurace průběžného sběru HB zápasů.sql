-- CO: STEP 12B – aktuální konfigurace průběžného sběru HB zápasů
-- K ČEMU: Zjistit, zda se nové zápasy sbírají nezávisle na sezónních targetech.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

SELECT *
FROM ops.provider_jobs
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND endpoint_code = 'fixtures';