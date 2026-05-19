-- 912_mark_bk_core_legacy_public_ready.sql

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    state_reason = 'BK core public data exists from legacy api_sport flow; generic staging/raw evidence missing for historical run.',
    public_merge_confirmed = true,
    downstream_confirmed = true,
    db_evidence_summary = 'public.leagues api_sport/BK=427 | public.team_provider_map api_sport=2178 | public.matches api_sport/BK=383 | staging.stg_provider_* BK=0 legacy gap',
    next_action = 'Use new controlled harvest flow for future BK runs; do not backfill legacy staging manually unless needed.',
    updated_at = now()
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity IN ('leagues', 'teams', 'fixtures');

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    public_merge_confirmed,
    downstream_confirmed,
    db_evidence_summary,
    next_action,
    updated_at
FROM ops.runtime_entity_audit
WHERE provider = 'api_sport'
  AND sport_code = 'BK'
  AND entity IN ('leagues', 'teams', 'fixtures')
ORDER BY entity;