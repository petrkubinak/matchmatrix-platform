-- =====================================================
-- 712_update_vb_folder_standardized.sql
-- VB ingest folder standardized (players placeholder)
-- =====================================================

UPDATE ops.runtime_entity_audit
SET
    state_reason = state_reason || ' | ingest folder standardized (players placeholder + RAW wrapper)',
    audit_note = COALESCE(audit_note, '') || ' | VB ingest folder aligned to standard (pull + parse placeholder)',
    updated_at = NOW()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB';