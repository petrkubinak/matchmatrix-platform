/*
MATCHMATRIX SQL 108_F
AI OPS SUMMARY VIEW V1

CO TO JE:
- Realtime AI OPS dashboard summary.

K ČEMU TO JE:
- Panel zobrazí:
    - CRITICAL issues
    - SAFE RETRY tasks
    - AUTO FIXABLE tasks
    - BLOCKING tasks
    - MANUAL REVIEW tasks

KDE TO UVIDÍME:
- MATCHMATRIX OPERATIONS CENTER

JAK SE TO VYUŽIJE:
- autonomní scheduler
- AI OPS monitoring
- retry orchestrace
- production stability
*/

CREATE OR REPLACE VIEW ops.v_ai_ops_summary_v1 AS
SELECT

    COUNT(*) FILTER (
        WHERE ai_risk_level = 'CRITICAL'
    ) AS critical_count,

    COUNT(*) FILTER (
        WHERE ai_recommended_action = 'SAFE_RETRY'
    ) AS safe_retry_count,

    COUNT(*) FILTER (
        WHERE auto_fixable = true
    ) AS auto_fixable_count,

    COUNT(*) FILTER (
        WHERE blocks_scheduler = true
    ) AS blocking_count,

    COUNT(*) FILTER (
        WHERE ai_recommended_action = 'MANUAL_REVIEW'
    ) AS manual_review_count,

    ROUND(AVG(ai_ops_score), 2) AS avg_ai_ops_score

FROM ops.v_fix_task_ai_ops_v1
WHERE task_status = 'open';