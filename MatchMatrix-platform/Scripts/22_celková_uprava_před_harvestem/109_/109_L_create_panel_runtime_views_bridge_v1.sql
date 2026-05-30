/*
MATCHMATRIX SQL 109_L Create Panel Runtime Views Bridge V1

CO TO JE:
- Přemosťovací vrstva mezi OPS runtime monitoringem a panelem.

K ČEMU TO JE:
- Aby panel nemusel číst přímo technické tabulky.
- Aby měl jednoduché view pro zobrazení aktivních běhů.
- Aby měl jednoduché view pro cooldown doporučení.

KDE TO UVIDÍME:
- MATCHMATRIX CONTROL PANEL V17.9+
- AKTIVNÍ BĚHY
- COOLDOWN PLÁNOVAČE

JAK SE TO VYUŽIJE:
- Runtime monitoring
- Autonomous Scheduler
- AI OPS doporučení
*/


CREATE OR REPLACE VIEW ops.v_panel_active_runs_v1 AS
SELECT
    lock_name,
    owner_id,
    live_state,
    live_color,
    running_seconds,
    heartbeat_age_seconds,
    seconds_to_expire,
    acquired_at,
    heartbeat_at,
    expires_at,
    note
FROM ops.v_active_runs_live_v2
ORDER BY acquired_at DESC;


CREATE OR REPLACE VIEW ops.v_panel_cooldowns_v1 AS
SELECT
    target_rank,
    provider,
    sport_code,
    entity,
    league_id,
    season,
    run_group,
    planner_target_state,
    empty_runs,
    empty_pct,
    suggested_retry_after,
    suggested_action
FROM ops.v_planner_cooldown_candidates_v2
ORDER BY target_rank;


CREATE OR REPLACE VIEW ops.v_panel_runtime_summary_v1 AS
SELECT

    COUNT(*) FILTER (
        WHERE live_state = 'RUNNING'
    ) AS active_workers,

    COUNT(*) FILTER (
        WHERE live_state = 'EXPIRED'
    ) AS expired_workers,

    COUNT(*) FILTER (
        WHERE live_state = 'STALE'
    ) AS stale_workers,

    (
        SELECT COUNT(*)
        FROM ops.v_panel_cooldowns_v1
    ) AS cooldown_targets,

    now() AS generated_at

FROM ops.v_panel_active_runs_v1;