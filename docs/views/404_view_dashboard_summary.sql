-- ============================================================
-- MATCHMATRIX - DASHBOARD SUMMARY VIEW
-- FILE: 404_view_dashboard_summary.sql
-- ============================================================

CREATE OR REPLACE VIEW ops.v_dashboard_summary AS
SELECT
    sport_code,

    COUNT(*) AS total_entities,

    -- COVERAGE STATUS
    COUNT(*) FILTER (WHERE coverage_status = 'planned') AS planned_cnt,
    COUNT(*) FILTER (WHERE coverage_status = 'tech_ready') AS tech_ready_cnt,
    COUNT(*) FILTER (WHERE coverage_status = 'runtime_tested') AS runtime_tested_cnt,
    COUNT(*) FILTER (WHERE coverage_status = 'blocked') AS blocked_cnt,

    -- READY
    COUNT(*) FILTER (WHERE is_ready = true) AS ready_cnt,

    -- RUNTIME
    SUM(pending_cnt) AS total_pending,
    SUM(running_cnt) AS total_running,
    SUM(done_cnt)    AS total_done,
    SUM(error_cnt)   AS total_error,

    -- PROGRESS %
    CASE
        WHEN COUNT(*) = 0 THEN 0
        ELSE ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE coverage_status IN ('runtime_tested', 'production_ready')
            ) / COUNT(*),
        2)
    END AS progress_percent

FROM ops.v_provider_entity_status
GROUP BY sport_code
ORDER BY sport_code;