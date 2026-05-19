-- 99_playground / PEOPLE SMOKE TEST FB 2024

UPDATE ops.ingest_planner
SET
    run_group = 'PEOPLE_SMOKE_TEST_FB_2024',
    next_run = now(),
    updated_at = now()
WHERE id IN (
    SELECT id
    FROM ops.ingest_planner
    WHERE provider = 'api_football'
      AND sport_code = 'FB'
      AND entity = 'players'
      AND season = '2024'
      AND status = 'pending'
    LIMIT 2
);

SELECT
    run_group,
    status,
    COUNT(*) AS jobs,
    COUNT(*) FILTER (WHERE next_run IS NOT NULL) AS runnable_now
FROM ops.ingest_planner
WHERE run_group = 'PEOPLE_SMOKE_TEST_FB_2024'
GROUP BY run_group, status;

-- C:\Python314\python.exe C:\MatchMatrix-platform\workers\run_players_pipeline_transitional_v1.py

