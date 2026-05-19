-- 99_playground / PEOPLE READY QUEUE CHECK

SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    status,
    next_run,
    CASE
        WHEN status = 'pending'
         AND (next_run IS NULL OR next_run <= now())
        THEN true
        ELSE false
    END AS ready_now
FROM ops.ingest_planner
WHERE entity IN ('players', 'coaches', 'player_stats', 'player_season_stats')
  AND status = 'pending'
ORDER BY ready_now DESC, sport_code, run_group, id
LIMIT 100;