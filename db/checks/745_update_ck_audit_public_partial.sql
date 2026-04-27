-- 745_update_ck_audit_public_partial.sql

UPDATE ops.runtime_entity_audit
SET
    public_merge_confirmed = true,
    current_state = 'PARTIAL',
    state_reason = 'CK core raw + staging potvrzeny, public merge rozbehnut pro teams/leagues/fixtures',
    last_check_at = now(),
    last_log_summary = 'CK public progress: teams merged, leagues merged, fixtures merged partially (4 matches in public)',
    db_evidence_summary = 'CK public: teams mapped, leagues inserted/fixed, public.matches api_cricket=4',
    next_action = 'Rozsirit CK fixtures public merge coverage a overit proc se propsaly jen 4 z 44 staging fixtures',
    updated_at = now()
WHERE provider = 'api_cricket'
  AND sport_code = 'CK'
  AND entity IN ('fixtures', 'leagues', 'teams');