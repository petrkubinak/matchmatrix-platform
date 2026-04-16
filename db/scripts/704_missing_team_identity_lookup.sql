-- 704_missing_team_identity_lookup.sql

WITH missing_ids AS (
    SELECT DISTINCT
        provider,
        sport_code,
        external_league_id,
        season,
        missing_provider_team_id
    FROM (
        -- sem vlož výstup z 703 (nebo použij jako subquery)
        SELECT
            provider,
            sport_code,
            external_league_id,
            season,
            missing_provider_team_id
        FROM (
            SELECT
                f.provider,
                f.sport_code,
                f.external_league_id,
                f.season,
                f.home_team_external_id AS missing_provider_team_id
            FROM staging.stg_provider_fixtures f
            LEFT JOIN public.team_provider_map h
                ON h.provider = f.provider
               AND h.provider_team_id = f.home_team_external_id
            WHERE h.team_id IS NULL

            UNION

            SELECT
                f.provider,
                f.sport_code,
                f.external_league_id,
                f.season,
                f.away_team_external_id
            FROM staging.stg_provider_fixtures f
            LEFT JOIN public.team_provider_map a
                ON a.provider = f.provider
               AND a.provider_team_id = f.away_team_external_id
            WHERE a.team_id IS NULL
        ) x
    ) y
)

SELECT
    m.provider,
    m.sport_code,
    m.external_league_id,
    m.season,
    m.missing_provider_team_id,
    t.team_name,
    COUNT(*) AS usage_count
FROM missing_ids m
LEFT JOIN staging.stg_provider_teams t
    ON t.provider = m.provider
   AND t.external_team_id = m.missing_provider_team_id
GROUP BY
    m.provider,
    m.sport_code,
    m.external_league_id,
    m.season,
    m.missing_provider_team_id,
    t.team_name
ORDER BY usage_count DESC;