/*
MATCHMATRIX SQL 19_4_F
BK PEOPLE Standalone Routing Fix V1

CO TO JE:
- Přepne BK PEOPLE z GenericApiSportProvider na standalone people worker.

K ČEMU TO JE:
- Log potvrdil:
  api_sport/basketball existuje,
  ale entity players není podporována v GenericApiSportProvider.

KDE TO UVIDÍME:
- PC2 Command Center
- ops.ingest_planner
- PC2 Execution History

JAK SE TO VYUŽIJE:
- Staré BK players joby označíme jako routing_error.
- Vytvoříme nový pending job pro basketball_people_standalone.
- PC2 příkaz přepneme na standalone worker.
*/

UPDATE ops.ingest_planner
SET
    status = 'routing_error',
    updated_at = now()
WHERE run_group = 'PC2_PEOPLE_BK'
  AND sport_code = 'BK'
  AND entity = 'players'
  AND provider IN ('api_basketball', 'api_sport')
  AND status IN ('pending','error','failed','running');


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
    'basketball_people_standalone',
    'BK',
    'players',
    NULL,
    '2024',
    'PC2_PEOPLE_BK_STANDALONE',
    20,
    'pending',
    0,
    now(),
    now(),
    now()
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.ingest_planner
    WHERE provider = 'basketball_people_standalone'
      AND sport_code = 'BK'
      AND entity = 'players'
      AND season = '2024'
      AND run_group = 'PC2_PEOPLE_BK_STANDALONE'
      AND status = 'pending'
);


UPDATE ops.pc2_run_command_queue
SET
    command_text =
        'python workers/basketball/run_basketball_standalone_players_v1.py --season 2024 --run-group PC2_PEOPLE_BK_STANDALONE',
    run_status = 'READY_TO_RUN',
    last_result = 'BK PEOPLE rerouted to basketball standalone people worker.',
    updated_at = now()
WHERE id = 4;


SELECT
    id,
    provider,
    sport_code,
    entity,
    season,
    run_group,
    status,
    attempts,
    next_run
FROM ops.ingest_planner
WHERE sport_code = 'BK'
  AND entity = 'players'
ORDER BY id DESC;


SELECT
    id,
    sport_code,
    target_layer,
    run_status,
    command_text,
    last_result
FROM ops.pc2_run_command_queue
WHERE id = 4;