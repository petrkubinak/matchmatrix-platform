/*
===============================================================================
MATCHMATRIX SQL 109_A
CREATE AI OPS SUMMARY V1
===============================================================================

CO TO JE:
- Bridge view pro aktuální panel V17.9.14.

K ČEMU TO JE:
- Napojí nové AI OPS výpočty do existujících KPI v panelu.

KDE TO UVIDÍME:
- Horní KPI lišta v MatchMatrix Control Panelu.

JAK SE TO VYUŽIJE:
- AI CRITICAL
- SAFE RETRY
- AUTO FIX
- BLOCKING
- AI SCORE
===============================================================================
*/

CREATE OR REPLACE VIEW ops.v_ai_ops_summary_v1 AS

SELECT
    SUM(
        CASE
            WHEN er.provider_health_status = 'CRITICAL'
            THEN 1 ELSE 0
        END
    ) AS critical_count,

    SUM(
        CASE
            WHEN execution_decision = 'RUN_WITH_CAUTION'
            THEN 1 ELSE 0
        END
    ) AS safe_retry_count,

    SUM(
        CASE
            WHEN recommended_action IN ('MONITOR', 'NO_ACTION')
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

    (
        SELECT global_health_score
        FROM ops.v_ai_health_score
        LIMIT 1
    ) AS avg_ai_ops_score

FROM ops.v_execution_risk er
LEFT JOIN ops.v_provider_instability pi
    USING (provider);