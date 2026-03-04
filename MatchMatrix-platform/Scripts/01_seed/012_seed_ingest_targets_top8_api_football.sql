-- 012_seed_ingest_targets_top8_api_football.sql
-- Naplní ops.ingest_targets pro TOP ligy z public.league_provider_map (api_football)
-- Idempotentní: ON CONFLICT update

BEGIN;

-- TOP 8 (včetně Championship) podle provider_league_id
WITH whitelist AS (
  SELECT unnest(ARRAY['39','40','61','78','88','94','135','140'])::text AS provider_league_id
),
src AS (
  SELECT
    'football'::text AS sport_code,
    l.id AS canonical_league_id,
    m.provider,
    m.provider_league_id,
    ''::text AS season,
    true AS enabled,
    l.tier,
    7  AS fixtures_days_back,
    14 AS fixtures_days_forward,
    3  AS odds_days_forward,
    500::int AS max_requests_per_run,
    'TOP8 whitelist'::text AS notes
  FROM public.league_provider_map m
  JOIN public.leagues l ON l.id = m.league_id
  JOIN whitelist w ON w.provider_league_id = m.provider_league_id
  WHERE m.provider = 'api_football'
)
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
  created_at,
  updated_at
)
SELECT
  sport_code,
  canonical_league_id,
  provider,
  provider_league_id,
  season,
  enabled,
  COALESCE(tier, 1),
  fixtures_days_back,
  fixtures_days_forward,
  odds_days_forward,
  max_requests_per_run,
  notes,
  now(),
  now()
FROM src
ON CONFLICT (provider, provider_league_id, season)
DO UPDATE SET
  canonical_league_id     = EXCLUDED.canonical_league_id,
  enabled                = EXCLUDED.enabled,
  tier                   = EXCLUDED.tier,
  fixtures_days_back      = EXCLUDED.fixtures_days_back,
  fixtures_days_forward   = EXCLUDED.fixtures_days_forward,
  odds_days_forward       = EXCLUDED.odds_days_forward,
  max_requests_per_run    = EXCLUDED.max_requests_per_run,
  notes                  = EXCLUDED.notes,
  updated_at             = now();

COMMIT;