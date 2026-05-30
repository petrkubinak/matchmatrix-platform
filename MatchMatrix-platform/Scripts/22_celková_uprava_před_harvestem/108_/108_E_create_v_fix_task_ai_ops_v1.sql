/*
MATCHMATRIX SQL 108_E
CREATE FIX TASK AI OPS VIEW V1

CO TO JE:
- AI OPS pohled nad fix tasky.

K ČEMU TO JE:
- Panel dostane:
    - AI score
    - risk level
    - retry recommendation
    - scheduler impact

KDE TO UVIDÍME:
- FIX TASKS
- Scheduler
- AI OPS CENTER

JAK SE TO VYUŽIJE:
- autonomní orchestrace
- retry engine
- safe execution
- production monitoring
*/

CREATE OR REPLACE VIEW ops.v_fix_task_ai_ops_v1 AS
SELECT

    ft.id,
    ft.created_at,
    ft.provider,
    ft.sport_code,
    ft.entity_type,
    ft.endpoint_name,
    ft.parse_status,
    ft.severity,
    ft.issue_type,
    ft.auto_review_status,
    ft.auto_fixable,
    ft.safe_retry,
    ft.blocks_scheduler,
    ft.review_confidence,
    ft.priority_level,
    ft.priority_score,
    ft.task_status,

    CASE

        WHEN ft.blocks_scheduler = true
            THEN 'CRITICAL'

        WHEN ft.priority_level = 'HIGH'
            THEN 'HIGH'

        WHEN ft.priority_level = 'MEDIUM'
            THEN 'MEDIUM'

        ELSE 'LOW'

    END AS ai_risk_level,

    CASE

        WHEN ft.safe_retry = true
            THEN 'SAFE_RETRY'

        WHEN ft.auto_fixable = true
            THEN 'AUTO_FIX'

        WHEN ft.blocks_scheduler = true
            THEN 'BLOCK_EXECUTION'

        ELSE 'MANUAL_REVIEW'

    END AS ai_recommended_action,

    CASE

        WHEN ft.blocks_scheduler = true
            THEN 100

        WHEN ft.priority_level = 'HIGH'
            THEN 90

        WHEN ft.priority_level = 'MEDIUM'
            THEN 70

        WHEN ft.priority_level = 'LOW'
            THEN 40

        ELSE 20

    END AS ai_ops_score

FROM ops.fix_tasks ft;