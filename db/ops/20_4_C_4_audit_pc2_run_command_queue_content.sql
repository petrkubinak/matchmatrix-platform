/*
MATCHMATRIX
20_4_C_4_audit_pc2_run_command_queue_content.sql
*/

SELECT
    id,
    sport_code,
    sport_name,
    target_layer,
    execution_bucket,
    priority_score,
    command_title,
    run_status,
    safety_mode,
    panel_action_enabled,
    LEFT(command_text, 120) AS command_preview,
    expected_result,
    last_started_at,
    last_finished_at,
    last_result
FROM ops.v_pc2_run_command_queue_v2
ORDER BY
    priority_score DESC,
    sport_code,
    target_layer;
select


    target_layer,
    run_status,
    COUNT(*) AS total
FROM ops.v_pc2_run_command_queue_v2
GROUP BY
    target_layer,
    run_status
ORDER BY
    target_layer,
    run_status;
