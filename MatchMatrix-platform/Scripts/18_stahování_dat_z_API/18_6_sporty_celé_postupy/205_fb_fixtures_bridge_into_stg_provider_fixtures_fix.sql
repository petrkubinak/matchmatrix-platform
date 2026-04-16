-- =====================================================================
-- 205_fb_fixtures_bridge_into_stg_provider_fixtures_fix.sql
-- MatchMatrix - FB fixtures bridge FIX
-- respektuje unique constraint: (provider, external_fixture_id)
-- =====================================================================

INSERT INTO staging.stg_provider_fixtures
(
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
    created_at,
    updated_at
)
SELECT
    'api_football'::text            AS provider,
    'football'::text                AS sport_code,
    src.fixture_id::text            AS external_fixture_id,
    src.league_id::text             AS external_league_id,
    src.season::text                AS season,
    src.home_team_id::text          AS home_team_external_id,
    src.away_team_id::text          AS away_team_external_id,
    src.kickoff                     AS fixture_date,
    src.status                      AS status_text,
    src.home_goals::text            AS home_score,
    src.away_goals::text            AS away_score,
    NULL::bigint                    AS raw_payload_id,
    COALESCE(src.fetched_at, now()) AS created_at,
    COALESCE(src.fetched_at, now()) AS updated_at
FROM (
    SELECT DISTINCT ON (fixture_id)
           fixture_id,
           league_id,
           season,
           home_team_id,
           away_team_id,
           kickoff,
           status,
           home_goals,
           away_goals,
           fetched_at
    FROM staging.api_football_fixtures
    WHERE fixture_id IS NOT NULL
    ORDER BY fixture_id, fetched_at DESC NULLS LAST, kickoff DESC NULLS LAST
) src
WHERE NOT EXISTS (
    SELECT 1
    FROM staging.stg_provider_fixtures tgt
    WHERE tgt.provider = 'api_football'
      AND tgt.external_fixture_id = src.fixture_id::text
);

-- =====================================================================
-- KONTROLA 1
-- =====================================================================
SELECT COUNT(*) AS stg_provider_fixtures_api_football_count
FROM staging.stg_provider_fixtures
WHERE provider = 'api_football'
  AND sport_code = 'football';

-- =====================================================================
-- KONTROLA 2
-- =====================================================================
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
    away_score
FROM staging.stg_provider_fixtures
WHERE provider = 'api_football'
  AND sport_code = 'football'
ORDER BY fixture_date DESC NULLS LAST
LIMIT 100;