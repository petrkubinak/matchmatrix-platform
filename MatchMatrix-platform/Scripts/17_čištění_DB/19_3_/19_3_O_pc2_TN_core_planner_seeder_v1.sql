/*
MATCHMATRIX SQL 19_3_O
PC2 TN Core Planner Seeder V1

CO TO JE:
- Doplní TN CORE planner joby podle ops.ingest_targets.
- Použije konkrétní provider_league_id: ATP / WTA.

K ČEMU TO JE:
- TN CORE nesmí běžet bez LeagueId.
- Předchozí placeholder joby bez ligy způsobily chybu.

KDE TO UVIDÍME:
- PC2 Command Center
- PC2 Execution Readiness Audit
- ops.ingest_planner

JAK SE TO VYUŽIJE:
- TN CORE přejde z PLANNER_JOB_MISSING na READY_TO_RUN.
*/

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
SELECT
    t.provider,
    t.sport_code,
    'fixtures' AS entity,
    t.provider_league_id,
    t.season,
    'PC2_CORE_TN' AS run_group,
    CASE
        WHEN t.tier = 1 THEN 10
        WHEN t.tier = 2 THEN 20
        ELSE 30
    END AS priority,
    'pending' AS status,
    0 AS attempts,
    now() AS next_run,
    now() AS created_at,
    now() AS updated_at
FROM ops.ingest_targets t
WHERE t.sport_code = 'TN'
  AND t.enabled = true
  AND t.provider_league_id IS NOT NULL
  AND t.provider_league_id <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner p
      WHERE p.provider = t.provider
        AND p.sport_code = t.sport_code
        AND p.entity = 'fixtures'
        AND p.provider_league_id = t.provider_league_id
        AND p.season = t.season
        AND p.run_group = 'PC2_CORE_TN'
  );


UPDATE ops.pc2_run_command_queue
SET
    run_status = 'READY_TO_RUN',
    last_started_at = NULL,
    last_finished_at = NULL,
    last_result = 'TN CORE seeded from ops.ingest_targets ATP/WTA.',
    updated_at = now()
WHERE sport_code = 'TN'
  AND target_layer = 'CORE'
  AND run_group = '19_3_PC2_DEPENDENCY_QUEUE';


SELECT
    command_id,
    sport_code,
    target_layer,
    run_status,
    provider,
    entity,
    planner_jobs,
    pending_jobs,
    execution_readiness_status,
    next_fix_action
FROM ops.v_pc2_orchestration_panel_v1
WHERE sport_code = 'TN';