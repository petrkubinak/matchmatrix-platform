-- 727_expand_hb_ingest_targets.sql
-- Rozsireni HB ingest_targets o dalsi dostupne ligy z public.leagues pro sezonu 2024

-- 1) preview: ktere HB ligy jeste nejsou v ingest_targets
SELECT
    l.id AS canonical_league_id,
    l.name,
    l.country,
    l.ext_league_id AS provider_league_id,
    l.ext_source
FROM public.leagues l
WHERE l.ext_source = 'api_handball'
  AND l.ext_league_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_targets t
      WHERE t.provider = 'api_handball'
        AND t.sport_code = 'HB'
        AND t.provider_league_id = l.ext_league_id
        AND t.season = '2024'
  )
ORDER BY l.country NULLS LAST, l.name;

-- 2) insert novych HB targetu
INSERT INTO ops.ingest_targets (
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    fixtures_days_back,
    fixtures_days_forward,
    odds_days_forward,
    max_requests_per_run,
    notes,
    run_group
)
SELECT
    'HB' AS sport_code,
    l.id AS canonical_league_id,
    'api_handball' AS provider,
    l.ext_league_id AS provider_league_id,
    '2024' AS season,
    true AS enabled,
    3 AS tier,
    30 AS fixtures_days_back,
    30 AS fixtures_days_forward,
    3 AS odds_days_forward,
    20 AS max_requests_per_run,
    'HB expansion auto target from public.leagues' AS notes,
    'HB_CORE' AS run_group
FROM public.leagues l
WHERE l.ext_source = 'api_handball'
  AND l.ext_league_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_targets t
      WHERE t.provider = 'api_handball'
        AND t.sport_code = 'HB'
        AND t.provider_league_id = l.ext_league_id
        AND t.season = '2024'
  );

-- 3) kontrola po insertu
SELECT
    t.id,
    t.sport_code,
    t.provider,
    t.provider_league_id,
    t.season,
    t.enabled,
    t.tier,
    t.run_group,
    t.notes
FROM ops.ingest_targets t
WHERE t.provider = 'api_handball'
  AND t.sport_code = 'HB'
  AND t.season = '2024'
ORDER BY t.tier, t.provider_league_id;