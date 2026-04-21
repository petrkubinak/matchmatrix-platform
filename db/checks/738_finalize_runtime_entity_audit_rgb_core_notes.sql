-- 738_finalize_runtime_entity_audit_rgb_core_notes.sql

update ops.runtime_entity_audit
set
    next_action = 'RGB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    updated_at = now()
where sport_code = 'RGB'
  and entity in ('teams', 'leagues');