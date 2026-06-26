/*
MATCHMATRIX SQL 108_U
Scheduler Ready Governance V1

CO TO JE:
- Governance view pro scheduler intelligence.

K ČEMU TO JE:
- Scheduler uvidí:
  - co je READY
  - co je migration debt
  - co je planned
  - co je blocked

KDE TO UVIDÍME:
- ops.v_scheduler_ready_governance_v1
- panel V18+

JAK SE TO VYUŽIJE:
- autonomous orchestration
- scheduler filtering
- runtime prioritization
- migration governance
*/

CREATE OR REPLACE VIEW ops.v_scheduler_ready_governance_v1 AS

SELECT
    provider,
    sport_code,
    entity,

    orchestration_layer,

    flow_type,
    migration_state,

    runtime_ready,
    panel_ready,
    scheduler_ready,

    pull_worker,
    parse_worker,
    merge_worker,

    CASE
        WHEN scheduler_ready = true
         AND runtime_ready = true
         AND migration_state ILIKE 'OK%'
            THEN 'READY'

        WHEN migration_state ILIKE '%PLANNED%'
            THEN 'PLANNED'

        WHEN migration_state ILIKE '%MIGRATION%'
            THEN 'MIGRATION_DEBT'

        WHEN migration_state ILIKE '%MISSING%'
            THEN 'BLOCKED'

        ELSE 'REVIEW'
    END AS scheduler_state,

    CASE
        WHEN scheduler_ready = true
         AND runtime_ready = true
         AND migration_state ILIKE 'OK%'
            THEN 1

        WHEN migration_state ILIKE '%PLANNED%'
            THEN 5

        WHEN migration_state ILIKE '%MIGRATION%'
            THEN 8

        WHEN migration_state ILIKE '%MISSING%'
            THEN 9

        ELSE 99
    END AS scheduler_rank,

    updated_at

FROM ops.unified_worker_registry;