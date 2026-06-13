/*
MATCHMATRIX SQL 19_4_D
BK PEOPLE Planner Seeder V1

CO TO JE:
- Doplní BK PEOPLE planner job, protože panel našel EMPTY_RUN.

K ČEMU TO JE:
- BK command existuje, ale ops.ingest_planner neměl spustitelný pending job.

KDE TO UVIDÍME:
- PC2 Command Center
- ops.ingest_planner
- PC2 Execution Readiness Audit

JAK SE TO VYUŽIJE:
- BK PEOPLE se vrátí do READY_TO_RUN a bude možné ho z panelu znovu spustit.
*/

INSERT INTO ops.ingest_planner (
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run,
    created_at,
    updated_at
)
SELECT
    'api_basketball',
    'BK',
    'players',
    NULL,
    '2024',
    'PC2_PEOPLE_BK',
    20,
    'pending',
    0,
    now(),
    now(),
    now()
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_planner
    WHERE provider = 'api_basketball'
      AND sport_code = 'BK'
      AND entity = 'players'
      AND season = '2024'
      AND run_group = 'PC2_PEOPLE_BK'
      AND status = 'pending'
);

UPDATE ops.pc2_run_command_queue
SET
    run_status = 'READY_TO_RUN',
    last_result = 'BK PEOPLE planner job seeded after EMPTY_RUN.',
    updated_at = now()
WHERE id = 4;

SELECT
    provider,
    sport_code,
    entity,
    season,
    run_group,
    status,
    attempts,
    next_run
FROM ops.ingest_planner
WHERE run_group = 'PC2_PEOPLE_BK'
ORDER BY id DESC;

SELECT
    id,
    sport_code,
    target_layer,
    run_status,
    last_result
FROM ops.pc2_run_command_queue
WHERE id = 4;