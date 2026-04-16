-- 718_verify_api_football_league_duplicates.sql
-- Spustit až po novém natažení api_football leagues do staging

SELECT
    provider,
    sport_code,
    external_league_id,
    league_name,
    season,
    COUNT(*) AS row_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_football'
GROUP BY
    provider,
    sport_code,
    external_league_id,
    league_name,
    season
HAVING COUNT(*) > 1
ORDER BY
    row_count DESC,
    external_league_id,
    season,
    league_name;