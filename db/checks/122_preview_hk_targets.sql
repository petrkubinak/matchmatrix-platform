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
WHERE sport_code = 'HK'
ORDER BY tier, canonical_league_id
LIMIT 300;