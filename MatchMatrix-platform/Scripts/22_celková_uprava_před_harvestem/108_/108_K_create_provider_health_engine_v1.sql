/*
MATCHMATRIX SQL 108_K
Create Provider Health Engine V1 - FIXED

CO TO JE:
- Runtime provider health engine.

K ČEMU TO JE:
- Vyhodnocuje provider health podle běhů workerů.

KDE TO UVIDÍME:
- ops.v_provider_health_engine_v1
- panel V17.8+

JAK SE TO VYUŽIJE:
- provider governance
- planner optimization
- fallback provider selection
*/

CREATE OR REPLACE VIEW ops.v_provider_health_engine_v1 AS
WITH base AS (
    SELECT
        CASE
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_football%' THEN 'api_football'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_hockey%' THEN 'api_hockey'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_sport%' THEN 'api_sport'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_basketball%' THEN 'api_basketball'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_handball%' THEN 'api_handball'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_volleyball%' THEN 'api_volleyball'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_baseball%' THEN 'api_baseball'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_cricket%' THEN 'api_cricket'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%api_american_football%' THEN 'api_american_football'
    		WHEN (command_text || ' ' || stdout_preview || ' ' || stderr_preview) ILIKE '%sportsdataio%' THEN 'sportsdataio'
    		ELSE 'unknown'
		END AS provider,
        status,
        duration_sec,
        created_at,
        stdout_preview,
        stderr_preview
    FROM ops.runtime_execution_history
    WHERE created_at >= NOW() - INTERVAL '24 hours'
),
runtime_24h AS (
    SELECT
        provider,
        COUNT(*) AS total_runs,

        COUNT(*) FILTER (
            WHERE LOWER(status) IN ('success', 'ok', 'completed')
        ) AS success_runs,

        COUNT(*) FILTER (
            WHERE LOWER(status) = 'warning'
        ) AS warning_runs,

        COUNT(*) FILTER (
            WHERE LOWER(status) IN ('error', 'failed', 'fail', 'critical')
        ) AS failed_runs,

        COUNT(*) FILTER (
            WHERE LOWER(COALESCE(stdout_preview, '') || ' ' || COALESCE(stderr_preview, ''))
                  LIKE '%no fixtures returned%'
        ) AS empty_runs,

        ROUND(AVG(duration_sec), 2) AS avg_duration_sec,
        MAX(created_at) AS last_run_at,
        (ARRAY_AGG(status ORDER BY created_at DESC))[1] AS last_status,

        (ARRAY_AGG(
            LEFT(COALESCE(stderr_preview, stdout_preview, ''), 200)
            ORDER BY created_at DESC
        ))[1] AS last_message

    FROM base
    GROUP BY provider
),
calc AS (
    SELECT
        provider,
        total_runs,
        success_runs,
        warning_runs,
        failed_runs,
        empty_runs,

        ROUND(100.0 * success_runs / NULLIF(total_runs, 0), 2) AS success_pct,
        ROUND(100.0 * empty_runs / NULLIF(total_runs, 0), 2) AS empty_pct,
        ROUND(100.0 * failed_runs / NULLIF(total_runs, 0), 2) AS failed_pct,

        avg_duration_sec,
        last_run_at,
        last_status,
        last_message
    FROM runtime_24h
)
SELECT
    *,
    CASE
        WHEN failed_pct >= 30 THEN 'CRITICAL'
        WHEN empty_pct >= 40 THEN 'WARNING'
        WHEN failed_pct >= 10 THEN 'WARNING'
        WHEN success_pct >= 80 THEN 'HEALTHY'
        ELSE 'UNKNOWN'
    END AS provider_health,

    CASE
        WHEN failed_pct >= 30 THEN 1
        WHEN empty_pct >= 40 THEN 2
        WHEN failed_pct >= 10 THEN 3
        WHEN success_pct >= 80 THEN 9
        ELSE 99
    END AS health_rank
FROM calc;