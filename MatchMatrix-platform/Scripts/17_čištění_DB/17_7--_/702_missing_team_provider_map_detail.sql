-- 702_missing_team_provider_map_detail.sql

SELECT
    f.provider,
    f.sport_code,
    f.external_league_id,
    f.season,
    f.external_fixture_id,
    f.fixture_date,
    f.home_team_external_id,
    f.away_team_external_id,
    h.team_id AS mapped_home_team_id,
    a.team_id AS mapped_away_team_id,
    CASE
        WHEN h.team_id IS NULL AND a.team_id IS NULL THEN 'MISSING_BOTH'
        WHEN h.team_id IS NULL THEN 'MISSING_HOME'
        WHEN a.team_id IS NULL THEN 'MISSING_AWAY'
        ELSE 'OK'
    END AS mapping_status
FROM staging.stg_provider_fixtures f
LEFT JOIN public.team_provider_map h
    ON h.provider = f.provider
   AND h.provider_team_id = f.home_team_external_id
LEFT JOIN public.team_provider_map a
    ON a.provider = f.provider
   AND a.provider_team_id = f.away_team_external_id
WHERE h.team_id IS NULL
   OR a.team_id IS NULL
ORDER BY f.provider, f.sport_code, f.external_league_id, f.fixture_date
LIMIT 500;