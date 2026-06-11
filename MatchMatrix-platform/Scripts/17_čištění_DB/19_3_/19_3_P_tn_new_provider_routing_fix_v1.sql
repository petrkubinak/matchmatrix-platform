/*
MATCHMATRIX SQL 19_3_P
TN New Provider Routing Fix V1

CO TO JE:
- Přepne TN CORE z chybného GenericApiSportProvider/API-Sport routingu
  na samostatný tennis provider režim.

K ČEMU TO JE:
- TN nesmí běžet přes pull_api_sport_fixtures.ps1.
- Log potvrdil: "Pro TN použij samostatný tennis provider."

KDE TO UVIDÍME:
- PC2 Command Center
- PC2 Execution Readiness
- ops.ingest_planner

JAK SE TO VYUŽIJE:
- Staré TN joby se označí jako routing_error.
- Vytvoří se nové TN joby pro samostatný tennis provider.
- PC2 fronta se vrátí do READY_TO_RUN.
*/

-- 1) Označit špatně naroutované TN joby
UPDATE ops.ingest_planner
SET
    status = 'routing_error',
    updated_at = now()
WHERE run_group = 'PC2_CORE_TN'
  AND sport_code = 'TN'
  AND provider = 'api_tennis'
  AND entity = 'fixtures'
  AND status IN ('pending','error','failed','running');


-- 2) Vložit nové TN joby přes samostatný tennis provider
INSERT INTO ops.ingest_planner
(
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
VALUES
(
    'tennis_standalone',
    'TN',
    'fixtures',
    'ATP',
    '2024',
    'PC2_CORE_TN_STANDALONE',
    10,
    'pending',
    0,
    now(),
    now(),
    now()
),
(
    'tennis_standalone',
    'TN',
    'fixtures',
    'WTA',
    '2024',
    'PC2_CORE_TN_STANDALONE',
    10,
    'pending',
    0,
    now(),
    now(),
    now()
)
ON CONFLICT DO NOTHING;


-- 3) Přepsat PC2 příkaz na samostatný tennis worker
UPDATE ops.pc2_run_command_queue
SET
    command_text =
        'python workers/tennis/run_tennis_standalone_fixtures_v1.py --season 2024 --run-group PC2_CORE_TN_STANDALONE',
    run_status = 'READY_TO_RUN',
    last_started_at = NULL,
    last_finished_at = NULL,
    last_result = 'TN CORE rerouted to standalone tennis provider worker.',
    updated_at = now()
WHERE sport_code = 'TN'
  AND target_layer = 'CORE'
  AND run_group = '19_3_PC2_DEPENDENCY_QUEUE';


-- 4) Kontrola
SELECT
    id,
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status
FROM ops.ingest_planner
WHERE sport_code = 'TN'
  AND run_group LIKE 'PC2_CORE_TN%'
ORDER BY id;


SELECT
    id,
    sport_code,
    target_layer,
    run_status,
    command_text,
    last_result
FROM ops.pc2_run_command_queue
WHERE sport_code = 'TN'
  AND target_layer = 'CORE';