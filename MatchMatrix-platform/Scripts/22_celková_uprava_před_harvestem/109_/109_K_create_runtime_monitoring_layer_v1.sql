/*
MATCHMATRIX SQL 109_K Runtime Monitoring Layer V1
OPRAVA 2:
- Nepřepisuje existující view ops.v_active_runs_live_v1.
- Vytváří nové bezpečné view pro další napojení panelu.
*/

CREATE OR REPLACE VIEW ops.v_active_runs_live_v2 AS
SELECT
    wl.lock_name,
    wl.owner_id,
    wl.acquired_at,
    wl.heartbeat_at,
    wl.expires_at,

    EXTRACT(EPOCH FROM (now() - wl.acquired_at))::integer AS running_seconds,
    EXTRACT(EPOCH FROM (now() - wl.heartbeat_at))::integer AS heartbeat_age_seconds,
    EXTRACT(EPOCH FROM (wl.expires_at - now()))::integer AS seconds_to_expire,

    CASE
        WHEN wl.expires_at IS NULL THEN 'UNKNOWN'
        WHEN wl.expires_at < now() THEN 'EXPIRED'
        WHEN wl.heartbeat_at IS NULL THEN 'NO_HEARTBEAT'
        WHEN wl.heartbeat_at < now() - interval '5 minutes' THEN 'STALE'
        ELSE 'RUNNING'
    END AS live_state,

    CASE
        WHEN wl.expires_at IS NULL THEN 'YELLOW'
        WHEN wl.expires_at < now() THEN 'RED'
        WHEN wl.heartbeat_at IS NULL THEN 'YELLOW'
        WHEN wl.heartbeat_at < now() - interval '5 minutes' THEN 'YELLOW'
        ELSE 'GREEN'
    END AS live_color,

    wl.note,
    wl.created_at,
    wl.updated_at,

    CASE
        WHEN wl.expires_at IS NOT NULL
         AND wl.expires_at >= now()
        THEN true
        ELSE false
    END AS is_active

FROM ops.worker_locks wl;


CREATE OR REPLACE VIEW ops.v_planner_cooldown_candidates_v2 AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            ip.attempts DESC,
            ip.last_attempt DESC NULLS LAST
    ) AS target_rank,

    ip.provider,
    ip.sport_code,
    ip.entity,
    ip.provider_league_id AS league_id,
    ip.season,
    ip.run_group,
    ip.priority,
    ip.status AS planner_target_state,
    ip.attempts AS empty_runs,
    ip.last_attempt,
    ip.next_run,

    CASE
        WHEN ip.attempts >= 3 THEN 100
        WHEN ip.attempts = 2 THEN 66
        WHEN ip.attempts = 1 THEN 33
        ELSE 0
    END AS empty_pct,

    CASE
        WHEN ip.attempts >= 3 THEN now() + interval '6 hours'
        WHEN ip.attempts = 2 THEN now() + interval '2 hours'
        WHEN ip.attempts = 1 THEN now() + interval '30 minutes'
        ELSE now()
    END AS suggested_retry_after,

    CASE
        WHEN ip.attempts >= 3 THEN 'POZASTAVIT / OVĚŘIT PROVIDERA'
        WHEN ip.attempts = 2 THEN 'ODLOŽIT RETRY'
        WHEN ip.attempts = 1 THEN 'OPATRNÝ RETRY'
        ELSE 'BEZ COOLDOWNU'
    END AS suggested_action

FROM ops.ingest_planner ip
WHERE ip.status IN ('pending', 'error', 'failed')
  AND COALESCE(ip.attempts, 0) > 0;