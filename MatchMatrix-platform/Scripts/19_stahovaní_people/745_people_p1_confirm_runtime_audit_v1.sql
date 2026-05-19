/*
745_people_p1_confirm_runtime_audit_v1.sql

Účel:
- promítne potvrzené people endpointy do ops.runtime_entity_audit
- zatím potvrzujeme pouze provider endpoint + RAW/parser next step
- neoznačujeme public merge jako hotový
*/

BEGIN;

INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    run_group,
    provider_endpoint_confirmed,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    evidence_note,
    next_step,
    updated_at
)
SELECT
    provider,
    sport_code,
    entity,
    'PARTIAL',
    sport_code || '_PEOPLE',
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    evidence_note,
    'Připravit RAW pull + parser do staging.stg_provider_players/coaches. Public merge až po ověření staging struktury.',
    now()
FROM ops.provider_people_audit
WHERE final_verdict = 'ENDPOINT_EXISTS'
  AND provider IN ('api_football', 'api_sport')
  AND sport_code IN ('FB', 'BK')
  AND entity IN ('players', 'coaches')
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state = EXCLUDED.current_state,
    run_group = EXCLUDED.run_group,
    provider_endpoint_confirmed = EXCLUDED.provider_endpoint_confirmed,
    evidence_note = EXCLUDED.evidence_note,
    next_step = EXCLUDED.next_step,
    updated_at = now();

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    run_group,
    provider_endpoint_confirmed,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    next_step
FROM ops.runtime_entity_audit
WHERE run_group IN ('FB_PEOPLE', 'BK_PEOPLE')
ORDER BY provider, sport_code, entity;