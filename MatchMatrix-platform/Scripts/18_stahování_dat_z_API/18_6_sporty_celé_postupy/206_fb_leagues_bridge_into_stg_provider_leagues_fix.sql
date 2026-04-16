-- =====================================================================
-- 206_fb_leagues_bridge_into_stg_provider_leagues_fix.sql
-- MatchMatrix - FB leagues bridge FIX
-- respektuje unique logiku provider + external_league_id + season
-- =====================================================================

INSERT INTO staging.stg_provider_leagues
(
    provider,
    sport_code,
    external_league_id,
    league_name,
    country_name,
    season,
    raw_payload_id,
    is_active,
    created_at,
    updated_at
)
SELECT
    'api_football'::text            AS provider,
    'football'::text                AS sport_code,
    src.league_id::text             AS external_league_id,
    src.name                        AS league_name,
    src.country                     AS country_name,
    src.season::text                AS season,
    NULL::bigint                    AS raw_payload_id,
    TRUE                            AS is_active,
    COALESCE(src.fetched_at, now()) AS created_at,
    COALESCE(src.fetched_at, now()) AS updated_at
FROM (
    SELECT DISTINCT ON (league_id, COALESCE(season, 0))
           league_id,
           name,
           country,
           season,
           fetched_at
    FROM staging.api_football_leagues
    WHERE league_id IS NOT NULL
      AND name IS NOT NULL
    ORDER BY league_id, COALESCE(season, 0), fetched_at DESC NULLS LAST
) src
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.stg_provider_leagues tgt
    WHERE tgt.provider = 'api_football'
      AND tgt.external_league_id = src.league_id::text
      AND COALESCE(tgt.season, '') = COALESCE(src.season::text, '')
);

-- =====================================================================
-- KONTROLA 1
-- =====================================================================
SELECT COUNT(*) AS stg_provider_leagues_api_football_count
FROM staging.stg_provider_leagues
WHERE provider = 'api_football'
  AND sport_code = 'football';

-- =====================================================================
-- KONTROLA 2
-- =====================================================================
SELECT
    provider,
    sport_code,
    external_league_id,
    league_name,
    country_name,
    season,
    is_active
FROM staging.stg_provider_leagues
WHERE provider = 'api_football'
  AND sport_code = 'football'
ORDER BY external_league_id::bigint, season
LIMIT 100;