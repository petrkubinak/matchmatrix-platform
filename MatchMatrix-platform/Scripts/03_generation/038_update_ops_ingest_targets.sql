UPDATE ops.ingest_targets t
SET
  canonical_league_id    = lpm.league_id,
  sport_code             = COALESCE(p.sport_code, 'football'),
  enabled                = p.enabled,
  tier                   = p.tier,
  fixtures_days_back     = p.fixtures_days_back,
  fixtures_days_forward  = p.fixtures_days_forward,
  odds_days_forward      = p.odds_days_forward,
  max_requests_per_run   = p.max_requests_per_run,
  notes                  = p.notes,
  run_group              = CASE
                             WHEN p.notes ILIKE 'EU exact v1%' THEN 'EU_exact_v1'
                             WHEN p.notes ILIKE 'EU major v4%' THEN 'EU_major_v4'
                             ELSE NULL
                           END,
  updated_at             = now()
FROM ops.league_import_plan p
JOIN public.league_provider_map lpm
  ON lpm.provider = p.provider
 AND lpm.provider_league_id = p.provider_league_id
WHERE p.enabled = true
  AND t.provider = p.provider
  AND t.provider_league_id = p.provider_league_id
  AND t.season = p.season;


UPDATE ops.ingest_targets
SET run_group =
  CASE
    WHEN run_group = 'EU_major_v4' AND (abs(hashtext(provider_league_id)) % 2) = 0 THEN 'EU_major_v4_A'
    WHEN run_group = 'EU_major_v4' THEN 'EU_major_v4_B'
    ELSE run_group
  END
WHERE enabled = true
  AND run_group = 'EU_major_v4';

SELECT run_group, COUNT(*) 
FROM ops.ingest_targets
WHERE enabled = true
GROUP BY run_group
ORDER BY run_group;