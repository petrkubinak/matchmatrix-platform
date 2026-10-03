-- CO: STEP 12A – sezóny připravené v HB ingest targets
-- K ČEMU: Zjistit, zda jsou připravené targety i pro novější sezóny než 2024.
-- KDE: PostgreSQL matchmatrix na PC2.
-- JAK: Pouze čtení; spustit celý dotaz.

SELECT
    season,
    count(*) AS targety,
    count(*) FILTER (WHERE enabled IS TRUE) AS aktivni_targety,
    count(DISTINCT provider_league_id) AS zdrojove_souteze
FROM ops.ingest_targets
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
GROUP BY season
ORDER BY season DESC NULLS LAST;