SELECT
    id,
    sport_code,
    canonical_league_id,
    provider,
    provider_league_id,
    enabled,
    tier,
    notes,
    run_group
FROM ops.ingest_targets
WHERE sport_code = 'BK'
  AND enabled = TRUE
  AND notes = 'NBL'
ORDER BY canonical_league_id, provider_league_id;