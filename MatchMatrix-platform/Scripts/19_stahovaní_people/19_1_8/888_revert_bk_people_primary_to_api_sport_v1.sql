BEGIN;

UPDATE ops.provider_people_audit
SET
    provider_role = 'primary',
    technical_status = 'planned',
    final_verdict = 'WAIT_PROVIDER',
    alternative_provider_needed = TRUE,
    evidence_note = 'BK runtime core pipeline is currently based on api_sport, not api_basketball.',
    next_step = 'Ověřit, zda api_sport umí BK players/coaches; pokud ne, teprve potom zavést api_basketball jako nový people provider.',
    updated_at = NOW()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity IN ('players', 'coaches');

UPDATE ops.provider_people_audit
SET
    provider_role = 'candidate',
    technical_status = 'planned',
    final_verdict = 'WAIT_PROVIDER',
    alternative_provider_needed = FALSE,
    evidence_note = 'api_basketball supports players/coaches in matrix, but BK core data is not currently loaded for this provider.',
    next_step = 'Nepoužívat jako primary, dokud nebudou api_basketball leagues/teams/fixtures namapované do staging/public.',
    updated_at = NOW()
WHERE provider = 'api_basketball'
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
    next_step
FROM ops.provider_people_audit
WHERE sport_code = 'BK'
ORDER BY provider_role, provider, entity;
