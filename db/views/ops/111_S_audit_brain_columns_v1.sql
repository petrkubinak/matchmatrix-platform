/*
MATCHMATRIX SQL 111_S
AUDIT BRAIN SOURCE COLUMNS V1
*/

SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'ops'
  AND table_name IN (
      'v_sport_completion_dashboard_v2',
      'v_panel_ai_recommendations_v1',
      'v_autonomous_execution_queue_v1',
      'ai_action_execution_log'
  )
ORDER BY
    table_name,
    ordinal_position;