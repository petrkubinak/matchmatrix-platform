-- 702_audit_tn_leagues_current_state.sql
-- Účel:
-- Ověřit aktuální stav Tennis (TN / api_tennis / leagues)
-- v OPS i PUBLIC vrstvě podle nového dumpu / aktuální DB.

-- =========================================================
-- A. Sport existuje?
-- =========================================================
SELECT
    s.id,
    s.code,
    s.name,
    s.sport_key,
    s.is_team_sport,
    s.is_active
FROM public.sports s
WHERE s.code IN ('TN', 'tennis')
   OR lower(s.name) LIKE '%tennis%'
ORDER BY s.code, s.name;

-- =========================================================
-- B. Provider sport matrix
-- =========================================================
SELECT
    psm.id,
    psm.provider,
    psm.sport_code,
    psm.sport_name,
    psm.is_enabled,
    psm.supports_leagues,
    psm.supports_teams,
    psm.supports_fixtures,
    psm.supports_players,
    psm.supports_odds,
    psm.notes
FROM ops.provider_sport_matrix psm
WHERE psm.sport_code = 'TN'
   OR psm.provider = 'api_tennis'
ORDER BY psm.provider, psm.sport_code;

-- =========================================================
-- C. Ingest entity plan
-- =========================================================
SELECT
    iep.id,
    iep.provider,
    iep.sport_code,
    iep.entity,
    iep.enabled,
    iep.priority,
    iep.scope_type,
    iep.requires_league,
    iep.requires_season,
    iep.default_run_group,
    iep.source_endpoint,
    iep.target_table,
    iep.worker_script,
    iep.notes
FROM ops.ingest_entity_plan iep
WHERE iep.sport_code = 'TN'
   OR iep.provider = 'api_tennis'
ORDER BY iep.provider, iep.entity, iep.id;

-- =========================================================
-- D. Provider entity coverage
-- =========================================================
SELECT
    pec.id,
    pec.provider,
    pec.sport_code,
    pec.entity,
    pec.coverage_status,
    pec.is_enabled,
    pec.is_primary_source,
    pec.is_fallback_source,
    pec.free_plan_supported,
    pec.paid_plan_supported,
    pec.source_endpoint,
    pec.target_table,
    pec.worker_script,
    pec.notes,
    pec.limitations,
    pec.next_action
FROM ops.provider_entity_coverage pec
WHERE pec.sport_code = 'TN'
   OR pec.provider = 'api_tennis'
ORDER BY pec.provider, pec.entity, pec.id;

-- =========================================================
-- E. Ingest targets
-- =========================================================
SELECT
    it.id,
    it.sport_code,
    it.canonical_league_id,
    it.provider,
    it.provider_league_id,
    it.season,
    it.enabled,
    it.tier,
    it.run_group,
    it.max_requests_per_run,
    it.notes,
    it.created_at,
    it.updated_at
FROM ops.ingest_targets it
WHERE it.sport_code = 'TN'
   OR it.provider = 'api_tennis'
ORDER BY it.provider, it.provider_league_id, it.season, it.id;

-- =========================================================
-- F. Ingest planner
-- =========================================================
SELECT
    ip.id,
    ip.provider,
    ip.sport_code,
    ip.entity,
    ip.provider_league_id,
    ip.season,
    ip.run_group,
    ip.priority,
    ip.status,
    ip.attempts,
    ip.last_attempt,
    ip.next_run,
    ip.created_at,
    ip.updated_at
FROM ops.ingest_planner ip
WHERE ip.sport_code = 'TN'
   OR ip.provider = 'api_tennis'
ORDER BY ip.entity, ip.priority, ip.id;

-- =========================================================
-- G. Runtime entity audit
-- =========================================================
SELECT
    rea.id,
    rea.provider,
    rea.sport_code,
    rea.entity,
    rea.current_state,
    rea.state_reason,
    rea.panel_runner_exists,
    rea.planner_target_exists,
    rea.batch_target_exists,
    rea.pull_confirmed,
    rea.raw_confirmed,
    rea.staging_confirmed,
    rea.provider_map_confirmed,
    rea.public_merge_confirmed,
    rea.downstream_confirmed,
    rea.last_run_group,
    rea.last_run_at,
    rea.last_check_at,
    rea.last_log_summary,
    rea.db_evidence_summary,
    rea.next_action,
    rea.audit_note
FROM ops.runtime_entity_audit rea
WHERE rea.sport_code = 'TN'
   OR rea.provider = 'api_tennis'
ORDER BY rea.entity, rea.id;

-- =========================================================
-- H. Sport completion audit
-- =========================================================
SELECT
    sca.id,
    sca.sport_code,
    sca.entity,
    sca.layer_type,
    sca.current_status,
    sca.production_readiness,
    sca.provider_primary,
    sca.provider_fallback,
    sca.db_layer_ready,
    sca.planner_ready,
    sca.queue_ready,
    sca.public_ready,
    sca.key_gap,
    sca.next_step,
    sca.evidence_note,
    sca.priority_rank
FROM ops.sport_completion_audit sca
WHERE sca.sport_code = 'TN'
ORDER BY sca.entity, sca.layer_type, sca.id;

-- =========================================================
-- I. Public leagues už něco mají?
-- =========================================================
SELECT
    l.id,
    l.sport_id,
    l.name,
    l.country,
    l.ext_source,
    l.ext_league_id,
    l.is_cup,
    l.is_international,
    l.is_active,
    l.created_at,
    l.updated_at
FROM public.leagues l
WHERE l.ext_source = 'api_tennis'
   OR l.ext_league_id IS NOT NULL AND l.ext_source = 'api_tennis'
ORDER BY l.id;

-- =========================================================
-- J. Hledání tennis staging tabulek / view
-- =========================================================
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND (
      table_name ILIKE '%tennis%'
      OR table_name ILIKE '%tn%'
  )
ORDER BY table_name;

SELECT
    table_schema,
    table_name
FROM information_schema.views
WHERE table_schema = 'staging'
  AND (
      table_name ILIKE '%tennis%'
      OR table_name ILIKE '%tn%'
  )
ORDER BY table_name;