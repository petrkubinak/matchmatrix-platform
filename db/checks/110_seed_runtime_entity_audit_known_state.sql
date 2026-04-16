-- 110_seed_runtime_entity_audit_known_state.sql
-- Doplnění ops.runtime_entity_audit podle toho, co už je ověřené.

-- ============================================================
-- 1) HK teams = CONFIRMED
-- ============================================================
INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    last_run_at,
    last_check_at,
    last_log_summary,
    db_evidence_summary,
    next_action,
    audit_note
)
VALUES (
    'api_hockey',
    'HK',
    'teams',
    'CONFIRMED',
    'Reálný batch run proběhl OK a DB potvrdila raw + parsed staging + provider map + canonical public napojení.',
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    'HK_TOP',
    NOW(),
    NOW(),
    'run_unified_ingest_batch_v1 -> run_unified_ingest_v1 -> pull_api_hockey_teams.ps1 | API response OK | LEGACY RAW saved | UNIFIED RAW saved | RESULT OK',
    'api_raw_payloads_hockey_teams=44 | api_hockey_teams_raw=1317 | api_hockey_teams=399 | team_provider_map_hockey=294 | hk_staging_without_provider_map=0',
    'Ověřit HK fixtures stejným způsobem.',
    'HK teams má potvrzený chain: orchestrace -> pull -> raw -> parsed staging -> provider map -> canonical public teams'
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state          = EXCLUDED.current_state,
    state_reason           = EXCLUDED.state_reason,
    panel_runner_exists    = EXCLUDED.panel_runner_exists,
    planner_target_exists  = EXCLUDED.planner_target_exists,
    batch_target_exists    = EXCLUDED.batch_target_exists,
    pull_confirmed         = EXCLUDED.pull_confirmed,
    raw_confirmed          = EXCLUDED.raw_confirmed,
    staging_confirmed      = EXCLUDED.staging_confirmed,
    provider_map_confirmed = EXCLUDED.provider_map_confirmed,
    public_merge_confirmed = EXCLUDED.public_merge_confirmed,
    downstream_confirmed   = EXCLUDED.downstream_confirmed,
    last_run_group         = EXCLUDED.last_run_group,
    last_run_at            = EXCLUDED.last_run_at,
    last_check_at          = EXCLUDED.last_check_at,
    last_log_summary       = EXCLUDED.last_log_summary,
    db_evidence_summary    = EXCLUDED.db_evidence_summary,
    next_action            = EXCLUDED.next_action,
    audit_note             = EXCLUDED.audit_note;

-- ============================================================
-- 2) HK fixtures = RUNNABLE / čeká na ověření
-- ============================================================
INSERT INTO ops.runtime_entity_audit (
    provider,
    sport_code,
    entity,
    current_state,
    state_reason,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    next_action,
    audit_note,
    last_check_at
)
VALUES (
    'api_hockey',
    'HK',
    'fixtures',
    'RUNNABLE',
    'HK provider větev existuje a HK teams potvrdily, že orchestrace funguje. Fixtures je další prioritní ověření.',
    TRUE,
    TRUE,
    TRUE,
    'Spustit HK fixtures přes panel a ověřit raw -> staging -> public matches.',
    'Zatím bez DB potvrzení v tomto auditu.',
    NOW()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state         = EXCLUDED.current_state,
    state_reason          = EXCLUDED.state_reason,
    panel_runner_exists   = EXCLUDED.panel_runner_exists,
    planner_target_exists = EXCLUDED.planner_target_exists,
    batch_target_exists   = EXCLUDED.batch_target_exists,
    next_action           = EXCLUDED.next_action,
    audit_note            = EXCLUDED.audit_note,
    last_check_at         = EXCLUDED.last_check_at;

-- ============================================================
-- 3) FB core = RUNNABLE / historicky silná větev, ale v tomto auditu zatím bez fresh re-run potvrzení
-- ============================================================
INSERT INTO ops.runtime_entity_audit (
    provider, sport_code, entity, current_state, state_reason,
    panel_runner_exists, planner_target_exists, batch_target_exists,
    next_action, audit_note, last_check_at
)
VALUES
(
    'api_football', 'FB', 'teams', 'RUNNABLE',
    'FB je nejdotaženější větev v systému, ale v tomto živém runtime auditu zatím bez nového potvrzovacího runu.',
    TRUE, TRUE, TRUE,
    'Provést fresh audit run pro FB teams pouze pokud bude potřeba.',
    'Historicky funkční větev; stav zatím neoznačujeme jako CONFIRMED v tomto auditním kole.',
    NOW()
),
(
    'api_football', 'FB', 'fixtures', 'RUNNABLE',
    'FB fixtures jsou dlouhodobě hlavní funkční větev, ale v tomto auditním kole bez nového DB potvrzení.',
    TRUE, TRUE, TRUE,
    'Provést fresh audit run pro FB fixtures pouze pokud bude potřeba.',
    'Nejpokročilejší sportovní větev, ale zatím bez fresh CONFIRMED statusu v této sérii.',
    NOW()
),
(
    'api_football', 'FB', 'players', 'RUNNABLE',
    'Existuje players pipeline a runtime práce, ale v tomto auditním kole bez nového potvrzení.',
    TRUE, TRUE, TRUE,
    'Později ověřit FB players reálným během + DB stopou.',
    'Zatím pracovní stav.',
    NOW()
),
(
    'api_football', 'FB', 'coaches', 'RUNNABLE',
    'Existuje coaches worker a DB napojení, ale v tomto auditním kole bez nového potvrzení.',
    TRUE, TRUE, TRUE,
    'Později ověřit FB coaches reálným během + DB stopou.',
    'Zatím pracovní stav.',
    NOW()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state         = EXCLUDED.current_state,
    state_reason          = EXCLUDED.state_reason,
    panel_runner_exists   = EXCLUDED.panel_runner_exists,
    planner_target_exists = EXCLUDED.planner_target_exists,
    batch_target_exists   = EXCLUDED.batch_target_exists,
    next_action           = EXCLUDED.next_action,
    audit_note            = EXCLUDED.audit_note,
    last_check_at         = EXCLUDED.last_check_at;

-- ============================================================
-- 4) BK / VB základní pracovní seed
-- ============================================================
INSERT INTO ops.runtime_entity_audit (
    provider, sport_code, entity, current_state, state_reason,
    panel_runner_exists, planner_target_exists, batch_target_exists,
    next_action, audit_note, last_check_at
)
VALUES
(
    'api_sport', 'BK', 'teams', 'PLANNED',
    'BK má v systému provider větev a panel routing, ale v tomto auditu zatím bez potvrzeného reálného runu.',
    TRUE, TRUE, TRUE,
    'Ověřit BK teams přes panel stejně jako HK teams.',
    'Stav založen na existující orchestraci, nikoli na čerstvém DB důkazu.',
    NOW()
),
(
    'api_sport', 'BK', 'fixtures', 'PLANNED',
    'BK fixtures zatím bez runtime potvrzení v tomto auditu.',
    TRUE, TRUE, TRUE,
    'Ověřit BK fixtures po BK teams.',
    'Pracovní seed.',
    NOW()
),
(
    'api_volleyball', 'VB', 'teams', 'PLANNED',
    'VB má provider větev a panel routing, ale bez potvrzeného reálného runu v tomto auditu.',
    TRUE, TRUE, TRUE,
    'Ověřit VB teams přes panel.',
    'Pracovní seed.',
    NOW()
),
(
    'api_volleyball', 'VB', 'fixtures', 'PLANNED',
    'VB fixtures zatím bez runtime potvrzení.',
    TRUE, TRUE, TRUE,
    'Ověřit VB fixtures po VB teams.',
    'Pracovní seed.',
    NOW()
)
ON CONFLICT (provider, sport_code, entity)
DO UPDATE SET
    current_state         = EXCLUDED.current_state,
    state_reason          = EXCLUDED.state_reason,
    panel_runner_exists   = EXCLUDED.panel_runner_exists,
    planner_target_exists = EXCLUDED.planner_target_exists,
    batch_target_exists   = EXCLUDED.batch_target_exists,
    next_action           = EXCLUDED.next_action,
    audit_note            = EXCLUDED.audit_note,
    last_check_at         = EXCLUDED.last_check_at;

-- ============================================================
-- 5) Rychlý výpis aktuálního stavu
-- ============================================================
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    panel_runner_exists,
    planner_target_exists,
    batch_target_exists,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    last_run_group,
    next_action
FROM ops.runtime_entity_audit
ORDER BY sport_code, provider, entity;