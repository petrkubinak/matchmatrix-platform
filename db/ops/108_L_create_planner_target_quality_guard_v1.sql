/*
MATCHMATRIX SQL 108_L
Planner Target Quality Guard V1

CO TO JE:
- Kontrola kvality planner targetů.

K ČEMU TO JE:
- Odhaluje targety které:
    - vrací empty data
    - generují warning spam
    - zatěžují planner

KDE TO UVIDÍME:
- ops.v_planner_target_quality_guard_v1

JAK SE TO VYUŽIJE:
- planner governance
- autonomous cooldown
- target disable
- retry reduction
*/

CREATE OR REPLACE VIEW ops.v_planner_target_quality_guard_v1 AS

WITH runtime AS (

    SELECT
        worker_name,
        command_text,
        status,
        created_at,
        stdout_preview,
        stderr_preview,

        CASE
            WHEN LOWER(
                COALESCE(stdout_preview, '') ||
                ' ' ||
                COALESCE(stderr_preview, '')
            ) LIKE '%no fixtures returned%'
            THEN 1
            ELSE 0
        END AS is_empty

    FROM ops.runtime_execution_history

    WHERE created_at >= NOW() - INTERVAL '72 hours'
),

parsed AS (

    SELECT
        worker_name,

        CASE

            WHEN (
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview
            ) ~ 'league[= ]+[0-9]+'

            THEN regexp_replace(
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview,
                '.*league[= ]+([0-9]+).*',
                '\1'
            )

            WHEN (
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview
            ) ~ '--league-id[ =][0-9]+'

            THEN regexp_replace(
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview,
                '.*--league-id[ =]([0-9]+).*',
                '\1'
            )

            ELSE NULL

        END AS league_id,

        CASE

            WHEN (
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview
            ) ~ 'season[= ]+[0-9]+'

            THEN regexp_replace(
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview,
                '.*season[= ]+([0-9]+).*',
                '\1'
            )

            WHEN (
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview
            ) ~ '--season[ =][0-9]+'

            THEN regexp_replace(
                command_text || ' ' ||
                stdout_preview || ' ' ||
                stderr_preview,
                '.*--season[ =]([0-9]+).*',
                '\1'
            )

            ELSE NULL

        END AS season,

        status,
        is_empty,
        created_at

    FROM runtime
),

agg AS (

    SELECT
        league_id,
        season,

        COUNT(*) AS total_runs,

        COUNT(*) FILTER (
            WHERE LOWER(status) = 'warning'
        ) AS warning_runs,

        COUNT(*) FILTER (
            WHERE LOWER(status) IN (
                'failed',
                'error',
                'critical'
            )
        ) AS failed_runs,

        SUM(is_empty) AS empty_runs,

        MAX(created_at) AS last_run_at

    FROM parsed

    WHERE league_id IS NOT NULL

    GROUP BY league_id, season
)

SELECT
    league_id,
    season,

    total_runs,
    warning_runs,
    failed_runs,
    empty_runs,

    ROUND(
        100.0 * empty_runs
        / NULLIF(total_runs, 0),
        2
    ) AS empty_pct,

    last_run_at,

    CASE

        WHEN empty_runs >= 5
            THEN 'BLOCK_TARGET'

        WHEN empty_runs >= 2
            THEN 'COOLDOWN'

        WHEN failed_runs >= 3
            THEN 'REVIEW'

        ELSE 'OK'

    END AS planner_target_state,

    CASE

        WHEN empty_runs >= 5
            THEN 1

        WHEN empty_runs >= 2
            THEN 2

        WHEN failed_runs >= 3
            THEN 3

        ELSE 9

    END AS target_rank

FROM agg;