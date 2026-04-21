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
    notes
FROM ops.ingest_targets
WHERE sport_code = 'HB'
  AND provider = 'api_handball'
  AND run_group = 'HB_CORE'
ORDER BY provider_league_id::int, season;