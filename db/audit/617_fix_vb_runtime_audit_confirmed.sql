-- 617_fix_vb_runtime_audit_confirmed.sql
-- VB final audit fix po ověření wrapperů, sport_code a merge V3

BEGIN;

UPDATE ops.runtime_entity_audit
SET
    current_state = 'CONFIRMED',
    panel_runner_exists = true,
    planner_target_exists = true,
    batch_target_exists = true,
    pull_confirmed = true,
    raw_confirmed = true,
    staging_confirmed = true,
    provider_map_confirmed = true,
    public_merge_confirmed = true,
    downstream_confirmed = true,
    last_run_group = 'VB_CORE',
    last_check_at = now(),
    next_action = 'VB core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    state_reason = 'VB core fyzicka slozka doplnena, pull/parse wrappery overeny, sport_code sjednocen na VB, merge V3 dobehl OK.',
    db_evidence_summary = 'api_volleyball VB leagues/teams/fixtures CONFIRMED; staging sport_code sjednocen; public merge OK; data_providers doplneny.',
    last_log_summary = 'VB wrapper + planner + parse + merge overeno 2026-04-26.',
    audit_note = 'Final VB core audit fix po rekonstrukci opakovatelne pipeline.',
    updated_at = now()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity IN ('leagues', 'teams', 'fixtures');

UPDATE ops.runtime_entity_audit
SET
    current_state = 'PLANNED',
    last_run_group = 'VB_CORE',
    last_check_at = now(),
    next_action = 'Aktivovat realny odds runtime po placenem API planu a potvrzeni endpointu.',
    state_reason = 'VB odds zatim nejsou aktivni runtime core.',
    audit_note = 'Odds zustava PLANNED.',
    updated_at = now()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'odds';

UPDATE ops.runtime_entity_audit
SET
    current_state = 'PLANNED',
    last_check_at = now(),
    next_action = 'Najit nahradniho providera pro VB players / people layer.',
    state_reason = 'API-Volleyball endpoint /players neexistuje; people layer bude resen jinym providerem.',
    audit_note = 'Players zustava people layer / provider blocked.',
    updated_at = now()
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
  AND entity = 'players';

COMMIT;

SELECT
    provider,
    sport_code,
    entity,
    current_state,
    last_run_group,
    next_action,
    updated_at
FROM ops.runtime_entity_audit
WHERE provider = 'api_volleyball'
  AND sport_code = 'VB'
ORDER BY entity;