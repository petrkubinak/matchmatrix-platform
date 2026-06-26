/*
755_people_confirm_staging_audit_v1.sql

Účel:
- potvrdit PEOPLE staging pro 4 větve:
  FB players, FB coaches, BK players, AFB players
*/

BEGIN;

UPDATE ops.provider_people_audit
SET
    technical_status = 'STAGING_PARSED',
    data_quality_status = 'BASIC_OK',
    final_verdict = 'STAGING_CONFIRMED',
    alternative_provider_needed = false,
    next_step = 'Další krok: provider_map/public merge do public.players / player_provider_map, případně coaches public model.',
    updated_at = now()
WHERE (provider, sport_code, entity) IN (
    ('api_football', 'FB', 'players'),
    ('api_football', 'FB', 'coaches'),
    ('api_sport', 'BK', 'players'),
    ('api_american_football', 'AFB', 'players')
);

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    technical_status,
    final_verdict,
    next_step,
    updated_at
FROM ops.provider_people_audit
WHERE final_verdict = 'STAGING_CONFIRMED'
ORDER BY provider, sport_code, entity;