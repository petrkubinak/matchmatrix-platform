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
  'football' AS sport_code,
  l.id AS canonical_league_id,
  'api_football' AS provider,
  lpm.provider_league_id,
  '2024' AS season,         -- season je u tebe text (už jsme to řešili)
  true  AS enabled,
  1     AS tier,
  2     AS fixtures_days_back,
  10    AS fixtures_days_forward,
  3     AS odds_days_forward,
  NULL::int AS max_requests_per_run,
  'auto-generated from league_provider_map' AS notes,
  NOW(), NOW()
FROM public.leagues l
JOIN public.sports sp ON sp.id = l.sport_id
JOIN public.league_provider_map lpm
  ON lpm.league_id = l.id
 AND lpm.provider = 'api_football'
LEFT JOIN ops.ingest_targets it
  ON it.canonical_league_id = l.id
 AND it.provider = 'api_football'
WHERE sp.code = 'football'
  AND it.id IS NULL;