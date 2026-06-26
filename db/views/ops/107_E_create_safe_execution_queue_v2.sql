/*
MATCHMATRIX SQL 107_E
Create safe execution queue V2

CO TO JE:
- Finální safe execution queue bez duplicit.
- Z každé kombinace sport + entity vybere nejlepší bezpečnou route podle routing_rank z v_automation_ready_queue_v4.

K ČEMU TO JE:
- Aby RUN NEXT nespouštěl duplicitní providery pro stejný sport/entity.
- Aby měl panel jeden jasný TOP kandidát.
- Aby fallback provider zůstal dostupný v DB, ale nešel jako první do RUN NEXT.

NA CO TO BUDE:
- SAFE RUN NEXT
- autonomous scheduler
- panel V17.1+
- retry/fallback governance

KDE TO POUŽIJEME:
- ops.v_safe_execution_queue_v2
- C:\MatchMatrix-platform\tools\matchmatrix_control_panel_V17_1.py
*/

CREATE OR REPLACE VIEW ops.v_safe_execution_queue_v2 AS
WITH ranked AS (
    SELECT
        q.sport_code,
        q.entity,
        q.candidate_provider,
        q.run_group,
        q.resolved_worker_script,
        q.worker_code,
        q.worker_name,
        q.layer_code,
        q.timeout_sec,
        q.max_attempts,
        q.worker_status,
        q.worker_can_run,
        q.worker_resolution_state,
        q.safe_to_execute,

        a.routing_rank,

        ROW_NUMBER() OVER (
            PARTITION BY q.sport_code, q.entity
            ORDER BY a.routing_rank ASC, q.candidate_provider ASC
        ) AS safe_rank

    FROM ops.v_safe_execution_queue_v1 q
    JOIN ops.v_automation_ready_queue_v4 a
      ON a.sport_code = q.sport_code
     AND a.entity = q.entity
     AND a.candidate_provider = q.candidate_provider
)
SELECT
    sport_code,
    entity,
    candidate_provider,
    run_group,
    resolved_worker_script,
    worker_code,
    worker_name,
    layer_code,
    timeout_sec,
    max_attempts,
    worker_status,
    worker_can_run,
    worker_resolution_state,
    safe_to_execute,
    routing_rank,
    safe_rank
FROM ranked
WHERE safe_rank = 1;