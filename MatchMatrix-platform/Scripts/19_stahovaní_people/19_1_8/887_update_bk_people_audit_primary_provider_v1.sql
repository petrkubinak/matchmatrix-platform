-- ============================================================
-- 887_update_bk_people_audit_primary_provider_v1.sql
-- MatchMatrix - BK people primary provider update
--
-- Kam uložit:
-- C:\MatchMatrix-platform\db\audit\887_update_bk_people_audit_primary_provider_v1.sql
--
-- Spustit v DBeaveru.
-- ============================================================

BEGIN;

UPDATE ops.provider_people_audit
SET
    provider_role = 'primary',
    technical_status = 'planned',
    final_verdict = 'WAIT_TEST',
    requires_pro = FALSE,
    alternative_provider_needed = FALSE,
    evidence_note = 'provider_sport_matrix confirms api_basketball supports players and coaches.',
    next_step = 'Připravit reality smoke test endpointů players/coaches pro api_basketball.',
    updated_at = NOW()
WHERE provider = 'api_basketball'
  AND sport_code = 'BK'
  AND entity IN ('players', 'coaches');

UPDATE ops.provider_people_audit
SET
    provider_role = 'fallback',
    technical_status = 'blocked',
    final_verdict = 'BLOCKED',
    alternative_provider_needed = TRUE,
    evidence_note = 'BK primary people provider is api_basketball; api_sport kept only as fallback.',
    next_step = 'Nepoužívat pro BK people, pokud api_basketball projde smoke testem.',
    updated_at = NOW()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity IN ('players', 'coaches');

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    provider_role,
    technical_status,
    final_verdict,
    priority_rank,
    next_step
FROM ops.provider_people_audit
WHERE sport_code = 'BK'
ORDER BY priority_rank, provider, entity;