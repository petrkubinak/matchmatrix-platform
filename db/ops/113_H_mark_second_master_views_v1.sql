UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    reviewed_at = NOW(),
    reviewed_by = 'ChatGPT + Petr manual DB audit',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name IN (
      'v_data_gap_engine_v2',
      'v_data_gap_panel_v2',
      'v_ingest_overview',
      'v_ingest_planner_queue',
      'v_ingest_planner_status'
  );

UPDATE ops.database_object_governance
SET
    governance_status = 'LEGACY_KEEP',
    is_master = false,
    master_replacement = CASE
        WHEN object_name = 'v_data_gap_engine_v1'
            THEN 'ops.v_data_gap_engine_v2'
        WHEN object_name = 'v_data_gap_panel_v1'
            THEN 'ops.v_data_gap_panel_v2'
        ELSE master_replacement
    END,
    cleanup_note = 'Starší verze. Nemazat bez kontroly závislostí.',
    reviewed_at = NOW(),
    reviewed_by = 'ChatGPT + Petr manual DB audit',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name IN (
      'v_data_gap_engine_v1',
      'v_data_gap_panel_v1'
  );