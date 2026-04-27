-- =====================================================
-- 706_update_tn_core_confirmed.sql
-- TN core pipeline → CONFIRMED (teams + fixtures + odds)
-- =====================================================

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = true,
    state_reason = 'TN teams (players-as-teams) + fixtures + odds fully operational',
    updated_at = NOW()
WHERE provider = 'api_tennis'
  AND sport_code = 'TN'
  AND entity IN ('teams', 'fixtures', 'odds');