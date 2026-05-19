-- 99_playground / PEOPLE SMOKE TEST MULTI-SPORT SETUP

UPDATE ops.ingest_planner p
SET
    run_group = 'PEOPLE_SMOKE_TEST_' || p.sport_code || '_2024',
    next_run = NULL,
    updated_at = now()
WHERE p.id IN (
    SELECT id
    FROM (
        SELECT id,
               sport_code,
               ROW_NUMBER() OVER (PARTITION BY sport_code ORDER BY id) AS rn
        FROM ops.ingest_planner
        WHERE entity = 'players'
          AND status = 'pending'
          AND season = '2024'
          AND provider IN (
              'api_football',
              'api_hockey',
              'api_handball',
              'api_volleyball',
              'api_baseball',
              'api_rugby',
              'api_cricket',
              'api_american_football'
          )
    ) x
    WHERE rn = 1
);