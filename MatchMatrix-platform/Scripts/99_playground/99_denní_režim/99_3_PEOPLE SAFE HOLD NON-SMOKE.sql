-- 99_playground / PEOPLE SAFE HOLD NON-SMOKE

UPDATE ops.ingest_planner
SET
    next_run = '2099-01-01 00:00:00'::timestamp,
    updated_at = now()
WHERE entity IN ('players', 'coaches', 'player_stats', 'player_season_stats')
  AND status = 'pending'
  AND run_group NOT LIKE 'PEOPLE_SMOKE_TEST_%';