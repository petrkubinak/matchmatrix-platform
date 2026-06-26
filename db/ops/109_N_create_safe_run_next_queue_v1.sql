/*
MATCHMATRIX SQL 109_N Create Safe Run Next Queue V1

CO TO JE:
- Bezpečná fronta pro tlačítko SPUSTIT DALŠÍ.

K ČEMU TO JE:
- Aby panel nespouštěl rizikové planner položky.
- Aby scheduler vybíral pouze bezpečné kandidáty.

KDE TO UVIDÍME:
- Panel V17.9+
- RUN NEXT
- AI OPS

JAK SE TO VYUŽIJE:
- Budoucí autonomní scheduler.
- Bezpečný RUN NEXT engine.
*/


CREATE OR REPLACE VIEW ops.v_safe_run_next_queue_v1 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            CASE
                WHEN empty_runs = 0 THEN 100
                WHEN empty_runs = 1 THEN 75
                ELSE 25
            END DESC,
            recommendation_rank
    ) AS queue_position,

    recommendation_rank,

    provider,
    sport_code,
    entity,
    league_id,
    season,
    run_group,

    ai_decision,
    ai_risk_level,
    ai_reason,

    autonomous_safe,

    CASE
        WHEN empty_runs = 0 THEN 100
        WHEN empty_runs = 1 THEN 75
        ELSE 25
    END AS priority_score,

    generated_at

FROM ops.v_panel_ai_recommendations_v1
WHERE autonomous_safe = true;

CREATE OR REPLACE VIEW ops.v_safe_run_next_summary_v1 AS
SELECT
    COUNT(*) AS runnable_count,

    COUNT(*) FILTER (
        WHERE ai_decision = 'SPUSTIT'
    ) AS run_now_count,

    COUNT(*) FILTER (
        WHERE ai_decision = 'OPATRNÝ RETRY'
    ) AS cautious_retry_count,

    MAX(priority_score) AS top_priority,

    now() AS generated_at

FROM ops.v_safe_run_next_queue_v1;