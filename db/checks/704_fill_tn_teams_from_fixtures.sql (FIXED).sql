-- =====================================================
-- 704_fill_tn_teams_from_fixtures.sql (FIXED)
-- =====================================================

INSERT INTO staging.stg_provider_teams (
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    created_at,
    updated_at
)
SELECT DISTINCT
    'api_tennis' AS provider,
    'TN' AS sport_code,
    md5(trim(x.player_name)) AS external_team_id,
    trim(x.player_name) AS team_name,
    NULL::text AS country_name,
    now() AS created_at,
    now() AS updated_at
FROM (
    SELECT player_1 AS player_name
    FROM staging.api_tennis_fixtures
    WHERE player_1 IS NOT NULL
      AND trim(player_1) <> ''

    UNION

    SELECT player_2 AS player_name
    FROM staging.api_tennis_fixtures
    WHERE player_2 IS NOT NULL
      AND trim(player_2) <> ''
) x
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.stg_provider_teams s
    WHERE s.provider = 'api_tennis'
      AND s.sport_code = 'TN'
      AND s.external_team_id = md5(trim(x.player_name))
);

-- kontrola
SELECT
    COUNT(*) AS rows_total,
    COUNT(DISTINCT external_team_id) AS distinct_ids,
    COUNT(DISTINCT team_name) AS distinct_names
FROM staging.stg_provider_teams
WHERE provider = 'api_tennis'
  AND sport_code = 'TN';