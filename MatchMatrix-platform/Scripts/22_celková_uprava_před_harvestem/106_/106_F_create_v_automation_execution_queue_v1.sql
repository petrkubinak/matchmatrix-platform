/*
MATCHMATRIX SQL 106_F
Create automation execution queue view V1

CO TO JE:
- Centrální automation execution queue pro MatchMatrix.
- Spojuje provider routing, planner, runtime audit a worker locks.
- Nevytváří tabulku, pouze VIEW.

K ČEMU TO JE:
- Aby V16 panel a budoucí scheduler věděly:
  co lze spustit,
  co je blokované,
  co čeká,
  co má fallback,
  co není automation-ready.

NA CO TO BUDE:
- V16 CONTROL PANEL
- scheduler/autopilot
- retry/fallback rozhodování
- monitoring providerů

KDE TO POUŽIJEME:
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V16.py
- budoucí automation runner
- DBeaver audit
*/

CREATE OR REPLACE VIEW ops.v_automation_execution_queue AS
WITH routing AS (
    SELECT
        sport_code,
        entity,
        primary_provider,
        primary_status,
        primary_runtime_status,
        primary_is_ready,
        fallback_provider,
        fallback_status,
        fallback_runtime_status,
        fallback_is_ready,
        blocked_providers,
        routing_status,
        automation_ready,
        routing_next_action
    FROM ops.v_provider_routing_master
),
planner AS (
    SELECT
        provider,
        sport_code,
        entity,
        run_group,
        priority,
        status AS planner_status,
        attempts,
        last_attempt,
        next_run,
        is_ready_now
    FROM ops.v_ingest_planner_queue
),
runtime AS (
    SELECT
        provider,
        sport_code,
        entity,
        current_state,
        state_reason,
        last_run_group,
        last_run_at,
        last_check_at,
        last_log_summary,
        db_evidence_summary,
        next_action AS runtime_next_action
    FROM ops.runtime_entity_audit
),
harvest AS (
    SELECT
        provider,
        sport_code,
        entity,
        worker_script,
        source_endpoint,
        target_table,
        active_worker_locks
    FROM ops.v_harvest_e2e_control
),
locks AS (
    SELECT
        lock_name,
        owner_id,
        acquired_at,
        expires_at,
        heartbeat_at,
        note
    FROM ops.worker_locks
),
joined AS (
    SELECT
        r.sport_code,
        r.entity,

        r.primary_provider,
        r.primary_status,
        r.primary_runtime_status,
        r.primary_is_ready,

        r.fallback_provider,
        r.fallback_status,
        r.fallback_runtime_status,
        r.fallback_is_ready,

        r.blocked_providers,
        r.routing_status,
        r.automation_ready,
        r.routing_next_action,

        p.run_group,
        p.priority,
        p.planner_status,
        p.attempts,
        p.last_attempt,
        p.next_run,
        p.is_ready_now,

        rt.current_state,
        rt.state_reason,
        rt.last_run_group,
        rt.last_run_at,
        rt.last_check_at,
        rt.last_log_summary,
        rt.db_evidence_summary,
        rt.runtime_next_action,

        h.worker_script,
        h.source_endpoint,
        h.target_table,
        h.active_worker_locks,

        CASE
            WHEN l.lock_name IS NOT NULL THEN true
            ELSE false
        END AS is_locked

    FROM routing r
    LEFT JOIN planner p
           ON p.provider = r.primary_provider
          AND p.sport_code = r.sport_code
          AND p.entity = r.entity
    LEFT JOIN runtime rt
           ON rt.provider = r.primary_provider
          AND rt.sport_code = r.sport_code
          AND rt.entity = r.entity
    LEFT JOIN harvest h
           ON h.provider = r.primary_provider
          AND h.sport_code = r.sport_code
          AND h.entity = r.entity
    LEFT JOIN locks l
           ON LOWER(l.lock_name) LIKE '%' || LOWER(r.sport_code) || '%'
)
SELECT
    sport_code,
    entity,

    primary_provider,
    primary_status,
    primary_runtime_status,
    primary_is_ready,

    fallback_provider,
    fallback_status,
    fallback_runtime_status,
    fallback_is_ready,

    blocked_providers,
    routing_status,
    automation_ready,

    run_group,
    priority,
    planner_status,
    attempts,
    last_attempt,
    next_run,
    is_ready_now,

    current_state,
    state_reason,
    last_run_group,
    last_run_at,
    last_check_at,

    worker_script,
    source_endpoint,
    target_table,

    active_worker_locks,
    is_locked,

    CASE
        WHEN is_locked = true
            THEN 'BLOCKED_LOCK'

        WHEN LOWER(COALESCE(primary_status, '')) LIKE '%blocked%'
            THEN 'BLOCKED_PROVIDER'

        WHEN automation_ready = false
            THEN 'NOT_AUTOMATION_READY'

        WHEN planner_status IN ('paused', 'disabled', 'blocked')
            THEN 'PLANNER_BLOCKED'

        WHEN next_run IS NOT NULL
             AND next_run > NOW()
            THEN 'WAITING_NEXT_RUN'

        WHEN current_state IN ('ERROR', 'error', 'FAILED', 'failed')
             AND fallback_provider IS NOT NULL
            THEN 'FAILOVER_READY'

        WHEN primary_is_ready = true
             AND COALESCE(is_ready_now, true) = true
            THEN 'CAN_RUN_NOW'

        WHEN primary_is_ready = true
            THEN 'WAITING_PLANNER'

        ELSE 'WAITING_RUNTIME'
    END AS execution_state,

    CASE
        WHEN is_locked = true
            THEN 'Worker lock je aktivní.'

        WHEN LOWER(COALESCE(primary_status, '')) LIKE '%blocked%'
            THEN 'Primary provider je blokovaný.'

        WHEN automation_ready = false
            THEN 'Routing není připraven pro automation.'

        WHEN planner_status IN ('paused', 'disabled', 'blocked')
            THEN 'Planner job je pozastaven nebo blokován.'

        WHEN next_run IS NOT NULL
             AND next_run > NOW()
            THEN 'Čeká na naplánovaný další běh.'

        WHEN current_state IN ('ERROR', 'error', 'FAILED', 'failed')
             AND fallback_provider IS NOT NULL
            THEN 'Možný failover na fallback providera.'

        WHEN primary_is_ready = true
             AND COALESCE(is_ready_now, true) = true
            THEN 'Připraveno ke spuštění.'

        ELSE COALESCE(runtime_next_action, routing_next_action, 'Čeká na runtime/planner stav.')
    END AS execution_reason

FROM joined
ORDER BY
    CASE
        WHEN primary_is_ready = true AND automation_ready = true THEN 1
        WHEN automation_ready = true THEN 2
        ELSE 3
    END,
    sport_code,
    entity;