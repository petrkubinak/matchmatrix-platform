/*
MATCHMATRIX SQL 109_P Create Run Next Execution Queue V1

CO TO JE:
- Finální fronta pro tlačítko SPUSTIT DALŠÍ.

K ČEMU TO JE:
- Vrací pouze položky, které AI označila jako bezpečné.
- Připravuje podklad pro autonomní scheduler.

KDE TO UVIDÍME:
- Panel V18
- RUN NEXT
- AI OPS

JAK SE TO VYUŽIJE:
- Jedním kliknutím vybere další vhodný job.
- Později bude používáno schedulerem bez zásahu uživatele.
*/


CREATE OR REPLACE VIEW ops.v_run_next_execution_queue_v1 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            priority_score DESC,
            recommendation_rank
    ) AS queue_position,

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

    autonomous_safe,

    generated_at

FROM ops.v_safe_run_next_queue_v1
WHERE autonomous_safe = true;


CREATE OR REPLACE VIEW ops.v_run_next_execution_candidate_v1 AS
SELECT *
FROM ops.v_run_next_execution_queue_v1
ORDER BY
    queue_position
LIMIT 1;


CREATE OR REPLACE VIEW ops.v_run_next_execution_summary_v1 AS
SELECT
    COUNT(*) AS queue_size,

    MAX(priority_score) AS highest_priority,

    COUNT(*) FILTER (
        WHERE ai_decision = 'OPATRNÝ RETRY'
    ) AS cautious_retry_count,

    COUNT(*) FILTER (
        WHERE ai_decision = 'SPUSTIT'
    ) AS direct_run_count,

    now() AS generated_at

FROM ops.v_run_next_execution_queue_v1;