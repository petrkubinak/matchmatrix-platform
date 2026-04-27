-- =====================================================
-- 707_update_tn_leagues_confirmed.sql
-- TN leagues → CONFIRMED
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
    state_reason = 'TN leagues stable (5/5 staging vs public match)',
    updated_at = NOW()
WHERE provider = 'api_tennis'
  AND sport_code = 'TN'
  AND entity = 'leagues';

