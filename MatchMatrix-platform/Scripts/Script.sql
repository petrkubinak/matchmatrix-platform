SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    season,
    enabled,
    tier,
    run_group,
    fixtures_days_back,
    fixtures_days_forward,
    max_requests_per_run,
    updated_at
FROM ops.ingest_targets
WHERE provider = 'api_football'
  AND sport_code = 'FB'
ORDER BY enabled DESC, tier NULLS LAST, canonical_league_id, season;