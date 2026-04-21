-- ============================================================
-- 137_hb_audit_confirm.sql
-- HB - runtime_entity_audit + sport_completion_audit
--
-- Kam ulozit:
-- C:\MatchMatrix-platform\db\sql\137_hb_audit_confirm.sql
--
-- Jak spustit:
-- DBeaver -> otevrit soubor -> spustit cely script
-- ============================================================

-- ------------------------------------------------------------
-- 1) HB LEAGUES -> runtime_entity_audit = CONFIRMED
-- ------------------------------------------------------------
UPDATE ops.runtime_entity_audit
SET
    current_state            = 'CONFIRMED',
    state_reason             = 'HB leagues jsou potvrzene end-to-end. Planner i ingest_cycle_v3 funguje, HB full pipeline probehla OK a public.leagues pro api_handball je naplnena sirsi coverage nad puvodni smoke-test subset.',
    panel_runner_exists      = TRUE,
    planner_target_exists    = TRUE,
    batch_target_exists      = TRUE,
    pull_confirmed           = TRUE,
    raw_confirmed            = TRUE,
    staging_confirmed        = TRUE,
    provider_map_confirmed   = TRUE,
    public_merge_confirmed   = TRUE,
    downstream_confirmed     = TRUE,
    last_run_group           = 'HB_CORE',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'HB leagues CONFIRMED | planner + ingest_cycle_v3 + unified merge OK | 136_hb_full_pipeline.sql hotovo',
    db_evidence_summary      = 'HB leagues CONFIRMED | public.leagues api_handball=31 | league coverage rozsiren mimo puvodni 3 competition smoke-test',
    next_action              = 'HB leagues core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    audit_note               = 'HB leagues jsou po odblokovani merge logiky a planner queue na stejne CONFIRMED urovni jako BK/VB/AFB.'
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'leagues';

-- ------------------------------------------------------------
-- 2) HB TEAMS -> runtime_entity_audit = CONFIRMED
-- ------------------------------------------------------------
UPDATE ops.runtime_entity_audit
SET
    current_state            = 'CONFIRMED',
    state_reason             = 'HB teams jsou potvrzene end-to-end. Standardni /teams endpoint ma neuplnou coverage, proto byl potvrzen funkcni fallback teams-from-fixtures -> stg_provider_teams -> public.team_provider_map.',
    panel_runner_exists      = TRUE,
    planner_target_exists    = TRUE,
    batch_target_exists      = TRUE,
    pull_confirmed           = TRUE,
    raw_confirmed            = TRUE,
    staging_confirmed        = TRUE,
    provider_map_confirmed   = TRUE,
    public_merge_confirmed   = TRUE,
    downstream_confirmed     = TRUE,
    last_run_group           = 'HB_CORE',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'HB teams CONFIRMED | fallback teams-from-fixtures potvrzen | unified merge OK | missing_team_map=0',
    db_evidence_summary      = 'HB teams CONFIRMED | public.team_provider_map api_handball=752 | HB fallback teams-from-fixtures aktivni | missing_team_map=0',
    next_action              = 'HB teams core pipeline je uzavrena. Dalsi krok pripadne enrichment team_name/country z dalsiho provideru.',
    audit_note               = 'HB teams nejsou blokovane provider /teams endpointem, protoze finalni pipeline pouziva fallback teams-from-fixtures.'
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'teams';

-- ------------------------------------------------------------
-- 3) HB FIXTURES -> runtime_entity_audit = CONFIRMED
-- ------------------------------------------------------------
UPDATE ops.runtime_entity_audit
SET
    current_state            = 'CONFIRMED',
    state_reason             = 'HB fixtures jsou potvrzene end-to-end. Planner funguje, payloady se ukladaji, merge do public.matches funguje a po doplneni HB teams fallbackem je missing_team_map = 0.',
    panel_runner_exists      = TRUE,
    planner_target_exists    = TRUE,
    batch_target_exists      = TRUE,
    pull_confirmed           = TRUE,
    raw_confirmed            = TRUE,
    staging_confirmed        = TRUE,
    provider_map_confirmed   = TRUE,
    public_merge_confirmed   = TRUE,
    downstream_confirmed     = TRUE,
    last_run_group           = 'HB_CORE',
    last_run_at              = NOW(),
    last_check_at            = NOW(),
    last_log_summary         = 'HB fixtures CONFIRMED | ingest_cycle_v3 + unified merge OK | 136_hb_full_pipeline.sql hotovo',
    db_evidence_summary      = 'HB fixtures CONFIRMED | public.matches api_handball=2517 | missing_team_map=0 | FINISHED=2468 | SCHEDULED=38 | CANCELLED=11',
    next_action              = 'HB fixtures core pipeline je uzavrena. Dalsi krok pripadne odds / people / downstream entity.',
    audit_note               = 'HB fixtures uz nejsou blokovane teams coverage. Full pipeline bezi end-to-end stejne jako BK/VB/AFB, s HB-specific fallbackem.'
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
  AND entity = 'fixtures';

-- ------------------------------------------------------------
-- 4) sport_completion_audit -> HB core DONE / READY
--    pattern podle 709_upsert_sport_completion_audit_afb_fix2.sql
-- ------------------------------------------------------------
UPDATE ops.sport_completion_audit
SET
    entity = 'core',
    layer_type = 'core_pipeline',
    current_status = 'DONE',
    production_readiness = 'READY',
    provider_primary = 'api_handball',
    provider_fallback = NULL,
    db_layer_ready = TRUE,
    planner_ready = TRUE,
    queue_ready = TRUE,
    public_ready = TRUE,
    key_gap = NULL,
    next_step = 'HB core pipeline uzavrena. Dalsi krok pripadne odds / people / downstream.',
    evidence_note = 'HB teams CONFIRMED | HB fixtures CONFIRMED | HB leagues CONFIRMED | public.matches api_handball=2517 | missing_team_map=0 | fallback teams-from-fixtures aktivni',
    priority_rank = 90,
    updated_at = NOW()
WHERE sport_code = 'HB'
  AND entity = 'core';

INSERT INTO ops.sport_completion_audit (
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    provider_fallback,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    key_gap,
    next_step,
    evidence_note,
    priority_rank,
    created_at,
    updated_at
)
SELECT
    'HB',
    'core',
    'core_pipeline',
    'DONE',
    'READY',
    'api_handball',
    NULL,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    NULL,
    'HB core pipeline uzavrena. Dalsi krok pripadne odds / people / downstream.',
    'HB teams CONFIRMED | HB fixtures CONFIRMED | HB leagues CONFIRMED | public.matches api_handball=2517 | missing_team_map=0 | fallback teams-from-fixtures aktivni',
    90,
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1
    FROM ops.sport_completion_audit
    WHERE sport_code = 'HB'
      AND entity = 'core'
);

-- ------------------------------------------------------------
-- 5) kontroly
-- ------------------------------------------------------------
SELECT
    provider,
    sport_code,
    entity,
    current_state,
    pull_confirmed,
    raw_confirmed,
    staging_confirmed,
    provider_map_confirmed,
    public_merge_confirmed,
    downstream_confirmed,
    last_run_group,
    db_evidence_summary,
    next_action
FROM ops.runtime_entity_audit
WHERE provider = 'api_handball'
  AND sport_code = 'HB'
ORDER BY entity;

SELECT
    sport_code,
    entity,
    layer_type,
    current_status,
    production_readiness,
    provider_primary,
    db_layer_ready,
    planner_ready,
    queue_ready,
    public_ready,
    evidence_note
FROM ops.sport_completion_audit
WHERE sport_code = 'HB'
ORDER BY entity, layer_type;