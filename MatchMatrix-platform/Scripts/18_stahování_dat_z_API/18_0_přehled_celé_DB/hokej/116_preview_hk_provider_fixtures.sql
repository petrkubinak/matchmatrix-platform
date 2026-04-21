-- 116_preview_hk_provider_fixtures.sql

SELECT
    provider,
    sport_code,
    external_fixture_id,
    external_league_id,
    season,
    home_team_external_id,
    away_team_external_id,
    fixture_date,
    status_text,
    home_score,
    away_score,
    raw_payload_id,
    created_at
FROM staging.stg_provider_fixtures
WHERE LOWER(COALESCE(provider, '')) LIKE '%hockey%'
   OR LOWER(COALESCE(sport_code, '')) IN ('hk', 'hockey')
ORDER BY created_at DESC, id DESC
LIMIT 30;