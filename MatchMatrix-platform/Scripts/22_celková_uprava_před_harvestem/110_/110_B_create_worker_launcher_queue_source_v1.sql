/*
MATCHMATRIX SQL 110_B Create Worker Launcher Queue Source V1

CO TO JE:
- Zdroj kandidátů pro autonomní launcher.

K ČEMU TO JE:
- AI OPS vybírá pouze bezpečné kandidáty.
- Připravuje akce do autonomous_execution_queue.

KDE TO UVIDÍME:
- AI OPS
- AUTONOMNÍ FRONTA
- WORKER LAUNCHER

JAK SE TO VYUŽIJE:
- Run Next kandidát
- kontrola bezpečnosti
- vložení do execution queue
- následné spuštění workeru
*/


CREATE OR REPLACE VIEW ops.v_worker_launcher_candidates_v1 AS
SELECT

    ROW_NUMBER() OVER (
        ORDER BY
            priority_score DESC,
            queue_position
    ) AS launcher_rank,

    provider,
    sport_code,
    entity,
    league_id,
    season,
    run_group,

    ai_decision,
    ai_risk_level,

    priority_score,

    ai_reason,

    CASE
        WHEN autonomous_safe = true
         AND ai_risk_level = 'NÍZKÉ'
        THEN true
        ELSE false
    END AS launcher_allowed,

    CASE
        WHEN autonomous_safe = true
         AND ai_risk_level = 'NÍZKÉ'
        THEN 'AUTONOMNÍ SPUŠTĚNÍ POVOLENO'

        WHEN autonomous_safe = true
        THEN 'POVOLENO PO SCHVÁLENÍ'

        ELSE 'BLOKOVÁNO'
    END AS launcher_state,

    generated_at

FROM ops.v_run_next_execution_candidate_v1;



CREATE OR REPLACE VIEW ops.v_worker_launcher_next_v1 AS
SELECT *
FROM ops.v_worker_launcher_candidates_v1
WHERE launcher_allowed = true
ORDER BY launcher_rank
LIMIT 1;



CREATE OR REPLACE VIEW ops.v_worker_launcher_summary_v1 AS
SELECT

    COUNT(*) AS total_candidates,

    COUNT(*) FILTER (
        WHERE launcher_allowed = true
    ) AS autonomous_ready,

    COUNT(*) FILTER (
        WHERE launcher_allowed = false
    ) AS blocked_candidates,

    now() AS generated_at

FROM ops.v_worker_launcher_candidates_v1;