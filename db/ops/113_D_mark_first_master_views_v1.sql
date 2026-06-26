/*
===============================================================================
MATCHMATRIX SQL 113_D
MARK FIRST MASTER VIEWS

CO TO JE:
- Označí první potvrzené master view v OPS databázi.

K ČEMU TO JE:
- Aby nový chat, panel i další audit věděly, která view jsou aktuální zdroj pravdy.

KDE TO UVIDÍME:
- ops.database_object_governance

JAK SE TO VYUŽIJE:
- Cleanup DB
- Dokumentace DB
- Ochrana proti používání starých view
===============================================================================
*/

UPDATE ops.database_object_governance
SET
    governance_status = 'ACTIVE_MASTER',
    is_master = true,
    used_by = 'OPS panel / Autonomous OPS / Scheduler / Database governance audit',
    reviewed_at = NOW(),
    reviewed_by = 'ChatGPT + Petr manual DB audit',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name IN (
      'v_autonomous_ops_brain_v5',
      'v_autonomous_ops_brain_summary_v1',
      'v_automation_ready_queue_v4',
      'v_provider_routing_master_v2',
      'v_sport_completion_dashboard_v2'
  );

UPDATE ops.database_object_governance
SET
    governance_status = 'LEGACY_KEEP',
    is_master = false,
    master_replacement = CASE
        WHEN object_name IN (
            'v_autonomous_ops_brain_v1',
            'v_autonomous_ops_brain_v2',
            'v_autonomous_ops_brain_v3',
            'v_autonomous_ops_brain_v4'
        ) THEN 'ops.v_autonomous_ops_brain_v5'

        WHEN object_name IN (
            'v_automation_ready_queue_v1',
            'v_automation_ready_queue_v2',
            'v_automation_ready_queue_v3'
        ) THEN 'ops.v_automation_ready_queue_v4'

        ELSE master_replacement
    END,
    cleanup_note = 'Starší vývojová verze. Nemazat bez kontroly závislostí.',
    reviewed_at = NOW(),
    reviewed_by = 'ChatGPT + Petr manual DB audit',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name IN (
      'v_autonomous_ops_brain_v1',
      'v_autonomous_ops_brain_v2',
      'v_autonomous_ops_brain_v3',
      'v_autonomous_ops_brain_v4',
      'v_automation_ready_queue_v1',
      'v_automation_ready_queue_v2',
      'v_automation_ready_queue_v3'
  );

UPDATE ops.database_object_governance
SET
    governance_status = 'DROP_CANDIDATE',
    is_master = false,
    master_replacement = CASE
        WHEN object_name = 'v_provider_routing_master'
            THEN 'ops.v_provider_routing_master_v2'
        WHEN object_name = 'v_sport_completion_dashboard_v1'
            THEN 'ops.v_sport_completion_dashboard_v2'
        ELSE master_replacement
    END,
    cleanup_note = 'Kandidát na odstranění po kontrole závislostí v kódu, panelu a workerech.',
    reviewed_at = NOW(),
    reviewed_by = 'ChatGPT + Petr manual DB audit',
    updated_at = NOW()
WHERE schema_name = 'ops'
  AND object_name IN (
      'v_provider_routing_master',
      'v_sport_completion_dashboard_v1'
  );