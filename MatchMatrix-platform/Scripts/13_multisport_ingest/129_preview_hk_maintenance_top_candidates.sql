SELECT
    id,
    sport_code,
    canonical_league_id,
    notes,
    run_group
FROM ops.ingest_targets
WHERE run_group = 'BK_MAINTENANCE_TOP'
ORDER BY notes, canonical_league_id;