-- 720_verify_api_football_leagues_by_run.sql
-- Pokud tabulka staging.stg_provider_leagues obsahuje run_id

SELECT
    run_id,
    COUNT(*) AS rows_total,
    COUNT(DISTINCT external_league_id) AS distinct_leagues,
    COUNT(DISTINCT (external_league_id::text || '|' || COALESCE(season::text, ''))) AS distinct_league_season
FROM staging.stg_provider_leagues
WHERE provider = 'api_football'
GROUP BY run_id
ORDER BY run_id DESC;