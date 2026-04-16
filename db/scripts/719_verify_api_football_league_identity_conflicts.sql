-- 719_verify_api_football_league_identity_conflicts.sql
-- Konflikty identity lig ve staging po rebuild

SELECT
    provider,
    sport_code,
    external_league_id,
    COUNT(DISTINCT league_name) AS distinct_league_names,
    STRING_AGG(DISTINCT league_name, ' | ' ORDER BY league_name) AS league_names,
    COUNT(DISTINCT season) AS distinct_seasons,
    STRING_AGG(DISTINCT season::text, ', ' ORDER BY season::text) AS seasons
FROM staging.stg_provider_leagues
WHERE provider = 'api_football'
GROUP BY
    provider,
    sport_code,
    external_league_id
HAVING COUNT(DISTINCT league_name) > 1
ORDER BY
    distinct_league_names DESC,
    external_league_id;