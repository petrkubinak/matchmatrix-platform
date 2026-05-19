-- 900_harvest_e2e_current_status.sql
-- Aktuální přehled, co je připravené pro harvest / planner / people / odds

SELECT
    provider,
    sport_code,
    entity,
    run_group,
    harvest_status,
    coverage_status,
    entity_plan_enabled,
    coverage_enabled,
    targets_enabled,
    pending_cnt,
    running_cnt,
    done_cnt,
    error_cnt,
    active_accounts,
    max_plan_code,
    worker_script,
    next_action
FROM ops.v_harvest_e2e_control
ORDER BY
    harvest_rank NULLS LAST,
    sport_code,
    entity,
    provider;