CREATE OR REPLACE VIEW ops.v_league_mapping_governance_dashboard_v1 AS

SELECT
    'SAFE_LEAGUE_MAPPING_UPDATED' AS status,
    COUNT(*) AS rows_count
FROM ops.league_mapping_safe_update_run_log
WHERE run_note = '18_3_F_SAFE_LEAGUE_MAPPING_UPDATE'

UNION ALL

SELECT
    league_mapping_status AS status,
    COUNT(*) AS rows_count
FROM ops.league_mapping_review_hold
GROUP BY league_mapping_status;