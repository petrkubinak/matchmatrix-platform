-- =====================================================
-- 245_check_vb_staging_teams.sql
-- Účel:
--   Ověřit, zda vůbec existují volleyball týmy ve staging.stg_provider_teams.
-- =====================================================

SELECT
    provider,
    sport_code,
    COUNT(*) AS cnt
FROM staging.stg_provider_teams
WHERE provider = 'api_volleyball'
GROUP BY provider, sport_code;

SELECT
    provider,
    sport_code,
    external_team_id,
    team_name,
    external_league_id,
    season,
    updated_at
FROM staging.stg_provider_teams
WHERE provider = 'api_volleyball'
ORDER BY updated_at DESC, id DESC
LIMIT 50;