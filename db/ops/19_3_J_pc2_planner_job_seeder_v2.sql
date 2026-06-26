/*
MATCHMATRIX SQL 19_3_J
PC2 Planner Job Seeder V2 - FIXED

CO TO JE:
- Opravuje PC2 CORE joby tak, aby používaly konkrétní provider_league_id.
- Ruší špatné placeholder joby bez ligy.

K ČEMU TO JE:
- Fixtures harvest nesmí běžet s provider_league_id NULL.
- Worker potřebuje konkrétní ligu.

KDE TO UVIDÍME:
- PC2 Command Center
- ops.ingest_planner
- ops.v_ingest_planner_queue

JAK SE TO VYUŽIJE:
- PC2 RUN pro HB najde konkrétní ligové joby.
*/

-- 1) Zneplatnit chybné placeholder joby bez ligy
UPDATE ops.ingest_planner
SET
    status = 'cancelled',
    updated_at = now()
WHERE run_group IN ('PC2_CORE_HB', 'PC2_CORE_TN')
  AND entity = 'fixtures'
  AND provider_league_id IS NULL
  AND status IN ('pending', 'error', 'failed');


-- 2) Vložit HB CORE joby podle ingest_targets
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
    'PC2_CORE_HB' AS run_group,
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
WHERE t.sport_code = 'HB'
  AND t.enabled = true
  AND t.provider_league_id IS NOT NULL
  AND t.season = '2024'
  AND t.tier IN (1,2)
  AND NOT EXISTS (
      SELECT 1
      FROM ops.ingest_planner p
      WHERE p.provider = t.provider
        AND p.sport_code = t.sport_code
        AND p.entity = 'fixtures'
        AND p.provider_league_id = t.provider_league_id
        AND p.season = t.season
        AND p.run_group = 'PC2_CORE_HB'
  );


-- 3) TN zatím označit v PC2 frontě jako BLOCKED, protože nemá ingest_targets
UPDATE ops.pc2_run_command_queue
SET
    run_status = 'BLOCKED',
    last_result = 'TN CORE blocked: missing ops.ingest_targets provider_league_id rows.',
    updated_at = now()
WHERE sport_code = 'TN'
  AND target_layer = 'CORE'
  AND run_group = '19_3_PC2_DEPENDENCY_QUEUE';


-- 4) Kontrola
SELECT
    provider,
    sport_code,
    entity,
    provider_league_id,
    season,
    run_group,
    priority,
    status,
    attempts,
    next_run
FROM ops.ingest_planner
WHERE run_group IN ('PC2_CORE_HB', 'PC2_CORE_TN')
ORDER BY
    sport_code,
    priority,
    provider_league_id::int NULLS LAST;