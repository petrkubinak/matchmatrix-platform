/*
MATCHMATRIX SQL 109_O Create AI OPS Dashboard Panel V1

CO TO JE:
- Finální přehled AI OPS doporučení pro panel.

K ČEMU TO JE:
- Oddělí bezpečné, opatrné, čekající a blokované položky.

KDE TO UVIDÍME:
- Panel V17.9+
- AI OPS
- RUN NEXT / SPUSTIT DALŠÍ

JAK SE TO VYUŽIJE:
- Panel V18 z toho bude číst hlavní doporučení.
*/

CREATE OR REPLACE VIEW ops.v_ai_ops_dashboard_panel_v1 AS
SELECT
    recommendation_rank,
    provider,
    sport_code,
    entity,
    league_id,
    season,
    run_group,
    ai_decision,
    ai_risk_level,
    autonomous_safe,
    ai_reason,
    suggested_retry_after,
    generated_at,

    CASE
        WHEN ai_decision = 'SPUSTIT' THEN 'AI DOPORUČUJE SPUSTIT'
        WHEN ai_decision = 'OPATRNÝ RETRY' THEN 'AI DOPORUČUJE OPATRNÝ RETRY'
        WHEN ai_decision = 'POČKAT' THEN 'AI DOPORUČUJE POČKAT'
        WHEN ai_decision = 'POZASTAVIT' THEN 'AI DOPORUČUJE POZASTAVIT'
        ELSE 'AI BEZ DOPORUČENÍ'
    END AS panel_recommendation,

    CASE
        WHEN autonomous_safe = true THEN 'BEZPEČNÉ'
        ELSE 'BLOKOVANÉ'
    END AS panel_safety_state

FROM ops.v_panel_ai_recommendations_v1;


CREATE OR REPLACE VIEW ops.v_ai_ops_dashboard_panel_summary_v1 AS
SELECT
    COUNT(*) AS total_items,

    COUNT(*) FILTER (
        WHERE panel_safety_state = 'BEZPEČNÉ'
    ) AS safe_items,

    COUNT(*) FILTER (
        WHERE panel_safety_state = 'BLOKOVANÉ'
    ) AS blocked_items,

    COUNT(*) FILTER (
        WHERE ai_decision = 'SPUSTIT'
    ) AS run_items,

    COUNT(*) FILTER (
        WHERE ai_decision = 'OPATRNÝ RETRY'
    ) AS cautious_retry_items,

    COUNT(*) FILTER (
        WHERE ai_decision = 'POČKAT'
    ) AS wait_items,

    COUNT(*) FILTER (
        WHERE ai_decision = 'POZASTAVIT'
    ) AS hold_items,

    now() AS generated_at

FROM ops.v_ai_ops_dashboard_panel_v1;