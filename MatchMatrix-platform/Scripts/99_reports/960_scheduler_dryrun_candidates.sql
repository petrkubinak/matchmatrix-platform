-- 960_scheduler_dryrun_candidates.sql
-- Kandidáti pro první controlled scheduler cycle

SELECT
    provider,
    sport_code,
    entity,
    run_group,

    pending_cnt,
    running_cnt,
    done_cnt,
    error_cnt,

    active_accounts,
    max_plan_code,

    CASE
        WHEN pending_cnt > 0
             AND active_accounts > 0
             AND error_cnt = 0
        THEN 'RUN_READY'

        WHEN pending_cnt = 0
             AND done_cnt > 0
        THEN 'ALREADY_PROCESSED'

        WHEN pending_cnt = 0
             AND done_cnt = 0
        THEN 'EMPTY_QUEUE'

        ELSE 'REVIEW'
    END AS scheduler_decision,

    next_action

FROM ops.v_harvest_e2e_control

WHERE harvest_status = 'READY_AUTOMAT'

ORDER BY
    CASE
        WHEN pending_cnt > 0 THEN 1
        ELSE 2
    END,
    pending_cnt DESC,
    sport_code,
    entity;