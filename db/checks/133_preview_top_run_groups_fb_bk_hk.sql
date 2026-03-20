SELECT
    sport_code,
    run_group,
    canonical_league_id,
    provider,
    provider_league_id,
    enabled,
    tier,
    notes
FROM ops.ingest_targets
WHERE run_group IN (
    'FOOTBALL_MAINTENANCE_TOP',
    'BK_MAINTENANCE_TOP',
    'HK_MAINTENANCE_TOP'
)
ORDER BY sport_code, run_group, notes, canonical_league_id;