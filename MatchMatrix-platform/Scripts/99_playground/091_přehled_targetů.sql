-- kolik EU exact v1 targetů je aktivních
SELECT count(*)
FROM ops.ingest_targets
WHERE provider='api_football'
  AND enabled=true
  AND notes ILIKE 'EU exact v1%';

-- přehled targetů
SELECT provider_league_id, tier, fixtures_days_back, fixtures_days_forward, max_requests_per_run, notes
FROM ops.ingest_targets
WHERE provider='api_football'
  AND notes ILIKE 'EU exact v1%'
ORDER BY tier, provider_league_id;

-- ověření mapování
SELECT count(*) FROM public.league_provider_map WHERE provider='api_football';