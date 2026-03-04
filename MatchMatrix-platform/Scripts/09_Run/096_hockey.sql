INSERT INTO ops.ingest_targets (
  provider,
  provider_league_id,
  canonical_league_id,
  sport_code,
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
  p.provider,
  p.provider_league_id,
  lpm.league_id,
  COALESCE(p.sport_code, 'football'),
  p.season,
  p.enabled,
  p.tier,
  p.fixtures_days_back,
  p.fixtures_days_forward,
  p.odds_days_forward,
  p.max_requests_per_run,
  p.notes,
  CASE
    WHEN p.notes ILIKE 'EU exact v1%' THEN 'EU_exact_v1'
    WHEN p.notes ILIKE 'EU major v4%' THEN 'EU_major_v4'
    ELSE NULL
  END
FROM ops.league_import_plan p
JOIN public.league_provider_map lpm
  ON lpm.provider = p.provider
 AND lpm.provider_league_id = p.provider_league_id
LEFT JOIN ops.ingest_targets t
  ON t.provider = p.provider
 AND t.provider_league_id = p.provider_league_id
 AND t.season = p.season
WHERE p.enabled = true
  AND t.id IS NULL;