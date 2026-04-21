-- =====================================================================
-- 203_fb_teams_bridge_into_stg_provider_teams_fix.sql
-- MatchMatrix - FB teams bridge FIX
-- respektuje unique constraint: (provider, external_team_id)
-- =====================================================================

INSERT INTO staging.stg_provider_teams
(
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
)
SELECT
    'api_football'::text                  AS provider,
    'football'::text                      AS sport_code,
    src.team_id::text                     AS external_team_id,
    src.name                              AS team_name,
    src.country                           AS country_name,
    src.league_id::text                   AS external_league_id,
    src.season::text                      AS season,
    NULL::bigint                          AS raw_payload_id,
    TRUE                                  AS is_active,
    COALESCE(src.fetched_at, now())       AS created_at,
    COALESCE(src.fetched_at, now())       AS updated_at
FROM (
    SELECT DISTINCT ON (team_id)
           team_id,
           name,
           country,
           league_id,
           season,
           fetched_at
    FROM staging.api_football_teams
    WHERE team_id IS NOT NULL
      AND name IS NOT NULL
    ORDER BY team_id, fetched_at DESC NULLS LAST, season DESC, league_id
) src
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.stg_provider_teams tgt
    WHERE tgt.provider = 'api_football'
      AND tgt.external_team_id = src.team_id::text
);

-- =====================================================================
-- KONTROLA 1
-- =====================================================================
SELECT COUNT(*) AS stg_provider_teams_api_football_count
FROM staging.stg_provider_teams
WHERE provider = 'api_football'
  AND sport_code = 'football';

-- =====================================================================
-- KONTROLA 2
-- =====================================================================
SELECT
    provider,
    sport_code,
    external_team_id,
    team_name,
    country_name,
    external_league_id,
    season,
    is_active,
    created_at
FROM staging.stg_provider_teams
WHERE provider = 'api_football'
  AND sport_code = 'football'
ORDER BY external_team_id::bigint
LIMIT 100;