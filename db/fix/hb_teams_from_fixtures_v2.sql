-- ============================================
-- HB FIX: DOPLNĚNÍ CHYBĚJÍCÍCH TEAMS Z FIXTURES
-- verze V2 - bezpečná přes ON CONFLICT
-- ============================================

INSERT INTO staging.stg_provider_teams (
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    raw_payload_id,
    is_active
)
SELECT
    x.provider,
    x.sport_code,
    x.external_team_id,
    'UNKNOWN_' || x.external_team_id AS team_name,
    'UNKNOWN' AS country_name,
    MIN(x.external_league_id) AS external_league_id,
    MIN(x.season) AS season,
    MIN(x.raw_payload_id) AS raw_payload_id,
    TRUE AS is_active
FROM (
    SELECT
        sf.provider,
        sf.sport_code,
        sf.home_team_external_id AS external_team_id,
        sf.external_league_id,
        sf.season,
        sf.raw_payload_id
    FROM staging.stg_provider_fixtures sf
    WHERE sf.provider = 'api_handball'

    UNION ALL

    SELECT
        sf.provider,
        sf.sport_code,
        sf.away_team_external_id AS external_team_id,
        sf.external_league_id,
        sf.season,
        sf.raw_payload_id
    FROM staging.stg_provider_fixtures sf
    WHERE sf.provider = 'api_handball'
) x
LEFT JOIN staging.stg_provider_teams st
    ON st.provider = x.provider
   AND st.external_team_id = x.external_team_id
WHERE st.external_team_id IS NULL
GROUP BY
    x.provider,
    x.sport_code,
    x.external_team_id
ON CONFLICT (provider, external_team_id) DO NOTHING;