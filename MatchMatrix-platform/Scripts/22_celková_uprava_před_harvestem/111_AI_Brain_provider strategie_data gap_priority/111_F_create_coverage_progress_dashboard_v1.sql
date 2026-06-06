/*
MATCHMATRIX SQL 111_F Coverage Progress Dashboard V1
*/


CREATE OR REPLACE VIEW ops.v_coverage_progress_dashboard_v1 AS
SELECT

    gap_status_code,

    COUNT(*) AS item_count,

    ROUND(
        COUNT(*)::numeric
        /
        SUM(COUNT(*)) OVER ()
        * 100,
        2
    ) AS pct

FROM ops.v_data_gap_engine_v2
GROUP BY gap_status_code;



CREATE OR REPLACE VIEW ops.v_coverage_progress_by_sport_v1 AS
SELECT

    sport_code,

    gap_status_code,

    COUNT(*) AS item_count

FROM ops.v_data_gap_engine_v2
GROUP BY
    sport_code,
    gap_status_code
ORDER BY
    sport_code,
    gap_status_code;