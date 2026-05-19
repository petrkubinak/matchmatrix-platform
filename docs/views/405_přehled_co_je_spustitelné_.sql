--Tohle view ti dá:
--co je spustitelné hned
--co je jen na validaci
--co je jen na plán
--co je blokované
--co je kandidát pro PRO harvest

SELECT
    provider,
    sport_code,
    entity,
    coverage_status,
    runtime_status,
    pending_cnt,
    can_run_now,
    pro_harvest_candidate,
    queue_action,
    planner_priority_band,
    fetch_priority,
    provider_priority
FROM ops.v_run_ready_queue
LIMIT 100;