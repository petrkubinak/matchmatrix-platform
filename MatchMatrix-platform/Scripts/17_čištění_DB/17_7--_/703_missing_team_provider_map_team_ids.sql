-- 703_missing_team_provider_map_team_ids.sql

WITH missing_home AS (
    SELECT
        f.provider,
        f.sport_code,
        f.external_league_id,
        f.season,
        f.home_team_external_id AS missing_provider_team_id,
        COUNT(*) AS usage_count
    FROM staging.stg_provider_fixtures f
    LEFT JOIN public.team_provider_map h
        ON h.provider = f.provider
       AND h.provider_team_id = f.home_team_external_id
    WHERE h.team_id IS NULL
      AND f.home_team_external_id IS NOT NULL
    GROUP BY
        f.provider,
        f.sport_code,
        f.external_league_id,
        f.season,
        f.home_team_external_id
),
missing_away AS (
    SELECT
        f.provider,
        f.sport_code,
        f.external_league_id,
        f.season,
        f.away_team_external_id AS missing_provider_team_id,
        COUNT(*) AS usage_count
    FROM staging.stg_provider_fixtures f
    LEFT JOIN public.team_provider_map a
        ON a.provider = f.provider
       AND a.provider_team_id = f.away_team_external_id
    WHERE a.team_id IS NULL
      AND f.away_team_external_id IS NOT NULL
    GROUP BY
        f.provider,
        f.sport_code,
        f.external_league_id,
        f.season,
        f.away_team_external_id
),
all_missing AS (
    SELECT * FROM missing_home
    UNION ALL
    SELECT * FROM missing_away
)
SELECT
    provider,
    sport_code,
    external_league_id,
    season,
    missing_provider_team_id,
    SUM(usage_count) AS total_usage_count
FROM all_missing
GROUP BY
    provider,
    sport_code,
    external_league_id,
    season,
    missing_provider_team_id
ORDER BY
    total_usage_count DESC,
    provider,
    sport_code,
    external_league_id,
    season,
    missing_provider_team_id;