-- =====================================================
-- 240_check_volleyball_merge_result.sql
-- Účel:
--   Ověřit, jak jsou volleyball fixtures ve staging
--   a proč se neukazují v public.matches jako api_volleyball.
-- =====================================================

-- 1) staging fixtures pro volleyball
SELECT
    provider,
    sport_code,
    COUNT(*) AS cnt
FROM staging.stg_provider_fixtures
WHERE provider = 'api_volleyball'
GROUP BY provider, sport_code;

-- 2) jaké ext_match_id máme ve staging
SELECT
    provider,
    sport_code,
    external_fixture_id,
    external_league_id,
    season,
    home_team_id,
    away_team_id,
    created_at,
    updated_at
FROM staging.stg_provider_fixtures
WHERE provider = 'api_volleyball'
ORDER BY updated_at DESC, id DESC
LIMIT 20;

-- 3) existují ty stejné ext_match_id už v public.matches?
SELECT
    m.id,
    m.ext_source,
    m.ext_match_id,
    m.league_id,
    m.season,
    m.home_team_id,
    m.away_team_id
FROM public.matches m
WHERE CAST(m.ext_match_id AS text) IN (
    SELECT CAST(f.external_fixture_id AS text)
    FROM staging.stg_provider_fixtures f
    WHERE f.provider = 'api_volleyball'
)
ORDER BY m.id DESC
LIMIT 50;

-- 4) kolik public.matches je navázaných na ligy,
--    které mají provider map api_volleyball
SELECT
    lpm.provider,
    COUNT(*) AS cnt
FROM public.matches m
JOIN public.league_provider_map lpm
  ON lpm.league_id = m.league_id
WHERE lpm.provider = 'api_volleyball'
GROUP BY lpm.provider;

-- 5) detail pár zápasů přes league_provider_map
SELECT
    m.id,
    m.ext_source,
    m.ext_match_id,
    m.league_id,
    m.season,
    m.home_team_id,
    m.away_team_id,
    lpm.provider
FROM public.matches m
JOIN public.league_provider_map lpm
  ON lpm.league_id = m.league_id
WHERE lpm.provider = 'api_volleyball'
ORDER BY m.id DESC
LIMIT 20;