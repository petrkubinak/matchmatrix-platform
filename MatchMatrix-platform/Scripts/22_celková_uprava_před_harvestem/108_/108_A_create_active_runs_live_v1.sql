/*
MATCHMATRIX SQL 108_A
Active Runs Live View V1

CO TO JE:
- Live view nad runtime locky.
- Ukazuje právě běžící workery, heartbeat a expiraci locku.

K ČEMU TO JE:
- Panel V17.5 uvidí ACTIVE RUNS LIVE.
- Scheduler pozná, co právě běží.
- Pomůže odhalit zamrzlé / expirované workery.

KDE TO UVIDÍME:
- ops.v_active_runs_live_v1
- Panel V17.5

JAK SE TO VYUŽIJE:
- live runtime monitoring
- heartbeat governance
- lock governance
- autonomous scheduler guard
*/

CREATE OR REPLACE VIEW ops.v_active_runs_live_v1 AS
SELECT
    lock_name,
    owner_id,

    acquired_at,
    heartbeat_at,
    expires_at,

    EXTRACT(EPOCH FROM (now() - acquired_at))::integer AS running_seconds,

    EXTRACT(EPOCH FROM (now() - heartbeat_at))::integer AS heartbeat_age_seconds,

    seconds_to_expire,

    CASE
        WHEN is_active = true
         AND seconds_to_expire > 60
         AND EXTRACT(EPOCH FROM (now() - heartbeat_at)) <= 60
            THEN 'ACTIVE_HEALTHY'

        WHEN is_active = true
         AND seconds_to_expire > 0
         AND EXTRACT(EPOCH FROM (now() - heartbeat_at)) > 60
            THEN 'ACTIVE_STALE_HEARTBEAT'

        WHEN is_active = true
         AND seconds_to_expire <= 0
            THEN 'EXPIRED_LOCK'

        ELSE 'INACTIVE'
    END AS live_state,

    CASE
        WHEN is_active = true
         AND seconds_to_expire > 60
         AND EXTRACT(EPOCH FROM (now() - heartbeat_at)) <= 60
            THEN 'GREEN'

        WHEN is_active = true
         AND seconds_to_expire > 0
            THEN 'YELLOW'

        WHEN is_active = true
         AND seconds_to_expire <= 0
            THEN 'RED'

        ELSE 'GRAY'
    END AS live_color,

    note,
    created_at,
    updated_at,
    is_active

FROM ops.v_worker_locks_active
ORDER BY
    is_active DESC,
    seconds_to_expire ASC NULLS LAST,
    acquired_at DESC;