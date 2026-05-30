/*
MATCHMATRIX SQL 109_M Create AI Recommendation Bridge V1

CO TO JE:
- Jednoduchá AI doporučovací vrstva pro OPS panel.

K ČEMU TO JE:
- Aby panel ukázal, co je bezpečné spustit.
- Aby bylo vidět, co má počkat.
- Aby cooldown položky nešly hned znovu do běhu.

KDE TO UVIDÍME:
- MATCHMATRIX CONTROL PANEL V17.9+
- AI OPS
- FRONTA KE SPUŠTĚNÍ
- COOLDOWN PLÁNOVAČE

JAK SE TO VYUŽIJE:
- Bezpečné řízení scheduleru.
- Později autonomní run-next engine.
*/

CREATE OR REPLACE VIEW ops.v_panel_ai_recommendations_v1 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            p.empty_pct DESC,
            p.empty_runs DESC,
            p.target_rank
    ) AS recommendation_rank,

    p.provider,
    p.sport_code,
    p.entity,
    p.league_id,
    p.season,
    p.run_group,

    p.empty_runs,
    p.empty_pct,
    p.planner_target_state,
    p.suggested_retry_after,

    CASE
        WHEN p.empty_runs >= 3 THEN 'POZASTAVIT'
        WHEN p.empty_runs = 2 THEN 'POČKAT'
        WHEN p.empty_runs = 1 THEN 'OPATRNÝ RETRY'
        ELSE 'SPUSTIT'
    END AS ai_decision,

    CASE
        WHEN p.empty_runs >= 3 THEN 'VYSOKÉ'
        WHEN p.empty_runs = 2 THEN 'STŘEDNÍ'
        WHEN p.empty_runs = 1 THEN 'NÍZKÉ'
        ELSE 'MINIMÁLNÍ'
    END AS ai_risk_level,

    CASE
        WHEN p.empty_runs >= 3 THEN
            'Planner položka má 3 neúspěšné pokusy. Doporučeno pozastavit a ověřit providera nebo scope.'
        WHEN p.empty_runs = 2 THEN
            'Planner položka má 2 neúspěšné pokusy. Doporučeno počkat a nespouštět hned znovu.'
        WHEN p.empty_runs = 1 THEN
            'Planner položka má 1 neúspěšný pokus. Možný opatrný retry.'
        ELSE
            'Bez rizikového signálu.'
    END AS ai_reason,

    CASE
        WHEN p.empty_runs >= 3 THEN false
        WHEN p.empty_runs = 2 THEN false
        ELSE true
    END AS autonomous_safe,

    now() AS generated_at

FROM ops.v_panel_cooldowns_v1 p;


CREATE OR REPLACE VIEW ops.v_panel_ai_recommendations_summary_v1 AS
SELECT
    COUNT(*) AS total_recommendations,

    COUNT(*) FILTER (
        WHERE ai_decision = 'SPUSTIT'
    ) AS run_count,

    COUNT(*) FILTER (
        WHERE ai_decision = 'OPATRNÝ RETRY'
    ) AS cautious_retry_count,

    COUNT(*) FILTER (
        WHERE ai_decision = 'POČKAT'
    ) AS wait_count,

    COUNT(*) FILTER (
        WHERE ai_decision = 'POZASTAVIT'
    ) AS hold_count,

    COUNT(*) FILTER (
        WHERE autonomous_safe = true
    ) AS autonomous_safe_count,

    COUNT(*) FILTER (
        WHERE autonomous_safe = false
    ) AS blocked_count,

    now() AS generated_at

FROM ops.v_panel_ai_recommendations_v1;