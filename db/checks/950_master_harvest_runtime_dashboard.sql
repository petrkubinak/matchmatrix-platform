-- 950_master_harvest_runtime_dashboard.sql
-- MASTER HARVEST RUNTIME DASHBOARD
-- Hlavní operační přehled harvest-ready sportů/providerů

SELECT
    provider,
    sport_code,
    entity,
    run_group,

    harvest_status,
    coverage_status,

    active_accounts,
    max_plan_code,

    pending_cnt,
    running_cnt,
    done_cnt,
    error_cnt,

    targets_enabled,

    next_action

FROM ops.v_harvest_e2e_control

WHERE harvest_status IN (
    'READY_AUTOMAT',
    'READY_VALIDATE',
    'REVIEW_ERROR',
    'HOLD'
)

ORDER BY
    CASE harvest_status
        WHEN 'REVIEW_ERROR' THEN 1
        WHEN 'READY_VALIDATE' THEN 2
        WHEN 'READY_AUTOMAT' THEN 3
        WHEN 'HOLD' THEN 4
        ELSE 99
    END,
    sport_code,
    entity,
    provider;