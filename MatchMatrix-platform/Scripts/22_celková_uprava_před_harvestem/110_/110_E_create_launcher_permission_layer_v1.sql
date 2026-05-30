/*
MATCHMATRIX SQL 110_E Create Launcher Permission Layer V1

CO TO JE:
- Bezpečnostní vrstva launcheru.

K ČEMU TO JE:
- Rozhoduje, zda smí být akce spuštěna.
- Centralizuje pravidla před spuštěním workeru.

KDE TO UVIDÍME:
- AI OPS
- AUTONOMNÍ FRONTA
- LAUNCHER

JAK SE TO VYUŽIJE:
- Launcher čte pouze tuto vrstvu.
- Pokud can_launch = true, akce smí být spuštěna.
*/


CREATE OR REPLACE VIEW ops.v_launcher_permission_v1 AS
SELECT

    q.id AS queue_id,

    q.action_type,

    q.provider,
    q.sport_code,
    q.entity,

    q.provider_league_id AS league_id,

    q.season,
    q.run_group,

    q.priority_score,
    q.risk_level,

    q.execution_status,

    CASE

        WHEN q.execution_status <> 'PENDING'
        THEN false

        WHEN q.risk_level IN ('VYSOKÉ','HIGH')
        THEN false

        ELSE true

    END AS can_launch,

    CASE

        WHEN q.execution_status <> 'PENDING'
        THEN 'AKCE NENÍ VE STAVU PENDING'

        WHEN q.risk_level IN ('VYSOKÉ','HIGH')
        THEN 'RIZIKO JE PŘÍLIŠ VYSOKÉ'

        ELSE 'SPUŠTĚNÍ POVOLENO'

    END AS launch_reason_cz,

    CASE

        WHEN q.execution_status <> 'PENDING'
        THEN 'BLOCKED'

        WHEN q.risk_level IN ('VYSOKÉ','HIGH')
        THEN 'BLOCKED'

        ELSE 'READY'

    END AS launcher_state,

    q.created_at

FROM ops.autonomous_execution_queue q
ORDER BY
    q.priority_score DESC,
    q.created_at ASC;



CREATE OR REPLACE VIEW ops.v_launcher_next_action_v1 AS
SELECT *
FROM ops.v_launcher_permission_v1
WHERE can_launch = true
ORDER BY
    priority_score DESC,
    created_at ASC
LIMIT 1;



CREATE OR REPLACE VIEW ops.v_launcher_permission_summary_v1 AS
SELECT

    COUNT(*) AS total_actions,

    COUNT(*) FILTER (
        WHERE can_launch = true
    ) AS ready_to_launch,

    COUNT(*) FILTER (
        WHERE can_launch = false
    ) AS blocked_actions,

    now() AS generated_at

FROM ops.v_launcher_permission_v1;