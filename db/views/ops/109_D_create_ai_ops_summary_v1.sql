/*
===============================================================================
MATCHMATRIX SQL 109_D
UPDATE AI OPS SUMMARY V1 TO FULL RISK
===============================================================================

CO TO JE:
- Přepočítává horní AI KPI z kompletního provider registry.

K ČEMU TO JE:
- Aby AI CRITICAL, SAFE RETRY, AUTO FIX, BLOCKING a AI SCORE odpovídaly full providerům.

KDE TO UVIDÍME:
- Horní KPI lišta v MatchMatrix Control Panelu.

JAK SE TO VYUŽIJE:
- AI OPS Health
- Risk Engine
- Scheduler Autopilot
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_ai_ops_summary_v1 AS

SELECT
    SUM(
        CASE
            WHEN execution_decision = 'BLOCK'
            THEN 1 ELSE 0
        END
    ) AS critical_count,

    SUM(
        CASE
            WHEN execution_decision IN ('RUN_WITH_CAUTION', 'SMOKE_TEST')
            THEN 1 ELSE 0
        END
    ) AS safe_retry_count,

    SUM(
        CASE
            WHEN execution_decision IN ('RUN_SAFE', 'SMOKE_TEST', 'PLANNED_ONLY')
            THEN 1 ELSE 0
        END
    ) AS auto_fixable_count,

    SUM(
        CASE
            WHEN execution_decision = 'BLOCK'
            THEN 1 ELSE 0
        END
    ) AS blocking_count,

    SUM(
        CASE
            WHEN execution_decision IN ('WAIT', 'REVIEW')
            THEN 1 ELSE 0
        END
    ) AS manual_review_count,

    ROUND(AVG(provider_health_score), 0) AS avg_ai_ops_score

FROM ops.v_execution_risk_full;